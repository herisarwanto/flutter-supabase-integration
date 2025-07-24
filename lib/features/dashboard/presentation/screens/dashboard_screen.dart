import 'package:flutter/material.dart';
import 'package:flutter_supabase_integration/common/theme/app_strings.dart';
import 'package:flutter_supabase_integration/common/theme/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common/router/routes.dart';
import '../providers/dashboard_provider.dart';
import '../providers/message_provider.dart';
import '../providers/analytics_provider.dart';
import 'package:go_router/go_router.dart';
import 'message_list_widget.dart';
import '../widgets/message_form_widget.dart';
import '../../domain/model/message_model.dart';
import 'analytics_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _messageController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(messageProvider.notifier).startRealtimeSubscription();
    });
  }

  @override
  void dispose() {
    ref.read(messageProvider.notifier).stopRealtimeSubscription();
    _nameController.dispose();
    _messageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _showMessageFormSheet() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            return MessageFormWidget(
              nameController: _nameController,
              messageController: _messageController,
              formKey: _formKey,
              isSubmitting: ref.watch(messageProvider).isSubmitting,
              onSubmit: () async {
                if (!_formKey.currentState!.validate()) return;
                final user = Supabase.instance.client.auth.currentUser;
                if (user == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(AppStrings.userNotLoggedIn),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                final name = _nameController.text.trim();
                final message = _messageController.text.trim();
                await ref
                    .read(messageProvider.notifier)
                    .createMessage(
                      userId: user.id,
                      name: name,
                      message: message,
                    );
                _messageController.clear();
                if (!context.mounted) return;
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(AppStrings.messageSent),
                    backgroundColor: Colors.green,
                  ),
                );
                refreshAnalytics(ref);
              },
            );
          },
        );
      },
    );
  }

  Future<void> _editMessageDialog(Message message) async {
    final TextEditingController editNameController = TextEditingController(
      text: message.name,
    );
    final TextEditingController editMessageController = TextEditingController(
      text: message.message,
    );
    final GlobalKey<FormState> editFormKey = GlobalKey<FormState>();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final isSubmitting = ref.watch(messageProvider).isSubmitting;
            return MessageFormWidget(
              nameController: editNameController,
              messageController: editMessageController,
              formKey: editFormKey,
              isSubmitting: isSubmitting,
              title: AppStrings.editMessage,
              buttonText: AppStrings.save,
              onSubmit: () async {
                if (!editFormKey.currentState!.validate()) return;
                await ref
                    .read(messageProvider.notifier)
                    .updateMessage(
                      id: message.id,
                      name: editNameController.text.trim(),
                      message: editMessageController.text.trim(),
                    );
                if (!context.mounted) return;
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppStrings.messageUpdatedSuccess),
                    backgroundColor: AppColors.snackbarSuccess,
                  ),
                );
                refreshAnalytics(ref);
              },
            );
          },
        );
      },
    );
  }

  Future<void> _deleteMessageDialog(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.dialogBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: AppColors.dialogWarningIcon,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              AppStrings.deleteMessageTitle,
              style: TextStyle(
                color: AppColors.danger,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Text(
          AppStrings.deleteMessageContent,
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.spaceAround,
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        actions: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => context.pop(false),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.dialogCancelButton,
                side: BorderSide(color: AppColors.dialogCancelBorder),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(AppStrings.cancel),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () => context.pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: AppColors.dialogDeleteText,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(AppStrings.delete),
            ),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(messageProvider.notifier).deleteMessage(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.messageDeleted),
          backgroundColor: AppColors.snackbarSuccess,
        ),
      );
      refreshAnalytics(ref);
    }
  }

  Future<void> _logout() async {
    final success = await ref.read(dashboardProvider.notifier).logout();
    if (success && mounted) {
      context.go(AppRoutes.intro);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.logoutFailed),
          backgroundColor: AppColors.snackbarError,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final messageState = ref.watch(messageProvider);
    final user = Supabase.instance.client.auth.currentUser;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      appBar: AppBar(
        title: Text(
          AppStrings.dashboard,
          style: TextStyle(color: AppColors.dashboardAppBarText),
        ),
        backgroundColor: AppColors.primary,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.dashboardTabIndicator,
          labelColor: AppColors.dashboardTabLabel,
          unselectedLabelColor: AppColors.dashboardTabUnselectedLabel,
          tabs: const [
            Tab(icon: Icon(Icons.message), text: AppStrings.messages),
            Tab(icon: Icon(Icons.analytics), text: AppStrings.analytics),
          ],
        ),
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final isRealtimeActive = ref
                  .watch(messageProvider.notifier)
                  .isRealtimeActive;
              final connectionStatus = ref
                  .watch(messageProvider.notifier)
                  .connectionStatus;
              final hasError = ref.watch(messageProvider).error != null;

              Color statusColor;
              IconData statusIcon;
              String statusText;

              if (hasError) {
                statusColor = AppColors.statusError;
                statusIcon = Icons.error;
                statusText = AppStrings.statusError;
              } else if (isRealtimeActive) {
                statusColor = AppColors.statusLive;
                statusIcon = Icons.wifi;
                statusText = AppStrings.statusLive;
              } else if (connectionStatus == 'connecting') {
                statusColor = AppColors.statusConnecting;
                statusIcon = Icons.wifi_find;
                statusText = AppStrings.statusConnecting;
              } else {
                statusColor = AppColors.grey;
                statusIcon = Icons.wifi_off;
                statusText = AppStrings.statusOffline;
              }

              return Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: AppColors.statusText, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: AppColors.statusText,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Consumer(
            builder: (context, ref, _) {
              final isRealtimeActive = ref
                  .watch(messageProvider.notifier)
                  .isRealtimeActive;
              final hasError = ref.watch(messageProvider).error != null;

              if (isRealtimeActive && !hasError) return const SizedBox.shrink();

              return IconButton(
                icon: Icon(Icons.refresh, color: AppColors.dashboardAppBarText),
                tooltip: AppStrings.reconnectRealtime,
                onPressed: () {
                  ref.read(messageProvider.notifier).reconnect();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppStrings.reconnectingToRealtime),
                      backgroundColor: AppColors.snackbarInfo,
                    ),
                  );
                },
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.dashboardAppBarText),
            tooltip: AppStrings.refreshMessages,
            onPressed: () {
              ref.read(messageProvider.notifier).fetchMessages();
              refreshAnalytics(ref);
            },
          ),
          IconButton(
            icon: Icon(Icons.logout, color: AppColors.dashboardAppBarText),
            tooltip: AppStrings.logout,
            onPressed: _logout,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Messages Tab
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    if (user != null && user.email != null)
                      Row(
                        children: [
                          Icon(
                            Icons.email,
                            color: AppColors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            user.email ?? '',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: AppColors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: Icon(
                              Icons.add_circle_outline,
                              color: AppColors.primary,
                            ),
                            tooltip: AppStrings.addMessage,
                            onPressed: _showMessageFormSheet,
                          ),
                        ],
                      ),
                    const SizedBox(height: 4),
                    Consumer(
                      builder: (context, ref, _) {
                        final error = ref.watch(messageProvider).error;
                        if (error == null) return const SizedBox.shrink();

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.errorBackground,
                            border: Border.all(color: AppColors.errorBorder),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: AppColors.danger,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  error,
                                  style: TextStyle(
                                    color: AppColors.danger,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.close,
                                  color: AppColors.danger,
                                  size: 16,
                                ),
                                onPressed: () {
                                  ref
                                      .read(messageProvider.notifier)
                                      .clearError();
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          await ref
                              .read(messageProvider.notifier)
                              .fetchMessages();
                          refreshAnalytics(ref);
                        },
                        child: MessageListWidget(
                          messageState: messageState,
                          user: user,
                          theme: theme,
                          onEdit: _editMessageDialog,
                          onDelete: _deleteMessageDialog,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Analytics Tab
          const AnalyticsScreen(),
        ],
      ),
    );
  }
}

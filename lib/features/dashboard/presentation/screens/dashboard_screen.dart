import 'package:flutter/material.dart';
import 'package:flutter_supabase_integration/common/theme/app_strings.dart';
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

    // Messages are already fetched in main.dart auth handler
    // No need to clear and reload here
  }

  @override
  void dispose() {
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
                      content: Text('User not logged in!'),
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
                // Refresh analytics after creating message
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
              title: 'Edit Message',
              buttonText: 'Save',
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
                  const SnackBar(
                    content: Text('Message updated!'),
                    backgroundColor: Colors.green,
                  ),
                );
                // Refresh analytics after updating message
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
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'Delete Message',
              style: TextStyle(
                color: Colors.red[700],
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete this message? This action cannot be undone.',
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
                foregroundColor: Colors.grey[800],
                side: BorderSide(color: Colors.grey[400]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () => context.pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Delete'),
            ),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(messageProvider.notifier).deleteMessage(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.messageDeleted),
          backgroundColor: Colors.green,
        ),
      );
      // Refresh analytics after deleting message
      refreshAnalytics(ref);
    }
  }

  Future<void> _logout() async {
    final success = await ref.read(dashboardProvider.notifier).logout();
    if (success && mounted) {
      context.go(AppRoutes.intro);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logout failed!'),
          backgroundColor: Colors.red,
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.message), text: 'Messages'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh Messages',
            onPressed: () {
              ref.read(messageProvider.notifier).fetchMessages();
              refreshAnalytics(ref);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
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
                          const Icon(Icons.email, color: Colors.grey, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            user.email ?? '',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(
                              Icons.add_circle_outline,
                              color: Colors.deepPurple,
                            ),
                            tooltip: 'Add Message',
                            onPressed: _showMessageFormSheet,
                          ),
                        ],
                      ),
                    const SizedBox(height: 4),
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
              if (messageState.isSubmitting)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.2),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.deepPurple,
                      ),
                    ),
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

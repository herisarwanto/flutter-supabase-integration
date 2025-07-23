import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/message_state.dart';
import '../widgets/message_item_widget.dart';
import '../widgets/message_skeleton_widget.dart';
import '../../domain/model/message_model.dart';

class MessageListWidget extends StatelessWidget {
  final MessageState messageState;
  final User? user;
  final ThemeData theme;
  final Future<void> Function(Message message)? onEdit;
  final void Function(String id)? onDelete;

  const MessageListWidget({
    super.key,
    required this.messageState,
    required this.user,
    required this.theme,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: messageState.isLoading
          ? const MessageListSkeleton(itemCount: 5)
          : messageState.error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${messageState.error}',
                    style: TextStyle(color: Colors.red[700]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : messageState.messages.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No messages yet.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Be the first to send a message!',
                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                  ),
                ],
              ),
            )
          : ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: messageState.messages.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final msg = messageState.messages[index];
                final isMine = user != null && msg.userId == user?.id;
                return MessageItemWidget(
                  message: msg,
                  isMine: isMine,
                  theme: theme,
                  onEdit: onEdit != null ? () => onEdit!(msg) : null,
                  onDelete: onDelete != null ? () => onDelete!(msg.id) : null,
                );
              },
            ),
    );
  }
}

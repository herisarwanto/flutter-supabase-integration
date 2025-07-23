import 'package:flutter/material.dart';
import '../../domain/model/message_model.dart';

class MessageItemWidget extends StatelessWidget {
  final Message message;
  final bool isMine;
  final ThemeData theme;
  final void Function()? onEdit;
  final void Function()? onDelete;

  const MessageItemWidget({
    super.key,
    required this.message,
    required this.isMine,
    required this.theme,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: isMine ? Colors.deepPurple[50] : Colors.grey[50],
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          title: Text(
            message.name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isMine ? Colors.deepPurple : Colors.black,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Text(message.message, style: theme.textTheme.bodyLarge),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message.createdAt
                    .toString()
                    .substring(0, 16)
                    .replaceFirst('T', ' '),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              if (isMine)
                Expanded(
                  child: SizedBox(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          tooltip: 'Edit',
                          onPressed: onEdit,
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20),
                          tooltip: 'Delete',
                          onPressed: onDelete,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

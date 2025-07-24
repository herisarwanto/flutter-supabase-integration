import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/model/message_model.dart';

class MessageService {
  final _client = Supabase.instance.client;
  RealtimeChannel? _channel;

  Future<void> createMessage({
    required String userId,
    required String name,
    required String message,
  }) async {
    await _client.from('messages').insert({
      'user_id': userId,
      'name': name,
      'message': message,
    });
  }

  Future<List<Message>> getMessages() async {
    final response = await _client
        .from('messages')
        .select()
        .order('created_at', ascending: false);
    return (response as List)
        .map((e) => Message.fromMapSafe(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateMessage({
    required String id,
    String? name,
    String? message,
  }) async {
    final updateData = <String, dynamic>{};
    if (name != null) updateData['name'] = name;
    if (message != null) updateData['message'] = message;
    await _client.from('messages').update(updateData).eq('id', id);
  }

  Future<void> deleteMessage(String id) async {
    await _client.from('messages').delete().eq('id', id);
  }

  // Realtime subscription methods
  RealtimeChannel subscribeToMessages({
    required Function(Message) onMessageInserted,
    required Function(Message) onMessageUpdated,
    required Function(String) onMessageDeleted,
    required Function(String) onError,
  }) {
    // Clean up existing subscription if any
    _channel?.unsubscribe();

    _channel = _client
        .channel('messages_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            try {
              final message = Message.fromMapSafe(payload.newRecord);
              onMessageInserted(message);
            } catch (e) {
              onError('Error parsing inserted message: $e');
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            try {
              final message = Message.fromMapSafe(payload.newRecord);
              onMessageUpdated(message);
            } catch (e) {
              onError('Error parsing updated message: $e');
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            try {
              final messageId = payload.oldRecord['id'] as String;
              onMessageDeleted(messageId);
            } catch (e) {
              onError('Error parsing deleted message: $e');
            }
          },
        );

    _channel!.subscribe((status, [error]) {
      if (error != null) {
        onError('Subscription error: $error');
      }
      print('Realtime subscription status: $status');
    });

    return _channel!;
  }

  void unsubscribeFromMessages() {
    _channel?.unsubscribe();
    _channel = null;
  }

  bool get isSubscribed => _channel != null;
}

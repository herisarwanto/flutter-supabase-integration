import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/model/message_model.dart';

class MessageService {
  final _client = Supabase.instance.client;
  RealtimeChannel? _channel;
  bool _isConnecting = false;

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
  void subscribeToMessages({
    required Function(List<Message>) onMessagesChanged,
    required Function(String) onError,
    required Function(bool) onConnectionStatusChanged,
  }) {
    if (_isConnecting || _channel != null) {
      log('Realtime: Already connected or connecting');
      return;
    }

    _isConnecting = true;
    onConnectionStatusChanged(false); 

    try {
      unsubscribeFromMessages();

      _channel = _client
          .channel('messages_changes_${DateTime.now().millisecondsSinceEpoch}')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'messages',
            callback: (payload) {
              _fetchMessagesForRealtime(onMessagesChanged, onError);
            },
          )
          .subscribe((status, [error]) {
            _isConnecting = false;

            if (error != null) {
              log('Realtime: Subscription error - $error');
              onError('Connection error: ${error.toString()}');
              onConnectionStatusChanged(false);
            } else {
              onConnectionStatusChanged(
                status == RealtimeSubscribeStatus.subscribed,
              );

              if (status == RealtimeSubscribeStatus.subscribed) {
                log('Realtime: Successfully connected');
                _fetchMessagesForRealtime(onMessagesChanged, onError);
              } else if (status == RealtimeSubscribeStatus.closed ||
                  status == RealtimeSubscribeStatus.channelError) {
                log('Realtime: Connection closed or error');
                onConnectionStatusChanged(false);
                _attemptReconnection(
                  onMessagesChanged,
                  onError,
                  onConnectionStatusChanged,
                );
              } else if (status == RealtimeSubscribeStatus.timedOut) {
                log('Realtime: Connection timed out');
                onError(
                  'Connection timed out. Please check your internet connection.',
                );
                onConnectionStatusChanged(false);
              }
            }
          });
    } catch (e) {
      _isConnecting = false;
      log('Realtime: Setup error - $e');
      onError('Setup error: ${e.toString()}');
      onConnectionStatusChanged(false);
    }
  }

  void _attemptReconnection(
    Function(List<Message>) onMessagesChanged,
    Function(String) onError,
    Function(bool) onConnectionStatusChanged,
  ) {
    Future.delayed(Duration(seconds: 3), () {
      if (_channel == null) {
        subscribeToMessages(
          onMessagesChanged: onMessagesChanged,
          onError: onError,
          onConnectionStatusChanged: onConnectionStatusChanged,
        );
      }
    });
  }

  void unsubscribeFromMessages() {
    if (_channel != null) {
      log('Realtime: Unsubscribing...');
      _channel!.unsubscribe();
      _channel = null;
    }
    _isConnecting = false;
  }

  Future<void> _fetchMessagesForRealtime(
    Function(List<Message>) onMessagesChanged,
    Function(String) onError,
  ) async {
    try {
      final messages = await getMessages();
      onMessagesChanged(messages);
    } catch (e) {
      log('Realtime: Error fetching messages - $e');
      onError('Fetch error: ${e.toString()}');
    }
  }

  bool get isSubscribed => _channel != null && !_isConnecting;

  String get connectionStatus {
    if (_isConnecting) return 'connecting';
    if (_channel != null) return 'connected';
    return 'disconnected';
  }
}

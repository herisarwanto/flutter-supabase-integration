import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/message_service.dart';
import 'message_state.dart';

class MessageNotifier extends StateNotifier<MessageState> {
  final MessageService _service;

  MessageNotifier(this._service) : super(const MessageState());

  Future<void> fetchMessages() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final messages = await _service.getMessages();
      state = state.copyWith(messages: messages, isLoading: false);
    } catch (e) {
      log('Error fetching messages: $e');
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> createMessage({
    required String userId,
    required String name,
    required String message,
  }) async {
    state = state.copyWith(isSubmitting: true);
    try {
      await _service.createMessage(
        userId: userId,
        name: name,
        message: message,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }

  Future<void> updateMessage({
    required String id,
    String? name,
    String? message,
  }) async {
    try {
      await _service.updateMessage(id: id, name: name, message: message);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteMessage(String id) async {
    try {
      await _service.deleteMessage(id);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Realtime subscription methods
  void startRealtimeSubscription() {
    _service.subscribeToMessages(
      onMessagesChanged: (messages) {
        state = state.copyWith(
          messages: messages,
          isLoading: false,
          error: null,
        );
      },
      onError: (error) {
        log('Realtime error: $error');
        state = state.copyWith(error: error);
      },
      onConnectionStatusChanged: (isConnected) {
        log(
          'Realtime connection status: ${isConnected ? "Connected" : "Disconnected"}',
        );
      },
    );
  }

  void stopRealtimeSubscription() {
    log('Stopping realtime subscription...');
    _service.unsubscribeFromMessages();
  }

  void setLoadingState() {
    state = state.copyWith(isLoading: true, error: null);
  }

  void clearMessagesAndLoad() {
    state = state.copyWith(messages: [], isLoading: true, error: null);
  }

  bool get isRealtimeActive => _service.isSubscribed;

  String get connectionStatus => _service.connectionStatus;

  void reconnect() {
    log('Manual reconnection requested...');
    stopRealtimeSubscription();
    Future.delayed(Duration(milliseconds: 500), () {
      startRealtimeSubscription();
    });
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final messageProvider = StateNotifierProvider<MessageNotifier, MessageState>((
  ref,
) {
  return MessageNotifier(MessageService());
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/message_service.dart';
import 'message_state.dart';

class MessageNotifier extends StateNotifier<MessageState> {
  final MessageService _service;

  MessageNotifier(this._service) : super(const MessageState()) {
    // Initialize realtime subscription
    _initializeRealtimeSubscription();
  }

  Future<void> fetchMessages() async {
    // Always set loading state first
    state = state.copyWith(isLoading: true, error: null);

    try {
      final messages = await _service.getMessages();
      print('Fetched ${messages.length} messages'); // Debug log
      state = state.copyWith(messages: messages, isLoading: false);
    } catch (e) {
      print('Error fetching messages: $e'); // Debug log
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
      // No need to fetch messages - realtime will handle the update
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
      // No need to fetch messages - realtime will handle the update
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteMessage(String id) async {
    try {
      await _service.deleteMessage(id);
      // No need to fetch messages - realtime will handle the update
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Method to force loading state for testing
  void setLoadingState() {
    state = state.copyWith(isLoading: true, error: null);
  }

  // Method to clear messages and show loading
  void clearMessagesAndLoad() {
    state = state.copyWith(messages: [], isLoading: true, error: null);
  }

  // Realtime subscription methods
  void _initializeRealtimeSubscription() {
    _service.subscribeToMessages(
      onMessageInserted: (message) {
        // Add new message to the beginning of the list
        final updatedMessages = [message, ...state.messages];
        state = state.copyWith(messages: updatedMessages);
        print('Realtime: Message inserted - ${message.id}');
      },
      onMessageUpdated: (updatedMessage) {
        // Update existing message in the list
        final updatedMessages = state.messages.map((message) {
          return message.id == updatedMessage.id ? updatedMessage : message;
        }).toList();
        state = state.copyWith(messages: updatedMessages);
        print('Realtime: Message updated - ${updatedMessage.id}');
      },
      onMessageDeleted: (messageId) {
        // Remove deleted message from the list
        final updatedMessages = state.messages
            .where((message) => message.id != messageId)
            .toList();
        state = state.copyWith(messages: updatedMessages);
        print('Realtime: Message deleted - $messageId');
      },
      onError: (error) {
        print('Realtime error: $error');
        state = state.copyWith(error: error);
      },
    );
  }

  @override
  void dispose() {
    _service.unsubscribeFromMessages();
    super.dispose();
  }

  // Method to manually refresh realtime subscription
  void refreshRealtimeSubscription() {
    _service.unsubscribeFromMessages();
    _initializeRealtimeSubscription();
  }

  // Method to check if realtime is connected
  bool get isRealtimeConnected => _service.isSubscribed;
}

final messageProvider = StateNotifierProvider<MessageNotifier, MessageState>((
  ref,
) {
  return MessageNotifier(MessageService());
});

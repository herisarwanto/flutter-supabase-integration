import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/message_service.dart';
import 'message_state.dart';

class MessageNotifier extends StateNotifier<MessageState> {
  final MessageService _service;

  MessageNotifier(this._service) : super(const MessageState());

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
      await fetchMessages();
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
      await fetchMessages();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteMessage(String id) async {
    try {
      await _service.deleteMessage(id);
      await fetchMessages();
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
}

final messageProvider = StateNotifierProvider<MessageNotifier, MessageState>((
  ref,
) {
  return MessageNotifier(MessageService());
});

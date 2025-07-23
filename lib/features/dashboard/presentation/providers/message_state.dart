import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/model/message_model.dart';

part 'message_state.freezed.dart';

@freezed
class MessageState with _$MessageState {
  const factory MessageState({
    @Default([]) List<Message> messages,
    @Default(false) bool isLoading,
    @Default(false) bool isSubmitting,
    String? error,
  }) = _MessageState;
}

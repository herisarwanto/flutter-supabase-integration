import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/model/message_model.dart';

class MessageService {
  final _client = Supabase.instance.client;

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
}

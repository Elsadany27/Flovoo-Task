import 'package:hive/hive.dart';
import '../../../../core/constants/hive_constants.dart';
import 'message_model.dart';

class ChatModel {
  ChatModel({
    required this.id,
    required this.title,
    required this.messages,
    required this.updatedAt,
    this.unreadCount = 0,
  });

  final String id;
  final String title;
  final List<MessageModel> messages;
  final DateTime updatedAt;
  final int unreadCount;

  String get lastMessagePreview {
    if (messages.isEmpty) return 'No messages yet';

    final last = messages.last;
    if (last.emoji != null && last.text.isEmpty) {
      return last.emoji!;
    }
    if (last.emoji != null && last.text.isNotEmpty) {
      return '${last.text} ${last.emoji!}';
    }
    return last.text;
  }

  ChatModel copyWith({
    String? id,
    String? title,
    List<MessageModel>? messages,
    DateTime? updatedAt,
    int? unreadCount,
  }) {
    return ChatModel(
      id: id ?? this.id,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      updatedAt: updatedAt ?? this.updatedAt,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

class ChatModelAdapter extends TypeAdapter<ChatModel> {
  @override
  int get typeId => HiveConstants.chatTypeId;

  @override
  ChatModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatModel(
      id: fields[0] as String,
      title: fields[1] as String,
      messages: (fields[2] as List).cast<MessageModel>(),
      updatedAt: fields[3] as DateTime,
      unreadCount: fields[4] as int? ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, ChatModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.messages)
      ..writeByte(3)
      ..write(obj.updatedAt)
      ..writeByte(4)
      ..write(obj.unreadCount);
  }
}

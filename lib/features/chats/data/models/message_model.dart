import 'package:hive/hive.dart';

import '../../../../core/constants/hive_constants.dart';

enum MessageStatus { sending, sent, delivered }

class MessageModel {
  MessageModel({
    required this.id,
    required this.text,
    this.emoji,
    required this.isMe,
    required this.timestamp,
    this.status,
  });

  final String id;
  final String text;
  final String? emoji;
  final bool isMe;
  final DateTime timestamp;
  final MessageStatus? status;

  MessageModel copyWith({
    String? id,
    String? text,
    String? emoji,
    bool? isMe,
    DateTime? timestamp,
    MessageStatus? status,
  }) {
    return MessageModel(
      id: id ?? this.id,
      text: text ?? this.text,
      emoji: emoji ?? this.emoji,
      isMe: isMe ?? this.isMe,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
    );
  }
}

class MessageModelAdapter extends TypeAdapter<MessageModel> {
  @override
  int get typeId => HiveConstants.messageTypeId;

  @override
  MessageModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    final isMe = fields[3] as bool;
    return MessageModel(
      id: fields[0] as String,
      text: fields[1] as String,
      emoji: fields[2] as String?,
      isMe: isMe,
      timestamp: fields[4] as DateTime,
      status: fields.containsKey(5)
          ? MessageStatus.values[fields[5] as int]
          : (isMe ? MessageStatus.delivered : null),
    );
  }

  @override
  void write(BinaryWriter writer, MessageModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.text)
      ..writeByte(2)
      ..write(obj.emoji)
      ..writeByte(3)
      ..write(obj.isMe)
      ..writeByte(4)
      ..write(obj.timestamp)
      ..writeByte(5)
      ..write(obj.status?.index);
  }
}

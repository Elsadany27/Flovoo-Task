import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/hive_constants.dart';
import '../../features/chats/data/models/chat_model.dart';
import '../../features/chats/data/models/message_model.dart';

class HiveService {
  HiveService._();

  static final HiveService instance = HiveService._();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(HiveConstants.messageTypeId)) {
      Hive.registerAdapter(MessageModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveConstants.chatTypeId)) {
      Hive.registerAdapter(ChatModelAdapter());
    }

    await _deleteLegacyBox('chats_box');

    await Hive.openBox(HiveConstants.appBox);
    await Hive.openBox(HiveConstants.chatsBox);

    _initialized = true;
  }

  Future<void> _deleteLegacyBox(String name) async {
    if (await Hive.boxExists(name)) {
      await Hive.deleteBoxFromDisk(name);
    }
  }

  Box get appBox => Hive.box(HiveConstants.appBox);

  Box get chatsBox => Hive.box(HiveConstants.chatsBox);
}

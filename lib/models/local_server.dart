import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:ot_dart/models/command.dart';
import 'package:ot_dart/models/local_client.dart';

class LocalServer with ChangeNotifier {
  static final LocalServer _singleton = LocalServer._internal();

  factory LocalServer() {
    return _singleton;
  }

  LocalServer._internal() {
    init();
  }

  void init() {}

  final List<LocalClient> clients = []; // 已连接的用户
  final List<Command> commands = []; // 已收到的消息
  String documentText = ''; // 服务器当前的text
  int revision = 0; // 服务器当前文本版本

  registerClient(LocalClient client) {
    client.revision = revision;
    clients.add(client);
    client.connected = true;
  }

  // 向服务器发送消息
  Future<void> writeCmd(Command cmd) async {
    commands.add(cmd);
    // todo ot
    for (final client in clients) {
      if (cmd.client == client) {
        client.onMessage(Command(client, CommandType.retain, revision));
      } else {
        cmd.revision = revision;
        client.onMessage(cmd);
      }
    }
    documentText = cmd.handleText(documentText);
    // todo 发送消息给clients
    notifyListeners();
  }
}

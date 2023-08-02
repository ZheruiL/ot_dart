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

  registerClient(LocalClient client) {
    clients.add(client);
    client.connected = true;
  }

  // 向服务器发送消息
  Future<void> writeCmd(Command cmd) async {
    commands.add(cmd);
    // todo ot
    documentText = cmd.handleText(documentText);
    // todo 发送消息给clients
    notifyListeners();
  }
}

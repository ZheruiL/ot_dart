import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ot_dart/models/command.dart';
import 'package:ot_dart/models/local_client.dart';
import 'package:ot_dart/models/operation_list.dart';

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
  final List<OperationList> operationLists = []; // 已收到的消息
  String documentText = ''; // 服务器当前的text
  int revision = 0; // 服务器当前文本版本

  registerClient(LocalClient client) {
    client.revision = revision;
    clients.add(client);
    client.connected = true;
    client.receivedAck = true;
  }

  // 向服务器发送消息
  Future<void> writeOperations(OperationList operationList) async {
    // 服务器处理消息, 处理完成后发送给客户
    operationLists.add(operationList);
    // todo ot转换后发送给所有用户
    for (final client in clients) {
      final List<Command> operationsToSend = [];
      for (final operation in operationList.operations) {
        operation.revision = revision;
        if (operation.client == client) {
          operationsToSend.add(Command(client, CommandType.retain, revision));
          continue;
        }
        operationsToSend.add(operation);
      }
      final operationListToSend = OperationList(operationsToSend, operationList.client);
      client.onMessage(operationListToSend);
    }
    for (final op in operationList.operations) {
      documentText = op.handleText(documentText);
    }
    // todo 发送消息给clients
    notifyListeners();
  }
}

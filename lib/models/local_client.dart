import 'dart:async';

import 'package:ot_dart/models/abstracts/client.dart';
import 'package:ot_dart/models/command.dart';
import 'package:ot_dart/models/local_server.dart';
import 'package:ot_dart/models/operation_list.dart';

class LocalClient extends Client {
  LocalClient(super.username, super.currVal, super.controller, super.color);

  @override
  Future<void> connect() async {
    // await Future.delayed(const Duration(seconds: 2));
    LocalServer().registerClient(this);
  }

  // @override
  // Future<Command> readCmd() async {
  //   return commands.removeAt(0);
  // }

  // 通信层
  @override
  Future<void> writeOperations(List<Command> operations) async {
    final operationList = OperationList(operations, this);
    await LocalServer().writeOperations(operationList);
  }
}

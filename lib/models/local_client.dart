import 'dart:async';

import 'package:ot_dart/models/abstracts/client.dart';
import 'package:ot_dart/models/command.dart';
import 'package:ot_dart/models/local_server.dart';

class LocalClient extends Client {
  LocalClient(super.username, super.currVal, super.controller, super.color);

  // final Completer<Command> completer = Completer();

  @override
  Future<void> connect() async {
    // await Future.delayed(const Duration(seconds: 2));
    LocalServer().registerClient(this);
  }

  // @override
  // Future<Command> readCmd() async {
  //   return commands.removeAt(0);
  // }

  @override
  Future<void> writeCmd(Command cmd) async {
    await LocalServer().writeCmd(cmd);
    // _completer.complete(cmd);
  }
}

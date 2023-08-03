import 'package:flutter/material.dart';
import 'package:ot_dart/models/command.dart';

abstract class Client with ChangeNotifier {
  final String username;
  int revision = 0; // 当前版本
  String val; // 当前的文本
  final List<Command> sentCommands = []; // 已发送的消息
  final List<Command> receivedCommands = []; // 已收到的消息
  final TextEditingController controller;
  bool connected = false;
  Color color;

  Client(this.username, this.val, this.controller, this.color) {
    init();
  }

  @override
  bool operator ==(Object other) => other is Client && other.username == username;

  @override
  int get hashCode => username.hashCode;

  init() {
    controller.addListener(() {
      final currPos = controller.selection.start;
      debugPrint('currPos $currPos');
      // 不是用户输入的修改
      String currVal = controller.text;
      if (val == currVal) {
        return;
      }
      revision++;
      final length = currVal.length - val.length;
      late final Command command;
      if (length > 0) {
        // add value
        String addedValue = currVal.substring(currPos - length, currPos);
        final pos = currPos - length;
        debugPrint('insert pos: $pos, v: $addedValue');
        command = Command(
          this,
          CommandType.insert,
          revision,
          pos: pos,
          content: addedValue,
          length: length,
        );
      } else if (currVal.length < val.length) {
        // delete value
        debugPrint('delete pos: $currPos, length: ${-length}');
        command = Command(
          this,
          CommandType.delete,
          revision,
          pos: currPos,
          length: -length,
        );
      }
      val = currVal;
      sentCommands.add(command);
      notifyListeners();
    });
  }

  onMessage(Command cmd) {
    receivedCommands.add(cmd);
    revision++;
  }

  receiveCmd() {
    if (receivedCommands.isEmpty) {
      debugPrint(
        'client does not have any commands to receive',
      );
      return;
    }
    final cmd = receivedCommands.removeAt(0);
    val = cmd.handleText(controller.text);
    controller.text = val;
    notifyListeners();
  }

  Future<void> connect();

  // 发送信息给服务器
  Future<void> writeCmd(Command cmd);

// 读取服务器发来的消息
// Future<Command> readCmd();

// onMessage(Function(Command cmd) cb) async {
//   cb(await readCmd());
// }

  getUsername() {
    return username;
  }
}

import 'package:flutter/material.dart';
import 'package:ot_dart/models/command.dart';
import 'package:ot_dart/models/operation_list.dart';

abstract class Client with ChangeNotifier {
  final String username;
  int revision = 0; // 当前版本
  String val; // 当前的文本
  bool receivedAck = false; // 是否收到了服务器的ack
  final List<Command> sentCommands = []; // 可以发送给服务器的消息
  final List<Command> bufferedCommands = []; // 在本地缓存中还不能发送给服务器的消息
  final List<OperationList> receivedOperationsList = []; // 已收到的消息
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
      if (receivedAck) {
        sentCommands.add(command);
        receivedAck = false;
      } else {
        bufferedCommands.add(command);
      }
      notifyListeners();
    });
  }

  onMessage(OperationList operationList) {
    receivedOperationsList.add(operationList);
    revision++;
  }

  receiveCmd() {
    if (receivedOperationsList.isEmpty) {
      debugPrint(
        'client does not have any commands to receive',
      );
      return;
    }
    receivedAck = true;
    sentCommands.addAll(bufferedCommands);
    bufferedCommands.clear();
    final operationList = receivedOperationsList.removeAt(0);
    for (final op in operationList.operations) {
      val = op.handleText(controller.text);
      controller.text = val;
    }
    notifyListeners();
  }

  Future<void> connect();

  // 是否可以发送
  bool canSend() {
    return sentCommands.isNotEmpty;
  }

  // 是否可以接收
  bool canReceive() {
    return receivedOperationsList.isNotEmpty;
  }

  // 按确认发送
  Future<void> sendOperations() async {
    await writeOperations(sentCommands);
    sentCommands.clear();
  }

  // 发送信息给服务器 (通信曾)
  Future<void> writeOperations(List<Command> operations);

// 读取服务器发来的消息
// Future<Command> readCmd();

// onMessage(Function(Command cmd) cb) async {
//   cb(await readCmd());
// }

  getUsername() {
    return username;
  }
}

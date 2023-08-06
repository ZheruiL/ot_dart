import 'package:ot_dart/models/abstracts/client.dart';
import 'package:ot_dart/models/command.dart';

class OperationList {
  OperationList(this.operations, this.client);

  final List<Command> operations;
  final Client client;

  @override
  String toString() {
    String text = '';
    for (int i = 0; i < operations.length; i++) {
      text += operations[i].toString();
      if (i != operations.length - 1) {
        text += '\n';
      }
    }
    return text;
  }
}

import 'package:ot_dart/models/abstracts/client.dart';
import 'package:ot_dart/models/command.dart';

class OperationList {
  OperationList(this.operations, this.client);

  final List<Command> operations;
  final Client client;

  @override
  String toString() {
    String text = '';
    for (final op in operations) {
      text = '$op\n';
    }
    return text;
  }
}

import 'abstracts/client.dart';

enum CommandType {
  insert,
  delete,
}

class Command {
  Command(
    this.client,
    this.type,
    this.pos, {
    this.content = '',
    this.length = 0,
  });

  Client client;
  CommandType type;
  int pos;
  String content = '';
  int length = 0;

  @override
  String toString() {
    switch (type) {
      case CommandType.insert:
        return 'Insert(Pos=$pos, content="$content")';
      case CommandType.delete:
        return 'Delete(pos=$pos, length=$length)';
    }
  }

  String handleText(String text) {
    switch (type) {
      case CommandType.insert:
        return (text.substring(0, pos) + content + text.substring(pos, text.length));
      case CommandType.delete:
        return text.substring(0, pos) + text.substring(pos + length, text.length);
    }
  }
}

import 'abstracts/client.dart';

enum CommandType { insert, delete, retain }

class Command {
  Command(
    this.client,
    this.type,
    this.revision, {
    this.pos = 0,
    this.content = '',
    this.length = 0,
  });

  Client client;
  CommandType type;
  int revision;
  int pos;
  String content = '';
  int length = 0;

  @override
  String toString() {
    late final String text;
    switch (type) {
      case CommandType.insert:
        text = 'Insert(Pos=$pos, content="$content")';
      case CommandType.delete:
        text = 'Delete(pos=$pos, length=$length)';
      case CommandType.retain:
        text = 'Retain';
    }
    return 'Revision: $revision \n$text';
  }

  String handleText(String text) {
    switch (type) {
      case CommandType.insert:
        return (text.substring(0, pos) + content + text.substring(pos, text.length));
      case CommandType.delete:
        return text.substring(0, pos) + text.substring(pos + length, text.length);
      case CommandType.retain:
        return text;
    }
  }
}

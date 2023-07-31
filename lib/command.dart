enum CommandType {
  insert,
  delete,
}

class Command {
  Command(
    this.username,
    this.type,
    this.pos, {
    this.content = '',
    this.length = 0,
  });

  String username;
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
}

import 'package:flutter/material.dart';
import 'package:ot_dart/command.dart';
import 'package:ot_dart/sender.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter OT demo',
      theme: ThemeData(useMaterial3: true),
      home: const MyHomePage(
        title: 'Visualization of OT with a central server using flutter',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const _usernameAlice = 'Alice';
  static const _usernameBob = 'Bob';
  final List<Command> _commands = [];
  String _documentText = '';
  final _controllerAlice = TextEditingController();
  String _lastValueAlice = '';
  final List<Command> _bufferedCommandsAlice = [];
  final _controllerBob = TextEditingController();
  String _lastValueBob = '';
  final List<Command> _bufferedCommandsBob = [];

  @override
  void initState() {
    super.initState();
    handleListener(TextEditingController controller, String lastValue, String username) {
      final currPos = controller.selection.start;
      debugPrint('currPos $currPos');
      // 不是用户输入的修改
      String currVal = controller.text;
      if (lastValue == currVal) {
        return;
      }
      final length = currVal.length - lastValue.length;
      late final Command command;
      if (length > 0) {
        // add value
        String addedValue = currVal.substring(currPos - length, currPos);
        final pos = currPos - length;
        debugPrint('insert pos: $pos, v: $addedValue');
        command = Command(
          username,
          CommandType.insert,
          pos,
          content: addedValue,
          length: length,
        );
      } else if (currVal.length < lastValue.length) {
        // delete value
        debugPrint('delete pos: $currPos, length: ${-length}');
        command = Command(
          username,
          CommandType.delete,
          currPos,
          length: -length,
        );
      }
      switch (username) {
        case _usernameAlice:
          _lastValueAlice = currVal;
          _bufferedCommandsAlice.add(command);
          break;
        case _usernameBob:
          _lastValueBob = currVal;
          _bufferedCommandsBob.add(command);
          break;
        default:
          throw Exception('unknown user');
      }
      setState(() {});
    }

    _controllerAlice.addListener(() {
      handleListener(_controllerAlice, _lastValueAlice, _usernameAlice);
    });
    _controllerBob.addListener(() {
      handleListener(_controllerBob, _lastValueBob, _usernameBob);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controllerAlice.dispose();
    _controllerBob.dispose();
  }

  void handleCmd(Command cmd) {
    _commands.add(cmd);
    final pos = cmd.pos;
    switch (cmd.type) {
      case CommandType.insert:
        _documentText = (_documentText.substring(0, pos) +
            cmd.content +
            _documentText.substring(pos, _documentText.length));
      case CommandType.delete:
        _documentText = _documentText.substring(0, pos) +
            _documentText.substring(pos + cmd.length, _documentText.length);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Central Server',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SH16(),
                        Text('Document: $_documentText'),
                        const SH16(),
                        Row(
                          children: [
                            const Text('Operations:'),
                            Expanded(
                              child: SizedBox(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      for (final command in _commands) ...[
                                        const SizedBox(width: 8),
                                        Tooltip(
                                          message: command.toString(),
                                          child: Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: command.username == _usernameAlice
                                                  ? Colors.blue
                                                  : Colors.red,
                                            ),
                                          ),
                                        ),
                                      ]
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Sender(
                      name: _usernameAlice,
                      controller: _controllerAlice,
                      onSent: _bufferedCommandsAlice.isEmpty // todo 并且收到服务器的ack
                          ? null
                          : () => handleCmd(_bufferedCommandsAlice.removeAt(0)),
                      onReceived: () {},
                    ),
                  ),
                  const SW16(),
                  Expanded(
                    flex: 1,
                    child: Sender(
                      name: _usernameBob,
                      controller: _controllerBob,
                      onSent: _bufferedCommandsBob.isEmpty // todo 并且收到服务器的ack
                          ? null
                          : () => handleCmd(_bufferedCommandsBob.removeAt(0)),
                      onReceived: () {},
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SH16 extends StatelessWidget {
  const SH16({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 16);
  }
}

class SW16 extends StatelessWidget {
  const SW16({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SizedBox(width: 16);
  }
}

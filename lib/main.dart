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
      home: const MyHomePage(title: 'OT demo'),
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
  final usernameAlice = 'alice';
  final usernameBob = 'bob';
  List<Command> _commands = [];
  String _documentText = '';
  final _controllerAlice = TextEditingController();
  String _lastValueAlice = '';
  final _controllerBob = TextEditingController();
  String _lastValueBob = '';

  @override
  void initState() {
    super.initState();
    handleListener(
      TextEditingController controller,
      String lastValue,
      String username,
      Function(String v) cb,
    ) {
      final currPos = controller.selection.start;
      debugPrint('currPos $currPos');
      // 不是用户输入的修改
      String currVal = controller.text;
      if (lastValue == currVal) {
        return;
      }
      final length = currVal.length - lastValue.length;
      if (length > 0) {
        // add value
        String addedValue = currVal.substring(currPos - length, currPos);
        final pos = currPos - length;
        debugPrint('insert pos: $pos, v: $addedValue');
        _commands.add(Command(username, CommandType.insert, pos,
            content: addedValue, length: length));
      } else if (currVal.length < lastValue.length) {
        // delete value
        debugPrint('delete pos: $currPos, length: ${-length}');
        _commands.add(Command(username, CommandType.delete, currPos, length: -length));
      }
      cb(currVal);
      setState(() {});
    }

    _controllerAlice.addListener(() {
      handleListener(_controllerAlice, _lastValueAlice, usernameAlice, (v) {
        _lastValueAlice = v;
      });
    });
    _controllerBob.addListener(() {
      handleListener(_controllerBob, _lastValueBob, usernameBob, (v) {
        _lastValueBob = v;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controllerAlice.dispose();
    _controllerBob.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
                                              color: command.username == usernameAlice
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
                      name: 'Alice',
                      controller: _controllerAlice,
                      onSent: () {},
                      onReceived: () {},
                    ),
                  ),
                  const SW16(),
                  Expanded(
                    flex: 1,
                    child: Sender(
                      name: 'Bob',
                      controller: _controllerBob,
                      onSent: () {},
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

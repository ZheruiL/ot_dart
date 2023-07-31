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

// Widget _buildSender(String name, TextEditingController controller) {
// controller.addListener(() {
//   print(controller.selection.base.offset);
// });
// return Column(
//   children: [
//     Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         IconButton(
//           onPressed: () {
//             _documentText = controller.text;
//             setState(() {});
//           },
//           icon: const Icon(Icons.arrow_upward),
//         ),
//         const SizedBox(width: 64),
//       ],
//     ),
//     const SH16(),
//     const SH16(),
//     Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         const SizedBox(width: 64),
//         IconButton(
//           onPressed: () {
//             controller.text = _documentText;
//             setState(() {});
//           },
//           icon: const Icon(Icons.arrow_downward),
//         ),
//       ],
//     ),
//     Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             Text(name),
//             const SH16(),
//             TextFormField(
//               controller: controller,
//               onChanged: (String v) {
//                 // Get cursor current position
//                 var cursorPos = controller.selection.base.offset;
//
//                 // Right text of cursor position
//                 // String suffixText = controller.text.substring(cursorPos);
//
//                 // debugPrint(v[cursorPos - 1]);
//                 debugPrint('insert pos: $cursorPos, v: ${v[cursorPos - 1]}');
//
//                 // // Add new text on cursor position
//                 // String specialChars = ' text_1 ';
//                 // int length = specialChars.length;
//                 //
//                 // // Get the left text of cursor
//                 // String prefixText =
//                 // controller.text.substring(0, cursorPos);
//                 //
//                 // controller.text =
//                 //     prefixText + specialChars + suffixText;
//                 //
//                 // // Cursor move to end of added text
//                 // controller.selection = TextSelection(
//                 //   baseOffset: cursorPos + length,
//                 //   extentOffset: cursorPos + length,
//                 // );
//               },
//               minLines: 5,
//               maxLines: 5,
//               decoration: InputDecoration(
//                 filled: true,
//                 fillColor: Theme.of(context).colorScheme.surfaceVariant,
//               ),
//             ),
//           ],
//         ),
//       ),
//     ),
//   ],
// );
// }
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

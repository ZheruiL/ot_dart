import 'package:flutter/material.dart';
import 'package:ot_dart/models/abstracts/client.dart';
import 'package:ot_dart/components/sender.dart';
import 'package:ot_dart/models/local_client.dart';
import 'package:ot_dart/models/local_server.dart';

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
  late final Client _clientAlice;
  late final Client _clientBob;
  final _controllerAlice = TextEditingController();
  final _controllerBob = TextEditingController();

  @override
  void initState() {
    super.initState();
    _clientAlice = LocalClient(_usernameAlice, '', _controllerAlice);
    _clientBob = LocalClient(_usernameBob, '', _controllerBob);
    _clientAlice.connect();
    _clientBob.connect();
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
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListenableBuilder(
            listenable: LocalServer(),
            builder: (BuildContext context, Widget? child) {
              return Column(
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
                            Text('Document: ${LocalServer().documentText}'),
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
                                          const SizedBox(height: 24),
                                          for (final command
                                              in LocalServer().commands) ...[
                                            const SizedBox(width: 8),
                                            Tooltip(
                                              message: command.toString(),
                                              child: Container(
                                                width: 24,
                                                height: 24,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color:
                                                      command.username == _usernameAlice
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
                      Expanded(flex: 1, child: Sender(client: _clientAlice)),
                      const SW16(),
                      Expanded(flex: 1, child: Sender(client: _clientBob)),
                    ],
                  ),
                ],
              );
            },
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

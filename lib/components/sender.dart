import 'package:flutter/material.dart';
import 'package:ot_dart/models/abstracts/client.dart';

class Sender extends StatefulWidget {
  const Sender({
    super.key,
    required this.client,
  });

  final Client client;

  @override
  State<Sender> createState() => _SenderState();
}

class _SenderState extends State<Sender> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.client,
      builder: (BuildContext context, Widget? child) {
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Tooltip(
                      message: 'Receive next operation from client',
                      child: IconButton(
                        onPressed: widget.client.sentCommands.isEmpty // todo 并且收到服务器的ack
                            ? null
                            : () async {
                                if (widget.client.sentCommands.isEmpty) {
                                  debugPrint('client does not have any commands to send');
                                  return;
                                }
                                await widget.client.writeCmd(
                                  widget.client.sentCommands.removeAt(0),
                                );
                              },
                        icon: const Icon(Icons.arrow_upward),
                      ),
                    ),
                    const SizedBox(
                      height: 64,
                    ),
                  ],
                ),
                Column(
                  children: [
                    const SizedBox(
                      height: 64,
                      child: Column(),
                    ),
                    Tooltip(
                      message: 'Receive next operation from server',
                      child: IconButton(
                        onPressed: (widget.client.receivedCommands.isEmpty)
                            ? null
                            : () {
                                if (widget.client.receivedCommands.isEmpty) {
                                  debugPrint(
                                      'client does not have any commands to receive');
                                  return;
                                }
                              },
                        icon: const Icon(Icons.arrow_downward),
                      ),
                    ),
                  ],
                )
              ],
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(widget.client.username),
                    const SizedBox(height: 16),
                    TextFormField(
                      enabled: widget.client.connected,
                      controller: widget.client.controller,
                      // onChanged: (String v) {
                      //   // Get cursor current position
                      //   var cursorPos = controller.selection.base.offset;
                      //
                      //   // Right text of cursor position
                      //   // String suffixText = controller.text.substring(cursorPos);
                      //
                      //   // debugPrint(v[cursorPos - 1]);
                      //   debugPrint('insert pos: $cursorPos, v: ${v[cursorPos - 1]}');
                      // },
                      minLines: 5,
                      maxLines: 5,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

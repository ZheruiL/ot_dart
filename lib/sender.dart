import 'package:flutter/material.dart';

class Sender extends StatefulWidget {
  const Sender({
    super.key,
    required this.name,
    required this.controller,
    this.onSent,
    this.onReceived,
  });

  final String name;
  final TextEditingController controller;
  final Function()? onSent;
  final Function()? onReceived;

  @override
  State<Sender> createState() => _SenderState();
}

class _SenderState extends State<Sender> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: widget.onSent,
              icon: const Icon(Icons.arrow_upward),
            ),
            const SizedBox(width: 64),
          ],
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 64),
            IconButton(
              onPressed: widget.onReceived,
              icon: const Icon(Icons.arrow_downward),
            ),
          ],
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(widget.name),
                const SizedBox(height: 16),
                TextFormField(
                  controller: widget.controller,
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
  }
}

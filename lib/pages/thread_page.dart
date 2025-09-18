import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class ThreadPage extends StatelessWidget {
  final Message parent;
  const ThreadPage({super.key, required this.parent});

  @override
  Widget build(BuildContext context) {
    final channel = StreamChannel.of(context).channel;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Thread', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              'Replying to ${parent.user?.name ?? parent.user?.id}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.grey.shade100,
            child: Text(parent.text ?? '(attachment)'),
          ),
          Expanded(child: StreamMessageListView(parentMessage: parent)),
          StreamMessageInput(),
        ],
      ),
    );
  }
}

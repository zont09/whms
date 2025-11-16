import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/features/chat/bloc/chat_bloc.dart';
import 'package:whms/services/chat_service.dart';

class FloatingChatBox extends StatelessWidget {
  final String conversationId;
  final String userId;

  FloatingChatBox({required this.conversationId, required this.userId});

  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
      ChatBloc(ChatWebSocketService(), ChatApiService())
        ..add(ChatConnectEvent(conversationId, userId)),
      child: Align(
        alignment: Alignment.bottomRight,
        child: Container(
          width: 350,
          height: 450,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(blurRadius: 12, color: Colors.black12)],
          ),
          child: BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              final bloc = BlocProvider.of<ChatBloc>(context);
              return Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: state.messages
                          .map((m) =>
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              alignment: m.senderId == userId
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: m.senderId == userId
                                      ? Colors.blue.shade100
                                      : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(m.content),
                              ),
                            ),
                          ))
                          .toList(),
                    )
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          decoration: const InputDecoration(
                              hintText: "Nhập tin nhắn..."),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () {
                          final text = controller.text.trim();
                          if (text.isEmpty) return;

                          bloc.add(ChatSendEvent(
                            text,
                            conversationId,
                            userId,
                          ));
                          controller.clear();
                        },
                      )
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



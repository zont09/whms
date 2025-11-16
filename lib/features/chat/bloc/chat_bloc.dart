import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/models/message_model.dart';
import 'package:whms/services/chat_service.dart';

abstract class ChatEvent {}

class ChatConnectEvent extends ChatEvent {
  final String conversationId;
  final String userId;

  ChatConnectEvent(this.conversationId, this.userId);
}

class ChatSendEvent extends ChatEvent {
  final String content;
  final String conversationId;
  final String userId;

  ChatSendEvent(this.content, this.conversationId, this.userId);
}

class ChatReceivedEvent extends ChatEvent {
  final ChatMessage message;

  ChatReceivedEvent(this.message);
}

class ChatState {
  final List<ChatMessage> messages;
  final bool connected;

  ChatState({required this.messages, required this.connected});

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? connected,
  }) =>
      ChatState(
        messages: messages ?? this.messages,
        connected: connected ?? this.connected,
      );
}


class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatWebSocketService ws;
  final ChatApiService api;

  ChatBloc(this.ws, this.api) : super(ChatState(messages: [], connected: false)) {
    on<ChatConnectEvent>(_onConnect);
    on<ChatSendEvent>(_onSend);
    on<ChatReceivedEvent>(_onReceived);
  }

  void _onConnect(ChatConnectEvent e, Emitter emit) async {
    ws.connect(e.conversationId, e.userId);

    ws.stream?.listen((raw) {
      final jsonData = jsonDecode(raw);
      if (jsonData["type"] == "message") {
        final msg = ChatMessage.fromJson(jsonData["message"]);
        add(ChatReceivedEvent(msg));
      }
    });

    // load history
    final history = await api.loadMessages(e.conversationId);

    emit(state.copyWith(messages: history, connected: true));
  }

  void _onSend(ChatSendEvent e, Emitter emit) {
    ws.sendMessage(e.conversationId, e.userId, e.content);
  }

  void _onReceived(ChatReceivedEvent e, Emitter emit) {
    final updated = [...state.messages, e.message];
    emit(state.copyWith(messages: updated));
  }
}


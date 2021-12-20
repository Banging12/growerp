/*
 * This GrowERP software is in the public domain under CC0 1.0 Universal plus a
 * Grant of Patent License.
 * 
 * To the extent possible under law, the author(s) have dedicated all
 * copyright and related and neighboring rights to this software to the
 * public domain worldwide. This software is distributed without any
 * warranty.
 * 
 * You should have received a copy of the CC0 Public Domain Dedication
 * along with this software (see the LICENSE.md file). If not, see
 * <http://creativecommons.org/publicdomain/zero/1.0/>.
 */

// To parse this JSON data, do
//
//      chatMessage = chatMessageFromJson(jsonString);

import 'dart:convert';
import 'package:core/services/jsonConverters.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chatMessage_model.freezed.dart';
part 'chatMessage_model.g.dart';

ChatMessage chatMessageFromJson(String str) =>
    ChatMessage.fromJson(json.decode(str)["chatMessage"]);
String chatMessageToJson(ChatMessage data) =>
    '{"chatMessage":' + json.encode(data.toJson()) + "}";

List<ChatMessage> chatMessagesFromJson(String str) => List<ChatMessage>.from(
    json.decode(str)["chatMessages"].map((x) => ChatMessage.fromJson(x)));
String chatMessagesToJson(List<ChatMessage> data) =>
    '{"chatMessages":' +
    json.encode(List<dynamic>.from(data.map((x) => x.toJson()))) +
    "}";

// backend relation: product -> chatMessage -> chatMessageReservation -> orderItem

@freezed
class ChatMessage with _$ChatMessage {
  ChatMessage._();
  factory ChatMessage({
    String? fromUserId,
    String? chatMessageId,
    String? content,
    @DateTimeConverter() DateTime? creationDate,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
}
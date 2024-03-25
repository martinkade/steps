import 'ChatGPTRequestMessage.dart';

class Purchase {
  String title;

  String description;

  String price;

  List<ChatGPTRequestMessage> chatGptInfos;

  Purchase(this.title, this.description, this.price, this.chatGptInfos);
}
import 'package:flutter/material.dart';
import 'package:wandr/__secrets.dart';
import 'package:wandr/components/purchases/purchases.item.purchase.dart';
import 'package:wandr/components/shared/page.default.dart';
import 'package:wandr/model/preferences.dart';
import 'package:wandr/util/AprilJokes.dart';
import 'package:wandr/util/ChatGPTRequestMessage.dart';

import 'package:wandr/util/ChatGPTService.dart';

import 'package:wandr/components/shared/localizer.dart';

class PurchasesComponent extends StatefulWidget {
  ///
  final String? userKey;

  ///
  const PurchasesComponent({Key? key, this.userKey}) : super(key: key);

  @override
  _PurchasesState createState() => _PurchasesState();
}

class _PurchasesState extends State<PurchasesComponent> {
  final ChatGPTService chatGPTService = ChatGPTService(CHAT_GPT);

  Future<void> _chatGPTMessage(List<ChatGPTRequestMessage> messages) async {
    showLoaderDialog(context);
    String displayName = await Preferences().getDisplayName();
    messages.add(ChatGPTRequestMessage("user", "Mein Name ist $displayName"));
    String response = await chatGPTService.getChatResponse(messages);
    Navigator.pop(context);
    showTextDialog(response.isEmpty ? "Es ist ein Fehler aufgetreten" : response);
  }

  showTextDialog(text) {
    Widget cancelButton = TextButton(
        child: Text("Ok"),
        onPressed: () => Navigator.of(context).pop()
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Warnung"),
      content: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Text(
          text,
        ),
      ),
      actions: [
        cancelButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
            ]
          ),
          SizedBox(height: 10),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  child: Text("Geld wird abgebucht..." )
              ),
            ]
          )
        ],
      ),
    );
    showDialog(barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultPage(
      child: ListView.builder(
        itemCount: AprilJokes.purchases.length,
        itemBuilder: (context, index) {
          return PurchasesPurchaseItem(
              purchase: AprilJokes.purchases[index],
              clickedPurchase: (messages) => _chatGPTMessage(messages)
          );
        },
      ),
      title: Localizer.translate(context, 'lblDashboardActionPurchases'),
    );
  }
}

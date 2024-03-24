import 'package:flutter/material.dart';

import 'package:wandr/components/shared/localizer.dart';
import 'package:wandr/util/Purchase.dart';

class PurchasesPurchaseItem extends StatefulWidget {
  final Purchase purchase;

  ///
  final Function clickedPurchase;

  ///
  PurchasesPurchaseItem({Key? key, required this.purchase, required this.clickedPurchase})
      : super(key: key);

  @override
  _PurchasesPurchaseItemState createState() => _PurchasesPurchaseItemState();
}

class _PurchasesPurchaseItemState extends State<PurchasesPurchaseItem> {


  @override
  Widget build(BuildContext context) {

    final Widget contentWidget = Padding(
      padding: const EdgeInsets.all(16.0),
      child: GestureDetector(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.purchase.title,
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.purchase.description,
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    widget.purchase.price,
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () => widget.clickedPurchase(widget.purchase.chatGptInfos)
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
          child: Card(
            elevation: 8.0,
            shadowColor: Colors.grey.withAlpha(50),
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: contentWidget,
          ),
        ),
      ],
    );
  }
}

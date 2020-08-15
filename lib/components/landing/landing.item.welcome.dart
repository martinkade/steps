import 'package:flutter/material.dart';
import 'package:steps/components/landing/landing.item.dart';

class LandingWelcomeItem extends LandingItem {
  ///
  LandingWelcomeItem({Key key, int index, LandingDelegate delegate})
      : super(key: key, index: index, delegate: delegate);

  @override
  _LandingWelcomeItemState createState() => _LandingWelcomeItemState();
}

class _LandingWelcomeItemState extends State<LandingWelcomeItem> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
            child: Center(
              child: SizedBox(
                child: Image.asset('assets/images/rocket.png'),
                width: 128.0,
                height: 128.0,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
          child: Text(
            'Wir benötigen noch einige Informationen, doch in wenigen Schritten bist du startklar 🥳',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        FlatButton(
          child: Text(
            'Los gehts!',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () {
            widget.delegate.nextItem(widget);
          },
        )
      ],
    );
  }
}

import 'package:flutter/material.dart';

class SegmentedControl extends StatefulWidget {
  ///
  final List<OptionModel> options;

  ///
  final Function onChange;

  ///
  SegmentedControl({Key key, this.options, this.onChange}) : super(key: key);

  @override
  _SegmentedControlState createState() => _SegmentedControlState();
}

class _SegmentedControlState extends State<SegmentedControl> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List<SegmentedControlOption> options = widget.options
        .map(
          (model) => SegmentedControlOption(
            model: model,
            onTap: () {
              widget.onChange(model);
            },
          ),
        )
        .toList();

    return Card(
      elevation: 8.0,
      shadowColor: Colors.grey.withAlpha(50),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: options,
        ),
      ),
    );
  }
}

class OptionModel {
  final String title;
  final int index;
  final bool isSelected;
  OptionModel({this.index, this.title, this.isSelected = false});
}

class SegmentedControlOption extends StatelessWidget {
  final OptionModel model;
  final Function onTap;
  SegmentedControlOption({Key key, this.model, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        color:
            model.isSelected ? Color.fromARGB(255, 255, 215, 0) : Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Text(
            model.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight:
                  model.isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
      onTap: onTap,
    );
  }
}

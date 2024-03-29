import 'package:flutter/material.dart';

class SegmentedControl extends StatefulWidget {
  ///
  final List<OptionModel> options;

  ///
  final Function onChange;

  ///
  final double elevation;

  ///
  final bool scrollable;

  ///
  SegmentedControl({
    Key key,
    this.options,
    this.onChange,
    this.elevation = 8.0,
    this.scrollable = true,
  }) : super(key: key);

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
    final List<Widget> options = widget.options
        .map(
          (model) => widget.scrollable
              ? SegmentedControlOption(
                  model: model,
                  onTap: () {
                    widget.onChange(model);
                  },
                )
              : Expanded(
                  child: SegmentedControlOption(
                    model: model,
                    onTap: () {
                      widget.onChange(model);
                    },
                  ),
                ),
        )
        .toList();

    final Widget content = Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: options,
    );

    return Card(
      elevation: widget.elevation,
      shadowColor: Colors.grey.withAlpha(50),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: widget.scrollable
          ? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: content,
            )
          : content,
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
        color: model.isSelected
            ? Theme.of(context).colorScheme.primary.withAlpha(50)
            : Colors.transparent,
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

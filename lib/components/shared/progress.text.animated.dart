import 'package:flutter/material.dart';

class AnimatedProgressText extends StatefulWidget {
  ///
  final int start;

  ///
  final int end;

  ///
  final int target;

  ///
  final String label;

  ///
  final double fontSize;

  ///
  final bool animated;

  ///
  AnimatedProgressText({
    Key key,
    this.start,
    this.end,
    this.target,
    this.label,
    this.fontSize = 32.0,
    this.animated = true,
  }) : super(key: key);

  @override
  _AnimatedProgressTextState createState() => _AnimatedProgressTextState();
}

class _AnimatedProgressTextState extends State<AnimatedProgressText>
    with SingleTickerProviderStateMixin {
  ///
  Animation<double> _animation;

  ///
  AnimationController _controller;

  ///
  double _displayValue;

  @override
  void initState() {
    super.initState();

    _displayValue = widget.start.toDouble();
    if (widget.end == 0) return;

    _startAnimation();
  }

  @override
  void didUpdateWidget(AnimatedProgressText oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.end == 0) return;

    _startAnimation();
  }

  void _startAnimation() {
    if (_controller != null) return;

    _controller = AnimationController(
        duration: Duration(seconds: widget.animated ? 2 : 0), vsync: this);
    _animation = Tween<double>(
            begin: widget.start.toDouble(), end: widget.end.toDouble())
        .animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          0.0,
          1.0,
          curve: Curves.decelerate,
        ),
      ),
    );
    _animation.addListener(() {
      setState(() {
        _displayValue = _animation.value;
      });
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double padding = widget.fontSize / 6.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _displayValue.toStringAsFixed(0),
              style: TextStyle(
                fontSize: widget.fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(padding, 0.0, 4.0, padding),
              child: Text(
                '/${widget.target}',
              ),
            ),
            Expanded(child: Container()),
            widget.end >= widget.target
                ? Icon(
                    Icons.check_circle,
                    size: 16.0,
                    color: Colors.blue,
                  )
                : Container(),
          ],
        ),
        Text(
          widget.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: LinearProgressIndicator(
            backgroundColor: Colors.blue.withAlpha(50),
            value:
                widget.end > 0 ? _displayValue / widget.target.toDouble() : 0.0,
          ),
        ),
      ],
    );
  }
}

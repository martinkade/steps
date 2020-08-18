import 'package:flutter/material.dart';

class AnimatedProgressText extends StatefulWidget {
  ///
  final int start;

  ///
  final int end;

  ///
  final int target;

  ///
  final double fontSize;

  ///
  AnimatedProgressText(
      {Key key, this.start, this.end, this.target, this.fontSize = 32.0})
      : super(key: key);

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
  String _displayValue;

  @override
  void initState() {
    super.initState();

    _displayValue = widget.start.toString();
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

    _controller =
        AnimationController(duration: const Duration(seconds: 2), vsync: this);
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
        _displayValue = _animation.value.toStringAsFixed(0);
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          _displayValue,
          style: TextStyle(
            fontSize: widget.fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('/${widget.target}'),
        )
      ],
    );
  }
}

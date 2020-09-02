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
    with TickerProviderStateMixin {
  ///
  Animation<double> _animation;

  ///
  AnimationController _controller;

  ///
  double _displayValue;

  ///
  double _value;

  @override
  void initState() {
    super.initState();

    _value = 0.0;
    _displayValue = widget.start.toDouble();

    _startAnimation();
  }

  @override
  void didUpdateWidget(AnimatedProgressText oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.end != widget.end) {
      _startAnimation();
    }
  }

  void _startAnimation() async {
    if (_controller != null && _controller.isAnimating) {
      _controller.reset();
    }

    _controller = AnimationController(
        duration: Duration(seconds: widget.animated ? 1 : 0), vsync: this);
    _animation = Tween<double>(
            begin: _value == widget.end.toDouble()
                ? _value
                : widget.start.toDouble(),
            end: widget.end.toDouble())
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
    _animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _value = _animation.value;
      }
    });
    try {
      await _controller.forward().orCancel;
    } on TickerCanceled {}
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
            widget.end >= widget.target && (_animation?.isCompleted ?? true)
                ? Icon(
                    Icons.check_circle_outline,
                    size: 24.0,
                    color: Theme.of(context).colorScheme.primary,
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
            backgroundColor:
                Theme.of(context).colorScheme.primary.withAlpha(50),
            valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary),
            value:
                widget.end > 0 ? _displayValue / widget.target.toDouble() : 0.0,
          ),
        ),
      ],
    );
  }
}

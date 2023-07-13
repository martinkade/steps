import 'package:flutter/material.dart';

class RouteTransition extends PageRouteBuilder {
  ///
  final Widget page;

  ///
  final Widget Function(BuildContext)? builder;

  ///
  RouteTransition({required this.page, this.builder})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            final Curve curve = Curves.easeInOutCirc;
            final scaleTween = Tween<double>(
              begin: 0.5,
              end: 1.0,
            ).chain(
              CurveTween(curve: curve),
            );
            final fadeTween = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).chain(
              CurveTween(curve: curve),
            );
            return FadeTransition(
              opacity: animation.drive(fadeTween),
              child: ScaleTransition(
                scale: animation.drive(scaleTween),
                child: child,
              ),
            );
          },
        );
}

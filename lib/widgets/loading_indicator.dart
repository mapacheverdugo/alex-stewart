import 'package:asi/themes/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingIndicator extends StatelessWidget {
  final Color color;
  final AnimationController? controller;
  final EdgeInsetsGeometry padding;

  LoadingIndicator({
    this.color = const Color(MainTheme.PRIMARY_COLOR_VALUE),
    this.controller,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Center(
        child: Container(
          padding: padding,
          child: SpinKitDoubleBounce(
            controller: controller,
            color: color,
            size: 40.0,
          ),
        ),
      ),
    );
  }
}

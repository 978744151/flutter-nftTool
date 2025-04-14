// ignore: depend_on_referenced_packages
import 'package:flutter/material.dart';

import 'package:loading_indicator/loading_indicator.dart';

class LoadingIndicatorWidget extends StatelessWidget {
  final double size;
  final Indicator type;
  final List<Color> colors;

  const LoadingIndicatorWidget({
    super.key,
    this.size = 50,
    this.type = Indicator.lineSpinFadeLoader,
    this.colors = const [Colors.blue],
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: size,
        height: size,
        child: LoadingIndicator(
          indicatorType: type,
          strokeWidth: 2,
          colors: colors,
        ),
      ),
    );
  }
}

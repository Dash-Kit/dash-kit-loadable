import 'package:flutter/material.dart';

class Loadable extends StatelessWidget {
  const Loadable({
    @required this.child,
    @required this.isLoading,
    this.padding,
    this.backgroundColor = Colors.white,
    this.indicatorColor,
  })  : assert(child != null),
        assert(isLoading != null);

  final Widget child;
  final bool isLoading;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final Animation<Color> indicatorColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(child: child),
        Positioned.fill(child: _getLoadingWidget()),
      ],
    );
  }

  Widget _getLoadingWidget() {
    return Visibility(
      visible: isLoading,
      child: Container(
        padding: padding,
        color: backgroundColor,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: indicatorColor,
          ),
        ),
      ),
    );
  }
}

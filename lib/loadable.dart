import 'package:flutter/material.dart';

class Loadable extends StatelessWidget {
  const Loadable({
    @required this.child,
    @required this.isLoading,
    this.padding,
  });

  final Widget child;
  final bool isLoading;
  final EdgeInsetsGeometry padding;

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
        color: Colors.black54,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

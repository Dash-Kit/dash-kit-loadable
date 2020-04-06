import 'package:flutter/material.dart';

class BlockedLoadable extends StatelessWidget {
  const BlockedLoadable({
    @required this.child,
    @required this.isLoading,
    this.indicatorColor = Colors.white,
  })  : assert(child != null),
        assert(isLoading != null);

  final Widget child;
  final bool isLoading;
  final Color indicatorColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        child,
        Positioned.fill(
          child: Visibility(
            visible: isLoading,
            child: Container(
              color: Colors.black54,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

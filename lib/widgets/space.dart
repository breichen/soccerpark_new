import 'package:flutter/material.dart';

class Space extends StatelessWidget {
  final double _height;

  Space(this._height);

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: _height);
  }
}

class SpaceH extends StatelessWidget {
  final double _width;

  SpaceH(this._width);

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: _width);
  }
}

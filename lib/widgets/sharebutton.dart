import 'package:flutter/material.dart';

import '../utils/share.dart';

class DialogShareButton extends StatelessWidget {
  final GlobalKey globalKey;
  final String text;

  DialogShareButton(this.globalKey, this.text);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Icon(Icons.share, color: Colors.white, size: 24),
      onTap: () {
        share(globalKey, text);
      },
    );
  }
}

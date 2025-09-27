import 'package:flutter/material.dart';

class InvisibleScrollBarWidget extends ScrollBehavior {
  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
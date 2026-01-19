import 'package:flutter/cupertino.dart';

class ScaleUtils {
  static double scaleSize(double size, BuildContext context) =>
      size * sizeMaxWidth(context);
  // size * sizeMaxWidth(context) + (Responsive.isMobile(context) ? size * (MediaQuery.of(context).size.width > 1440.0 ? 1440.0 : MediaQuery.of(context).size.width) / 2880 : 0);
  static double sizeMaxWidth(BuildContext context) =>
      (MediaQuery.of(context).size.width > 1440
          ? 1440.0
          : MediaQuery.of(context).size.width) /
          1440.0;

  static double maxWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double scalePadding(double size, BuildContext context) =>
      size * sizeMaxWidth(context);
  // static double scalePadding(double size, BuildContext context) =>
  //     size * sizeMaxWidth(context) +
  //         (MediaQuery.of(context).size.width > 1440
  //             ? (MediaQuery.of(context).size.width - 1440) / 2
  //             : 0);
}

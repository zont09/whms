import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/scale_utils.dart';

class HoverText extends StatefulWidget {
  final String text;
  final Function() onTap;

  const HoverText({super.key, required this.text, required this.onTap});

  @override
  State<HoverText> createState() => _HoverTextState();
}

class _HoverTextState extends State<HoverText> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovering = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isHovering = false;
        });
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: Text(widget.text,
            style: TextStyle(
                height: 1,
                decorationColor: ColorConfig.primary1,
                decoration: _isHovering
                    ? TextDecoration.underline
                    : TextDecoration.none,
                fontWeight: FontWeight.w500,
                color: ColorConfig.primary1,
                fontSize: ScaleUtils.scaleSize(11, context))),
      ),
    );
  }
}
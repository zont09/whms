import 'package:flutter/material.dart';

class GradientText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final String? fontFamily;
  final TextAlign textAlign;
  final double lineHeight;
  final Gradient? gradient;

  const GradientText({
    super.key,
    required this.text,
    this.fontSize = 44,
    this.fontWeight = FontWeight.w700,
    this.fontFamily = 'SpaceGrotesk',
    this.textAlign = TextAlign.start,
    this.lineHeight = 1.5,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return (gradient ??
                const LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Color(0xFFB71C1C),
                    Color(0xFFA31417),
                    Color(0xFFE31E26),
                  ],
                  stops: [0.0, 0.2607, 0.5606],
                ))
            .createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height));
      },
      blendMode: BlendMode.srcIn,
      child: Text(
        text,
        textAlign: textAlign,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontFamily: fontFamily,
          height: lineHeight,
          color: Colors.white,
        ),
      ),
    );
  }
}

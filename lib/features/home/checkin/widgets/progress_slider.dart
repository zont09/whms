import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/scale_utils.dart';

class ProgressSlider extends StatefulWidget {
  final double initialValue;
  final ValueChanged<double> onChanged;

  const ProgressSlider({
    super.key,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<ProgressSlider> createState() => _ProgressSliderState();
}

class _ProgressSliderState extends State<ProgressSlider> {
  late double currentValue;

  @override
  void initState() {
    super.initState();
    currentValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        thumbShape: RoundSliderThumbShape(
          enabledThumbRadius: ScaleUtils.scaleSize(6, context), // Kích thước thumb
        ),
        overlayShape: RoundSliderOverlayShape(
          overlayRadius: ScaleUtils.scaleSize(12, context), // Kích thước overlay
        ),
        activeTrackColor: ColorConfig.slider, // Màu thanh đã kéo
        inactiveTrackColor: const Color(0xFFD9D9D9), // Màu thanh chưa kéo
        thumbColor: ColorConfig.slider, // Màu thumb
        overlayColor: ColorConfig.slider.withOpacity(0.2), // Màu overlay
        trackHeight: ScaleUtils.scaleSize(4, context), // Chiều cao của track
      ),
      child: Slider(
        value: currentValue,
        min: 0,
        max: 100,
        divisions: 100,
        label: '${currentValue.toInt()}%',
        onChanged: (value) {
          setState(() {
            currentValue = value;
          });
        },
        onChangeEnd: (value) {
          widget.onChanged(value); // Gọi hàm sự kiện khi thả slider
        },
      ),
    );
  }
}

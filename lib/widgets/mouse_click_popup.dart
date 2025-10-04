import 'package:flutter/material.dart';

class MouseClickPopup extends StatefulWidget {
  final Widget child;
  final Widget popup;
  final bool isShow;
  final double width;
  final double height;

  const MouseClickPopup({
    super.key,
    required this.child,
    required this.width,
    this.isShow = true,
    required this.popup,
    required this.height,
  });

  @override
  State<MouseClickPopup> createState() => _MouseClickPopupState();

  static GlobalKey<_MouseClickPopupState> popupKey = GlobalKey<_MouseClickPopupState>();

}

class _MouseClickPopupState extends State<MouseClickPopup> {
  OverlayEntry? _overlayEntry;
  double dx = 0;
  double dy = 0;

  @override
  void dispose() {
    removeOverlay();
    super.dispose();
  }

  void removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showOverlay(BuildContext context, Offset offset) {
    if (!widget.isShow) return;
    removeOverlay();

    final screenSize = MediaQuery.of(context).size;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        dx = offset.dx;
        dy = offset.dy;

        if (dx + widget.width > screenSize.width) {
          dx = screenSize.width - widget.width;
        }
        if (dy + widget.height  > screenSize.height) {
          dy = dy - widget.height - 10;
        }

        return Stack(
          children: [
            // Lắng nghe sự kiện click ngoài popup
            Positioned.fill(
              child: GestureDetector(
                onTap: () => removeOverlay(),
                behavior: HitTestBehavior.opaque,
                child: Container(),
              ),
            ),

            // Hiển thị popup
            Positioned(
              left: dx,
              top: dy + 12,
              width: widget.width,
              child: Material(
                color: Colors.transparent,
                child: widget.popup,
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);

  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (event) {
        _showOverlay(context, event.globalPosition);
      },
      child: widget.child,
    );
  }
}

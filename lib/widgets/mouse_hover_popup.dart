import 'package:flutter/material.dart';
import 'package:whms/untils/scale_utils.dart';

class MousePopup extends StatefulWidget {
  final Widget child;
  final Widget popupContent;
  final bool isShow;
  final double width;
  final Offset? mousePos;

  const MousePopup({
    Key? key,
    required this.child,
    required this.popupContent,
    required this.width,
    this.mousePos,
    this.isShow = true,
  }) : super(key: key);

  @override
  State<MousePopup> createState() => _MousePopupState();
}

class _MousePopupState extends State<MousePopup> {
  OverlayEntry? _overlayEntry;
  Offset? _mousePosition;
  final GlobalKey _popupKey = GlobalKey();
  double _popupHeight = 50;
  double dx = 0;
  double dy = 0;

  @override
  void didUpdateWidget(covariant MousePopup oldWidget) {
    if(oldWidget.mousePos != widget.mousePos) {
      setState(() {
        _mousePosition = widget.mousePos;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _getPopupSize() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final renderBox = _popupKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        setState(() {
          _popupHeight = renderBox.size.height;
        });
      }
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showOverlay(BuildContext context, Offset offset) {
    if (!widget.isShow) return;
    _removeOverlay();

    final screenSize = MediaQuery.of(context).size;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        dx = offset.dx;
        dy = offset.dy;

        if (dx + widget.width > screenSize.width) {
          dx = screenSize.width - widget.width;
        }
        if (dy + _popupHeight > screenSize.height) {
          dy = dy - _popupHeight - 10;
        }

        return Positioned(
          left: dx,
          top: dy + 10,
          width: widget.width,
          child: Material(
            color: Colors.transparent,
            child: Container(
              key: _popupKey,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(vertical: ScaleUtils.scaleSize(6, context), horizontal: ScaleUtils.scaleSize(12, context)),
              child: widget.popupContent,
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
    _getPopupSize(); // Gọi ngay sau khi insert Overlay
  }

  isMouseInPopup(Offset pos, BuildContext context) {
    final posR = Offset(dx + ScaleUtils.scaleSize(widget.width, context), dy + _popupHeight);
    return dx <= pos.dx && pos.dx <= posR.dx && dy <= pos.dy && pos.dy <= posR.dy;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) {
        setState(() => _mousePosition = event.position);
        _showOverlay(context, event.position);
      },
      onHover: (event) {
        if (_mousePosition != event.position) {
          setState(() => _mousePosition = event.position);
          _showOverlay(context, event.position);
        }
      },
      onExit: (_) {
        setState(() => _mousePosition = null);
        _removeOverlay();
      },
      child: widget.child,
    );
  }
}

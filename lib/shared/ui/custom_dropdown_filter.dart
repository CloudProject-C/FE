import 'package:campit_frontend/shared/constants/app_colors.dart';
import 'package:campit_frontend/shared/constants/app_text_styles.dart';
import 'package:flutter/material.dart';

class CustomDropdownFilter extends StatefulWidget {
  final String selected;
  final List<String> items;
  final Function(String) onSelected;

  const CustomDropdownFilter({
    super.key,
    required this.selected,
    required this.items,
    required this.onSelected,
  });

  @override
  State<CustomDropdownFilter> createState() => _CustomDropdownFilterState();
}

class _CustomDropdownFilterState extends State<CustomDropdownFilter> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool isOpen = false;

  void toggle() {
    if (isOpen) {
      close();
    } else {
      open();
    }
  }

  void open() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);

    setState(() => isOpen = true);
  }

  void close() {
    _overlayEntry?.remove();
    _overlayEntry = null;

    setState(() => isOpen = false);
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: (context) {
        return Positioned(
          width: size.width,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0, size.height + 6), // 아래로 살짝 띄움
            child: Material(
              color: Colors.transparent,
              child: _DropdownPanel(
                items: widget.items,
                onSelected: (value) {
                  widget.onSelected(value);
                  close();
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: toggle,
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.grey_4.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.selected,
                style: AppTextStyles.pretendard_regular.copyWith(
                  color: AppColors.grey_4,
                  fontSize: 14,
                ),
              ),
              Icon(
                isOpen
                    ? Icons.keyboard_arrow_up_rounded   // 열렸을 때
                    : Icons.keyboard_arrow_down_rounded, // 닫혔을 때
                color: AppColors.grey_4,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DropdownPanel extends StatelessWidget {
  final List<String> items;
  final Function(String) onSelected;

  const _DropdownPanel({
    required this.items,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.grey_4.withOpacity(0.2)),
      ),
      child: Column(
        children: items.map((e) {
          return GestureDetector(
            onTap: () => onSelected(e),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Text(
                e,
                style: AppTextStyles.pretendard_regular.copyWith(
                  color: AppColors.grey_4,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
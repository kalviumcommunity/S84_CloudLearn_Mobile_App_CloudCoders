import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DropdownField extends StatefulWidget {
  const DropdownField({
    super.key,
    required this.label,
    required this.items,
    required this.value,
    required this.onChanged,
    this.validator,
    this.focusNode,
  });

  final String label;
  final List<String> items;
  final String? value;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;

  @override
  State<DropdownField> createState() => _DropdownFieldState();
}

class _DropdownFieldState extends State<DropdownField> {
  late final FocusNode _focusNode;
  late final bool _isExternalFocusNode;

  @override
  void initState() {
    super.initState();
    _isExternalFocusNode = widget.focusNode != null;
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_focusListener);
  }

  void _focusListener() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_focusListener);
    if (!_isExternalFocusNode) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFocused = _focusNode.hasFocus;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withValues(alpha: isFocused ? 0.96 : 0.86),
        border: Border.all(
          color: isFocused
              ? const Color(0xFF8B5CF6)
              : const Color(0xFFF0E9FF),
          width: isFocused ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isFocused
                ? const Color(0x298B5CF6)
                : const Color(0x14000000),
            blurRadius: isFocused ? 24 : 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        initialValue: widget.value,
        focusNode: _focusNode,
        validator: widget.validator,
        isExpanded: true,
        borderRadius: BorderRadius.circular(16),
        icon: const Icon(Icons.keyboard_arrow_down_rounded),
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: GoogleFonts.poppins(
            color: const Color(0xFF6A5A89),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          floatingLabelStyle: GoogleFonts.poppins(
            color: const Color(0xFF7C3AED),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
        ),
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF2B1B4D),
        ),
        items: widget.items
            .map(
              (item) => DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              ),
            )
            .toList(),
        onChanged: widget.onChanged,
      ),
    );
  }
}

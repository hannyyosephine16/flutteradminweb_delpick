import 'package:flutter/material.dart';

import 'detailstext1.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String title;
  final IconData? icon, icon2;
  final double? height;
  final bool obscureText;
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final int? maxLines;

  const CustomTextField({
    super.key,
    required this.label,
    this.icon,
    this.icon2,
    this.height = 41,  // Set the default height to 41
    this.obscureText = false,
    this.controller,
    this.onChanged,
    required this.title,
    this.maxLines,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text1(text1: widget.title, size: 11),
              const Text1(text1: ' *', color: Colors.orange, size: 17),
            ],
          ),
          const SizedBox(height: 3),
          Container(
            height: widget.height,  // Use the specified or default height
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Colors.black38.withOpacity(0.2), width: 1),
            ),
            child: TextFormField(
              controller: widget.controller,
              onChanged: widget.onChanged,
              focusNode: _focusNode,
              obscureText: widget.obscureText,
              maxLines: widget.maxLines ?? 1,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 12),
                border: InputBorder.none,
                isDense: true,
                hintText: widget.label,
                hintStyle: const TextStyle(
                  color: Colors.black54,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: widget.icon != null ? Icon(widget.icon, color: Colors.black54) : null,
                suffixIcon: widget.icon2 != null ? Icon(widget.icon2, color: Colors.black54) : null,
              ),
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

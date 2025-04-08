import 'package:flutter/material.dart';

class Text1 extends StatelessWidget {
  final String text1;
  final double size;
  final Color color;
  final FontWeight fontWeight;

  const Text1({
    Key? key,
    required this.text1,
    this.size = 12,
    this.color = Colors.black54,
    this.fontWeight = FontWeight.normal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text1,
      style: TextStyle(
        fontSize: size,
        color: color,
        fontWeight: fontWeight,
      ),
    );
  }
}

class CustomTextField extends StatefulWidget {
  final String label;
  final String title;
  final IconData? icon, icon2;
  final double? height;
  final bool obscureText;
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final int? maxLines;
  final FocusNode? focusNode;
  final String? errorText;
  final TextInputType? keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;

  const CustomTextField({
    super.key,
    required this.label,
    this.icon,
    this.icon2,
    this.height = 48,  // Increased height for better touch targets
    this.obscureText = false,
    this.controller,
    this.onChanged,
    required this.title,
    this.maxLines,
    this.focusNode,
    this.errorText,
    this.keyboardType,
    this.readOnly = false,
    this.onTap,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late FocusNode _focusNode;
  bool _hasFocus = false;
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _obscureText = widget.obscureText;
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _hasFocus = _focusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.removeListener(_onFocusChange);
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text1(
                text1: widget.title,
                size: 13,
                fontWeight: FontWeight.w500,
              ),
              const Text1(
                text1: ' *',
                color: Colors.orange,
                size: 15,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            height: widget.height,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _hasFocus
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade300,
                width: 1.5,
              ),
              boxShadow: _hasFocus ? [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.15),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                )
              ] : null,
            ),
            child: TextFormField(
              controller: widget.controller,
              onChanged: widget.onChanged,
              focusNode: _focusNode,
              obscureText: _obscureText,
              maxLines: widget.maxLines ?? 1,
              keyboardType: widget.keyboardType,
              readOnly: widget.readOnly,
              onTap: widget.onTap,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                isDense: true,
                hintText: widget.label,
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: widget.icon != null
                    ? Icon(
                  widget.icon,
                  color: _hasFocus
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade500,
                  size: 20,
                )
                    : null,
                suffixIcon: widget.obscureText
                    ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey.shade500,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
                    : widget.icon2 != null
                    ? Icon(
                  widget.icon2,
                  color: Colors.grey.shade500,
                  size: 20,
                )
                    : null,
                errorText: widget.errorText,
              ),
              style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (widget.errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0, left: 12.0),
              child: Text(
                widget.errorText!,
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
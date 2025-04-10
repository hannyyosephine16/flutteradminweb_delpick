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

class CustomDropdown extends StatefulWidget {
  final String label;
  final String title;
  final IconData? icon, icon2;
  final double height;
  final List<String> items;
  final String? selectedItem;
  final void Function(String?)? onChanged;
  final String? errorText;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.title,
    required this.items,
    this.icon,
    this.icon2,
    this.height = 48, // Increased height for better touch targets
    this.selectedItem,
    this.onChanged,
    this.errorText,
  });

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  late FocusNode _focusNode;
  String? _currentSelectedItem;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _currentSelectedItem = widget.selectedItem;
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _hasFocus = _focusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
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
            child: DropdownButtonFormField<String>(
              focusNode: _focusNode,
              value: _currentSelectedItem,
              hint: Text(
                widget.label,
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                isDense: true,
                prefixIcon: widget.icon != null
                    ? Icon(
                  widget.icon,
                  color: _hasFocus
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade500,
                  size: 20,
                )
                    : null,
                suffixIcon: widget.icon2 != null
                    ? Icon(
                  widget.icon2,
                  color: Colors.grey.shade500,
                  size: 20,
                )
                    : null,
                errorText: widget.errorText,
              ),
              items: widget.items.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _currentSelectedItem = newValue;
                });
                if (widget.onChanged != null) {
                  widget.onChanged!(newValue);
                }
              },
              icon: const Icon(
                Icons.arrow_drop_down_rounded,
                color: Colors.grey,
                size: 26,
              ),
              isExpanded: true,
              style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              dropdownColor: Colors.white,
              elevation: 3,
              menuMaxHeight: 300,
            ),
          ),
        ],
      ),
    );
  }
}
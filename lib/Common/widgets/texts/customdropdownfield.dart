import 'package:flutter/material.dart';

import 'detailstext1.dart';


class CustomDropdown extends StatefulWidget {
  final String label;
  final String title;
  final IconData? icon, icon2;
  final double height;
  final List<String> items;
  final String? selectedItem;
  final void Function(String?)? onChanged;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.title,
    required this.items,
    this.icon,
    this.icon2,
    this.height = 41,
    this.selectedItem,
    this.onChanged,
  });

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  late FocusNode _focusNode;
  String? _currentSelectedItem;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _currentSelectedItem = widget.selectedItem ?? widget.items.first;
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
              const Text1(text1: ' *', color: Colors.orange,size: 17,),
            ],
          ),
          const SizedBox(height: 3),
          Container(
            height: widget.height,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Colors.black38.withOpacity(0.2), width: 1),
            ),
            child: DropdownButtonFormField<String>(
              focusNode: _focusNode,
              value: _currentSelectedItem,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 12),
                border: InputBorder.none,
                isDense: true,
                prefixIcon: widget.icon != null ? Icon(widget.icon, color: Colors.black54) : null,
                suffixIcon: widget.icon2 != null ? Icon(widget.icon2, color: Colors.black54) : null,
              ),
              items: widget.items.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: const TextStyle(color: Colors.black54, fontSize: 16, fontWeight: FontWeight.w400)),
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
              icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
              isExpanded: true,
              style: const TextStyle(color: Colors.black54, fontSize: 16, fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }
}

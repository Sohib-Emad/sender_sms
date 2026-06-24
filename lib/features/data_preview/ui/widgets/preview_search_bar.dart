import 'package:flutter/material.dart';

class PreviewSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const PreviewSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: controller,
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          hintText: 'بحث...',
          hintTextDirection: TextDirection.rtl,
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: onClear,
                )
              : null,
        ),
        onChanged: onChanged,
      ),
    );
  }
}

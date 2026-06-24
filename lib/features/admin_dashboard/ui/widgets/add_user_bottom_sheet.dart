import 'package:flutter/material.dart';
import 'add_user_form.dart';

class AddUserBottomSheet extends StatelessWidget {
  const AddUserBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24,
        left: 24,
        right: 24,
      ),
      child: const AddUserForm(),
    );
  }
}

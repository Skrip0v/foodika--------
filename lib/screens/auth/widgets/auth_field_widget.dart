import 'package:flutter/material.dart';
import 'package:foodika/style/app_colors.dart';

class AuthFieldWidget extends StatelessWidget {
  const AuthFieldWidget({
    super.key,
    required this.title,
    required this.controller,
    this.isHidePassword = false,
    this.keyboardType,
    this.suffix,
    this.onChanged,
  });

  final String title;
  final TextEditingController controller;
  final bool isHidePassword;
  final TextInputType? keyboardType;
  final Widget? suffix;
  final void Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.orange,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          cursorColor: const Color(0xFF6B6770),
          obscureText: isHidePassword,
          autocorrect: false,
          decoration: InputDecoration(
            isDense: true,
            suffixIcon: suffix,
            contentPadding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 17.5,
              bottom: 17.5,
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                color: Color(0xFFA19CA9),
                style: BorderStyle.solid,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.orange,
                style: BorderStyle.solid,
                width: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

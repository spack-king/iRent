import 'package:flutter/material.dart';

class TextFieldInput extends StatelessWidget {
  final TextEditingController textEditingController;
  final bool isPass;
  final bool enabled;
  final String hintText;
  final String labelText;
  final double? height;
  final IconData icon;
  final TextInputType textInputType;

  const TextFieldInput({Key? key,
    required this.textEditingController,
    this.isPass = false,
    this.enabled = true,
    this.height,
    required this.hintText,
    required this.labelText,
    required this.icon,
    required this.textInputType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
        borderSide: Divider.createBorderSide(context)
    );

    return TextField(
      enableSuggestions: true,
      controller: textEditingController,
      enabled: enabled,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        labelStyle: TextStyle(
          height: height,
            color: Colors.white
        ),
        border: inputBorder,
        focusedBorder: inputBorder,
        enabledBorder: inputBorder,
        filled: true,
        contentPadding: const EdgeInsets.all(8),

        prefixIcon: Icon(
          icon,
          color: Colors.grey,
        ),
      ),
      keyboardType: textInputType,
      obscureText: isPass,
    );
  }
}

//
// //then in your form use like this
// TextField(
// obscureText: _isObscure,
// decoration: InputDecoration(
// border: OutlineInputBorder(
// borderRadius: BorderRadius.circular(8.0),
// borderSide: BorderSide.none),
// filled: true,
// hintText: "Mot de passe",
// prefixIcon: Icon(
// Icons.lock,
// color: Color(0xfff28800),
// ),
// suffix: IconButton(
// padding: const EdgeInsets.all(0),
// iconSize: 20.0,
// icon: _isObscure
// ? const Icon(
// Icons.visibility_off,
// color: Colors.grey,
// )
//     : const Icon(
// Icons.visibility,
// color: Colors.black,
// ),
// onPressed: () {
// setState(() {
// _isObscure = !_isObscure;
// });
// },
// ),
// ),
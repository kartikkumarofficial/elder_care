import 'package:flutter/material.dart';


Widget socialLoginButton(String assetPath, VoidCallback onTap) {
  return SizedBox(
    width: 50,
    height: 50,
    child: ElevatedButton(
      onPressed: onTap,
      clipBehavior: Clip.hardEdge,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.zero,
      ),
      child: Image.asset(


        assetPath,
        width: 35,
        height: 35,
      ),
    ),
  );
}
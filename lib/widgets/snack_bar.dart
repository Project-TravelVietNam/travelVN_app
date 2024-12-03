import 'package:flutter/material.dart';

//sử dụng để hiển thị thông báo tạm thời
showSnackBar(BuildContext context, String text){
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
    ),
  );
}
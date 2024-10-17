import 'package:flutter/material.dart';
import 'app_color.dart';

class AppTheme {
  static final ligtTheme = ThemeData(
      primaryColor: AppColor.main,
      //màu cho ứng dụng
      scaffoldBackgroundColor: AppColor.light,
      //màu nền mặc định cho scaffold
      brightness: Brightness.light,
      //chỉnh chế độ tối hay sáng cho điện thoại
      fontFamily: 'Misans',
      elevatedButtonTheme: ElevatedButtonThemeData(
          //chỉnh sửa mặc định cho button
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.main,
              textStyle:
                  const TextStyle(
                    fontSize: 20, 
                    fontWeight: FontWeight.bold,
                    color: AppColor.light
                  ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)
                )
            )
        )
  );
  //drakTheme
  static final drakTheme = ThemeData(
      primaryColor: AppColor.main,
      //màu cho ứng dụng
      scaffoldBackgroundColor: AppColor.dark,
      //màu nền mặc định cho scaffold
      brightness: Brightness.dark,
      //chỉnh chế độ tối hay sáng cho điện thoại
      fontFamily: 'Misans',
      elevatedButtonTheme: ElevatedButtonThemeData(
          //chỉnh sửa mặc định cho button
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.main,
              textStyle:
                  const TextStyle(
                    fontSize: 20, 
                    fontWeight: FontWeight.bold,
                    color: AppColor.light),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)
                )
            )
        )
  );
}

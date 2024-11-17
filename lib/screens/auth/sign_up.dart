import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:travelvn/screens/auth/sign_in.dart';
import 'package:travelvn/screens/home.dart';
import 'package:travelvn/themes/app_color.dart';
import 'package:travelvn/widgets/snack_bar.dart';
import 'package:http/http.dart' as http;

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool isLoading = false;
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> addUser() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.post(
        Uri.parse('http://192.168.0.149:8800/v1/user/register'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': usernameController.text,
          'password': passwordController.text,
          'confirmPassword': confirmPasswordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        showSnackBar(context, data['message'] ?? 'Đăng ký thành công!');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        showSnackBar(context, 'Đăng ký thất bại: ${response.statusCode}');
      }
    } catch (e) {
      showSnackBar(context, 'Lỗi khi đăng ký: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SafeArea(
          child: ListView(
            children: [
              SizedBox(height: size.height * 0.03),
              const Text(
                "Đăng ký",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 36,
                  color: AppColor.main,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                "Hãy cùng TravelVietNam khám phá vẻ đẹp của đất nước Việt Nam",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, height: 1.2),
              ),
              SizedBox(height: size.height * 0.04),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  socialIcon("assets/images/facebook.png", "Facebook"),
                  socialIcon("assets/images/google.png", "Google"),
                ],
              ),
              SizedBox(height: size.height * 0.06),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 2,
                    width: size.width * 0.2,
                    color: Colors.black12,
                  ),
                  const Text(
                    "  Hoặc   ",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    height: 2,
                    width: size.width * 0.2,
                    color: Colors.black12,
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.06),
              buildTextField("Nhập username", usernameController, false),
              const SizedBox(height: 10),
              buildTextField("Mật khẩu", passwordController, true),
              const SizedBox(height: 10),
              buildTextField(
                  "Nhập lại mật khẩu", confirmPasswordController, true),
              SizedBox(height: size.height * 0.03),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: isLoading ? null : addUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.main,
                        minimumSize: const Size(200, 60),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(
                              color: AppColor.light)
                          : const Text(
                              "Tạo tài khoản",
                              style: TextStyle(
                                  fontSize: 22, color: AppColor.light),
                            ),
                    ),
                    SizedBox(height: size.height * 0.03),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Bạn đã có tài khoản",
                          style: TextStyle(fontSize: 16),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      const SignIn()),
                            );
                          },
                          child: const Text(
                            "Đăng nhập",
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColor.main,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //social button
  Container socialIcon(String image, String nameIcon) {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: (size.width - 60) / 2,
      padding: EdgeInsets.symmetric(
        vertical: 14,
        horizontal: size.width * 0.05,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColor.dark.withOpacity(0.1),
          width: 2,
        ),
        color: AppColor.light.withOpacity(0.1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            image,
            height: size.width * 0.08,
          ),
          const SizedBox(width: 8),
          Text(
            nameIcon,
            style: TextStyle(
              fontSize: size.width * 0.045,
            ),
          ),
        ],
      ),
    );
  }

  Container buildTextField(
      String hint, TextEditingController controller, bool isPassword) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !(isPassword == true ? isPasswordVisible : false),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          fillColor: AppColor.light,
          filled: true,
          border: OutlineInputBorder(
            borderSide: BorderSide(color: AppColor.dark),
            borderRadius: BorderRadius.circular(15),
          ),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black45, fontSize: 19),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.black45,
                  ),
                  onPressed: () {
                    setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:travelvn/screens/auth/sign_up.dart';
import 'package:travelvn/screens/home.dart';
import 'package:travelvn/themes/app_color.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool isPasswordVisible = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> signInUser() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://192.168.0.149:8800/v1/user/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': emailController.text,
          'password': passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final String token = data['token'];

        await saveToken(token);

        print('Đăng nhập thành công, token: $token');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        showError('Đăng nhập thất bại: ${response.statusCode}');
      }
    } catch (e) {
      showError('Lỗi khi đăng nhập: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
                "Đăng nhập",
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
              buildTextField("Nhập email", emailController, false),
              const SizedBox(height: 10),
              buildTextField("Mật khẩu", passwordController, true),
              const SizedBox(height: 10),
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "Quên mật khẩu?",
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(height: size.height * 0.04),
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: ElevatedButton(
                    onPressed: signInUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.main,
                      minimumSize: const Size(200, 60),
                    ),
                    child: const Text(
                      "Đăng nhập",
                      style: TextStyle(fontSize: 22, color: AppColor.light),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Container buildTextField(
      String hint, TextEditingController controller, bool isPassword) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !isPasswordVisible,
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

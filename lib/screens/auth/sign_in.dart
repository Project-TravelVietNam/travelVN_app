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
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool isPasswordVisible = false;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> loginUser() async {
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
          'username': usernameController.text,
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

  //Check đăng nhập
  Future<void> checkLoginStatus(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null) {
    // Nếu không có token, chuyển hướng về màn hình đăng nhập
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignIn()),
      );
    }
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
              SizedBox(height: size.height * 0.04),
              buildTextField("Nhập username", usernameController, false),
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
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: loginUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.main,
                          minimumSize: const Size(200, 60),
                        ),
                        child: const Text(
                          "Đăng nhập",
                          style: TextStyle(fontSize: 22, color: AppColor.light),
                        ),
                      ),
                      SizedBox(height: size.height * 0.04),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Bạn chưa có tài khoản?",
                              style: TextStyle(fontSize: 16)),
                          TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            SignUp()));
                              },
                              child: const Text("Đăng ký",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColor.main)))
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
    Size size = MediaQuery.of(context).size; // lấy size của màn hình
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

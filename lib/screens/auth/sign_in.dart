import 'package:flutter/material.dart';
import 'package:travelvn/screens/auth/sign_up.dart';
import 'package:travelvn/screens/home.dart';
import 'package:travelvn/service/auth.dart';
import 'package:travelvn/themes/app_color.dart';
import 'package:travelvn/widgets/snack_bar.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  void despose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  void signInUser() async {
    isLoading = true;
    String res = await AuthService().loginUser(
      email: emailController.text,
      password: passwordController.text,
    );
    //đăng ký thành công
    if (res == "Đăng nhập thành công!") {
      showSnackBar(context, res);
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomePage()));
    } else {
      //show errol
      showSnackBar(context, res);
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
            SizedBox(height: size.height * 0.06),
            // Nhập email
            buildTextField("Nhập email", emailController, false),
            const SizedBox(height: 10),
            // Nhập mật khẩu
            buildTextField("Mật khẩu", passwordController, true),
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                "Quên mật khẩu?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(height: size.height * 0.04),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                children: [
                  // for sign in button
                  ElevatedButton(
                      onPressed: () {
                        signInUser();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.main,
                          minimumSize: Size(200, 60)),
                      child: Text(
                        "Đăng nhập",
                        style: TextStyle(fontSize: 22, color: AppColor.light),
                      )),
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
                  )
                ],
              ),
            ),
          ],
        )),
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

  //input
  Container buildTextField(
      String hint, TextEditingController controller, bool isPassword) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 25,
        vertical: 10,
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword, // Ẩn văn bản nếu là mật khẩu
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 22,
          ),
          fillColor: AppColor.light,
          filled: true,
          border: OutlineInputBorder(
            borderSide: BorderSide(color: AppColor.dark),
            borderRadius: BorderRadius.circular(15),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColor.dark),
            borderRadius: BorderRadius.circular(15),
          ),
          hintText: hint,
          hintStyle: const TextStyle(
            color: Colors.black45,
            fontSize: 19,
          ),
          suffixIcon: isPassword
              ? const Icon(Icons.visibility_off_outlined, color: Colors.black45)
              : null,
        ),
      ),
    );
  }
}

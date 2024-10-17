import 'package:flutter/material.dart';
import 'package:travelvn/screens/onboarding_screen.dart';
import 'package:travelvn/themes/app_color.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    redirect();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColor.main,
      body: Center(
        child: Text(
          "TravelVietNam",
          style: TextStyle(
              fontSize: 36, fontWeight: FontWeight.bold, color: AppColor.light),
        ),
      ),
    );
  }

  Future<void> redirect() async {
    await Future.delayed(const Duration(seconds: 2));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (BuildContext context) => OnboardingView()), // Đảm bảo SignUp là một const constructor
    );
  }
}

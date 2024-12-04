import 'package:flutter/material.dart';
import 'package:travelvn/screens/auth/sign_in.dart';
import 'package:travelvn/screens/auth/sign_up.dart';
import 'package:travelvn/screens/home.dart';
import 'package:travelvn/themes/app_color.dart';
// import 'package:travelvn/screens/detail.dart';
// import 'package:travelvn/screens/details_Location.dart';
class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingView();
}

class _OnboardingView extends State<OnboardingView> {
  int currentIndex = 0;

  Widget dotIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      margin: const EdgeInsets.only(right: 6),
      width: currentIndex == index ? 30 : 15, //size dot
      height: 5,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: index == currentIndex ? Colors.white : Colors.white54,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //lấy size của màn hình
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          // PageView để chuyển đổi các màn hình
          PageView.builder(
            itemCount: onboarding.length,
            onPageChanged: (value) {
              setState(() {
                currentIndex = value;
              });
            },
            itemBuilder: (context, index) {
              return SizedBox(
                width: size.width,
                height: size.height,
                child: Image.asset(
                  onboarding[index].images,
                  fit: BoxFit.cover,
                ),
              );
            },
          ),
          //  "Skip" button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
            child: Column(
              children: [
                SizedBox(height: size.height * 0.07),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (currentIndex < onboarding.length - 1)
                      GestureDetector(
                        onTap: () {

                          // Navigator.pushAndRemoveUntil(
                          //   context,
                          //   MaterialPageRoute(builder: (_) => HomePage()),
                          //   (route) => false,
                          // );
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => SignUp()),
                            (route) => false,
                          );
                        },
                        // Navigator.pushAndRemoveUntil(
                        //       context,
                        //       MaterialPageRoute(
                        //         builder: (_) => const DetailsLocation(),
                        //       ),
                        //       (route) => false);               //Muốn chạy xem trang chi tiết thì mọi người mở cái này ra nha
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(builder: (_) => HomePage()),
                          // ); //nếu muốn chạy các trang khác thì có thể đóng trang home này nha
                        
                        //Styling cho nút skip
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.04,
                            vertical: size.height * 0.01,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColor.dark),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "Skip",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: AppColor.dark,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          // dot bnt
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: size.height * 0.35,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      onboarding.length,
                      dotIndicator,
                    ),
                  ),
                  SizedBox(height: size.height * 0.04),
                  
                  // "Get Started" (sắp xếp phần dưới màn hình từ text giới thiệu)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      height:
                          size.height * 0.30, // Chiều cao tổng là 30% màn hình
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        color: Colors.white,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 1),
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: _buildTextSpan(
                                    onboardingTexts[currentIndex]),
                              ),
                            ),
                            const SizedBox(height: 5),
                            const SizedBox(height: 20), // Added extra space between elements
                            Expanded(
                              flex: 4, // 40% height for button
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => SignUp()),
                                  );
                                },
                                child: Container(
                                  width: size.width * 0.8,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black12,
                                        offset: Offset(0, 5),
                                        spreadRadius: 15,
                                        blurRadius: 15,
                                      ),
                                    ],
                                    color: AppColor.blueLight,
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Text(
                                          "Hãy khám phá thôi nào!",
                                          style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(width: 5),
                                        Icon(
                                          Icons.arrow_forward,
                                          color: Colors.white,
                                          size: 25,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 15), // Extra spacing
                            Expanded(
                              flex: 4, // 20% height for login text
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Bạn đã có tài khoản?",
                                    style: TextStyle(fontSize: 18),
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
                                        fontSize: 18,
                                        color: AppColor.main,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Model class for onboarding screens (Quản lý các dữ liệu trong onboarding)
class OnboardingScreen {
  String images;

  OnboardingScreen({required this.images});
}

// List of onboarding screens
List<OnboardingScreen> onboarding = [
  OnboardingScreen(images: 'assets/images/start.png'),
  OnboardingScreen(images: 'assets/images/start1.jpg'),
  OnboardingScreen(images: 'assets/images/start2.png'),
  OnboardingScreen(images: 'assets/images/start3.jpg'),
];

// Danh sách văn bản tương ứng với các màn hình onboarding
List<String> onboardingTexts = [
  "Xin chào bạn, chúng mình là TravelVietNam",
  "Bạn đã khám phá hết vùng đất Việt Nam chưa?",
  "Nếu chưa hãy để chúng mình giúp bạn!",
  "TravelVietNam sẽ giúp bạn khám phá hết vẻ đẹp của đất nước Việt Nam"
];
//hàm chuyển đổi chữ
TextSpan _buildTextSpan(String text) {
  // Kiểm tra xem chuỗi có chứa "TravelVietNam" hay không
  if (text.contains("TravelVietNam")) {
    // Tách chuỗi thành 2 phần: trước và sau "TravelVietNam"
    List<String> parts = text.split("TravelVietNam");
    return TextSpan(
      children: [
        // Phần trước "TravelVietNam"
        TextSpan(
          text: parts[0],
          style: const TextStyle(
            color: Colors.black, // Màu đen cho phần còn lại
            fontSize: 24,
            fontWeight: FontWeight.w400,
          ),
        ),
        // "TravelVietNam" với màu khác
        TextSpan(
          text: "Travel",
          style: const TextStyle(
            color: AppColor.blueText, // Màu xanh cho "Travel"
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        TextSpan(
          text: "VietNam",
          style: const TextStyle(
            color: AppColor.red, // Màu xanh cho "Travel"
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        // Phần sau "TravelVietNam" (nếu có)
        TextSpan(
          text: parts.length > 1 ? parts[1] : '',
          style: const TextStyle(
            color: AppColor.dark, // Màu đen cho phần còn lại
            fontSize: 24,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
  // Nếu không chứa "TravelVietNam", trả về văn bản bình thường
  return TextSpan(
    text: text,
    style: const TextStyle(
      color: AppColor.dark,
      fontSize: 24,
      fontWeight: FontWeight.w400,
    ),
  );
}
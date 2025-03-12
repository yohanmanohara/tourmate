// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dots_indicator/dots_indicator.dart';
import '../screen/login.dart'; 

  // Image Paths
  class ImagesPath {
    static String kOnboarding1 = 'assets/images/onBoarding1.png';
    static String kOnboarding2 = 'assets/images/onBoarding2.png';
    static String kOnboarding3 = 'assets/images/onBoarding3.png';
  }

// Colors
class AppColor {
  static Color kPrimary = const Color(0XFF1460F2);
  static Color kWhite = const Color(0XFFFFFFFF);
  static Color kOnBoardingColor = const Color(0XFFFEFEFE);
  static Color kGrayscale40 = const Color(0XFFAEAEB2);
  static Color kGrayscaleDark100 = const Color(0XFF1C1C1E);
}

// Onboarding Model
class OnBoarding {
  String title;
  String description;
  String image;

  OnBoarding({
    required this.title,
    required this.description,
    required this.image,
  });
}

List<OnBoarding> onBoardinglist = [
  OnBoarding(
    title: ' Can be accessed from anywhere at any time',
    image: ImagesPath.kOnboarding1,
    description:
        'The essential language learning tools and resources you need to seamlessly transition into mastering a new language',
  ),
  OnBoarding(
      title: 'Offers a dynamic and interactive experience',
      image: ImagesPath.kOnboarding2,
      description:
          'Engaging features including tests, storytelling, and conversations that motivate and inspire language learners to unlock their full potential'),
  OnBoarding(
      title: "Experience the Premium Features wit App",
      image: ImagesPath.kOnboarding3,
      description:
          'Updated TalkGpt with premium materials anfective learning'),
];


// Onboarding Screen
class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _pageController1 = PageController(initialPage: 0);
  final PageController _pageController2 = PageController(initialPage: 0);
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.kOnBoardingColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Container(
            height: 10,
            width: 10,
            margin: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColor.kPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            flex: 5,
            child: PageView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: onBoardinglist.length,
                physics: const BouncingScrollPhysics(),
                controller: _pageController1,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return OnBoardingCard(
                    onBoardingModel: onBoardinglist[index],
                  );
                }),
          ),

          
          const SizedBox(height: 40),
          Center(
            child: DotsIndicator(
              dotsCount: onBoardinglist.length,
              position: _currentIndex.toDouble(),
              decorator: DotsDecorator(
                color: AppColor.kPrimary.withOpacity(0.4),
                size: const Size.square(8.0),
                activeSize: const Size(20.0, 8.0),
                activeShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                activeColor: AppColor.kPrimary,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            flex: 2,
            child: PageView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: onBoardinglist.length,
                physics: const BouncingScrollPhysics(),
                controller: _pageController2,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return OnboardingTextCard(
                    onBoardingModel: onBoardinglist[index],
                  );
                }),
          ),
          
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.only(left: 25, right: 23, bottom: 36),
            child: PrimaryButton(
              elevation: 0,
              onTap: () {
  if (_currentIndex == onBoardinglist.length - 1) {
    // Handle onboarding completion
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Login()),
    ); // <- Missing parenthesis added here
  } else {
    _pageController1.nextPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
    );
    _pageController2.nextPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
    );
  }
},

              text: _currentIndex == onBoardinglist.length - 1
                  ? 'Get Started'
                  : 'Next',
              bgColor: AppColor.kPrimary,
              borderRadius: 20,
              height: 46,
              width: 327,
              textColor: AppColor.kWhite,
            ),
          ),
        ],
      ),
    );
  }
}

// Onboarding Image Card
class OnBoardingCard extends StatelessWidget {
  final OnBoarding onBoardingModel;
  const OnBoardingCard({super.key, required this.onBoardingModel});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      onBoardingModel.image,
      height: 300,
      width: double.maxFinite,
      fit: BoxFit.fitWidth,
    );
  }
}

// Onboarding Text Card
class OnboardingTextCard extends StatelessWidget {
  final OnBoarding onBoardingModel;
  const OnboardingTextCard({required this.onBoardingModel, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 23),
      child: Column(
        children: [
          Text(
            onBoardingModel.title,
            textAlign: TextAlign.center,
           style: GoogleFonts.plusJakartaSans(
            fontSize: 24, 
          fontWeight: FontWeight.bold,
           color: AppColor.kGrayscaleDark100,
         ),

          ),
          const SizedBox(height: 16),
          Text(
            onBoardingModel.description,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColor.kGrayscale40,
            ),
          ),
        ],
      ),
    );
  }
}

// Primary Button
class PrimaryButton extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  final double? width;
  final double? height;
  final double borderRadius;
  final double? elevation;
  final Color textColor;
  final Color bgColor;

  const PrimaryButton({
    super.key,
    required this.onTap,
    required this.text,
    this.width,
    this.height,
    this.elevation = 5,
    this.borderRadius = 10,
    required this.textColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(color: textColor),
      ),
    );
  }
}

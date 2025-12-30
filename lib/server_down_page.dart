import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ServerDownPage extends StatelessWidget {
  const ServerDownPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Full-screen background animation
            SizedBox(
              width: screenWidth,
              height: screenHeight,
              child: Lottie.asset(
                'assets/lottie/background_animation.json', // add your background animation here
                fit: BoxFit.cover,
                repeat: true,
              ),
            ),

            // Foreground content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Main server down animation
                  SizedBox(
                   height: screenHeight * 0.45, // responsive size
                    child: Lottie.asset(
                      'assets/lottie/serverdown.json',
                      repeat: true,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    "Server Down",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "We are facing some technical issues at the moment, please try again later.",
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color.fromARGB(255, 52, 52, 52),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

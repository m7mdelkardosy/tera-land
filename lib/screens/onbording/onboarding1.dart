import 'package:flutter/material.dart';

class Onboarding1 extends StatelessWidget {
  const Onboarding1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsetsGeometry.all(35),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image(image: AssetImage('assets/images/bulding.png')),
                ),
              ),
              
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(height: 120, width: 100,
                  color: Colors.transparent,
                    child: Image(image: AssetImage('assets/images/logo.png'))),
                 SizedBox(width: 0,),
                  Text(
                    'أركان',
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'kofi',
                      fontSize: 50,
                    ),
                  ),
                
                ],
                
              ),
              
              Text(
                'تحكم كامل في الأراضي ',
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'ibm',
                  fontSize: 37,
                ),
              ),
              // SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(padding: EdgeInsetsGeometry.only(left: 20)),
                  Text(
                    'بكل سهولة ',
                    style: TextStyle(
                      fontFamily: 'ibm',
                      foreground: Paint()
                        ..shader = LinearGradient(
                          colors: [
                            const Color.fromARGB(255, 0, 125, 209),
                            const Color.fromARGB(255, 0, 188, 212),
                          ],
                        ).createShader(Rect.fromLTWH(0, 5, 200, 70)),
          
                      
                      fontSize: 34,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 50),
              Text(
                '.إداراة الأراضي والمناطق بشكل منظم وسريع',
                style: TextStyle(
                  // color: const Color.fromARGB(200, 96, 125, 139),
                  fontFamily: 'Cairo',
                  fontSize: 15,
                    foreground: Paint()
                        ..shader = LinearGradient(
                          colors: [
                            const Color(0xFFB0B0B0),
                            const Color(0xFF505050),
                          ],
                        ).createShader(Rect.fromLTWH(25, 15, 300, 70)),
          
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

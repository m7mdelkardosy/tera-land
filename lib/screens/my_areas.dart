import 'package:arkan_app/screens/add_area.dart';
import 'package:arkan_app/services/navigation.dart';
import 'package:arkan_app/shared/gridpainter.dart';
import 'package:arkan_app/shared/themes/colors.dart';
import 'package:flutter/material.dart';

class MyAreas extends StatelessWidget {
  const MyAreas({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 208, 235, 228),
          // appBar: AppBar(),
          body: Container(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    color: Colors.white70,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(size: Size.infinite, painter: GridPainter()),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(60, 210, 239, 253),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.query_stats_outlined,
                          color: Colors.blue,
                          size: 50,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'لم تتم إضافة مناطق حتى الان ',
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Din',
                    color: mainTxt,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'ابدء بمتابعة المناطق عن طريق إضافة أول منطقة لك',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Cairo',
                    color: Colors.blueGrey,
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: 250,
                  height: 60,
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: ElevatedButton.icon(
                      onPressed: () {  goTo(context, AddArea());},
                      icon: Icon(
                        Icons.add_circle_outline,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: Text(
                        'إضافة منطقة ',
                        style: TextStyle(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          fontFamily: 'Cairo',
                        ),
                      ),

                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                          const Color.fromARGB(255, 84, 108, 116),
                        ),
                        shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(15),
                          ),
                        ),
                        // padding:WidgetStatePropertyAll(EdgeInsets.all(10))
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

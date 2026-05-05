import 'package:arkan_app/services/area_service.dart';
import 'package:arkan_app/shared/themes/app_bar.dart';
import 'package:arkan_app/shared/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:arkan_app/shared/areatextfield.dart' hide FormField;
// import 'package:cloud_firestore/cloud_firestore.dart';

class AddArea extends StatelessWidget {
  AddArea({super.key});
  final TextEditingController nameee = TextEditingController();
  final AreaService areaService = AreaService();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Scaffold(
            appBar: const CustomAppBar(),
            backgroundColor: backgrround,
            body: SizedBox(
              height: double.infinity,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 15, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'إضافة منطقة جديدة ',
                      style: TextStyle(
                        fontSize: 30,
                        fontFamily: 'Din',

                        color: mainTxt,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'أكتب اسم المنطقة التى تريد إضافتها',
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Cairo',
                        color: Colors.blueGrey,
                      ),
                    ),
                    SizedBox(height: 25),
                    MyFormField(
                      hinttt: 'مثال : شمال الواحة',
                      controller: nameee,
                    ),
                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            areaService.submitArea(
                              controller: nameee,
                              context: context,
                            );
                          },
                          icon: Icon(
                            Icons.add_circle_outline,
                            color: Colors.white,
                            size: 20,
                          ),
                          label: Text(
                            'إضافة منطقة ',
                            style: TextStyle(
                              fontSize: 20,
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
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

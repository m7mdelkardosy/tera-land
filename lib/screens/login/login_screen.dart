import 'package:arkan_app/screens/imports.dart';
import 'package:arkan_app/services/auth_service.dart';
import 'package:arkan_app/shared/themes/textfield.dart' show MyTextField;
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:awesome_dialog/awesome_dialog.dart';
// import 'package:arkan_app/services/navigation.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isObscure = true;
  var formkey = GlobalKey<FormState>();
  var passwordNode = FocusNode();
  var emailNode = FocusNode();
  var email = TextEditingController();
  var password = TextEditingController();
  final RegExp emailReg = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: const Color.fromARGB(255, 208, 235, 228),
            body: SingleChildScrollView(
              child: Form(
                key: formkey,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 60, 25, 25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'مرحبا بعودتك ! \n لقد افتقدناك كثيرًا',

                            style: TextStyle(
                              fontSize: 25,
                              color: const Color.fromARGB(255, 14, 19, 44),
                              fontFamily: 'ibm',
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    MyTextField(
                      controller: email,
                      focusNode: emailNode,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (value) {
                        FocusScope.of(context).requestFocus(passwordNode);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return ' خانة الايميل فارغة ';
                        }
                        RegExp emailReg = RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        );

                        if (!emailReg.hasMatch(value)) {
                          return 'البريد الالكتروني غير صحيح';
                        }
                        return null;
                      },
                      Ktype: TextInputType.emailAddress,
                      IsPassword: false,
                      isObscure: false,
                      hintt: 'البريد الإلكتروني',
                      icona: Icon(Icons.email_outlined),
                    ),
                    SizedBox(height: 25),
                    MyTextField(
                      controller: password,
                      focusNode: passwordNode,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return ' خانة كلمة المرور فارغة ';
                        }
                      },
                      textInputAction: TextInputAction.done,
                      Ktype: TextInputType.text,
                      IsPassword: true,
                      isObscure: isObscure,
                      hintt: ' كلمة المرور',
                      icona: IconButton(
                        icon: Icon(
                          isObscure ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            isObscure = !isObscure;
                          });
                        },
                      ),
                    ),

                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        TextButton(
                          onPressed: () {},
                          child: Text('نسيت كلمة المرور '),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: 250,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () {
                          if (formkey.currentState!.validate()) {
                            FocusScope.of(context).requestFocus(FocusNode());
                            Auth().userLogin(
                              email: email.text,
                              password: password.text,
                              context: context,
                            );
                          }
                        },
                        child: Text(
                          'تسجيل الدخول',
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
                    SizedBox(height: 25),
                    SizedBox(
                      width: 290,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Divider(
                              height: 9,
                              thickness: 0.5,
                              color: Colors.blueGrey,
                            ),
                          ),
                          Text(
                            'أو المتابعة بإستخدام ',
                            style: TextStyle(
                              fontSize: 10,
                              fontFamily: 'Cairo',
                              color: Colors.blueGrey,
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              height: 9,
                              thickness: 0.5,
                              color: Colors.blueGrey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 30,
                          width: 130,
                          child: Directionality(
                            textDirection: TextDirection.ltr,
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: Image.asset(
                                'assets/images/1.png',
                                width: 25,
                              ),
                              label: Text(
                                'جوجل',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontFamily: 'Cairo',
                                  color: const Color.fromARGB(255, 14, 19, 44),
                                ),
                              ),
                              style: ButtonStyle(
                                shape: WidgetStatePropertyAll(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadiusGeometry.circular(
                                      11,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 20),
                        SizedBox(
                          height: 30,
                          width: 130,
                          child: Directionality(
                            textDirection: TextDirection.ltr,
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: Image.asset(
                                'assets/images/apple.png',
                                width: 25,
                              ),
                              label: Text(
                                'أبل',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontFamily: 'Cairo',
                                  color: const Color.fromARGB(255, 14, 19, 44),
                                ),
                              ),
                              style: ButtonStyle(
                                shape: WidgetStatePropertyAll(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadiusGeometry.circular(
                                      11,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Text(
                            'لا تملك حسابًا حتى الان ؟',
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'cairo',
                              color: Colors.blueGrey,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignupScreen(),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: Text(
                              'انشاء حساب',
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'cairo',
                                color: const Color.fromARGB(255, 38, 57, 66),
                              ),
                            ),
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

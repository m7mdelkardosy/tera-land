import 'package:arkan_app/screens/imports.dart';
import 'package:arkan_app/services/auth_service.dart';
import 'package:arkan_app/shared/themes/textfield.dart' show MyTextField;
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool isObscure = true;
  var email = TextEditingController();
  var password = TextEditingController();
  var name = TextEditingController();
  var formkey = GlobalKey<FormState>();
  var passwordNode = FocusNode();
  var emailNode = FocusNode();
  var nameNode = FocusNode();
  bool isButtonEnabled = false;
  final RegExp passwordReg = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&]).{8,}$',
  );
  final RegExp emailReg = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  @override
  void initState() {
    super.initState();

    name.addListener(updateButtonState);
    email.addListener(updateButtonState);
    password.addListener(updateButtonState);
  }

  void updateButtonState() {
    setState(() {
      isButtonEnabled =
          name.text.isNotEmpty &&
          email.text.isNotEmpty &&
          password.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();

    nameNode.dispose();
    emailNode.dispose();
    passwordNode.dispose();

    super.dispose();
  }

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
                    Image(image: AssetImage('assets/images/log.png')),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 2, 25, 25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // Text(
                          //   'مرحبا بعودتك ! \n لقد افتقدناك كثيرًا',

                          //   style: TextStyle(
                          //     fontSize: 25,
                          //     color: const Color.fromARGB(255, 14, 19, 44),
                          //     fontFamily: 'ibm',
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                    SizedBox(height: 5),
                    MyTextField(
                      controller: name,
                      focusNode: nameNode,
                      textInputAction: TextInputAction.next,

                      onFieldSubmitted: (value) {
                        FocusScope.of(context).requestFocus(emailNode);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return ' خانة الاسم فارغة ';
                        }
                        return null;
                      },
                      Ktype: TextInputType.text,
                      IsPassword: false,
                      isObscure: false,
                      hintt: 'اسمك ',
                      icona: Icon(Icons.person_2_outlined),
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
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return ' خانة كلمة المرور فارغة ';
                        }
                        if (value.length < 8) {
                          return 'كلمة المرور يجب ان تكون 8 أحرف على الأقل';
                        }

                        if (!passwordReg.hasMatch(value)) {
                          return 'يجب أن تحتوي على حروف وأرقام ورموز';
                        }
                        return null;
                      },
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
                        //   TextButton(
                        //     onPressed: () {},
                        //     child: Text('نسيت كلمة المرور '),
                        //   ),
                      ],
                    ),
                    // SizedBox(height: 5),
                    SizedBox(
                      width: 250,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: isButtonEnabled
                            ? () {
                                if (formkey.currentState!.validate()) {
                                  Auth().createUserByEmail(
                                    name: name.text,
                                    email: email.text,
                                    password: password.text,
                                    
                                  );
                                }
                              }
                            : null,
                        child: Text(
                          'أنشيء حسابي ',
                          style: TextStyle(
                            color: const Color.fromARGB(255, 255, 255, 255),
                            fontFamily: 'Cairo',
                            fontSize: 18,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isButtonEnabled
                              ? const Color(0xff546C74)
                              : const Color.fromARGB(255, 41, 74, 85),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        // padding:WidgetStatePropertyAll(EdgeInsets.all(10))
                      ),
                    ),

                    SizedBox(height: 20),
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
                            'لديك حساب بالفعل ؟',
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
                                builder: (context) => LoginScreen(),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: Text(
                              'تسجيل الدخول ',
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

import 'package:arkan_app/services/land_service.dart';
import 'package:arkan_app/shared/areatextfield.dart';
import 'package:arkan_app/shared/themes/colors.dart';
import 'package:flutter/material.dart';

class AddLands extends StatefulWidget {
  final String areaId;
  final String areaName;
  final Map<String, dynamic>? landData;
  AddLands({
    super.key,
    required this.areaId,
    required this.areaName,
    this.landData,
  });

  @override
  State<AddLands> createState() => _AddLandsState();
}

class _AddLandsState extends State<AddLands> {
  final TextEditingController address = TextEditingController();
  final TextEditingController level = TextEditingController();
  final TextEditingController landNum = TextEditingController();
  final TextEditingController size = TextEditingController();
  final TextEditingController owner = TextEditingController();
  final TextEditingController paid = TextEditingController();
  final TextEditingController offer = TextEditingController();

  @override
  void initState() {
    super.initState();

    // 🟡 Fill data if editing
    if (widget.landData != null) {
      address.text = widget.landData!['address'] ?? '';
      level.text = widget.landData!['level'] ?? '';
      landNum.text = widget.landData!['landNum'] ?? '';
     size.text = widget.landData!['size'] ?? '';
     owner.text = widget.landData!['owner'] ?? '';
      paid.text = widget.landData!['paid'] ?? '';
      offer.text = widget.landData!['offer'] ?? '';
    }
  }

  Future<void> saveData() async {
    if (address.text.isEmpty || landNum.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("من فضلك املأ البيانات المطلوبة")),
      );
      return;
    }

    if (widget.landData == null) {
      // 🟢 ADD
      await LandService.addLand(
        areaId: widget.areaId,
        areaName: widget.areaName,
        address: address.text,
        level: level.text,
        landNum: landNum.text,
        size: size.text,
        owner: owner.text,
        paid: paid.text,
        offer: offer.text,
      );
    } else {
      // 🟡 EDIT
      await LandService.updateLand(
        areaId: widget.areaId,
        landId: widget.landData!['id'],
        address: address.text,
        level: level.text,
        landNum: landNum.text,
        size: size.text,
        owner: owner.text,
        paid: paid.text,
        offer: offer.text,
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.landData == null
              ? "تم حفظ البيانات بنجاح"
              : "تم تعديل البيانات بنجاح",
        ),
      ),
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: backgrround,
          body: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 15, 0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'بيان القطعة',
                      style: TextStyle(
                        fontSize: 22,
                        fontFamily: 'Din',
                        color: mainTxt,
                      ),
                    ),

                    SizedBox(height: 10),

                    Text(
                      'أدخل تفاصيل القطعة التى تريد إضافتها',
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Cairo',
                        color: Colors.blueGrey,
                      ),
                    ),

                    SizedBox(height: 20),

                    Text(
                      ' الحي أو المسلسل',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'ibm',
                        color: mainTxt,
                      ),
                    ),
                    SizedBox(height: 5),
                    MyFormField(
                      hinttt: 'مثال : حي أول مجاورة 5',
                      controller: address,
                    ),

                    SizedBox(height: 10),
                    Text(
                      'المرحلة ',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'ibm',
                        color: mainTxt,
                      ),
                    ),
                    SizedBox(height: 5),
                    MyFormField(
                      hinttt: 'مثال : المرحلة العاشرة',
                      controller: level,
                    ),

                    SizedBox(height: 10),
                    Text(
                      'رقم القطعة',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'ibm',
                        color: mainTxt,
                      ),
                    ),
                    SizedBox(height: 5),
                    MyFormField(hinttt: 'مثال : 104', controller: landNum),

                    SizedBox(height: 10),
                    Text(
                      'مساحة القطعة',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'ibm',
                        color: mainTxt,
                      ),
                    ),
                    SizedBox(height: 5),
                    MyFormField(hinttt: 'مثال : 450 م²', controller: size),

                    SizedBox(height: 10),
                    Text(
                      'الملكية ',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'ibm',
                        color: mainTxt,
                      ),
                    ),
                    SizedBox(height: 5),
                    MyFormField(
                      hinttt: 'مثال : أصيل ، توكيل',
                      controller: owner,
                    ),

                    SizedBox(height: 10),
                    Text(
                      'المدفوع ',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'ibm',
                        color: mainTxt,
                      ),
                    ),
                    SizedBox(height: 5),
                    MyFormField(hinttt: 'مثال : 16313', controller: paid),

                    SizedBox(height: 10),
                    Text(
                      'الأوفر ',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'ibm',
                        color: mainTxt,
                      ),
                    ),
                    SizedBox(height: 5),
                    MyFormField(hinttt: 'مثال : 3 مليون', controller: offer),

                    SizedBox(height: 15),

                    Center(
                      child: ElevatedButton.icon(
                        onPressed: saveData,
                        icon: const Icon(Icons.save, color: Colors.white),
                        label: Text(
                          widget.landData == null
                              ? "حفظ البيانات"
                              : "تعديل البيانات",
                          style: const TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff546C74),
                          padding: const EdgeInsets.all(20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
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

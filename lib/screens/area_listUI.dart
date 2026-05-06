import 'package:arkan_app/screens/add_area.dart';
import 'package:arkan_app/screens/imports.dart';
import 'package:arkan_app/screens/land_listview.dart';
import 'package:arkan_app/services/navigation.dart';
// import 'package:arkan_app/services/notification.dart';
import 'package:arkan_app/services/notification_badge.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:arkan_app/shared/themes/colors.dart';

class AreaList extends StatelessWidget {
  const AreaList({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: backgrround,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(55),
          child: Material(
            elevation: 8,
            shadowColor: Colors.black.withOpacity(0.3),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              child: AppBar(
                backgroundColor: const Color(0xFF1F3F45),
                elevation: 0, // مهم عشان مايبقاش فيه double shadow
                leading: const NotificationBadge(),
                actions: [
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 8.0)),
                  Builder(
                    builder: (context) {
                      return IconButton(
                        icon: const Icon(
                          Icons.menu,
                          color: Colors.white,
                          size: 26,
                        ),
                        onPressed: () {
                          Scaffold.of(context).openEndDrawer();
                        },
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ),
        endDrawer: const AppDrawer(),
        body: SafeArea(
          child: Column(
            children: [
              /// HEADER
              Padding(
                padding: const EdgeInsets.all(12),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Collec_Areas')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const SizedBox(height: 40),

                            const Text(
                              "جاري تحميل البيانات...",
                              style: TextStyle(
                                color: Colors.grey,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final areas = snapshot.data!.docs;
                    // --------------------------------------
                    String getAreasCountText(int count) {
                      if (count == 1) {
                        return 'منطقة واحدة';
                      } else if (count == 2) {
                        return 'منطقتين';
                      } else if (count >= 3 && count <= 10) {
                        return '$count مناطق';
                      } else {
                        return '$count منطقة';
                      }
                    }
                    // ---------------------------------------

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'جميع المناطق',
                          style: TextStyle(fontSize: 20, fontFamily: 'Din'),
                        ),
                        Text(
                          getAreasCountText(areas.length),
                          style: const TextStyle(
                            color: const Color(0xFF1F3F45),
                            fontSize: 18,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              /// LIST
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Collec_Areas')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final areas = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: areas.length,
                      itemBuilder: (context, index) {
                        final doc = areas[index];
                        final data = doc.data() as Map<String, dynamic>;

                        return InkWell(
                          onTap: () {
                            goTo(
                              context,
                              LandListView(
                                areaId: doc.id,
                                areaName: data['name'] ?? '',
                              ),
                            );
                          },

                          onLongPress: () {
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.warning,
                              animType: AnimType.leftSlide,
                              title: 'حذف',
                              desc: 'سيتم حذف البيان ',
                              btnCancelOnPress: () {},
                              btnOkOnPress: () async {
                                await FirebaseFirestore.instance
                                    .collection('Collec_Areas')
                                    .doc(doc.id)
                                    .delete();
                              },
                            ).show();
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(color: Colors.black12, blurRadius: 5),
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data['name'] ?? '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),

                                      const SizedBox(height: 6),

                                      /// 🔥 LIVE COUNT OF LANDS
                                      StreamBuilder<QuerySnapshot>(
                                        stream: FirebaseFirestore.instance
                                            .collection('Collec_Areas')
                                            .doc(doc.id)
                                            .collection('Lands')
                                            .snapshots(),
                                        builder: (context, snap) {
                                          final count =
                                              snap.data?.docs.length ?? 0;

                                          return Text(
                                            "$count أرض",
                                            style: const TextStyle(
                                              color: Colors.grey,
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),

                                const Icon(Icons.arrow_forward_ios, size: 16),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              /// BUTTON
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      goTo(context, AddArea());
                    },
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'إضافة منطقة',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff546C74),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

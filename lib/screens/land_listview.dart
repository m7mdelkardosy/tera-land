import 'dart:async';
import 'package:arkan_app/screens/add_lands.dart';
import 'package:arkan_app/services/land_service.dart';
import 'package:arkan_app/shared/themes/app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:arkan_app/shared/themes/colors.dart';
import 'package:intl/intl.dart' as intl;

class Land {
  final String id;
  final String landNum;
  final String address;
  final String? level;
  final double? landSize;
  final String? landOwner;
  final String? offer;
  final String? paid;
  final String? createdBy;
  final Timestamp? createdAt;

  Land({
    required this.id,
    required this.landNum,
    required this.address,
    this.level,
    this.landSize,
    this.landOwner,
    this.offer,
    this.paid,
    this.createdBy,
    this.createdAt,
  });
}

class LandCard extends StatefulWidget {
  final String areaId;
  final String areaName;
  final String? initialSearch;

  const LandCard({
    super.key,
    required this.areaId,
    required this.areaName,
    this.initialSearch,
  });

  @override
  State<LandCard> createState() => _LandCardState();
}

class _LandCardState extends State<LandCard> {
  final TextEditingController controller = TextEditingController();
  final ValueNotifier<List<Land>> filteredNotifier = ValueNotifier([]);

  List<Land> allLands = [];
  Timer? debounce;

  String sortType = 'newest';
  bool showMyLandsOnly = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialSearch != null && widget.initialSearch!.isNotEmpty) {
      controller.text = widget.initialSearch!;
    }
  }

  @override
  void dispose() {
    debounce?.cancel();
    controller.dispose();
    filteredNotifier.dispose();
    super.dispose();
  }

  Query getLandsQuery() {
    Query query = FirebaseFirestore.instance
        .collection('Collec_Areas')
        .doc(widget.areaId)
        .collection('Lands');

    final user = FirebaseAuth.instance.currentUser;

    if (showMyLandsOnly && user != null) {
      query = query.where('createdBy', isEqualTo: user.uid);
    }

    if (sortType == 'newest') {
      query = query.orderBy('createdAt', descending: true);
    } else {
      query = query.orderBy('createdAt', descending: false);
    }

    return query;
  }

  String normalizeArabic(String text) {
    return text
        .replaceAll("أ", "ا")
        .replaceAll("إ", "ا")
        .replaceAll("آ", "ا")
        .replaceAll("ة", "ه")
        .replaceAll("ى", "ي")
        .replaceAll("ؤ", "و")
        .replaceAll("ئ", "ي")
        .replaceAll("ء", "")
        .replaceAll(RegExp(r'[\u064B-\u0652]'), '')
        .replaceAll("التالت", "الثالث")
        .replaceAll("تالت", "ثالث")
        .replaceAll("الثالث", "ثالث")
        .trim()
        .toLowerCase();
  }

  void filter(String rawQuery) {
    final q = normalizeArabic(rawQuery.trim());
    final bool isExactSearch = rawQuery.endsWith(' ');

    if (q.isEmpty) {
      filteredNotifier.value = List.from(allLands);
      return;
    }

    final queryWords = q
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();

    filteredNotifier.value = allLands.where((land) {
      final combined =
          "${land.landOwner ?? ''} ${land.paid ?? ''} ${land.offer ?? ''} "
          "${land.address} ${land.level ?? ''} ${land.landSize ?? ''} ${land.landNum}";

      final normalizedText = normalizeArabic(combined);

      if (isExactSearch) {
        final textWords = normalizedText.split(RegExp(r'\s+'));
        return queryWords.every((word) => textWords.contains(word));
      } else {
        return queryWords.every((word) => normalizedText.contains(word));
      }
    }).toList();
  }

  void onSearchChanged(String value) {
    if (debounce?.isActive ?? false) debounce!.cancel();
    debounce = Timer(const Duration(milliseconds: 250), () {
      filter(value);
    });
  }

  void clearSearch() {
    controller.clear();
    filter('');
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: backgrround,
        appBar: CustomAppBar(
          titleBar: Text(
            widget.areaName,
            style: const TextStyle(fontFamily: 'Din', color: Colors.white),
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: getLandsQuery().snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("لم تتم إضافة أراضي حتى الآن"),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddLands(
                            areaId: widget.areaId,
                            areaName: widget.areaName,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        "إضافة قطعة أرض",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff546C74),
                      ),
                    ),
                  ],
                ),
              );
            }

            allLands = snapshot.data!.docs.map((doc) {
              final Map<String, dynamic> data =
                  doc.data() as Map<String, dynamic>;
              return Land(
                id: doc.id,
                landNum: data['landNum']?.toString() ?? '',
                address: data['address']?.toString() ?? '',
                level: data['level']?.toString(),
                landSize: (data['landSize'] ?? 0).toDouble(),
                paid: data['paid']?.toString(),
                offer: data['offer']?.toString(),
                landOwner: data['landOwner']?.toString(),
                createdBy: data['createdBy']?.toString(),
                createdAt: data['createdAt'] as Timestamp?,
              );
            }).toList();

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                filter(controller.text);
              }
            });

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: controller,
                    onChanged: onSearchChanged,
                    decoration: InputDecoration(
                      hintText: "بحث ... ",
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: controller.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: clearSearch,
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DropdownButton<String>(
                        value: sortType,
                        items: const [
                          DropdownMenuItem(
                            value: 'newest',
                            child: Text("الأحدث"),
                          ),
                          DropdownMenuItem(
                            value: 'oldest',
                            child: Text("الأقدم"),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            sortType = value!;
                          });
                        },
                      ),
                      Row(
                        children: [
                          Text(
                            "أراضي بواسطتي",
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              color: showMyLandsOnly
                                  ? const Color(0xFF1F3F45)
                                  : Colors.black,
                              fontWeight: showMyLandsOnly
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          Switch(
                            thumbColor: WidgetStateProperty.resolveWith<Color>((
                              states,
                            ) {
                              if (states.contains(WidgetState.selected)) {
                                return const Color(0xFF1F3F45);
                              }
                              return Colors.white;
                            }),
                            trackColor: WidgetStateProperty.resolveWith<Color>((
                              states,
                            ) {
                              if (states.contains(WidgetState.selected)) {
                                return const Color(0xFF1F3F45).withOpacity(0.4);
                              }
                              return Colors.grey.shade300;
                            }),
                            trackOutlineColor:
                                WidgetStateProperty.resolveWith<Color>((
                                  states,
                                ) {
                                  if (states.contains(WidgetState.selected)) {
                                    return const Color(0xFF1F3F45);
                                  }
                                  return Colors.transparent;
                                }),
                            value: showMyLandsOnly,
                            onChanged: (val) {
                              setState(() {
                                showMyLandsOnly = val;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: ValueListenableBuilder<List<Land>>(
                    valueListenable: filteredNotifier,
                    builder: (context, filteredList, child) {
                      if (filteredList.isEmpty) {
                        return const Center(
                          child: Text("لم يتم العثور على نتائج"),
                        );
                      }

                      return ListView.builder(
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final land = filteredList[index];
                          return GestureDetector(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddLands(
                                    areaId: widget.areaId,
                                    areaName: widget.areaName,
                                    landData: {
                                      'id': land.id,
                                      'address': land.address,
                                      'level': land.level,
                                      'landNum': land.landNum,
                                      'size': land.landSize?.toString() ?? '',
                                      'owner': land.landOwner,
                                      'paid': land.paid,
                                      'offer': land.offer,
                                    },
                                  ),
                                ),
                              );
                            },
                            child: LandCardd(
                              areaId: widget.areaId,
                              landId: land.id,
                              landNum: land.landNum,
                              address: land.address,
                              level: land.level,
                              landSize: land.landSize,
                              paid: land.paid,
                              offer: land.offer,
                              landOwner: land.landOwner,
                              createdBy: land.createdBy,
                              createdAt: land.createdAt,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddLands(
                            areaId: widget.areaId,
                            areaName: widget.areaName,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        "إضافة قطعة أرض",
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
            );
          },
        ),
      ),
    );
  }
}

class LandCardd extends StatelessWidget {
  final String landNum;
  final String address;
  final String? level;
  final double? landSize;
  final String? landOwner;
  final String? offer;
  final String? paid;
  final String areaId;
  final String landId;
  final String? createdBy;
  final Timestamp? createdAt;

  const LandCardd({
    super.key,
    required this.areaId,
    required this.landId,
    required this.landNum,
    required this.address,
    this.level,
    this.landSize,
    this.landOwner,
    this.offer,
    this.paid,
    this.createdBy,
    this.createdAt,
  });

  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return "وقت غير معروف";
    var date = timestamp.toDate();
    // أضف كلمة intl. قبل DateFormat
    return intl.DateFormat('yyyy/MM/dd hh:mm a').format(date);
  }

  List<Widget> buildInfoItems() {
    List<Widget> items = [];
    if (address.isNotEmpty) items.add(_item(Icons.location_on, address));
    if (level != null && level!.isNotEmpty)
      items.add(_item(Icons.layers, level!));
    if (landSize != null && landSize! > 0)
      items.add(_item(Icons.square_foot, "${landSize!.toInt()} م²"));
    if (paid != null && paid!.isNotEmpty)
      items.add(_item(Icons.attach_money, paid!));
    if (offer != null && offer!.isNotEmpty)
      items.add(_item(Icons.monetization_on_outlined, offer!));
    if (landOwner != null && landOwner!.isNotEmpty)
      items.add(_item(Icons.person, landOwner!));
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final bool isOwner =
        currentUser != null &&
        createdBy != null &&
        createdBy == currentUser.uid;

    return GestureDetector(
      onLongPress: () {
        if (!isOwner) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("غير مسموح لك بحذف هذه الأرض")),
          );
          return;
        }

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("حذف الأرض"),
            content: Text("هل أنت متأكد من حذف الأرض رقم $landNum ؟"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("إلغاء"),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await LandService.deleteLand(areaId: areaId, landId: landId);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text("تم حذف الأرض")));
                },
                child: const Text("حذف", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        height: 230,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              blurRadius: 10,
              color: Colors.black12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/images/land.jpeg',
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.5),
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),

            // ✅ الإضافة الجديدة: تمت الإضافة بواسطة + الوقت
            Positioned(
              top: 12,
              left: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.person_pin,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(createdBy)
                            .get(),
                        builder: (context, snapshot) {
                          String displayName = "جاري التحميل...";
                          if (isOwner) {
                            displayName = "أنت";
                          } else if (snapshot.hasData &&
                              snapshot.data!.exists) {
                            // تأكد أن الحقل في الفايربيز اسمه 'name' أو 'userName' حسب ما سميته عندك
                            displayName =
                                snapshot.data!['name'] ?? "مستخدم غير معروف";
                          } else if (snapshot.hasError) {
                            displayName = "خطأ في الاسم";
                          }

                          return Text(
                            "بواسطة: $displayName",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Cairo',
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  Text(
                    formatTimestamp(createdAt),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  Text(
                    "# $landNum",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(spacing: 8, runSpacing: 8, children: buildInfoItems()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }
}

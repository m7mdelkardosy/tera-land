import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? titleBar ;
  final List<Widget>? actions;

  const CustomAppBar({super.key,  this.titleBar, this.actions});

  @override
  Size get preferredSize => const Size.fromHeight(55);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.2),
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
          elevation: 0,
           titleSpacing: 0,
          iconTheme: const IconThemeData(
            color: Colors.white, // غير اللون اللي يعجبك
          ),

          // centerTitle: true,
          leading: Padding(
            padding: const EdgeInsets.only(top: 6), // نزّل الأيقونة لتحت
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          title: (titleBar),

          actions: actions,
        ),
      ),
    );
  }
}

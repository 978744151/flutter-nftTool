import 'package:flutter/material.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const CustomBottomNavigation({
    Key? key,
    required this.currentIndex,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        onTap?.call(index);
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: const Color.fromARGB(255, 199, 46, 102),
      unselectedItemColor: const Color.fromARGB(255, 54, 53, 53),
      selectedLabelStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 16,
      ),
      elevation: 0,
      items: [
        // 移除 const
        const BottomNavigationBarItem(
          icon: SizedBox(),
          label: '首页',
        ),
        const BottomNavigationBarItem(
          icon: SizedBox(),
          label: '藏品',
        ),
        BottomNavigationBarItem(
          icon: SizedBox(
            height: 20, // 与文字高度一致
            child: Icon(
              Icons.add_circle_outline,
              size: 40,
              color: Color.fromARGB(255, 199, 46, 102),
            ),
          ),
          label: '',
        ),
        const BottomNavigationBarItem(
          icon: SizedBox(),
          label: '社区',
        ),
        const BottomNavigationBarItem(
          icon: SizedBox(),
          label: '我的',
        ),
      ],
    );
  }
}

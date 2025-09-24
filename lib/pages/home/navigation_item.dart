// ignore_for_file: prefer_if_null_operators

import 'package:flutter/material.dart';

class BottomNavigationItem extends StatelessWidget {
  final IconData icon;
  final String footer;
  final bool active;
  final int index;
  final double? width;
  final Function(int currentIndex) onTap;
  const BottomNavigationItem({
    super.key,
    required this.index,
    required this.icon,
    required this.footer,
    this.width,
    this.active = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(index),
        child: Container(
          width: width != null
              ? width
              : MediaQuery.of(context).size.width * 0.16,
          decoration: !active
              ? null
              : const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Color.fromARGB(128, 255, 193, 7),
                    ],
                  ),
                ),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 10,
                children: [
                  Center(child: Icon(icon)),
                  Text(footer),
                ],
              ),
              active
                  ? Positioned(
                      bottom: 0,
                      right: 0,
                      left: 0,
                      child: Container(height: 3, color: Colors.amber),
                    )
                  : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}

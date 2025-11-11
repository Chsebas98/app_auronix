import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppbarDefault extends StatelessWidget implements PreferredSizeWidget {
  const AppbarDefault({
    super.key,
    required this.goTo,
    this.isCenter = false,
    this.content,
  });
  final VoidCallback goTo;
  final bool isCenter;
  final Widget? content;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      forceMaterialTransparency: true,
      centerTitle: isCenter,

      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: goTo,
            icon: Icon(Icons.arrow_back_ios_rounded, size: 24.r),
          ),
          if (content != null) Expanded(child: content!),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

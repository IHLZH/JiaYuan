import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../styles/app_colors.dart';
import '../title/app_text.dart';

///item中的tag组件
class TagWidget extends StatelessWidget {
  final String? name;
  final Color? color;

  const TagWidget({super.key, this.name, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: 30.h,
      color: AppColors.searchBgColor,
      padding: EdgeInsets.symmetric(horizontal: 7.w),
      child: AppText(
        text: name ?? "",
        textColor: color ?? AppColors.textColor86,
      ),
    );
  }
}

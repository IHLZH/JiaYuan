import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jiayuan/route/route_path.dart';
import 'package:jiayuan/route/route_utils.dart';
import 'package:jiayuan/route/routes.dart';
import 'package:oktoast/oktoast.dart';

import 'common_ui/styles/app_colors.dart';

/// 设计尺寸
Size get designSize {
  final firstView = WidgetsBinding.instance.platformDispatcher.views.first;
  // 逻辑短边
  final logicalShortestSide =
      firstView.physicalSize.shortestSide / firstView.devicePixelRatio;
  // 逻辑长边
  final logicalLongestSide =
      firstView.physicalSize.longestSide / firstView.devicePixelRatio;
  // 缩放比例 designSize越小，元素越大
  const scaleFactor = 1;
  // 缩放后的逻辑短边和长边
  return Size(
      logicalShortestSide * scaleFactor, logicalLongestSide * scaleFactor);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print(designSize);
    //toast提示必须为APP的顶层组件
    return OKToast(
        //屏幕适配父组件组件
        child: ScreenUtilInit(
      designSize: designSize,
      builder: (context, child) {
        return MaterialApp(
          theme: ThemeData(
              tabBarTheme: TabBarTheme(dividerColor: Colors.transparent),
              useMaterial3: true,
              primaryColor: Colors.teal,
              cardColor: Colors.grey,
              textTheme: TextTheme(
                bodyLarge: TextStyle(
                    color: Colors.teal,
                    fontSize: 17,
                    fontWeight: FontWeight.bold),
                bodyMedium: TextStyle(color: Colors.teal),
              ),
              textSelectionTheme: TextSelectionThemeData(
                selectionColor: AppColors.appColor,
                selectionHandleColor: AppColors.appColor,
                cursorColor: AppColors.appColor,
              )),
          navigatorKey: RouteUtils.navigatorKey,
          onGenerateRoute: Routes.generateRoute,
          initialRoute: RoutePath.startPage,
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate, // 添加这一行
            GlobalWidgetsLocalizations.delegate
          ],
          supportedLocales: [
            const Locale("zh", "CH"),
            const Locale("en", "US")
          ],
          debugShowCheckedModeBanner: false,
          builder: EasyLoading.init(),
        );
      },
    ));
  }
}

// ///调试App
// class DebugMyApp extends StatelessWidget {
//   const DebugMyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     //toast提示必须为APP的顶层组件
//     return OKToast(
//         //屏幕适配父组件组件
//         child: ScreenUtilInit(
//       designSize: designSize,
//       builder: (context, child) {
//         return MaterialApp(
//           theme: ThemeData(
//             useMaterial3: true,
//           ),
//           navigatorKey: RouteUtils.navigatorKey,
//           onGenerateRoute: Routes.generateRoute,
//           // initialRoute: RoutePath.tab,
//           home: DebugPage(),
//         );
//       },
//     ));
//   }
// }

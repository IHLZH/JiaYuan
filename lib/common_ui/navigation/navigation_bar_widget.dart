import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jiayuan/page/tab_page/tab_page_vm.dart';

import '../styles/app_colors.dart';
import 'navigation_bar_item.dart';

///底部导航栏组件
class NavigationBarWidget extends StatefulWidget {
  NavigationBarWidget({
    super.key,
    required this.tabItems,
    required this.tabLabels,
    required this.tabIcons,
    required this.tabActiveIcons,
    this.themeData,
    this.onItemChange,
    this.bottomNavigationBarType,
    this.bottomBarIconWidth,
    this.bottomBarIconHeight,
  }) {
    // assert(tabItems.length != tabLabels.length && tabItems.length!= tabIcons.length&& tabItems
    //     .length!= tabActiveIcon.length);
    if (tabItems.length != tabLabels.length &&
        tabItems.length != tabIcons.length &&
        tabItems.length != tabActiveIcons.length) {
      throw Exception("tabItems、tabLabels、tabIcons、tabActiveIcon length must same！ ");
    }
  }



  //界面集合
  final List<Widget> tabItems;

  //标题集合
  final List<String> tabLabels;

  //未选中icon
  final List<String> tabIcons;

  //选中icon
  final List<String> tabActiveIcons;


  //底部导航栏切换事件
  final ValueChanged<int>? onItemChange;

  //页面主题
  final ThemeData? themeData;

  //底部导航栏风格
  final BottomNavigationBarType? bottomNavigationBarType;

  //底部导航栏icon宽高
  final double? bottomBarIconWidth;
  final double? bottomBarIconHeight;

  @override
  State<StatefulWidget> createState() {
    return _NavigationBarWidgetState();
  }
}

class _NavigationBarWidgetState extends State<NavigationBarWidget> {

  TabPageViewModel tabPageViewModel = TabPageViewModel();

  @override
  void initState() {
    super.initState();
    //第一次进入默认调用一次
    widget.onItemChange?.call(TabPageViewModel.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashFactory: NoSplash.splashFactory, // 取消水波纹效果
      ),
        child: Scaffold(
          backgroundColor: Colors.white,
          //tab页面
          body: IndexedStack(index: TabPageViewModel.currentIndex, children: widget.tabItems),
          //底部导航栏
          bottomNavigationBar: BottomNavigationBar(
              iconSize: 22.r,
              selectedFontSize: 13.sp,
              unselectedFontSize: 10.sp,
              //已选择与未选中的字体颜色
              unselectedItemColor: AppColors.blackColor333,
              selectedItemColor: AppColors.appColor,
              backgroundColor: Colors.white,
              //fixedColor: AppColors.appColor,
              type: widget.bottomNavigationBarType ?? BottomNavigationBarType.fixed,
              currentIndex: TabPageViewModel.currentIndex,
              onTap: (index) {
                //重复事件不处理
                if (TabPageViewModel.currentIndex == index) {
                  return;
                }
                //点击切换page事件
                widget.onItemChange?.call(index);
                TabPageViewModel.currentIndex = index;
                setState(() {});
              },
              items: _barItemList()
          ),
        ),
    );

  }

  ///底部导航栏集合
  List<BottomNavigationBarItem> _barItemList() {
    List<BottomNavigationBarItem> items = [];
    for (var i = 0; i < widget.tabItems.length; i++) {
      items.add(BottomNavigationBarItem(
          activeIcon: NavigationBarItem(builder: (context) {
            return _iconContainer(widget.tabActiveIcons[i]);
          }),
          icon: _iconContainer(widget.tabIcons[i]),
          label: widget.tabLabels[i]));
    }
    return items;
  }

  Widget _iconContainer(String iconPath) {
    return Container(
        padding: EdgeInsets.only(top: 4.h),
        child: Image.asset(
          iconPath,
          width: widget.bottomBarIconWidth ?? 25.r,
          height: widget.bottomBarIconHeight ?? 25.r,
        ));
  }
}

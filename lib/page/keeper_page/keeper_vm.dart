import 'package:flutter/material.dart';
import 'package:jiayuan/repository/api/keeper_api.dart';
import 'package:jiayuan/repository/model/HouseKeeper_data_detail.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class KeeperViewModel with ChangeNotifier {
  HousekeeperDataDetail? keeperData ;
  bool isLoading = false;
  String? error;
  bool isFavorite = false;

  //收藏家政员
  Future<void> addFavorite() async {
    try {
    isFavorite =  await KeeperApi.instance.addFavorite(keeperData!.keeperId);
    } catch (e) {
      print("收藏失败：" + e.toString());
    }
    notifyListeners();
  }

  //判断是否被收藏
  Future<void> checkIsFavorite() async {
    try {
      isFavorite = await KeeperApi.instance.addFavorite(keeperData!.keeperId);
      isFavorite = await KeeperApi.instance.addFavorite(keeperData!.keeperId);
    } catch (e) {
      print("判断收藏失败：" + e.toString());
    }
  }

  //获取评论
  Future<void> getComments(int id) async {
    try {
      keeperData!.evaluations = [];
      keeperData!.evaluations!.addAll(await KeeperApi.instance.getComments(id,1,1))  ;
    } catch (e) {
      print("获取评论失败：" + e.toString());
    }
  }

  //根据家政员id获取家政员信息
  Future<void> getKeeperDataDetail(int id) async {

    try {
      isLoading = true;
      notifyListeners();
      //模拟网络延迟
      await Future.delayed(Duration(seconds: 1));
      keeperData = await KeeperApi.instance.getKeeperDataDetail(id);
      await checkIsFavorite();
      await getComments(id);
      isLoading = false;
      error = null;
      notifyListeners();
    } catch (e) {
      print("获取数据失败: $e");
      isLoading = false;
      error = e.toString();
      notifyListeners();
    }
  }

      //拨打电话
  Future<void> makePhoneCall(String phone) async {
    try {
      if (phone == null) {
        throw '电话号码不能为空';
      }
      var status = await Permission.phone.status;
      if(!status.isGranted){
        status = await Permission.phone.request();
        if (!status.isGranted) {
          throw '需要电话权限才能拨打电话';
        }
      }

      final phoneNumber = phone.replaceAll(RegExp(r'[^\d]'), '');
      final Uri telUri = Uri.parse('tel:${phone}');
      print('准备拨打电话: ${telUri.toString()}');

      if (await canLaunchUrl(telUri,)) {
        await launchUrl(telUri,mode: LaunchMode.externalApplication);
      } else {
        throw '无法拨打电话: ${phoneNumber}';
      }
    } catch (e) {
      print('拨打电话失败: $e');
      // 可以在这里添加错误提示
      rethrow;
    }
  }

}

import 'dart:async';
import 'dart:io';
import 'package:amap_flutter_location/amap_flutter_location.dart';
import 'package:amap_flutter_location/amap_location_option.dart';
import 'package:permission_handler/permission_handler.dart';

import '../global.dart';
import '../location_data.dart';

class GaodeMap{

  static GaodeMap get instance => GaodeMap._();

  GaodeMap._();

  //高德地图sdk
  // 实例化
  AMapFlutterLocation? _locationPlugin;
  // 监听定位
  StreamSubscription<Map<String, Object>>? _locationListener;

  Completer<void> _locationCompleter = Completer<void>(); // 用于等待定位完成

  static bool isMapInitialized = false;

  Future<void> initGaodeMap() async {
    //实例化
    _locationPlugin = AMapFlutterLocation();
    _registerListener();

    //获取定位权限
    await _getPermission();
    //开始定位
    await _getLocation();

    print("====================== 高德初始化完毕 ====================");
  }

  Future<void> _getLocation() async {
    _startLocation();
    return _locationCompleter.future; // 等待定位完成
  }

  void _registerListener() {
    ///注册定位结果监听
    try{
      _locationListener = _locationPlugin
          ?.onLocationChanged()
          .listen((Map<String, Object> result) {

        print("位置信息为：" + result.toString());

        Global.locationInfo = LocationData(
            latitude: result["latitude"] as double,
            longitude: result["longitude"]as double,
            country: result['country'].toString(),
            province: result['province'].toString(),
            city: result['city'].toString(),
            district: result['district'].toString(),
            street: result['street'].toString(),
            adCode: result['adCode'].toString(),
            address: result['address'].toString(),
            cityCode: result['cityCode'].toString()
        );

        print("定位信息为：" + Global.locationInfo.toString());

        // 定位信息获取后，完成 Completer
        if (!_locationCompleter.isCompleted) {
          _locationCompleter.complete();
        }
      });
    }catch(e){
      print("定位错误信息为：" + e.toString());
    }
  }

  Future<void> disposeGaodeMap() async {
    if(_locationPlugin != null){
      //停止定位
      _stopLocation();
      //销毁定位
      _locationPlugin!.destroy();

      //取消定位订阅
      await _locationListener!.cancel();

      print("================= 高德定位已被销毁 ==================");
    }else{
      print("无法销毁高德定位：定位插件未初始化");
    }
  }

  /// 执行单次定位
  Future<void> doSingleLocation() async {
    // 如果插件未初始化，先初始化
    if (_locationPlugin == null) {
      await initGaodeMap();
    }

    // 保存原有的定位选项
    if (_locationPlugin != null) {
      // 设置单次定位选项
      AMapLocationOption singleLocationOption = AMapLocationOption();
      singleLocationOption.onceLocation = true;  // 设置为单次定位
      singleLocationOption.needAddress = true;
      singleLocationOption.desiredAccuracy = DesiredAccuracy.Best;

      // 应用单次定位设置
      _locationPlugin!.setLocationOption(singleLocationOption);

      // 创建新的 Completer
      _locationCompleter = Completer<void>();

      // 开始定位
      _locationPlugin!.startLocation();

      // 等待定位完成
      await _locationCompleter.future;

      // 恢复原有的定位选项
      _setLocationOption();  // 这会重新设置为原来的1分钟间隔
    } else {
      print("无法执行单次定位：定位插件未初始化");
    }
  }

  Future<void> _getPermission() async {
    /// 动态申请定位权限
    await _requestPermission();

    /// 设置Android和iOS的apikey，
    AMapFlutterLocation.setApiKey("deec9d608ddc51b91c745ba02af59a96", "");

    ///设置是否已经取得用户同意，如果未取得用户同意，高德定位SDK将不会工作,这里传true
    AMapFlutterLocation.updatePrivacyAgree(true);

    /// 设置是否已经包含高德隐私政策并弹窗展示显示用户查看，如果未包含或者没有弹窗展示，高德定位SDK将不会工作,这里传true
    AMapFlutterLocation.updatePrivacyShow(true, true);

    ///iOS 获取native精度类型
    if (Platform.isIOS) {
      _requestAccuracyAuthorization();
    }
  }

  /// 动态申请定位权限
  Future<void> _requestPermission() async {
    // 申请权限
    bool hasLocationPermission = await _requestLocationPermission();
    if (hasLocationPermission) {
      print("定位权限申请通过");
    } else {
      print("定位权限申请不通过");
    }
  }

  /// 申请定位权限
  /// 授予定位权限返回true， 否则返回false
  Future<bool> _requestLocationPermission() async {
    //获取当前的权限
    var status = await Permission.location.status;
    if (status == PermissionStatus.granted) {
      //已经授权
      return true;
    } else {
      //未授权则发起一次申请
      status = await Permission.location.request();
      if (status == PermissionStatus.granted) {
        return true;
      } else {
        return false;
      }
    }
  }

  ///获取iOS native的accuracyAuthorization类型
  void _requestAccuracyAuthorization() async {
    //iOS 14中系统的定位类型信息
    if(_locationPlugin != null){
      AMapAccuracyAuthorization currentAccuracyAuthorization =
      await _locationPlugin!.getSystemAccuracyAuthorization();
      if (currentAccuracyAuthorization ==
          AMapAccuracyAuthorization.AMapAccuracyAuthorizationFullAccuracy) {
        print("精确定位类型");
      } else if (currentAccuracyAuthorization ==
          AMapAccuracyAuthorization.AMapAccuracyAuthorizationReducedAccuracy) {
        print("模糊定位类型");
      } else {
        print("未知定位类型");
      }
    }
  }

  ///设置定位参数
  void _setLocationOption() {
    if (null != _locationPlugin) {
      AMapLocationOption locationOption = AMapLocationOption();

      ///是否单次定位
      locationOption.onceLocation = false;

      ///是否需要返回逆地理信息
      locationOption.needAddress = true;

      ///逆地理信息的语言类型
      locationOption.geoLanguage = GeoLanguage.DEFAULT;

      locationOption.desiredLocationAccuracyAuthorizationMode =
          AMapLocationAccuracyAuthorizationMode.ReduceAccuracy;

      locationOption.fullAccuracyPurposeKey = "AMapLocationScene";

      ///设置Android端连续定位的定位间隔
      locationOption.locationInterval = 60000;

      ///设置Android端的定位模式<br>
      ///可选值：<br>
      ///<li>[AMapLocationMode.Battery_Saving]</li>
      ///<li>[AMapLocationMode.Device_Sensors]</li>
      ///<li>[AMapLocationMode.Hight_Accuracy]</li>
      locationOption.locationMode = AMapLocationMode.Hight_Accuracy;

      ///设置iOS端的定位最小更新距离<br>
      locationOption.distanceFilter = -1;

      ///设置iOS端期望的定位精度
      /// 可选值：<br>
      /// <li>[DesiredAccuracy.Best] 最高精度</li>
      /// <li>[DesiredAccuracy.BestForNavigation] 适用于导航场景的高精度 </li>
      /// <li>[DesiredAccuracy.NearestTenMeters] 10米 </li>
      /// <li>[DesiredAccuracy.Kilometer] 1000米</li>
      /// <li>[DesiredAccuracy.ThreeKilometers] 3000米</li>
      locationOption.desiredAccuracy = DesiredAccuracy.Best;

      ///设置iOS端是否允许系统暂停定位
      locationOption.pausesLocationUpdatesAutomatically = false;

      ///将定位参数设置给定位插件
      _locationPlugin!.setLocationOption(locationOption);
    }
  }

  ///开始定位
  Future<void> _startLocation() async {
    if(_locationPlugin != null){
      ///开始定位之前设置定位参数
      _setLocationOption();
      _locationPlugin!.startLocation();
    }else{
      print("无法开始定位：定位插件未初始化");
    }
  }

  ///停止定位
  void _stopLocation() {
    if(_locationPlugin != null){
      _locationPlugin!.stopLocation();
      print("113");
    }else{
      print("无法停止定位：定位插件未初始化");
    }

  }

  StreamSubscription<Map<String, Object>> get locationListener =>
      _locationListener!;

  set locationListener(StreamSubscription<Map<String, Object>> value) {
    _locationListener = value;
  }
}
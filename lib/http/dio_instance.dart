import 'package:dio/dio.dart';
import 'package:jiayuan/http/interceptor/cookie_interceptor.dart';
import 'package:jiayuan/http/url_path.dart';
import 'http_method.dart';
import 'interceptor/print_log_interceptor.dart';
import 'interceptor/rsp_interceptor.dart';
import 'interceptor/token_interceptor.dart';

class DioInstance {
  static DioInstance? _instance;

  DioInstance._internal();

  static DioInstance instance() {
    return _instance ??= DioInstance._internal();
  }

  Dio _dio = Dio();
  final _defaultTimeout = const Duration(seconds: 30);
  var _inited = false;

  void initDio({
    String? baseUrl,
    String? method = HttpMethod.GET,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
    ResponseType? responseType = ResponseType.json,
    String? contentType,
  }) async {
    _dio.options = buildBaseOptions(
        method: method,
        baseUrl: UrlPath.BaseUrl,
        connectTimeout: connectTimeout ?? _defaultTimeout,
        receiveTimeout: receiveTimeout ?? _defaultTimeout,
        sendTimeout: sendTimeout ?? _defaultTimeout,
        responseType: responseType,
        contentType: contentType);
     _dio.interceptors.add(TokenInterceptor());
    // _dio.interceptors.add(PrintLogInterceptor());
    // _dio.interceptors.add(RspInterceptor());

    _dio.interceptors.add(CookieInterceptor().getCookieManager());

    _inited = true;
  }

  ///get请求方式
  Future<Response> get({
    required String path,
    Map<String, dynamic>? param,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    if (!_inited) {
      throw Exception("you should call initDio() first!");
    }
    return await _dio.get(path,
        queryParameters: param,
        options: options ??
            Options(
              method: HttpMethod.GET,
              receiveTimeout: _defaultTimeout,
              sendTimeout: _defaultTimeout,
            ),
        cancelToken: cancelToken);
  }

  ///post请求方式
  Future<Response> post(
      {required String path,
      Object? data,
      Map<String, dynamic>? queryParameters,
      Options? options,
      CancelToken? cancelToken,
        void Function(int, int)? onSendProgress,
      }) async {
    if (!_inited) {
      throw Exception("you should call initDio() first!");
    }
    return await _dio.post(path,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options ??
            Options(
              method: HttpMethod.POST,
              receiveTimeout: _defaultTimeout,
              sendTimeout: _defaultTimeout,
            ),
      onSendProgress: onSendProgress
    );
  }

  ///put请求方式
  Future<Response> put(
      {required String path,
      Object? data,
      Map<String, dynamic>? queryParameters,
      Options? options,
      CancelToken? cancelToken}) async {
    if (!_inited) {
      throw Exception("you should call initDio() first!");
    }
    return await _dio.put(path,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options ??
            Options(
              method: HttpMethod.PUT,
              receiveTimeout: _defaultTimeout,
              sendTimeout: _defaultTimeout,
            ));
  }

  //delete请求方式
  Future<Response> delete(
      {required String path,
      Object? data,
      Map<String, dynamic>? queryParameters,
      Options? options,
      CancelToken? cancelToken}) async {
    if (!_inited) {
      throw Exception("you should call initDio() first!");
    }
    return await _dio.delete(path,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options ??
            Options(
              method: HttpMethod.DELETE,
              receiveTimeout: _defaultTimeout,
              sendTimeout: _defaultTimeout,
            ));
  }

  BaseOptions buildBaseOptions({
    required String baseUrl,
    String? method = HttpMethod.GET,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
    ResponseType? responseType = ResponseType.json,
    String? contentType,
  }) {
    return BaseOptions(
        method: method,
        baseUrl: baseUrl,
        connectTimeout: connectTimeout ?? _defaultTimeout,
        receiveTimeout: receiveTimeout ?? _defaultTimeout,
        sendTimeout: sendTimeout ?? _defaultTimeout,
        responseType: responseType,
        contentType: contentType);
  }

  void changeBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
  }

  void changenIterceptors(List<Interceptor> interceptors){
    _dio.interceptors.clear();
    _dio.interceptors.addAll(interceptors);
    _dio.interceptors.add(CookieInterceptor().getCookieManager());
  }
}

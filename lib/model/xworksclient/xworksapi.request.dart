import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wandr/model/xworksclient/xworksapi.error.dart';

class XworksApiClient {
  final String authority;
  XworksApiClient({required this.authority});

  late http.Client _httpClient = http.Client();
  late String? _token = null;

  Future<dynamic> makeRequest(
    String path, {
    required XworksApiRequestMethod method,
    XworksApiRequestParams? headerParams,
    XworksApiRequestParams? queryParams,
    XworksApiRequestBody? data,
  }) async {
    final _XworksApiRequest request = _XworksApiRequest(
      authority: authority,
      path: path,
      method: method,
      headerParams: headerParams,
      queryParams: queryParams,
    );
    return await request.make(_httpClient, body: data);
  }

  Future<String> requireToken() async {
    if (_token != null) {
      return _token ?? '';
    }
    try {
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      return preferences.getString('kXworksToken') ?? '';
    } on Exception {
      return '';
    }
  }

  void dispose() {
    _httpClient.close();
  }
}

class _XworksApiRequest {
  final String authority;
  final String path;
  final XworksApiRequestMethod method;
  final XworksApiRequestParams? headerParams;
  final XworksApiRequestParams? queryParams;
  _XworksApiRequest({
    required this.authority,
    required this.path,
    required this.method,
    this.headerParams,
    this.queryParams,
  });

  Uri get requestUrl => Uri.https(
        authority,
        path,
        queryParams?.data,
      );

  Future<dynamic> make(
    http.Client client, {
    XworksApiRequestBody? body,
  }) async {
    try {
      final response = await _makeImpl(client, body: body);
      final statusCode = response.statusCode;
      dynamic responseBody;
      XworksApiResponseContentType responseType;
      if (response.headers['content-type']?.startsWith('application/json') ==
          true) {
        try {
          responseBody = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
          responseType = XworksApiResponseContentType.json;
          if (responseBody['state'] == 'ERROR') {
            throw XworksApiException(
              error: XworksApiError(
                uri: requestUrl,
                statusCode: statusCode,
                errorCode: responseBody['error']?['status'],
                errorMessage: responseBody['error']?['message'],
              ),
            );
          }
        } on XworksApiException catch (ex) {
          throw ex;
        } on Exception catch (ex) {
          throw XworksApiException(
            error: XworksApiError(
              uri: requestUrl,
              statusCode: statusCode,
              errorCode: 'E_NETWORK_ERROR',
            ),
            cause: ex,
          );
        }
      } else if (response.headers['content-type']?.startsWith('text/html') ==
          true) {
        responseBody = utf8.decode(response.bodyBytes);
        responseType = XworksApiResponseContentType.text;
      } else {
        responseBody = response.bodyBytes;
        responseType = XworksApiResponseContentType.binary;
      }

      if (statusCode < 200 || statusCode >= 300) {
        switch (responseType) {
          case XworksApiResponseContentType.json:
            throw XworksApiException(
              error: XworksApiError(
                uri: requestUrl,
                statusCode: statusCode,
                errorCode: responseBody['state'],
                errorMessage: responseBody['error']?['message'],
              ),
            );
          default:
            throw XworksApiException(
              error: XworksApiError(
                uri: requestUrl,
                statusCode: statusCode,
                errorCode: 'E_NETWORK_ERROR',
              ),
            );
        }
      }
      return responseBody;
    } on XworksApiException catch (ex) {
      throw ex;
    } on Exception catch (ex) {
      throw XworksApiException(
        error: XworksApiError(
          uri: requestUrl,
          statusCode: 0,
          errorCode: 'E_NETWORK_ERROR',
        ),
        cause: ex,
      );
    }
  }

  Future<http.Response> _makeImpl(
    http.Client client, {
    XworksApiRequestBody? body,
  }) async {
    switch (method) {
      case XworksApiRequestMethod.post:
        return await client.post(
          requestUrl,
          headers: headerParams?.data,
          body: body?.payload,
        );
      case XworksApiRequestMethod.put:
        return await client.put(
          requestUrl,
          headers: headerParams?.data,
          body: body?.payload,
        );
      case XworksApiRequestMethod.patch:
        return await client.patch(
          requestUrl,
          headers: headerParams?.data,
          body: body?.payload,
        );
      case XworksApiRequestMethod.delete:
        return await client.delete(
          requestUrl,
          headers: headerParams?.data,
          body: body?.payload,
        );
      default:
        return await client.get(requestUrl, headers: headerParams?.data);
    }
  }
}

enum XworksApiRequestMethod { post, put, patch, delete, get }

enum XworksApiResponseContentType { json, binary, text }

class XworksApiRequestParams {
  final Map<String, String> data = Map();
  XworksApiRequestParams({Map<String, String>? data}) {
    if (data?.isNotEmpty == true) {
      this.data.addAll(data!);
    }
  }

  XworksApiRequestParams append({required Map<String, String> newData}) {
    data.addAll(newData);
    return this;
  }
}

abstract class XworksApiRequestBody<T, R> {
  final T data;
  const XworksApiRequestBody({required this.data});

  R get payload;
}

class XworksApiJsonRequestBody extends XworksApiRequestBody<dynamic, String> {
  XworksApiJsonRequestBody({
    required dynamic data,
  }) : super(data: data);

  String get payload => jsonEncode(data);
}

class XworksApiFileRequestBody extends XworksApiRequestBody<File, Uint8List> {
  XworksApiFileRequestBody({
    required File data,
  }) : super(data: data);

  Uint8List get payload => data.readAsBytesSync();
}

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:wandr/model/xworksclient/xworksapi.error.dart';

class XworksApiClient {
  final String authority;
  XworksApiClient({required this.authority});

  late http.Client _httpClient = http.Client();

  Future<dynamic> makeRequest(
    String path, {
    required XworksApiRequestMethod method,
    XworksApiRequestParams? headerParams,
    XworksApiRequestParams? queryParams,
    XworksApiRequestBody? data,
  }) async {
    final _XworksApiRequest request = _XworksApiRequest(
      path: path,
      method: method,
      headerParams: headerParams,
      queryParams: queryParams,
    );
    return await request.make(_httpClient, body: data);
  }

  void dispose() {
    _httpClient.close();
  }
}

class _XworksApiRequest {
  final String path;
  final XworksApiRequestMethod method;
  final XworksApiRequestParams? headerParams;
  final XworksApiRequestParams? queryParams;
  _XworksApiRequest({
    required this.path,
    required this.method,
    this.headerParams,
    this.queryParams,
  });

  Uri get requestUrl => Uri.https(
        'api.next.xworks.net',
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
      if (response.headers['Content-Type'] == 'application/json') {
        try {
          responseBody = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
          responseType = XworksApiResponseContentType.json;
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
      } else if (response.headers['Content-Type'] == 'text/html') {
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
                errorCode: responseBody['status'],
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
          body: body?.data,
          encoding: Encoding.getByName('utf-8'),
        );
      case XworksApiRequestMethod.put:
        return await client.put(
          requestUrl,
          headers: headerParams?.data,
          body: body?.data,
          encoding: Encoding.getByName('utf-8'),
        );
      case XworksApiRequestMethod.patch:
        return await client.patch(
          requestUrl,
          headers: headerParams?.data,
          body: body?.data,
          encoding: Encoding.getByName('utf-8'),
        );
      case XworksApiRequestMethod.delete:
        return await client.delete(
          requestUrl,
          headers: headerParams?.data,
          body: body?.data,
          encoding: Encoding.getByName('utf-8'),
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
}

abstract class XworksApiRequestBody<T> {
  final T data;
  const XworksApiRequestBody({required this.data});
}

class XworksApiJsonRequestBody extends XworksApiRequestBody<dynamic> {
  XworksApiJsonRequestBody({
    required dynamic data,
  }) : super(data: data);
}

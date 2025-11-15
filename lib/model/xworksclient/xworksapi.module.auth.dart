import 'package:wandr/model/xworksclient/xworksapi.module.dart';
import 'package:wandr/model/xworksclient/xworksapi.request.dart';

class XworksApiAuthModule extends XworksApiModule {
  XworksApiAuthModule(XworksApiClient apiClient) : super(apiClient: apiClient);

  Future<dynamic> getToken({
    required String username,
    required String password,
  }) async {
    final XworksApiRequestParams headerParams =
        XworksApiModule.defaultRequestHeaders;
    final XworksApiJsonRequestBody data = XworksApiJsonRequestBody(
      data: Map.from({
        'credentials': {
          'user': username,
          'pass': password,
        },
        'device': {
          'id': 'WANDR',
          'info': 'WANDR',
          'validDays': 365,
        },
      }),
    );
    return await apiClient.makeRequest(
      'rest/2/api/auth/getToken',
      method: XworksApiRequestMethod.post,
      headerParams: headerParams,
      data: data,
    );
  }
}

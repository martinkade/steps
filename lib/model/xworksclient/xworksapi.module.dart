import 'package:wandr/__secrets.dart';
import 'package:wandr/model/xworksclient/xworksapi.request.dart';

abstract class XworksApiModule {
  final XworksApiClient apiClient;
  XworksApiModule({required this.apiClient});

  static XworksApiClient get defaultApiClient =>
      XworksApiClient(authority: XWORKS_AUTHORITY);

  static XworksApiRequestParams get defaultRequestHeaders =>
      XworksApiRequestParams(
        data: Map.from({
          'X-XWORKS-DEVID': XWORKS_DEV_ID,
          'X-XWORKS-APPID': XWORKS_APP_ID,
        }),
      );

  void dispose() {
    apiClient.dispose();
  }
}

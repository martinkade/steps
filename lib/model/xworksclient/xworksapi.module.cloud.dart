import 'dart:io';

import 'package:wandr/model/xworksclient/xworksapi.module.dart';
import 'package:wandr/model/xworksclient/xworksapi.request.dart';

class XworksApiCloudModule extends XworksApiModule {
  XworksApiCloudModule(XworksApiClient apiClient) : super(apiClient: apiClient);

  Future<dynamic> getFolderTree({
    bool showArchiveFolders = false,
  }) async {
    final XworksApiRequestParams headerParams =
        XworksApiModule.defaultRequestHeaders.append(
      newData: Map.from(
        {'X-XWORKS-TOKEN': await apiClient.requireToken()},
      ),
    );
    final XworksApiRequestParams queryParams = XworksApiRequestParams(
      data: Map.from(
        {'showArchiveFolders': '$showArchiveFolders'},
      ),
    );
    return await apiClient.makeRequest(
      'rest/2/api/cloud/getFolderList',
      method: XworksApiRequestMethod.get,
      headerParams: headerParams,
      queryParams: queryParams,
    );
  }

  Future<dynamic> createFolder({
    required String name,
    required String parentUuid,
    int category = 0,
  }) async {
    final XworksApiRequestParams headerParams =
        XworksApiModule.defaultRequestHeaders.append(
      newData: Map.from(
        {
          'X-XWORKS-TOKEN': await apiClient.requireToken(),
          'Content-Type': 'application/json'
        },
      ),
    );
    final XworksApiJsonRequestBody data = XworksApiJsonRequestBody(
      data: Map.from({
        'name': name,
        'parentId': parentUuid,
        'category': category,
      }),
    );
    return await apiClient.makeRequest(
      'rest/2/api/cloud/createFolder',
      method: XworksApiRequestMethod.post,
      headerParams: headerParams,
      data: data,
    );
  }

  Future<dynamic> uploadFile({
    required File file,
    required String filename,
    required String folderUuid,
    String contentType = 'application/octet-stream',
    String option = 'replace',
  }) async {
    final XworksApiRequestParams headerParams =
        XworksApiModule.defaultRequestHeaders.append(
      newData: Map.from(
        {
          'X-XWORKS-TOKEN': await apiClient.requireToken(),
          'Content-Type': contentType
        },
      ),
    );
    final XworksApiRequestParams queryParams = XworksApiRequestParams(
      data: Map.from(
        {
          'folderId': folderUuid,
          'filename': filename,
          'option': option,
        },
      ),
    );
    final XworksApiFileRequestBody data = XworksApiFileRequestBody(data: file);
    return await apiClient.makeRequest(
      'rest/2/api/cloud/upload',
      method: XworksApiRequestMethod.post,
      headerParams: headerParams,
      queryParams: queryParams,
      data: data,
    );
  }

  Future<dynamic> downloadFile({
    required String fileUuid,
  }) async {
    final XworksApiRequestParams headerParams =
        XworksApiModule.defaultRequestHeaders.append(
      newData: Map.from(
        {'X-XWORKS-TOKEN': await apiClient.requireToken()},
      ),
    );
    final XworksApiRequestParams queryParams = XworksApiRequestParams(
      data: Map.from(
        {'fileId': fileUuid},
      ),
    );
    return await apiClient.makeRequest(
      'rest/2/api/cloud/download',
      method: XworksApiRequestMethod.get,
      headerParams: headerParams,
      queryParams: queryParams,
    );
  }
}

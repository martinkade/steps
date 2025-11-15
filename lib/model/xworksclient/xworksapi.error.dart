class XworksApiError {
  final Uri uri;
  final int statusCode;
  final String errorCode;
  final String? errorMessage;
  const XworksApiError({
    required this.uri,
    required this.statusCode,
    required this.errorCode,
    this.errorMessage,
  });

  String get messageKey {
    switch (errorCode) {
      case 'E_NETWORK_ERROR':
        return 'lblUnknownError';
      // lblSigningError
      // lblSigningErrorCredentials
      default:
        return 'lblUnknownError';
    }
  }
}

class XworksApiException implements Exception {
  final XworksApiError error;
  final Exception? cause;
  const XworksApiException({required this.error, this.cause});
}

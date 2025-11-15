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
      case 'E_LOGIN_DENIED':
        return 'lblSigningErrorCredentials';
      case 'E_ACCOUNT_IN_QUARANTINE':
        return 'lblSigningError';
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

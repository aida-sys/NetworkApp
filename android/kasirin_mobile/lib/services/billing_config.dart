/// Settings for billing server connection.
/// Reads from the server .env configuration.
class BillingConfig {
  /// Base URL of the billing server (set from server .env BASE_URL)
  final String baseUrl;
  
  /// API endpoint prefix
  final String apiPrefix;

  BillingConfig({
    required this.baseUrl,
    required this.apiPrefix,
  });

  String get fullApiUrl => apiPrefix;

  /// Get the full URL for a path
  String url(String path) => '$baseUrl$path';
}

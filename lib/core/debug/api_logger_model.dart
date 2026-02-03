class ApiLoggerModel {
  final String endpoint;
  final String method;
  final Map<String, dynamic>? requestData;
  final Map<String, dynamic>? requestHeaders;
  final Map<String, dynamic>? queryParameters;
  final int? statusCode;
  final dynamic responseData;
  final Map<String, dynamic>? responseHeaders;
  final String? errorMessage;
  final String? errorType;
  final DateTime timestamp;
  final String? baseUrl;
  final String? fullUrl;

  ApiLoggerModel({
    required this.endpoint,
    required this.method,
    this.requestData,
    this.requestHeaders,
    this.queryParameters,
    this.statusCode,
    this.responseData,
    this.responseHeaders,
    this.errorMessage,
    this.errorType,
    DateTime? timestamp,
    this.baseUrl,
    this.fullUrl,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'endpoint': endpoint,
      'method': method,
      'requestData': requestData,
      'requestHeaders': requestHeaders,
      'queryParameters': queryParameters,
      'statusCode': statusCode,
      'responseData': responseData,
      'responseHeaders': responseHeaders,
      'errorMessage': errorMessage,
      'errorType': errorType,
      'timestamp': timestamp.toIso8601String(),
      'baseUrl': baseUrl,
      'fullUrl': fullUrl,
    };
  }

  String get formattedTimestamp {
    return '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')} '
        '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}';
  }

  bool get isError =>
      errorMessage != null || (statusCode != null && statusCode! >= 400);
}

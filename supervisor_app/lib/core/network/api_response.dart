/// Standard API response model
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final dynamic error;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.error,
    this.statusCode,
  });

  /// Create success response
  factory ApiResponse.success({
    T? data,
    String? message,
    int? statusCode,
  }) {
    return ApiResponse<T>(
      success: true,
      data: data,
      message: message,
      statusCode: statusCode ?? 200,
    );
  }

  /// Create error response
  factory ApiResponse.error({
    String? message,
    dynamic error,
    int? statusCode,
  }) {
    return ApiResponse<T>(
      success: false,
      message: message,
      error: error,
      statusCode: statusCode,
    );
  }

  /// Parse from Dio response
  factory ApiResponse.fromDioResponse(
    dynamic response, {
    T Function(dynamic)? dataParser,
  }) {
    if (response == null) {
      return ApiResponse.error(message: 'No response from server');
    }

    final data = response.data;
    
    if (data is Map<String, dynamic>) {
      final success = data['success'] ?? (response.statusCode == 200);
      final message = data['message']?.toString();
      final responseData = data['data'];
      
      if (success) {
        return ApiResponse.success(
          data: dataParser != null && responseData != null 
              ? dataParser(responseData) 
              : responseData as T?,
          message: message,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse.error(
          message: message,
          error: data['error'],
          statusCode: response.statusCode,
        );
      }
    }

    return ApiResponse.success(
      data: dataParser != null ? dataParser(data) : data as T?,
      statusCode: response.statusCode,
    );
  }

  /// Check if response is successful
  bool get isSuccess => success;

  /// Check if response is failed
  bool get isFailed => !success;
}

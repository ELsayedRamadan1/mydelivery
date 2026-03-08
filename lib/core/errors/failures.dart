import 'package:equatable/equatable.dart';

/// Base Failure class - طبقة الأخطاء الأساسية
abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure({required this.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

/// Server-related failures
class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.statusCode});
}

/// Network/connection failures
class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'لا يوجد اتصال بالإنترنت'});
}

/// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure({required super.message});
}

/// Cache/local storage failures
class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

/// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}

/// Not found failures
class NotFoundFailure extends Failure {
  const NotFoundFailure({super.message = 'البيانات غير موجودة'});
}

/// Permission failures
class PermissionFailure extends Failure {
  const PermissionFailure({super.message = 'ليس لديك صلاحية'});
}

/// Unexpected failures
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({super.message = 'حدث خطأ غير متوقع'});
}

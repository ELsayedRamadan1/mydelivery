import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

/// Auth Repository Interface - العقد الذي تنفذه طبقة Data
abstract class AuthRepository {
  /// تسجيل الدخول بالبريد الإلكتروني وكلمة المرور
  Future<Either<Failure, UserEntity>> signIn({
    required String email,
    required String password,
  });

  /// إنشاء حساب جديد
  Future<Either<Failure, UserEntity>> signUp({
    required String name,
    required String email,
    required String password,
    String? phone,
  });

  /// تسجيل الخروج
  Future<Either<Failure, void>> signOut();

  /// الحصول على المستخدم الحالي
  Future<Either<Failure, UserEntity?>> getCurrentUser();

  /// إعادة تعيين كلمة المرور
  Future<Either<Failure, void>> resetPassword({required String email});

  /// تحديث بيانات المستخدم
  Future<Either<Failure, UserEntity>> updateProfile({
    required String userId,
    String? name,
    String? phone,
    String? photoUrl,
    String? address,
  });

  /// Stream لمراقبة حالة المصادقة
  Stream<UserEntity?> get authStateChanges;
}

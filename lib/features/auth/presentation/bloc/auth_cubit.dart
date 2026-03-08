import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart' show ResetPasswordUseCase;

// ===== STATES =====
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserEntity user;
  AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthPasswordResetSent extends AuthState {}

// ===== CUBIT =====
class AuthCubit extends Cubit<AuthState> {
  final SignInUseCase signInUseCase;
  final SignUpUseCase signUpUseCase;
  final SignOutUseCase signOutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthCubit({
    required this.signInUseCase,
    required this.signUpUseCase,
    required this.signOutUseCase,
    required this.getCurrentUserUseCase,
    required this.resetPasswordUseCase,
  }) : super(AuthInitial());

  /// التحقق من حالة المصادقة عند بدء التطبيق
  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    final result = await getCurrentUserUseCase();
    result.fold(
      (failure) => emit(AuthUnauthenticated()),
      (user) {
        if (user != null) {
          emit(AuthAuthenticated(user));
        } else {
          emit(AuthUnauthenticated());
        }
      },
    );
  }

  /// تسجيل الدخول
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    final result = await signInUseCase(
      SignInParams(email: email, password: password),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) async {
        // Ensure Firestore document exists for this user
        await _ensureUserDocument(user);
        emit(AuthAuthenticated(user));
      },
    );
  }

  /// إنشاء حساب جديد
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    emit(AuthLoading());
    try {
      final result = await signUpUseCase(
        SignUpParams(name: name, email: email, password: password, phone: phone),
      );
      result.fold(
        (failure) => emit(AuthError(failure.message)),
        (user) async {
          // Ensure Firestore document exists for this user
          await _ensureUserDocument(user, name: name);
          emit(AuthAuthenticated(user));
        },
      );
    } on FirebaseAuthException catch (e) {
      // Map common Firebase auth codes to friendly Arabic messages
      emit(AuthError(_mapFirebaseAuthError(e.code)));
    } catch (e) {
      // Fallback for any unexpected exceptions
      emit(AuthError('حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى'));
    }
  }

  /// طلب إعادة تعيين كلمة المرور
  Future<void> resetPassword({required String email}) async {
    emit(AuthLoading());
    final result = await resetPasswordUseCase(ResetPasswordParams(email: email));
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthPasswordResetSent()),
    );
  }

  // Create a Firestore users/{uid} doc if missing. Optional name to set on creation.
  Future<void> _ensureUserDocument(UserEntity user, {String? name}) async {
    try {
      final docRef = _firestore.collection('users').doc(user.id);
      final snapshot = await docRef.get();
      if (!snapshot.exists) {
        await docRef.set({
          'name': name ?? user.name,
          'email': user.email,
          'phone': user.phone,
          'photo_url': user.photoUrl,
          'address': user.address,
          'latitude': user.latitude,
          'longitude': user.longitude,
          'created_at': FieldValue.serverTimestamp(),
          'is_active': user.isActive,
        });
      }
    } catch (e) {
      // Log or ignore — do not block auth flow if Firestore fails in a transient way.
      // Add lightweight telemetry: print for now; if you use Crashlytics, record the error there too.
      debugPrint('ensureUserDocument failed for ${user.id}: $e');
    }
  }

  /// Ensure a Firestore users/{uid} doc exists for the currently signed-in Firebase user.
  /// This is used when the app receives auth state changes from Firebase native SDKs
  /// (e.g., sign-in from other flows). It creates a minimal doc if missing.
  Future<void> ensureUserDocumentFromFirebaseUser() async {
    try {
      final fbUser = FirebaseAuth.instance.currentUser;
      if (fbUser == null) return;
      final docRef = _firestore.collection('users').doc(fbUser.uid);
      final snapshot = await docRef.get();
      if (!snapshot.exists) {
        await docRef.set({
          'name': fbUser.displayName ?? '',
          'email': fbUser.email,
          'created_at': FieldValue.serverTimestamp(),
          'is_active': true,
        });
        debugPrint('Created Firestore user doc for ${fbUser.uid} from native auth state.');
      }
    } catch (e) {
      debugPrint('ensureUserDocumentFromFirebaseUser failed: $e');
    }
  }

  /// تسجيل الخروج
  Future<void> signOut() async {
    emit(AuthLoading());
    final result = await signOutUseCase();
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthUnauthenticated()),
    );
  }

  /// مسح رسالة الخطأ
  void clearError() {
    if (state is AuthError) {
      emit(AuthUnauthenticated());
    }
  }

  // Map FirebaseAuthException codes to Arabic user-friendly messages
  String _mapFirebaseAuthError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'البريد الإلكتروني غير صالح';
      case 'user-not-found':
        return 'المستخدم غير موجود';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'email-already-in-use':
        return 'البريد الإلكتروني مستخدم بالفعل';
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً';
      case 'user-disabled':
        return 'تم تعطيل هذا الحساب';
      case 'too-many-requests':
        return 'محاولات كثيرة، يرجى المحاولة لاحقاً';
      case 'operation-not-allowed':
        return 'العملية غير مسموحة';
      case 'network-request-failed':
        return 'فشل في الاتصال بالشبكة';
      default:
        return 'فشل في المصادقة. يرجى المحاولة لاحقاً';
    }
  }
}

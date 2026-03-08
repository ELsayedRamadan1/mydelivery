import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signIn({required String email, required String password});
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
    String? phone,
  });
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Future<void> resetPassword({required String email});
  Future<UserModel> updateProfile({
    required String userId,
    String? name,
    String? phone,
    String? photoUrl,
    String? address,
  });
  Stream<UserModel?> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
  });

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Attempt to read the user's Firestore document. If that fails due to
      // permissions, fall back to using the FirebaseAuth user info directly.
      try {
        final userDoc = await firestore
            .collection('users')
            .doc(credential.user!.uid)
            .get();

        if (!userDoc.exists) {
          // If the user exists in Firebase Auth but has no Firestore document,
          // create a minimal user document using available Firebase User info.
          final fbUser = credential.user!;
          final userModel = UserModel(
            id: fbUser.uid,
            name: fbUser.displayName ?? '',
            email: fbUser.email ?? email,
            phone: fbUser.phoneNumber,
            photoUrl: fbUser.photoURL,
            createdAt: DateTime.now(),
            isActive: true,
          );

          // Try to save a minimal document to Firestore; if it fails (e.g.,
          // permission-denied), log and continue returning the model so the
          // auth flow is not blocked by Firestore rules.
          try {
            await firestore.collection('users').doc(fbUser.uid).set(userModel.toFirestore());
          } catch (e) {
            // Non-fatal: Firestore rules might prevent client writes. Log and continue.
            // Do not rethrow so sign-in succeeds even if Firestore access is restricted.
            // If you want telemetry, record this exception to your logging backend.
            // ignore: avoid_print
            print('Warning: failed to create Firestore user doc for ${fbUser.uid}: $e');
          }

          return userModel;
        }

        return UserModel.fromFirestore(userDoc.data()!, userDoc.id);
      } on FirebaseException catch (e) {
        // Permission or network errors when accessing Firestore should not
        // block sign-in. Fallback to FirebaseAuth user info.
        final fbUser = credential.user!;
        final fallback = UserModel(
          id: fbUser.uid,
          name: fbUser.displayName ?? '',
          email: fbUser.email ?? email,
          phone: fbUser.phoneNumber,
          photoUrl: fbUser.photoURL,
          createdAt: DateTime.now(),
          isActive: true,
        );
        // ignore: avoid_print
        print('Firestore read failed for ${fbUser.uid}, returning auth-only user: ${e.code}');
        return fallback;
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: _mapFirebaseAuthError(e.code));
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user?.updateDisplayName(name);

      final userModel = UserModel(
        id: credential.user!.uid,
        name: name,
        email: email,
        phone: phone,
        createdAt: DateTime.now(),
        isActive: true,
      );

      // Save to Firestore
      await firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(userModel.toFirestore());

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: _mapFirebaseAuthError(e.code));
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await firebaseAuth.signOut();
    } catch (e) {
      throw ServerException(message: 'فشل تسجيل الخروج');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) return null;

      final userDoc =
          await firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) return null;

      return UserModel.fromFirestore(userDoc.data()!, userDoc.id);
    } catch (e) {
      throw ServerException(message: 'فشل الحصول على بيانات المستخدم');
    }
  }

  @override
  Future<void> resetPassword({required String email}) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: _mapFirebaseAuthError(e.code));
    }
  }

  @override
  Future<UserModel> updateProfile({
    required String userId,
    String? name,
    String? phone,
    String? photoUrl,
    String? address,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (phone != null) updateData['phone'] = phone;
      if (photoUrl != null) updateData['photo_url'] = photoUrl;
      if (address != null) updateData['address'] = address;

      await firestore.collection('users').doc(userId).update(updateData);

      final updatedDoc =
          await firestore.collection('users').doc(userId).get();
      return UserModel.fromFirestore(updatedDoc.data()!, updatedDoc.id);
    } catch (e) {
      throw ServerException(message: 'فشل تحديث البيانات');
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return firebaseAuth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      try {
        final doc =
            await firestore.collection('users').doc(user.uid).get();
        if (!doc.exists) return null;
        return UserModel.fromFirestore(doc.data()!, doc.id);
      } catch (e) {
        return null;
      }
    });
  }

  String _mapFirebaseAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'المستخدم غير موجود';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'email-already-in-use':
        return 'البريد الإلكتروني مستخدم بالفعل';
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صالح';
      case 'user-disabled':
        return 'تم تعطيل هذا الحساب';
      case 'too-many-requests':
        return 'محاولات كثيرة، يرجى المحاولة لاحقاً';
      default:
        return 'حدث خطأ في المصادقة';
    }
  }
}

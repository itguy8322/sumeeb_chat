import 'package:firebase_auth/firebase_auth.dart';

class FireauthRepository {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final collection = "users";
  FireauthRepository();

  Future<Map<String, dynamic>> sendOTPCode(String phone) async {
    String _verificationId = '';
    int _resendToken = 0;

    await auth.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto verification on Android
        await auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {},
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        _resendToken = resendToken ?? 0;
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
    return {
      'verificationId': _verificationId,
      'codeSent': _verificationId.isNotEmpty ? true : false,
      'resendToken': _resendToken,
    };
  }

  Future<bool> verifyOTP(String otp, String verificationId) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );

    try {
      await auth.signInWithCredential(credential);
      return true;
    } catch (e) {
      print("$e");
      return false;
    }
  }
}

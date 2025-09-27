import 'package:sumeeb_chat/data/models/user/user_model.dart';

class OtpVerificationState {
  final String phone;
  final String otp;
  final bool sendingOtp;
  final bool verifyingOtp;
  final bool optSent;
  final bool otpVerified;
  final String errorMessage;
  final String verificationId;
  final String resendToken;
  final AppUser? user;
  OtpVerificationState({
    required this.phone,
    required this.otp,
    required this.sendingOtp,
    required this.verifyingOtp,
    required this.optSent,
    required this.otpVerified,
    required this.errorMessage,
    required this.verificationId,
    required this.resendToken,
    required this.user,
  });

  factory OtpVerificationState.initial() {
    return OtpVerificationState(
      phone: '',
      otp: '',
      sendingOtp: false,
      verifyingOtp: false,
      optSent: false,
      otpVerified: false,
      errorMessage: '',
      verificationId: '',
      resendToken: '',
      user: null,
    );
  }

  OtpVerificationState copyWith({
    String? phone,
    String? otp,
    bool? sendingOtp,
    bool? verifyingOtp,
    bool? optSent,
    bool? otpVerified,
    String? errorMessage,
    String? verificationId,
    String? resendToken,
    AppUser? user,
  }) {
    return OtpVerificationState(
      phone: phone ?? this.phone,
      otp: otp ?? this.otp,
      sendingOtp: sendingOtp ?? this.sendingOtp,
      verifyingOtp: verifyingOtp ?? this.verifyingOtp,
      optSent: optSent ?? this.optSent,
      otpVerified: otpVerified ?? this.otpVerified,
      errorMessage: errorMessage ?? this.errorMessage,
      verificationId: verificationId ?? this.verificationId,
      resendToken: resendToken ?? this.resendToken,
      user: user ?? this.user,
    );
  }
}

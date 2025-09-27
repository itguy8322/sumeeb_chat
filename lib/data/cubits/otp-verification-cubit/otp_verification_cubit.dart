import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sumeeb_chat/data/cubits/otp-verification-cubit/otp_verification_state.dart';
import 'package:sumeeb_chat/data/repositories/fireauth/fireauth_repository.dart';

class OtpVerificationCubit extends Cubit<OtpVerificationState> {
  FireauthRepository auth;
  OtpVerificationCubit(this.auth) : super(OtpVerificationState.initial());

  sendOtp(String phone) async {
    emit(
      state.copyWith(
        phone: phone,
        sendingOtp: true,
        verifyingOtp: null,
        otpVerified: null,
      ),
    );
    try {
      final authData = await auth.sendOTPCode(phone);
      print("################ ############## ######################");
      print(authData);
      print("################ ############## ######################");
      if (authData["codeSent"]) {
        print("################ ############## ######################");
        print("############### OTP SENT #####################");
        emit(
          state.copyWith(
            phone: phone,
            sendingOtp: false,
            optSent: true,
            verificationId: authData['verificationId'],
            resendToken: authData['resendToken'],
          ),
        );
      } else {
        emit(state.copyWith(sendingOtp: false, optSent: false));
      }
    } catch (e) {
      emit(state.copyWith(sendingOtp: false));
    }
  }

  verifyOTP(String otp) async {
    emit(state.copyWith(verifyingOtp: true, sendingOtp: null, optSent: null));
    final status = await auth.verifyOTP(otp, state.verificationId);
    if (status) {
      emit(state.copyWith(otpVerified: status, verifyingOtp: false));
    } else {
      emit(state.copyWith(otpVerified: status, verifyingOtp: false));
    }
  }
}

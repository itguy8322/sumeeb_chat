import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:sumeeb_chat/data/cubits/otp-verification-cubit/otp_verification_cubit.dart';
import 'package:sumeeb_chat/data/cubits/otp-verification-cubit/otp_verification_state.dart';
import 'package:sumeeb_chat/data/cubits/user-cubit/user_cubit.dart';
import 'package:sumeeb_chat/data/cubits/user-cubit/user_state.dart';
import 'package:sumeeb_chat/pages/login/other_info_step.dart';

class OtpVerificationPage extends StatelessWidget {
  OtpVerificationPage({super.key});
  final otp = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Theme.of(context).colorScheme.primary,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              MultiBlocListener(
                listeners: [
                  BlocListener<OtpVerificationCubit, OtpVerificationState>(
                    listener: (context, state) {
                      if (state.otpVerified) {
                        context.read<UserCubit>().loadUser(state.phone);
                      }
                    },
                  ),
                  BlocListener<UserCubit, UserState>(
                    listener: (context, state) {
                      if (state.user != null) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OtherInfoStep(),
                          ),
                        );
                      }
                    },
                  ),
                ],
                child: SizedBox(),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.15),
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(shape: BoxShape.circle),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 70,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(70),
                        child: Image.asset("assets/images/logo.png"),
                      ),
                    ),
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: Icon(
                          Icons.security,
                          size: 30,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              Text(
                "OTP Verification",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              BlocBuilder<OtpVerificationCubit, OtpVerificationState>(
                builder: (context, state) {
                  return Text(
                    "Enter the otp sent to ${state.phone}",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
                  );
                },
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              Padding(
                padding: const EdgeInsets.fromLTRB(3, 0, 3, 0),
                child: BlocBuilder<OtpVerificationCubit, OtpVerificationState>(
                  builder: (context, state) {
                    return PinCodeTextField(
                      controller: otp,
                      enabled: state.verifyingOtp ? false : true,
                      appContext: context,
                      length: 6,
                      autoFocus: true,
                      onChanged: (value) {},
                      keyboardType: TextInputType.number,
                      cursorColor: Colors.white,
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.underline,
                        fieldHeight: 60,
                        fieldWidth: 50,
                        activeFillColor: Colors.transparent,
                        inactiveFillColor: Colors.transparent,
                        selectedFillColor: Colors.transparent,
                        borderWidth: 1,
                        activeColor: Colors.white,
                        inactiveColor: Colors.white54,
                        selectedColor: Colors.orange,
                      ),
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                      onCompleted: (value) {
                        context.read<OtpVerificationCubit>().verifyOTP(value);
                      },
                    );
                  },
                ),
              ),
              BlocBuilder<OtpVerificationCubit, OtpVerificationState>(
                builder: (context, state) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't receive the OTP?"),
                      TextButton(
                        onPressed: state.sendingOtp ? null : () {},
                        child: Text(
                          "Resend OTP",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.15),
              BlocBuilder<OtpVerificationCubit, OtpVerificationState>(
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: state.verifyingOtp
                        ? null
                        : () async {
                            // if (!_formKey.currentState!.validate()) {
                            //   return;
                            // }
                            if (otp.text.isNotEmpty) {
                              context.read<OtpVerificationCubit>().verifyOTP(
                                otp.text,
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: state.verifyingOtp
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            state.verifyingOtp ? "Verifiying..." : "Verify",
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.surface,
                            ),
                          ),
                  );
                },
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            ],
          ),
        ),
      ),
    );
  }
}

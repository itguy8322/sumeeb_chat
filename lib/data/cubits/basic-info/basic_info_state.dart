class BasicInfoState {
  final String? name;
  final String? profilePhoto;
  final bool uploadingPhotonInProgress;
  final bool uploadingPhotonSuccess;
  final bool uploadingPhotonFailure;
  final bool loadingInProgress;
  final bool loadingSuccess;
  final bool loadingFailure;
  const BasicInfoState({
    required this.name,
    required this.profilePhoto,
    required this.uploadingPhotonInProgress,
    required this.uploadingPhotonSuccess,
    required this.uploadingPhotonFailure,
    required this.loadingInProgress,
    required this.loadingSuccess,
    required this.loadingFailure,
  });
  factory BasicInfoState.initial() {
    return BasicInfoState(
      name: null,
      profilePhoto: null,
      uploadingPhotonInProgress: false,
      uploadingPhotonSuccess: false,
      uploadingPhotonFailure: false,
      loadingInProgress: false,
      loadingSuccess: false,
      loadingFailure: false,
    );
  }
  BasicInfoState copyWith({
    String? name,
    String? profilePhoto,
    bool? uploadingPhotonInProgress,
    bool? uploadingPhotonSuccess,
    bool? uploadingPhotonFailure,
    bool? loadingInProgress,
    bool? loadingSuccess,
    bool? loadingFailure,
  }) {
    return BasicInfoState(
      name: name ?? this.name,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      uploadingPhotonInProgress:
          uploadingPhotonInProgress ?? this.uploadingPhotonInProgress,
      uploadingPhotonSuccess:
          uploadingPhotonSuccess ?? this.uploadingPhotonSuccess,
      uploadingPhotonFailure:
          uploadingPhotonFailure ?? this.uploadingPhotonFailure,
      loadingInProgress: loadingInProgress ?? this.loadingInProgress,
      loadingSuccess: loadingSuccess ?? this.loadingSuccess,
      loadingFailure: loadingFailure ?? this.loadingFailure,
    );
  }
}

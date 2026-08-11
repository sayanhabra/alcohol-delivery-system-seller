// enum VerificationStatus {
//   draft('DRAFT'),
//   pendingApproval('PENDING_APPROVAL'),
//   autoVerified('AUTO_VERIFIED'),
//   manualReviewRequired('MANUAL_REVIEW_REQUIRED'),
//   verified('VERIFIED'),
//   rejected('REJECTED'),
//   suspended('SUSPENDED'),
//   unknown('UNKNOWN');

//   final String value;
//   const VerificationStatus(this.value);

//   factory VerificationStatus.fromString(String? raw) {
//     if (raw == null) return VerificationStatus.unknown;

//     return VerificationStatus.values.firstWhere(
//       (e) => e.value == raw,
//       orElse: () => VerificationStatus.unknown,
//     );
//   }

//   bool get isDraft => this == VerificationStatus.draft;

//   bool get isPendingApproval => this == VerificationStatus.pendingApproval;

//   bool get isAutoVerified => this == VerificationStatus.autoVerified;

//   bool get isManualReviewRequired =>
//       this == VerificationStatus.manualReviewRequired;

//   bool get isVerified => this == VerificationStatus.verified;

//   bool get isRejected => this == VerificationStatus.rejected;

//   bool get isSuspended => this == VerificationStatus.suspended;
// }

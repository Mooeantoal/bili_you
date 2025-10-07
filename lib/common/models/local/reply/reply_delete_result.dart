class ReplyDeleteResult {
  ReplyDeleteResult({required this.isSuccess, required this.error});
  static ReplyDeleteResult get zero =>
      ReplyDeleteResult(isSuccess: false, error: '');
  bool isSuccess;
  String error;
}
import '../common.dart';

class LoadingDialog {
  static BuildContext loadingCtx;
  static BuildContext errorCtx;

  showLoad(BuildContext context) => showDialog(
      barrierDismissible: false,
      context: context,
      builder: (ctx) {
        loadingCtx = ctx;
        return Center(child: CircularProgressIndicator());
      });

  dispLoad() {
    Navigator.of(loadingCtx).pop();
  }

  showError(BuildContext context, String errorMessage) => showDialog(
      barrierDismissible: false,
      context: context,
      builder: (ctx) {
        errorCtx = ctx;
        return AlertDialog(
          content: Text(validation(errorMessage, context)),
          actions: [
            TextButton(
              child: Text('Ок'),
              onPressed: () => Navigator.of(errorCtx).pop(),
            )
          ],
        );
      });

  String validation(String error, context) {
    AppLocalizations loc = AppLocalizations.of(context);
    String errorMessage;
    if (error == 'user-not-found') {
      errorMessage = loc.user_not_found;
    } else if (error == 'wrong-password') {
      errorMessage = loc.wrong_password;
    } else if (error.contains('invalid-email')) {
      errorMessage = loc.invalid_email;
    } else if (error == 'too-many-requests') {
      errorMessage = loc.too_many_requests;
    } else if (error == 'unverified-email') {
      errorMessage = loc.email_not_verified;
    } else if (error == 'requires-recent-login') {
      errorMessage = loc.req_recent_login;
    } else {
      errorMessage = loc.error;
    }
    return errorMessage;
  }
}

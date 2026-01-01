import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';

class MailUtils {
  static Future<void> openEmail({
    required String toEmail,
    String subject = '',
    String body = '',
  }) async {

    // Manually encode text because Uri(queryParameters) converts spaces to +
    final String encodedSubject = Uri.encodeComponent(subject);
    final String encodedBody = Uri.encodeComponent(body);

    final Uri mailUri = Uri.parse(
      "mailto:$toEmail?subject=$encodedSubject&body=$encodedBody",
    );

    try {
      if (!await launchUrl(mailUri)) {
        Get.snackbar("Error", "Could not open mail client",
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar("Error", "Unable to open email: $e",
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}

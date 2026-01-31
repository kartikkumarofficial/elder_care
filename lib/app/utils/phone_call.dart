import 'package:url_launcher/url_launcher.dart';

Future<void> makePhoneCall(String phoneNumber) async {
  if (phoneNumber.isEmpty) return;

  final Uri callUri = Uri(
    scheme: 'tel',
    path: phoneNumber,
  );

  if (!await canLaunchUrl(callUri)) {
    throw 'Could not launch dialer';
  }

  await launchUrl(
    callUri,
    mode: LaunchMode.externalApplication,
  );
}

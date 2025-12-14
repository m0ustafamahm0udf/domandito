import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_platforms_serv.dart';
import 'get_device_serv.dart';

class LaunchUrlsService {
  void launchWhatsApp({
    required String phone,
    required BuildContext context,
    String message = '',
  }) async {
    String phoneNumber = phone.replaceAll('+', '');
    if (phoneNumber.startsWith('0')) {
      phoneNumber = phoneNumber.substring(1);
    }

    // Encode the message to be URL-safe
    String encodedMessage = Uri.encodeComponent(message);

    // Create the WhatsApp URL with message
    String whatsappUrl = "https://wa.me/20$phoneNumber?text=$encodedMessage";
    Uri uri = Uri.parse(whatsappUrl);

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void launchCall({required String phone}) async {
    Uri phoneNumber = Uri.parse('tel:$phone');
    // log(phoneNumber.toString());
    await launchUrl(phoneNumber, mode: LaunchMode.externalApplication);
  }

  void launchEmail(String email, String subject) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {'subject': subject},
    );

    if (await canLaunchUrl(Uri.parse(emailLaunchUri.toString()))) {
      await launchUrl(Uri.parse(emailLaunchUri.toString()));
    } else {}
  }

  void launchFileDownload(
    String url, {
    LaunchMode mode = LaunchMode.externalApplication,
  }) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: mode);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> launchBrowesr({
    required String uri,
    required BuildContext context,
  }) async {
    Uri url = Uri.parse(uri);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  void openMap(double lat, double long) async {
    Uri url;

    final platform = PlatformService.platform;
    if (AppPlatform.iosApp == platform) {
      // 📍 Apple Maps
      url = Uri.parse('http://maps.apple.com/?q=$lat,$long');
    } else {
      // 📍 Google Maps
      url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$lat,$long',
      );
    }

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }
}

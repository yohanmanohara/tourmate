import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  Future<void> sendFeedbackEmail(Map<String, String> emailData) async {
    try {
      final zohoUsername = dotenv.env['ZOHO_MAIL_USERNAME'];
      final zohoPassword = dotenv.env['ZOHO_MAIL_PASSWORD'];
      final adminEmail = dotenv.env['ADMIN_EMAIL'];

      if (zohoUsername == null || zohoPassword == null || adminEmail == null) {
        throw Exception(
            'Zoho Mail credentials not found in environment variables');
      }

      // Configure Zoho Mail SMTP server
      final smtpServer = SmtpServer(
        'smtp.zoho.com',
        port: 587,
        username: zohoUsername,
        password: zohoPassword,
        ssl: false,
        allowInsecure: false,
      );

      // Create the email message
      final message = Message()
        ..from = Address(zohoUsername, 'TourMate Support')
        ..recipients.add(adminEmail)
        ..subject = '${emailData['subject']}'
        ..text = _buildEmailText(emailData)
        ..html = _buildEmailHtml(emailData);

      // Send email
      final sendReport = await send(message, smtpServer);

      print('Message sent: ${sendReport.toString()}');
    } catch (e) {
      print('Error sending email: $e');
      rethrow;
    }
  }

  String _buildEmailText(Map<String, String> data) {
    return '''
Feedback from TourMate App

Type: ${data['type']}
From: ${data['name']} (${data['email']})
Subject: ${data['subject']}

Message:
${data['message']}

Sent from TourMate app on ${DateTime.now().toString()}
''';
  }

  String _buildEmailHtml(Map<String, String> data) {
    return '''
<!DOCTYPE html>
<html>
<head>
  <style>
    body { font-family: Arial, sans-serif; margin: 0; padding: 20px; color: #333; }
    .container { max-width: 600px; margin: 0 auto; border: 1px solid #ddd; border-radius: 8px; overflow: hidden; }
    .header { background-color: #673AB7; color: white; padding: 15px 20px; }
    .content { padding: 20px; }
    .footer { background-color: #f5f5f5; padding: 15px 20px; font-size: 12px; color: #777; }
    .field { margin-bottom: 15px; }
    .label { font-weight: bold; margin-bottom: 5px; }
    .message-box { background-color: #f9f9f9; border: 1px solid #eee; border-radius: 4px; padding: 15px; margin-top: 5px; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h2>TourMate Feedback</h2>
    </div>
    <div class="content">
      <div class="field">
        <div class="label">Feedback Type:</div>
        <div>${data['type']}</div>
      </div>
      <div class="field">
        <div class="label">From:</div>
        <div>${data['name']} (${data['email']})</div>
      </div>
      <div class="field">
        <div class="label">Subject:</div>
        <div>${data['subject']}</div>
      </div>
      <div class="field">
        <div class="label">Message:</div>
        <div class="message-box">${data['message']?.replaceAll('\n', '<br>')}</div>
      </div>
    </div>
    <div class="footer">
      This message was sent from the TourMate app on ${DateTime.now().toString()}
    </div>
  </div>
</body>
</html>
''';
  }
}

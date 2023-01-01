import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:string_validator/string_validator.dart';
import 'package:tools_of_worship_server/properties.dart';

class EmailRelay {
  static Future<bool> sendNoReplyEmail(
      String to, String subject, String content) async {
    dynamic request = {
      'personalizations': [
        {
          'to': [
            {
              'email': normalizeEmail(to),
            }
          ]
        }
      ],
      'from': {
        'email': 'no-reply@${Properties.domain}',
        'name': 'Tools of Worship',
      },
      'subject': subject,
      'content': [
        {
          'type': 'text/html',
          'value': content,
        }
      ]
    };

    String body = json.encode(request);

    final http.Response response = await http.post(
      Uri.parse('https://api.sendgrid.com/v3/mail/send'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer ${Properties.sendGridApiKey}',
        HttpHeaders.contentTypeHeader: ContentType.json.mimeType
      },
      body: body,
    );

    if (response.statusCode == HttpStatus.accepted) {
      return true;
    }

    print(
        'Error sending mail - Code: ${response.statusCode} data: ${response.body}');

    return false;
  }
}

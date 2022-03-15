import 'dart:io';

import 'package:shelf/shelf.dart';

Middleware handleCors() {
  const corsHeaders = {
    HttpHeaders.accessControlAllowOriginHeader: '*',
    HttpHeaders.accessControlAllowMethodsHeader: 'GET, POST, PUT, DELETE',
    HttpHeaders.accessControlAllowHeadersHeader: '',
  };

  return createMiddleware(
    requestHandler: (Request request) {
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: corsHeaders);
      }

      return null;
    },
    responseHandler: (Response response) {
      return response.change(headers: corsHeaders);
    },
  );
}

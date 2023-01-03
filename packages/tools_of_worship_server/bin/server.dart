import 'dart:io';

import 'package:args/args.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_hotreload/shelf_hotreload.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_static/shelf_static.dart';
import 'package:tools_of_worship_server/tools_of_worship_server.dart';

void main(List<String> args) async {
  ArgParser parser = ArgParser()
    ..addOption('https')
    ..addOption('port', abbr: 'p');
  ArgResults result = parser.parse(args);
  // For running in containers, we respect the PORT environment variable.
  String httpsString =
      result['https'] ?? Platform.environment['USEHTTPS'] ?? 'false';
  final useHttps = httpsString == 'true';
  String portStr = result['port'] ??
      Platform.environment['PORT'] ??
      (useHttps ? '443' : '80');
  final port = int.tryParse(portStr);

  if (port == null) {
    print('Could not parse port value "$portStr" into a number.');
    // 64: command line usage error.
    exitCode = 64;
    return;
  }

  print('Connecting to database.');
  final db = await Db.create(Properties.databaseURI);
  await db.open();
  if (db.isConnected) {
    print('Database connected.');
  }

  Router router = Router()
    ..mount('/apis/', ToolsOfWorshipApi(db).handler)
    ..mount(
      '/',
      createStaticHandler('${Properties.publicUri}/app',
          defaultDocument: 'index.html'),
    );

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(handleCors())
      .addHandler(router);

  SecurityContext? securityContext;
  if (useHttps) {
    print('Using SSL certificates.');
    securityContext = SecurityContext()
      ..useCertificateChain('${Properties.certificatesUri}/server_chain.pem')
      ..usePrivateKey('${Properties.certificatesUri}/server_key.pem');
  }

  withHotreload(() => serve(handler, InternetAddress.anyIPv4, port,
      securityContext: securityContext));
}

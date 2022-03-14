import 'dart:io';

import 'package:args/args.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_hotreload/shelf_hotreload.dart';
import 'package:shelf_static/shelf_static.dart';
import 'package:tools_of_worship_server/tools_of_worship_server.dart';

// ..get('/', _rootHandler);
// ..get('/oauth2callback', oauth2callback);
// shelf.Response _rootHandler(shelf.Request request) {
//   Map<String, String> headers = {'location': '/oauth2callback'};
//   return shelf.Response(302, headers: headers);
// }
// shelf.Response oauth2callback(shelf.Request request) {
//   return shelf.Response.ok('Redirected!\n');
// }

void main(List<String> args) async {
  ArgParser parser = ArgParser()..addOption('port', abbr: 'p');
  ArgResults result = parser.parse(args);
  // For running in containers, we respect the PORT environment variable.
  String portStr =
      result['port'] ?? Platform.environment['PORT'] ?? '8080' /*'443'*/;
  final port = int.tryParse(portStr);

  if (port == null) {
    print('Could not parse port value "$portStr" into a number.');
    // 64: command line usage error.
    exitCode = 64;
    return;
  }

  print('Connecting to database.');
  final _db = await Db.create(Properties.databaseURI);
  await _db.open();
  if (_db.isConnected) {
    print('Database connected.');
  }

  final _staticHandler =
      createStaticHandler(Properties.publicUri, defaultDocument: 'index.html');

  Cascade cascade =
      Cascade().add(_staticHandler).add(ToolsOfWorshipApi(_db).handler);

  final _handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(handleCors())
      .addHandler(cascade.handler);

  // SecurityContext securityContext = SecurityContext()
  //   ..useCertificateChain(
  //       '${Properties.certificatesUri}/server_chain.pem')
  //   ..usePrivateKey('${Properties.certificatesUri}/server_key.pem');

  withHotreload(() => serve(_handler, InternetAddress.anyIPv4,
      port /*, securityContext: securityContext*/));
}

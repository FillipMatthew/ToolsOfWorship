import 'package:mongo_dart/mongo_dart.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:tools_of_worship_server/src/apis/feed.dart';
import 'package:tools_of_worship_server/src/apis/fellowships.dart';
import 'package:tools_of_worship_server/src/apis/users.dart';
import 'package:tools_of_worship_server/src/helpers/account_authentication.dart';

class ToolsOfWorshipApi {
  final Db _db;

  ToolsOfWorshipApi(Db db) : _db = db;

  Handler get handler {
    Router router = Router();

    router.mount('/apis/Users/', ApiUsers(_db).router);
    router.mount('/apis/Fellowships/', ApiFellowships(_db).router);
    router.mount('/apis/Feed/', ApiFeed(_db).router);

    final _handler = Pipeline()
        .addMiddleware(AccountAuthentication.handleAuth())
        .addMiddleware(AccountAuthentication.checkAuthorisation())
        .addHandler(router);

    return _handler;
  }
}

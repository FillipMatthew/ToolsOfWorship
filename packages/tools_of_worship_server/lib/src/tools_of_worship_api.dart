import 'package:mongo_dart/mongo_dart.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:tools_of_worship_api/tools_of_worship_server_api.dart';

import 'data/circles_db.dart';
import 'data/feed_db.dart';
import 'data/fellowships_db.dart';
import 'data/users_db.dart';

class ToolsOfWorshipApi {
  final Db _db;
  final UsersDataProvider _usersProvider;
  final FellowshipsDataProvider _fellowshipsProvider;
  final CirclesDataProvider _circlesProvider;
  final FeedDataProvider _feedProvider;

  ToolsOfWorshipApi(Db db)
      : _db = db,
        _usersProvider = UsersDatabase(
            db.collection('Users'), db.collection('UserConnections')),
        _fellowshipsProvider = FellowshipsDatabase(
            db.collection('Fellowships'), db.collection('FellowshipMembers')),
        _circlesProvider = CirclesDatabase(
            db.collection('Circles'), db.collection('CircleMembers')),
        _feedProvider = FeedDatabase(
            db.collection('Posts'),
            FellowshipsDatabase(db.collection('Fellowships'),
                db.collection('FellowshipMembers')),
            CirclesDatabase(
                db.collection('Circles'), db.collection('CircleMembers')));

  Handler get handler {
    Router router = Router();

    router.mount('/Users/', ApiUsers(_usersProvider).router);
    router.mount('/Fellowships/', ApiFellowships(_fellowshipsProvider).router);
    router.mount('/Feed/', ApiFeed(_feedProvider).router);

    final handler = Pipeline()
        .addMiddleware(AccountManagement.handleAuth())
        .addMiddleware(AccountManagement.checkAuthorisation())
        .addMiddleware(createMiddleware(requestHandler: _dbConnectionManager))
        .addHandler(router);

    return handler;
  }

  Future<Response?> _dbConnectionManager(Request request) async {
    while (_db.state == State.opening) {
      await Future.delayed(Duration(milliseconds: 100));
    }

    if (_db.isConnected) return null;
    await _db.close();
    await _db.open();

    if (!_db.isConnected) return Response.internalServerError();

    return null;
  }
}

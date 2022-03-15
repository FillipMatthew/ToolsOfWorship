import 'package:mongo_dart/mongo_dart.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:tools_of_worship_server/src/apis/feed.dart';
import 'package:tools_of_worship_server/src/apis/fellowships.dart';
import 'package:tools_of_worship_server/src/apis/users.dart';
import 'package:tools_of_worship_server/src/helpers/account_authentication.dart';

class ToolsOfWorshipApi {
  final Db _db;
  final DbCollection _userConnectionsCollection;
  final DbCollection _usersCollection;
  final DbCollection _postsCollection;
  final DbCollection _fellowshipsCollection;
  final DbCollection _fellowshipMembersCollection;
  final DbCollection _circlesCollection;
  final DbCollection _circleMembersCollection;

  ToolsOfWorshipApi(Db db)
      : _db = db,
        _userConnectionsCollection = db.collection('UserConnections'),
        _usersCollection = db.collection('Users'),
        _postsCollection = db.collection('Posts'),
        _fellowshipsCollection = db.collection('Fellowships'),
        _fellowshipMembersCollection = db.collection('FellowshipMembers'),
        _circlesCollection = db.collection('Circles'),
        _circleMembersCollection = db.collection('CircleMembers');

  Handler get handler {
    Router router = Router();

    router.mount('/apis/Users/',
        ApiUsers(_userConnectionsCollection, _usersCollection).router);
    router.mount(
        '/apis/Fellowships/',
        ApiFellowships(_fellowshipsCollection, _fellowshipMembersCollection)
            .router);
    router.mount(
        '/apis/Feed/',
        ApiFeed(
                _usersCollection,
                _postsCollection,
                _fellowshipsCollection,
                _fellowshipMembersCollection,
                _circlesCollection,
                _circleMembersCollection)
            .router);

    final _handler = Pipeline()
        .addMiddleware(AccountAuthentication.handleAuth())
        .addMiddleware(AccountAuthentication.checkAuthorisation())
        .addHandler(router);

    return _handler;
  }
}

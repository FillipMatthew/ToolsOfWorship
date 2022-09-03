import 'package:mongo_dart/mongo_dart.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:tools_of_worship_server/src/apis/feed.dart';
import 'package:tools_of_worship_server/src/apis/fellowships.dart';
import 'package:tools_of_worship_server/src/apis/users.dart';
import 'package:tools_of_worship_server/src/data/fellowships_db.dart';
import 'package:tools_of_worship_server/src/data/users_db.dart';
import 'package:tools_of_worship_server/src/helpers/account_authentication.dart';
import 'package:tools_of_worship_server/src/interfaces/fellowships_data_provider.dart';
import 'package:tools_of_worship_server/src/interfaces/users_data_provider.dart';

class ToolsOfWorshipApi {
  final UsersDataProvider _usersDataProvider;
  final FellowshipsDataProvider _fellowshipsDataProvider;
  final DbCollection _circlesCollection;
  final DbCollection _circleMembersCollection;
  final DbCollection _postsCollection;

  ToolsOfWorshipApi(Db db)
      : _usersDataProvider = UsersDatabase(db.collection('Users'), db.collection('UserConnections')),
        _fellowshipsDataProvider = FellowshipsDatabase(
            db.collection('Fellowships'), db.collection('FellowshipMembers')),
        _circlesCollection = db.collection('Circles'),
        _circleMembersCollection = db.collection('CircleMembers'),
        _postsCollection = db.collection('Posts');

  Handler get handler {
    Router router = Router();

    router.mount('/Users/',
        ApiUsers(_usersDataProvider).router);
    router.mount(
        '/Fellowships/', ApiFellowships(_fellowshipsDataProvider).router);
    router.mount(
        '/Feed/',
        ApiFeed(_usersDataProvider, _postsCollection, _fellowshipsDataProvider,
                _circlesCollection, _circleMembersCollection)
            .router);

    final handler = Pipeline()
        .addMiddleware(AccountAuthentication.handleAuth())
        .addMiddleware(AccountAuthentication.checkAuthorisation())
        .addHandler(router);

    return handler;
  }
}

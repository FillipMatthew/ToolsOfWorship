import 'package:mongo_dart/mongo_dart.dart';
import 'package:tools_of_worship_server/src/interfaces/circles_data_provider.dart';
import 'package:tools_of_worship_server/src/interfaces/fellowships_data_provider.dart';
import 'package:tools_of_worship_server/src/interfaces/feed_data_provider.dart';
import 'package:tools_of_worship_server/src/types/access_level.dart';
import 'package:tools_of_worship_server/src/types/circle.dart';
import 'package:tools_of_worship_server/src/types/fellowship.dart';
import 'package:tools_of_worship_server/src/types/post.dart';

class FeedDatabase implements FeedDataProvider {
  final DbCollection _postsCollection;
  final FellowshipsDataProvider _fellowshipsDataProvider;
  final CirclesDataProvider _circlesDataProvider;

  FeedDatabase(
      DbCollection posts,
      FellowshipsDataProvider fellowshipsDataProvider,
      CirclesDataProvider circlesDataProvider)
      : _postsCollection = posts,
        _fellowshipsDataProvider = fellowshipsDataProvider,
        _circlesDataProvider = circlesDataProvider;

  @override
  Stream<Post> getPosts(
      String userId, int? limit, DateTime? before, DateTime? after) async* {
    Stream<Fellowship> fellowships = _fellowshipsDataProvider
        .getUserFellowships(userId, AccessLevel.readOnly);

    List<String> fellowshipIds = [];
    await for (Fellowship item in fellowships) {
      fellowshipIds.add(item.id);
    }

    Stream<Circle> circles =
        _circlesDataProvider.getUserCircles(userId, AccessLevel.readOnly);

    List<String> circleIds = <String>[];
    await for (Circle item in circles) {
      circleIds.add(item.id);
    }

    SelectorBuilder selectorBuilder = where;
    if (fellowshipIds.isNotEmpty) {
      selectorBuilder = selectorBuilder.oneFrom('fellowshipId', fellowshipIds);
    }

    if (circleIds.isNotEmpty) {
      selectorBuilder = selectorBuilder.oneFrom('circleId', circleIds);
    }

    if (before != null) {
      selectorBuilder =
          selectorBuilder.lt('dateTime', before.toUtc().toIso8601String());
    }

    if (after != null) {
      selectorBuilder =
          selectorBuilder.gt('dateTime', after.toUtc().toIso8601String());
    }

    bool descending = (before == null && after != null) ? false : true;
    selectorBuilder =
        selectorBuilder.sortBy('dateTime', descending: descending);
    if (limit != null) {
      selectorBuilder = selectorBuilder.limit(limit);
    }

    if (fellowshipIds.isNotEmpty || circleIds.isNotEmpty) {
      // We should have at least one list of items to filter by.
      var postsResults = _postsCollection.find(selectorBuilder);

      await for (var item in postsResults) {
        yield Post.fromJson(item);
      }
    }
  }

  @override
  Future<bool> create(Post post) async {
    if (!post.isValid) {
      return false;
    }

    Map<String, dynamic> data = {
      'id': post.id,
      'authorId': post.authorId,
      if (post.circleId != null) 'circleId': post.circleId,
      if (post.circleId == null && post.fellowshipId != null)
        'fellowshipId': post.fellowshipId,
      'dateTime': post.dateTime.toUtc().toIso8601String(),
      'heading': post.heading,
      'article': post.article,
    };

    WriteResult result = await _postsCollection.insertOne(data);

    if (result.success) {
      return true;
    }

    return false;
  }
}

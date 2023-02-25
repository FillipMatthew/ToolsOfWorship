import '../../types/post.dart';

abstract class FeedDataProvider {
  Stream<Post> getPosts(
      String userId, int? limit, DateTime? before, DateTime? after);
  Future<bool> create(Post post);
}

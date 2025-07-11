/// Provides all the possible endPoint for Entity
/// IF anything fails, cross check with endpoint <host:port>/utils/urlmap
library;

class EntityEndPoint {
  static String getAll() => '/entity/all';
  static String get() => '/entity/match';
  static String create() => '/entity/create';
  static String getById(int id) => '/entity/$id';
  static String downloadMedia(int id) => '/entity/$id/download/media';
  static String downloadPreview(int id) => '/entity/$id/download/preview';
  static String streamM3U8(int id) => '/entity/$id/stream/m3u8';
  static String streamSegment(int id, String seg) => '/entity/$id/stream/$seg';
  static String update(int id) => '/entity/$id/update';
  static String toBin(int id) => '/entity/$id/to_bin';
  static String restore(int id) => '/entity/$id/restore';
  static String deletePermanent(int id) => '/entity/$id/delete';
  static String filterloopback() => '/entity/filter/loopback';
}

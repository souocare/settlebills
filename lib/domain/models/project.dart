/// A connected Cospend project saved on this device.
///
/// `id` is the local identifier (uuid/string).
/// `projectId` is the public token from the share link: https://<server>/index.php/apps/cospend/s/<token>
class Project {
  const Project({
    required this.id,
    required this.serverUrl,
    required this.projectId,
    required this.name,
  });

  /// Local ID used by the app (uuid/string).
  final String id;

  /// Base server URL (e.g. https://cloud.website.xyz).
  final String serverUrl;

  /// Public project token (from /s/<token>).
  final String projectId;

  /// Project name fetched from the API (can be null until fetched).
  final String? name;
}
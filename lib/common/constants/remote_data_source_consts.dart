import 'package:flutter_dotenv/flutter_dotenv.dart';

class RemoteDataSourceConsts {
  static String baseUrl = dotenv.get("BASE_URL");
  static String cloudName = dotenv.get("CLOUD_NAME");
  static String folderCloudName = dotenv.get("FOLDER_CLOUD_NAME");
  static String mapboxAccessToken = dotenv.env["MAPBOX_ACCESS_TOKEN"] ?? "";
  static String geoapifyApiKey = dotenv.env["GEOAPIFY_API_KEY"] ?? "";
}

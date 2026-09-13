import '../core/api_client.dart';
import '../core/api_config.dart';
import '../core/api_result.dart';
import '../models/jeep_route.dart';

class RouteService {
  const RouteService._();

  static const RouteService instance = RouteService._();

  Future<List<JeepRoute>> fetchRoutes({
    String search = '',
    String? vehicleType,
  }) async {
    final Map<String, String> query = <String, String>{};

    if (search.trim().isNotEmpty) {
      query['search'] = search.trim();
    }

    if (vehicleType != null && vehicleType.isNotEmpty) {
      query['vehicle_type'] = vehicleType;
    }

    final ApiResult result = await ApiClient.instance.get(
      ApiEndpoints.readRoutes,
      query: query,
    );

    if (!result.success) {
      throw ApiException(result.message);
    }

    final List<dynamic>? rows = result.dataAsList;

    if (rows == null) {
      throw ApiException('The server returned an unexpected list format.');
    }

    return rows
        .whereType<Map<String, dynamic>>()
        .map(JeepRoute.fromJson)
        .toList(growable: false);
  }

  Future<JeepRoute> fetchRouteById(int id) async {
    final ApiResult result = await ApiClient.instance.get(
      ApiEndpoints.readRoutes,
      query: <String, String>{'id': '$id'},
    );

    if (!result.success) {
      throw ApiException(result.message);
    }

    final Map<String, dynamic>? row = result.dataAsMap;

    if (row == null) {
      throw ApiException('The server did not return the requested route.');
    }

    return JeepRoute.fromJson(row);
  }

  Future<JeepRoute> createRoute(JeepRoute route) async {
    final ApiResult result = await ApiClient.instance.post(
      ApiEndpoints.createRoute,
      route.toPayload(),
    );

    if (!result.success) {
      throw ApiException(result.message);
    }

    final Map<String, dynamic>? row = result.dataAsMap;

    if (row == null) {
      throw ApiException('The route was not returned after creation.');
    }

    return JeepRoute.fromJson(row);
  }

  Future<JeepRoute> updateRoute(JeepRoute route) async {
    final ApiResult result = await ApiClient.instance.post(
      ApiEndpoints.updateRoute,
      route.toPayload(includeId: true),
    );

    if (!result.success) {
      throw ApiException(result.message);
    }

    final Map<String, dynamic>? row = result.dataAsMap;

    if (row == null) {
      throw ApiException('The route was not returned after the update.');
    }

    return JeepRoute.fromJson(row);
  }

  Future<String> deleteRoute(int id) async {
    final ApiResult result = await ApiClient.instance.post(
      ApiEndpoints.deleteRoute,
      <String, dynamic>{'id': id},
    );

    if (!result.success) {
      throw ApiException(result.message);
    }

    return result.message;
  }
}

import 'api_client.dart';

class RankService {
  int getIntValue(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value.toString()) ?? defaultValue;
  }

  double getDoubleValue(dynamic value, {double defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();

    return double.tryParse(value.toString()) ?? defaultValue;
  }

  Future<List<Map<String, dynamic>>> getActiveRanks() async {
    return ApiClient.getList('/api/ranks');
  }

  Future<Map<String, dynamic>?> getRankByPoints(int points) async {
    return ApiClient.getMap(
      '/api/ranks/by-points',
      queryParameters: {'points': points.toString()},
    );
  }

  Future<Map<String, dynamic>?> getNextRankByPoints(int points) async {
    return ApiClient.getMap(
      '/api/ranks/next',
      queryParameters: {'points': points.toString()},
    );
  }

  Future<Map<String, dynamic>?> getLowestRank() async {
    return ApiClient.getMap('/api/ranks/lowest');
  }

  Future<Map<String, dynamic>> getRankInfoByPoints(int points) async {
    final data = await ApiClient.getMap(
      '/api/ranks/info',
      queryParameters: {'points': points.toString()},
    );

    if (data != null) return data;

    final rankData = await getRankByPoints(points);
    final nextRankData = await getNextRankByPoints(points);

    final currentMin = getIntValue(rankData?['min_points']);
    final nextMin = getIntValue(nextRankData?['min_points']);

    double progress = 1.0;
    int missingPoints = 0;

    if (rankData == null) {
      progress = 0.0;
    } else if (nextRankData != null && nextMin > currentMin) {
      progress = ((points - currentMin) / (nextMin - currentMin)).clamp(0.0, 1.0);
      missingPoints = nextMin - points;
      if (missingPoints < 0) missingPoints = 0;
    }

    return {
      'rank_data': rankData,
      'next_rank_data': nextRankData,
      'rank': rankData?['name']?.toString() ?? 'Đồng',
      'rank_code': rankData?['code']?.toString() ?? 'bronze',
      'rank_discount': getDoubleValue(rankData?['discount_percent']),
      'points': points,
      'progress': progress,
      'missing_points': missingPoints,
      'next_rank_name': nextRankData?['name']?.toString() ?? 'MAX',
      'next_rank_code': nextRankData?['code']?.toString() ?? '',
    };
  }
}

import 'api_service.dart';

class ReportService {
  static Future<Map<String, dynamic>> getAdherenceReport({
    String period = 'week',
    String? startDate,
    String? endDate,
  }) async {
    final params = <String, String>{'period': period};
    if (startDate != null) params['startDate'] = startDate;
    if (endDate != null) params['endDate'] = endDate;

    final queryString = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    final response = await ApiService.get('reports/adherence?$queryString');
    return response['data'] as Map<String, dynamic>;
  }
}

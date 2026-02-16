class ExcelMapper {
  static Map<String, dynamic> fromList<T>(
    List<T> data,
    Map<String, dynamic> Function(T item) toJson,
  ) {
    if (data.isEmpty) {
      return {'headers': <String>[], 'rows': <List<String>>[]};
    }

    final jsonList = data.map(toJson).toList();

    final headers = jsonList.first.keys.toList();

    final rows = jsonList.map((map) {
      return headers.map((h) => map[h]?.toString() ?? '').toList();
    }).toList();

    return {'headers': headers, 'rows': rows};
  }
}

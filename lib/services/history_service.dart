import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/qr_history_item.dart';

/// Reads and writes the list of previously generated QR codes.
/// Uses SharedPreferences (simple key-value local storage) since
/// this task doesn't need a full database.
class HistoryService {
  static const _storageKey = 'qr_history';

  Future<List<QrHistoryItem>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey) ?? [];
    return raw
        .map((entry) => QrHistoryItem.fromJson(jsonDecode(entry)))
        .toList()
        .reversed // newest first
        .toList();
  }

  Future<void> addToHistory(QrHistoryItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey) ?? [];
    raw.add(jsonEncode(item.toJson()));
    await prefs.setStringList(_storageKey, raw);
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
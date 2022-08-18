import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_diary/entry/models/entry.dart';

const entriesPrefix = 'entries';

class EntryRepository {
  final FlutterSecureStorage storage = FlutterSecureStorage();

  String storageKeyFromEntry(Entry entry) =>
      storageKey(userId: entry.userId, day: entry.day);
  
  String storageKey({ required String userId, required DateTime day}) =>
      "${entriesPrefix}_${userId}_${day.year}_${day.month}_${day.day}";

  EntryRepository();

  Future<List<Entry>> findByDay(String userId, DateTime day) async {
    var rawEntries = await storage.read(
        key: storageKey(userId: userId, day: day));
    return Entry.listFromJson(rawEntries != null ? jsonDecode(rawEntries) : []);
  }

  Future<void> remove(Entry entry) async {
    var entries = await findByDay(entry.userId, entry.day);

    entries.removeWhere((storedEntry) => storedEntry.id == entry.id);

    storage.write(key: storageKeyFromEntry(entry), value: jsonEncode(entries));
  }

  Future<void> persist(Entry entry) async {
    var entries = await findByDay(entry.userId, entry.day);
    try {
      var storedEntry =
          entries.firstWhere((storedEntry) => entry.id == storedEntry.id);
      storedEntry.title = entry.title;
      storedEntry.body = entry.body;
    } catch (e) {
      entries.add(entry);
    }

    storage.write(key: storageKeyFromEntry(entry), value: jsonEncode(entries));
  }
}

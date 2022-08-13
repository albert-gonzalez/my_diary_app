import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_diary/entry/models/entry.dart';

const entriesPrefix = 'entries';

class EntryRepository {
  final FlutterSecureStorage _storage;

  String _storageKey(Entry entry) =>
      "${entriesPrefix}_${entry.day.year}_${entry.day.month}_${entry.day.day}";

  EntryRepository(this._storage);

  Future<List<Entry>> findByDay(DateTime day) async {
    var rawEntries = await _storage.read(
        key: "${entriesPrefix}_${day.year}_${day.month}_${day.day}");
    return Entry.listFromJson(rawEntries != null ? jsonDecode(rawEntries) : []);
  }

  Future<void> remove(Entry entry) async {
    var entries = await findByDay(entry.day);

    entries.removeWhere((storedEntry) => storedEntry.id == entry.id);
    print(entries);
    _storage.write(key: _storageKey(entry), value: jsonEncode(entries));
  }

  Future<void> persist(Entry entry) async {
    var entries = await findByDay(entry.day);
    try {
      var storedEntry =
          entries.firstWhere((storedEntry) => entry.id == storedEntry.id);
      storedEntry.title = entry.title;
      storedEntry.body = entry.body;
    } catch (e) {
      entries.add(entry);
    }

    _storage.write(key: _storageKey(entry), value: jsonEncode(entries));
  }
}

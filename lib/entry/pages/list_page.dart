import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_diary/components/calendar/calendar.dart';
import 'package:my_diary/entry/pages/entry_page.dart';
import 'package:my_diary/entry/pages/sign_in_page.dart';
import 'package:my_diary/entry/services/entry_repository.dart';
import 'package:my_diary/user/components/avatar.dart';
import 'package:my_diary/user/models/user.dart';
import 'package:my_diary/user/pages/profile_page.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../generated/l10n.dart';
import '../models/entry.dart';

class ListPage extends StatefulWidget {
  const ListPage({Key? key}) : super(key: key);

  @override
  ListPageState createState() => ListPageState();
}

class ListPageState extends State<ListPage> {
  var _entries = <Entry>[];
  var _focusedDay = DateTime.now();
  var _selectedDay = DateTime.now();

  final _entryRepository = EntryRepository(const FlutterSecureStorage());

  @override
  void initState() {
    super.initState();

    loadEntries();
  }

  Future<void> loadEntries() async {
    var entries = await _entryRepository.findByDay(_selectedDay);

    setState(() {
      _entries = entries;
    });
  }

  void openEntryModal({Entry? entry, readOnly = false}) {
    showDialog(
        context: context,
        builder: (context) => EntryPage(
            callback: reloadWithChange,
            entry: entry,
            readOnly: readOnly,
            day: _selectedDay));
  }

  void reloadWithChange(Entry entry) async {
    var entries = await _entryRepository.findByDay(entry.day);
    setState(() {
      _selectedDay = entry.day;
      _focusedDay = entry.day;
      _entries = entries;
    });
  }

  void removeEntry(Entry entry) {
    var index = _entries.indexOf(entry);
    setState(() {
      _entries.remove(entry);
    });

    var snackBar = SnackBar(
      content: Text(S.of(context).entryRemoved),
      behavior: SnackBarBehavior.floating,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5))),
      action: SnackBarAction(
          label: S.of(context).undo,
          onPressed: () {
            setState(() {
              _entries.insert(index, entry);
            });
          }),
    );

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar).closed.then((reason) {
      if (reason != SnackBarClosedReason.action) {
        _entryRepository.remove(entry);
      }
    });
  }

  List<Widget> buildEntryList() {
    if (_entries.isEmpty) {
      return [
        Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                    child: Icon(Icons.chat_bubble_outline,
                        size: 50,
                        color: Theme.of(context).textTheme.headline4!.color)),
                Flexible(
                    child: Text(
                  S.of(context).emptyDay,
                  style: Theme.of(context).textTheme.headline4,
                  textAlign: TextAlign.center,
                )),
                const SizedBox(height: 100)
              ],
            )),
      ];
    }
    return [
      Text(
        S.of(context).entries,
        style: Theme.of(context).textTheme.headline6,
      ),
      const SizedBox(height: 10),
      Expanded(
          flex: 1,
          child: ListView(
            children: _entries
                .map((entry) => Card(
                    elevation: 10,
                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                    child: ListTile(
                        onTap: () =>
                            openEntryModal(entry: entry, readOnly: true),
                        title: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(entry.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              )),
                        ),
                        trailing:
                            Row(mainAxisSize: MainAxisSize.min, children: [
                          IconButton(
                              onPressed: () async {
                                openEntryModal(entry: entry);
                              },
                              icon: const Icon(
                                Icons.edit,
                              )),
                          IconButton(
                              onPressed: () {
                                removeEntry(entry);
                              },
                              icon: Icon(
                                Icons.delete,
                                color: Theme.of(context).errorColor,
                              )),
                        ]))))
                .toList(),
          ))
    ];
  }

  selectDay(selectedDay, focusedDay) async {
      var entries =
      await _entryRepository.findByDay(selectedDay);
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _entries = entries;
      });

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }

  setMonthFocusedDay(focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
    });
  }

  @override
  Widget build(BuildContext context) {
    User user = context.watch();

    if (!user.isLogged) {
      Future.microtask(() => Navigator.pushReplacementNamed(context, '/'));

      return Scaffold();
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).myDiary),
          //leading: const Icon(Icons.menu_book),
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                  onPressed: () => Scaffold.of(context).openDrawer(), icon: Avatar());
            }),
        ),
        drawer: ProfilePage(),
        body: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                      elevation: 10,
                      margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                      child: Calendar(
                        focusedDay: _focusedDay,
                        headerStyle: Calendar.getHeaderStyle(),
                        calendarStyle: Calendar.getCalendarStyle(context),
                        selectedDayPredicate: (day) {
                          return isSameDay(_selectedDay, day);
                        },
                        onDaySelected: selectDay,
                        onPageChanged: setMonthFocusedDay,
                      )),
                  ...buildEntryList()
                ])),
        floatingActionButton: FloatingActionButton(
          onPressed: () => openEntryModal(),
          child: const Icon(Icons.add),
        ));
  }
}

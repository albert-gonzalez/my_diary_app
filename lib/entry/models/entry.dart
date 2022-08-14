class Entry {
  String id;
  String title;
  List body;
  DateTime day;

  Entry(this.id, this.title, this.body, this.day);

  Entry.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        body = json['body'],
        day = DateTime.parse(json['day']);

  static List<Entry> listFromJson(List<dynamic> json) {
    return json.map((e) => Entry.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'day': day.toString(),
      };
}
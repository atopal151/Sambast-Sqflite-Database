
class TodoItem {
  late final int? id;
  late final String content;
  late bool isDone;
  late final DateTime createdAt;

  TodoItem({
    this.id,
    required this.content,
    this.isDone = false,
    required this.createdAt,
  });

  TodoItem.fromJsonMap(Map<String, dynamic> map)
      : id = map['id'] as int,
        content = map['content'] as String,
        isDone = map['isDone'] as bool,
        createdAt =
        DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int);

  Map<String, dynamic> toJsonMap() => {
    'id': id,
    'content': content,
    'isDone': isDone,
    'createdAt': createdAt.millisecondsSinceEpoch
  };
}

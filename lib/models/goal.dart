class Goal {
  String title;
  bool isCompleted;

  Goal({required this.title, this.isCompleted = false});

  // JSON'dan Goal nesnesine dönüştürme
  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      title: json['title'],
      isCompleted: json['isCompleted'],
    );
  }

  // Goal nesnesinden JSON'a dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'isCompleted': isCompleted,
    };
  }
}

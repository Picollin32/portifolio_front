class MediaItem {
  final int id;
  final String title;
  final MediaType type;
  final int rating;
  final String image;
  final String? badge;
  final String? genre;
  final int? year;

  MediaItem({
    required this.id,
    required this.title,
    required this.type,
    required this.rating,
    required this.image,
    this.badge,
    this.genre,
    this.year,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type.name,
      'rating': rating,
      'image': image,
      'badge': badge,
      'genre': genre,
      'year': year,
    };
  }

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      id: json['id'] as int,
      title: json['title'] as String,
      type: MediaType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MediaType.game,
      ),
      rating: json['rating'] as int,
      image: json['image'] as String,
      badge: json['badge'] as String?,
      genre: json['genre'] as String?,
      year: json['year'] as int?,
    );
  }

  MediaItem copyWith({
    int? id,
    String? title,
    MediaType? type,
    int? rating,
    String? image,
    String? badge,
    String? genre,
    int? year,
  }) {
    return MediaItem(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      rating: rating ?? this.rating,
      image: image ?? this.image,
      badge: badge ?? this.badge,
      genre: genre ?? this.genre,
      year: year ?? this.year,
    );
  }

  String get typeLabel {
    switch (type) {
      case MediaType.game:
        return 'Jogo';
      case MediaType.movie:
        return 'Filme';
      case MediaType.series:
        return 'Série';
    }
  }

  String get detailPath {
    switch (type) {
      case MediaType.game:
        return '/jogos/$id';
      case MediaType.movie:
        return '/filmes/$id';
      case MediaType.series:
        return '/series/$id';
    }
  }
}

enum MediaType {
  game,
  movie,
  series,
}

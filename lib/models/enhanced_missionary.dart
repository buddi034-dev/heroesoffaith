import 'package:equatable/equatable.dart';

/// Enhanced Missionary model to match Cloudflare Workers API structure
/// Provides rich data including timeline, quiz, locations, and detailed biography
class EnhancedMissionary extends Equatable {
  final String id;
  final String name;
  final String displayName;
  final MissionaryDates dates;
  final String? image;
  final List<String> images;
  final String summary;
  final List<BiographySection> biography;
  final List<TimelineEvent> timeline;
  final List<MissionaryLocation> locations;
  final List<String> categories;
  final List<QuizQuestion> quiz;
  final List<String> achievements;
  final String source;
  final String sourceUrl;
  final String attribution;
  final String lastModified;
  final String lang;

  const EnhancedMissionary({
    required this.id,
    required this.name,
    required this.displayName,
    required this.dates,
    this.image,
    this.images = const [],
    required this.summary,
    this.biography = const [],
    this.timeline = const [],
    this.locations = const [],
    this.categories = const [],
    this.quiz = const [],
    this.achievements = const [],
    required this.source,
    required this.sourceUrl,
    required this.attribution,
    required this.lastModified,
    this.lang = 'en',
  });

  /// Create from API JSON response
  factory EnhancedMissionary.fromJson(Map<String, dynamic> json) {
    return EnhancedMissionary(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      displayName: json['displayName'] ?? json['name'] ?? '',
      dates: MissionaryDates.fromJson(json['dates'] ?? {}),
      image: json['image'],
      images: List<String>.from(json['images'] ?? []),
      summary: json['summary'] ?? '',
      biography: (json['biography'] as List<dynamic>?)
          ?.map((e) => BiographySection.fromJson(e))
          .toList() ?? [],
      timeline: (json['timeline'] as List<dynamic>?)
          ?.map((e) => TimelineEvent.fromJson(e))
          .toList() ?? [],
      locations: (json['locations'] as List<dynamic>?)
          ?.map((e) => MissionaryLocation.fromJson(e))
          .toList() ?? [],
      categories: List<String>.from(json['categories'] ?? []),
      quiz: (json['quiz'] as List<dynamic>?)
          ?.map((e) => QuizQuestion.fromJson(e))
          .toList() ?? [],
      achievements: List<String>.from(json['achievements'] ?? []),
      source: json['source'] ?? '',
      sourceUrl: json['sourceUrl'] ?? '',
      attribution: json['attribution'] ?? '',
      lastModified: json['lastModified'] ?? '',
      lang: json['lang'] ?? 'en',
    );
  }

  /// Convert to JSON for caching
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'displayName': displayName,
      'dates': dates.toJson(),
      'image': image,
      'images': images,
      'summary': summary,
      'biography': biography.map((e) => e.toJson()).toList(),
      'timeline': timeline.map((e) => e.toJson()).toList(),
      'locations': locations.map((e) => e.toJson()).toList(),
      'categories': categories,
      'quiz': quiz.map((e) => e.toJson()).toList(),
      'achievements': achievements,
      'source': source,
      'sourceUrl': sourceUrl,
      'attribution': attribution,
      'lastModified': lastModified,
      'lang': lang,
    };
  }

  /// Get primary service country
  String get primaryCountry {
    final countries = locations
        .where((loc) => loc.type == LocationType.missionField)
        .map((loc) => loc.name.split(',').last.trim())
        .toSet()
        .toList();
    return countries.isNotEmpty ? countries.first : '';
  }

  /// Get service years range
  String get serviceYearsRange {
    if (timeline.isEmpty) return dates.display;
    
    final years = timeline.map((e) => e.year).where((year) => year > 0).toList();
    if (years.isEmpty) return dates.display;
    
    years.sort();
    final firstYear = years.first;
    final lastYear = years.last;
    
    return firstYear == lastYear ? '$firstYear' : '$firstYear-$lastYear';
  }

  /// Get century of service
  String get century {
    final year = dates.birth ?? timeline.firstWhere(
      (event) => event.year > 0,
      orElse: () => TimelineEvent(year: 1800, event: '', description: ''),
    ).year;
    
    final centuryNum = ((year - 1) / 100).floor() + 1;
    return '${centuryNum}th Century';
  }

  /// Create copy with updated fields
  EnhancedMissionary copyWith({
    String? id,
    String? name,
    String? displayName,
    MissionaryDates? dates,
    String? image,
    List<String>? images,
    String? summary,
    List<BiographySection>? biography,
    List<TimelineEvent>? timeline,
    List<MissionaryLocation>? locations,
    List<String>? categories,
    List<QuizQuestion>? quiz,
    List<String>? achievements,
    String? source,
    String? sourceUrl,
    String? attribution,
    String? lastModified,
    String? lang,
  }) {
    return EnhancedMissionary(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      dates: dates ?? this.dates,
      image: image ?? this.image,
      images: images ?? this.images,
      summary: summary ?? this.summary,
      biography: biography ?? this.biography,
      timeline: timeline ?? this.timeline,
      locations: locations ?? this.locations,
      categories: categories ?? this.categories,
      quiz: quiz ?? this.quiz,
      achievements: achievements ?? this.achievements,
      source: source ?? this.source,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      attribution: attribution ?? this.attribution,
      lastModified: lastModified ?? this.lastModified,
      lang: lang ?? this.lang,
    );
  }

  @override
  List<Object?> get props => [
    id, name, displayName, dates, image, images, summary,
    biography, timeline, locations, categories, quiz, achievements,
    source, sourceUrl, attribution, lastModified, lang,
  ];
}

/// Missionary birth and death dates
class MissionaryDates extends Equatable {
  final int? birth;
  final int? death;
  final String display;

  const MissionaryDates({
    this.birth,
    this.death,
    required this.display,
  });

  factory MissionaryDates.fromJson(Map<String, dynamic> json) {
    return MissionaryDates(
      birth: json['birth'],
      death: json['death'],
      display: json['display'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'birth': birth,
      'death': death,
      'display': display,
    };
  }

  /// Calculate lifespan
  int? get lifespan {
    if (birth != null && death != null) {
      return death! - birth!;
    }
    return null;
  }

  /// Check if missionary is historical (deceased)
  bool get isHistorical => death != null;

  @override
  List<Object?> get props => [birth, death, display];
}

/// Biography section with title and content
class BiographySection extends Equatable {
  final String title;
  final String content;

  const BiographySection({
    required this.title,
    required this.content,
  });

  factory BiographySection.fromJson(Map<String, dynamic> json) {
    return BiographySection(
      title: json['title'] ?? '',
      content: json['content'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
    };
  }

  @override
  List<Object> get props => [title, content];
}

/// Timeline event in missionary's life
class TimelineEvent extends Equatable {
  final int year;
  final String event;
  final String description;

  const TimelineEvent({
    required this.year,
    required this.event,
    required this.description,
  });

  factory TimelineEvent.fromJson(Map<String, dynamic> json) {
    return TimelineEvent(
      year: json['year'] ?? 0,
      event: json['event'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'event': event,
      'description': description,
    };
  }

  @override
  List<Object> get props => [year, event, description];
}

/// Location where missionary served
class MissionaryLocation extends Equatable {
  final String name;
  final double lat;
  final double lng;
  final LocationType type;
  final String years;
  final String description;

  const MissionaryLocation({
    required this.name,
    required this.lat,
    required this.lng,
    required this.type,
    required this.years,
    required this.description,
  });

  factory MissionaryLocation.fromJson(Map<String, dynamic> json) {
    return MissionaryLocation(
      name: json['name'] ?? '',
      lat: (json['lat'] ?? 0.0).toDouble(),
      lng: (json['lng'] ?? 0.0).toDouble(),
      type: LocationType.fromString(json['type'] ?? 'mission_field'),
      years: json['years'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'lat': lat,
      'lng': lng,
      'type': type.toString(),
      'years': years,
      'description': description,
    };
  }

  @override
  List<Object> get props => [name, lat, lng, type, years, description];
}

/// Types of locations
enum LocationType {
  birthplace,
  missionField,
  finalRestingPlace;

  static LocationType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'birthplace':
        return LocationType.birthplace;
      case 'mission_field':
        return LocationType.missionField;
      case 'final_resting_place':
        return LocationType.finalRestingPlace;
      default:
        return LocationType.missionField;
    }
  }

  @override
  String toString() {
    switch (this) {
      case LocationType.birthplace:
        return 'birthplace';
      case LocationType.missionField:
        return 'mission_field';
      case LocationType.finalRestingPlace:
        return 'final_resting_place';
    }
  }

  /// Get display name for UI
  String get displayName {
    switch (this) {
      case LocationType.birthplace:
        return 'Birthplace';
      case LocationType.missionField:
        return 'Mission Field';
      case LocationType.finalRestingPlace:
        return 'Final Resting Place';
    }
  }

  /// Get spiritual display name
  String get spiritualName {
    switch (this) {
      case LocationType.birthplace:
        return 'Birthplace of Faith';
      case LocationType.missionField:
        return 'Field of Service';
      case LocationType.finalRestingPlace:
        return 'Eternal Rest';
    }
  }
}

/// Quiz question about missionary
class QuizQuestion extends Equatable {
  final String question;
  final List<String> options;
  final int answer;
  final String explanation;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.answer,
    required this.explanation,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      answer: json['answer'] ?? 0,
      explanation: json['explanation'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'options': options,
      'answer': answer,
      'explanation': explanation,
    };
  }

  /// Get correct answer text
  String get correctAnswerText {
    if (answer >= 0 && answer < options.length) {
      return options[answer];
    }
    return '';
  }

  /// Check if given answer is correct
  bool isCorrect(int selectedAnswer) {
    return selectedAnswer == answer;
  }

  @override
  List<Object> get props => [question, options, answer, explanation];
}

/// API response wrapper for profiles list
class ProfilesListResponse extends Equatable {
  final List<ProfileSummary> profiles;
  final Pagination pagination;
  final String category;

  const ProfilesListResponse({
    required this.profiles,
    required this.pagination,
    required this.category,
  });

  factory ProfilesListResponse.fromJson(Map<String, dynamic> json) {
    return ProfilesListResponse(
      profiles: (json['profiles'] as List<dynamic>?)
          ?.map((e) => ProfileSummary.fromJson(e))
          .toList() ?? [],
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
      category: json['category'] ?? '',
    );
  }

  @override
  List<Object> get props => [profiles, pagination, category];
}

/// Summary profile for lists
class ProfileSummary extends Equatable {
  final String id;
  final String name;
  final String displayName;
  final MissionaryDates dates;
  final String? image;
  final String summary;
  final List<String> categories;
  final String source;
  final String sourceUrl;
  final String lastModified;

  const ProfileSummary({
    required this.id,
    required this.name,
    required this.displayName,
    required this.dates,
    this.image,
    required this.summary,
    this.categories = const [],
    required this.source,
    required this.sourceUrl,
    required this.lastModified,
  });

  factory ProfileSummary.fromJson(Map<String, dynamic> json) {
    return ProfileSummary(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      displayName: json['displayName'] ?? json['name'] ?? '',
      dates: MissionaryDates.fromJson(json['dates'] ?? {}),
      image: json['image'],
      summary: json['summary'] ?? '',
      categories: List<String>.from(json['categories'] ?? []),
      source: json['source'] ?? '',
      sourceUrl: json['sourceUrl'] ?? '',
      lastModified: json['lastModified'] ?? '',
    );
  }

  @override
  List<Object?> get props => [
    id, name, displayName, dates, image, summary,
    categories, source, sourceUrl, lastModified,
  ];
}

/// Pagination information
class Pagination extends Equatable {
  final int limit;
  final int offset;
  final int total;
  final bool hasMore;

  const Pagination({
    required this.limit,
    required this.offset,
    required this.total,
    required this.hasMore,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      limit: json['limit'] ?? 20,
      offset: json['offset'] ?? 0,
      total: json['total'] ?? 0,
      hasMore: json['hasMore'] ?? false,
    );
  }

  /// Calculate current page number
  int get currentPage => (offset / limit).floor() + 1;

  /// Calculate total pages
  int get totalPages => (total / limit).ceil();

  @override
  List<Object> get props => [limit, offset, total, hasMore];
}
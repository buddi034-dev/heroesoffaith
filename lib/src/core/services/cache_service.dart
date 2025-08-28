import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../models/enhanced_missionary.dart';

/// Local cache service for offline support
/// Manages caching of API responses and user preferences
class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  late SharedPreferences _prefs;
  late Box<String> _missionaryBox;
  late Box<String> _profilesListBox;
  late Box<String> _searchBox;
  late Box<String> _locationsBox;

  static const String _cacheKeyPrefix = 'heroes_of_faith_';
  static const String _lastUpdateKey = '${_cacheKeyPrefix}last_update';
  static const String _cacheVersionKey = '${_cacheKeyPrefix}cache_version';
  static const int _currentCacheVersion = 1;

  /// Cache expiration times (in hours)
  static const int _profileCacheHours = 24;
  static const int _profilesListCacheHours = 12;
  static const int _searchCacheHours = 6;
  static const int _locationsCacheHours = 48;

  /// Initialize cache service
  Future<void> initialize() async {
    try {
      // Initialize Hive
      await Hive.initFlutter();
      
      // Open boxes for different data types
      _missionaryBox = await Hive.openBox<String>('missionaries');
      _profilesListBox = await Hive.openBox<String>('profiles_lists');
      _searchBox = await Hive.openBox<String>('search_results');
      _locationsBox = await Hive.openBox<String>('locations');
      
      // Initialize SharedPreferences
      _prefs = await SharedPreferences.getInstance();
      
      // Check cache version and clear if outdated
      await _checkCacheVersion();
      
      print('✅ Cache service initialized successfully');
    } catch (e) {
      print('❌ Error initializing cache service: $e');
      rethrow;
    }
  }

  /// Check if cache version is current, clear if not
  Future<void> _checkCacheVersion() async {
    final currentVersion = _prefs.getInt(_cacheVersionKey) ?? 0;
    if (currentVersion < _currentCacheVersion) {
      await clearAllCache();
      await _prefs.setInt(_cacheVersionKey, _currentCacheVersion);
      print('🔄 Cache cleared due to version update');
    }
  }

  // MISSIONARY PROFILE CACHING

  /// Cache a missionary profile
  Future<void> cacheProfile(EnhancedMissionary missionary) async {
    try {
      final key = _getProfileKey(missionary.id);
      final jsonData = jsonEncode(missionary.toJson());
      await _missionaryBox.put(key, jsonData);
      await _setTimestamp('profile_${missionary.id}');
      print('💾 Cached profile: ${missionary.name}');
    } catch (e) {
      print('❌ Error caching profile ${missionary.id}: $e');
    }
  }

  /// Get cached missionary profile
  Future<EnhancedMissionary?> getCachedProfile(String id) async {
    try {
      final key = _getProfileKey(id);
      final jsonData = _missionaryBox.get(key);
      
      if (jsonData == null) return null;
      
      // Check if cache is expired
      if (_isCacheExpired('profile_$id', _profileCacheHours)) {
        await _missionaryBox.delete(key);
        return null;
      }
      
      final jsonMap = jsonDecode(jsonData) as Map<String, dynamic>;
      return EnhancedMissionary.fromJson(jsonMap);
    } catch (e) {
      print('❌ Error retrieving cached profile $id: $e');
      return null;
    }
  }

  // PROFILES LIST CACHING

  /// Cache profiles list response
  Future<void> cacheProfilesList(
    ProfilesListResponse response,
    int limit,
    int offset,
    String category,
  ) async {
    try {
      final key = _getProfilesListKey(limit, offset, category);
      final jsonData = jsonEncode({
        'profiles': response.profiles.map((p) => {
          'id': p.id,
          'name': p.name,
          'displayName': p.displayName,
          'dates': p.dates.toJson(),
          'image': p.image,
          'summary': p.summary,
          'categories': p.categories,
          'source': p.source,
          'sourceUrl': p.sourceUrl,
          'lastModified': p.lastModified,
        }).toList(),
        'pagination': {
          'limit': response.pagination.limit,
          'offset': response.pagination.offset,
          'total': response.pagination.total,
          'hasMore': response.pagination.hasMore,
        },
        'category': response.category,
      });
      
      await _profilesListBox.put(key, jsonData);
      await _setTimestamp('profiles_list_${limit}_${offset}_$category');
      print('💾 Cached profiles list: $category ($limit/$offset)');
    } catch (e) {
      print('❌ Error caching profiles list: $e');
    }
  }

  /// Get cached profiles list
  Future<ProfilesListResponse?> getCachedProfilesList(
    int limit,
    int offset,
    String category,
  ) async {
    try {
      final key = _getProfilesListKey(limit, offset, category);
      final jsonData = _profilesListBox.get(key);
      
      if (jsonData == null) return null;
      
      // Check if cache is expired
      if (_isCacheExpired('profiles_list_${limit}_${offset}_$category', _profilesListCacheHours)) {
        await _profilesListBox.delete(key);
        return null;
      }
      
      final jsonMap = jsonDecode(jsonData) as Map<String, dynamic>;
      return ProfilesListResponse.fromJson(jsonMap);
    } catch (e) {
      print('❌ Error retrieving cached profiles list: $e');
      return null;
    }
  }

  // SEARCH RESULTS CACHING

  /// Cache search results
  Future<void> cacheSearchResults(String query, List<ProfileSummary> results) async {
    try {
      final key = _getSearchKey(query);
      final jsonData = jsonEncode(
        results.map((r) => {
          'id': r.id,
          'name': r.name,
          'displayName': r.displayName,
          'dates': r.dates.toJson(),
          'image': r.image,
          'summary': r.summary,
          'categories': r.categories,
          'source': r.source,
          'sourceUrl': r.sourceUrl,
          'lastModified': r.lastModified,
        }).toList(),
      );
      
      await _searchBox.put(key, jsonData);
      await _setTimestamp('search_$query');
      print('💾 Cached search results for: $query');
    } catch (e) {
      print('❌ Error caching search results for $query: $e');
    }
  }

  /// Get cached search results
  Future<List<ProfileSummary>?> getCachedSearchResults(String query) async {
    try {
      final key = _getSearchKey(query);
      final jsonData = _searchBox.get(key);
      
      if (jsonData == null) return null;
      
      // Check if cache is expired
      if (_isCacheExpired('search_$query', _searchCacheHours)) {
        await _searchBox.delete(key);
        return null;
      }
      
      final jsonList = jsonDecode(jsonData) as List<dynamic>;
      return jsonList.map((json) => ProfileSummary.fromJson(json)).toList();
    } catch (e) {
      print('❌ Error retrieving cached search results for $query: $e');
      return null;
    }
  }

  // LOCATIONS CACHING

  /// Cache locations data
  Future<void> cacheLocations(List<Map<String, dynamic>> locations) async {
    try {
      const key = 'all_locations';
      final jsonData = jsonEncode(locations);
      await _locationsBox.put(key, jsonData);
      await _setTimestamp('locations_all');
      print('💾 Cached locations data');
    } catch (e) {
      print('❌ Error caching locations: $e');
    }
  }

  /// Get cached locations
  Future<List<Map<String, dynamic>>?> getCachedLocations() async {
    try {
      const key = 'all_locations';
      final jsonData = _locationsBox.get(key);
      
      if (jsonData == null) return null;
      
      // Check if cache is expired
      if (_isCacheExpired('locations_all', _locationsCacheHours)) {
        await _locationsBox.delete(key);
        return null;
      }
      
      final jsonList = jsonDecode(jsonData) as List<dynamic>;
      return jsonList.cast<Map<String, dynamic>>();
    } catch (e) {
      print('❌ Error retrieving cached locations: $e');
      return null;
    }
  }

  // USER PREFERENCES & SETTINGS

  /// Cache user favorites
  Future<void> cacheFavorites(List<String> favoriteIds) async {
    await _prefs.setStringList('${_cacheKeyPrefix}favorites', favoriteIds);
  }

  /// Get cached favorites
  List<String> getCachedFavorites() {
    return _prefs.getStringList('${_cacheKeyPrefix}favorites') ?? [];
  }

  /// Add to favorites
  Future<void> addToFavorites(String missionaryId) async {
    final favorites = getCachedFavorites();
    if (!favorites.contains(missionaryId)) {
      favorites.add(missionaryId);
      await cacheFavorites(favorites);
    }
  }

  /// Remove from favorites
  Future<void> removeFromFavorites(String missionaryId) async {
    final favorites = getCachedFavorites();
    favorites.remove(missionaryId);
    await cacheFavorites(favorites);
  }

  /// Check if missionary is favorited
  bool isFavorite(String missionaryId) {
    return getCachedFavorites().contains(missionaryId);
  }

  /// Cache user search history
  Future<void> addToSearchHistory(String query) async {
    final history = getSearchHistory();
    history.remove(query); // Remove if exists to avoid duplicates
    history.insert(0, query); // Add to beginning
    
    // Keep only last 20 searches
    if (history.length > 20) {
      history.removeRange(20, history.length);
    }
    
    await _prefs.setStringList('${_cacheKeyPrefix}search_history', history);
  }

  /// Get search history
  List<String> getSearchHistory() {
    return _prefs.getStringList('${_cacheKeyPrefix}search_history') ?? [];
  }

  /// Clear search history
  Future<void> clearSearchHistory() async {
    await _prefs.remove('${_cacheKeyPrefix}search_history');
  }

  // CACHE UTILITY METHODS

  /// Set timestamp for cache entry
  Future<void> _setTimestamp(String key) async {
    await _prefs.setInt('${_cacheKeyPrefix}timestamp_$key', DateTime.now().millisecondsSinceEpoch);
  }

  /// Check if cache is expired
  bool _isCacheExpired(String key, int hours) {
    final timestamp = _prefs.getInt('${_cacheKeyPrefix}timestamp_$key');
    if (timestamp == null) return true;
    
    final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final expiryTime = cacheTime.add(Duration(hours: hours));
    return DateTime.now().isAfter(expiryTime);
  }

  /// Generate cache keys
  String _getProfileKey(String id) => 'profile_$id';
  String _getProfilesListKey(int limit, int offset, String category) => 
      'profiles_${limit}_${offset}_$category';
  String _getSearchKey(String query) => 'search_${query.toLowerCase().replaceAll(' ', '_')}';

  /// Get cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    return {
      'missionaries': _missionaryBox.length,
      'profiles_lists': _profilesListBox.length,
      'search_results': _searchBox.length,
      'locations': _locationsBox.length,
      'favorites_count': getCachedFavorites().length,
      'search_history_count': getSearchHistory().length,
      'last_update': _prefs.getInt(_lastUpdateKey) ?? 0,
      'cache_version': _prefs.getInt(_cacheVersionKey) ?? 0,
    };
  }

  /// Clear specific cache type
  Future<void> clearProfilesCache() async {
    await _missionaryBox.clear();
    print('🧹 Cleared profiles cache');
  }

  Future<void> clearProfilesListCache() async {
    await _profilesListBox.clear();
    print('🧹 Cleared profiles list cache');
  }

  Future<void> clearSearchCache() async {
    await _searchBox.clear();
    print('🧹 Cleared search cache');
  }

  Future<void> clearLocationsCache() async {
    await _locationsBox.clear();
    print('🧹 Cleared locations cache');
  }

  /// Clear all cached data
  Future<void> clearAllCache() async {
    await Future.wait([
      _missionaryBox.clear(),
      _profilesListBox.clear(),
      _searchBox.clear(),
      _locationsBox.clear(),
    ]);
    
    // Clear timestamps
    final keys = _prefs.getKeys().where((key) => key.startsWith('${_cacheKeyPrefix}timestamp_'));
    for (final key in keys) {
      await _prefs.remove(key);
    }
    
    await _prefs.setInt(_lastUpdateKey, DateTime.now().millisecondsSinceEpoch);
    print('🧹 Cleared all cache data');
  }

  /// Check if device has cached data for offline use
  bool get hasOfflineData {
    return _missionaryBox.isNotEmpty || _profilesListBox.isNotEmpty;
  }

  /// Get offline-capable missionary IDs
  List<String> get offlineMissionaryIds {
    return _missionaryBox.keys
        .where((key) => key.startsWith('profile_'))
        .map((key) => key.substring(8)) // Remove 'profile_' prefix
        .cast<String>()
        .toList();
  }

  /// Dispose resources
  Future<void> dispose() async {
    await Future.wait([
      _missionaryBox.close(),
      _profilesListBox.close(),
      _searchBox.close(),
      _locationsBox.close(),
    ]);
  }
}

/// Cache manager for coordinating caching strategies
class CacheManager {
  static final CacheManager _instance = CacheManager._internal();
  factory CacheManager() => _instance;
  CacheManager._internal();

  final CacheService _cacheService = CacheService();

  /// Initialize cache manager
  Future<void> initialize() async {
    await _cacheService.initialize();
  }

  /// Smart cache strategy: cache frequently accessed profiles
  Future<void> preloadPopularProfiles(List<String> popularIds) async {
    // This would be called with a list of frequently accessed missionary IDs
    // Implementation would depend on usage analytics
    print('📈 Preloading popular profiles: ${popularIds.length} items');
  }

  /// Background cache cleanup
  Future<void> performMaintenance() async {
    try {
      final stats = await _cacheService.getCacheStats();
      print('🔧 Cache maintenance - Stats: $stats');
      
      // Add logic for cache size management if needed
      final totalItems = stats['missionaries'] + stats['profiles_lists'] + 
                        stats['search_results'] + stats['locations'];
      
      if (totalItems > 1000) { // Arbitrary threshold
        // Could implement LRU eviction here
        print('⚠️ Cache size threshold reached, consider cleanup');
      }
    } catch (e) {
      print('❌ Error during cache maintenance: $e');
    }
  }

  /// Get cache service instance
  CacheService get cacheService => _cacheService;
}
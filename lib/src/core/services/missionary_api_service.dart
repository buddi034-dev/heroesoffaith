import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../models/enhanced_missionary.dart';
import 'cache_service.dart';

/// Service for communicating with Cloudflare Workers API
/// Handles all missionary profile data from the edge API
class MissionaryApiService {
  static final MissionaryApiService _instance = MissionaryApiService._internal();
  factory MissionaryApiService() => _instance;
  MissionaryApiService._internal();

  late final Dio _dio;
  final String _baseUrl = 'https://missionary-profiles-api.jbr01061981.workers.dev';
  final String _githubFallbackUrl = 'https://raw.githubusercontent.com/jbr01061981/missionary-profiles/main/fallback';
  
  // Test flag to simulate Cloudflare being down
  bool _simulateCloudflareDown = false;

  /// Initialize the service
  void initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'HeroesOfFaith-Flutter/1.0.0',
      },
    ));

    // Add interceptors
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: false,
        responseBody: false,
        requestHeader: false,
        responseHeader: false,
        error: true,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('🌐 API Request: ${options.method} ${options.path}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          print('✅ API Response: ${response.statusCode} ${response.requestOptions.path}');
          handler.next(response);
        },
        onError: (error, handler) {
          print('❌ API Error: ${error.response?.statusCode} ${error.requestOptions.path}');
          print('❌ Error message: ${error.message}');
          handler.next(error);
        },
      ),
    );
  }

  /// Check network connectivity
  Future<bool> _hasNetworkConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      print('Error checking connectivity: $e');
      return false;
    }
  }

  /// Health check endpoint
  Future<ApiResult<Map<String, dynamic>>> healthCheck() async {
    try {
      if (!await _hasNetworkConnection()) {
        return ApiResult.failure('No internet connection available');
      }

      // Test mode: simulate Cloudflare being down
      if (_simulateCloudflareDown) {
        return ApiResult.failure('Cloudflare API disabled for testing');
      }

      final response = await _dio.get('/health');
      
      if (response.statusCode == 200) {
        return ApiResult.success(response.data);
      } else {
        return ApiResult.failure('Health check failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      return ApiResult.failure(_handleDioError(e));
    } catch (e) {
      return ApiResult.failure('Unexpected error during health check: $e');
    }
  }

  /// Get single missionary profile by ID with fallback support
  Future<ApiResult<EnhancedMissionary>> getProfile(String id) async {
    try {
      if (!await _hasNetworkConnection()) {
        return await _getOfflineProfile(id);
      }

      // Try primary Cloudflare Workers API
      final primaryResult = await _tryCloudflareProfile(id);
      if (primaryResult.isSuccess) {
        return primaryResult;
      }

      // Fallback to GitHub + cached data
      return await _getFallbackProfile(id);
      
    } catch (e) {
      return await _getFallbackProfile(id);
    }
  }

  /// Try primary Cloudflare Workers API for single profile
  Future<ApiResult<EnhancedMissionary>> _tryCloudflareProfile(String id) async {
    try {
      // Test mode: simulate Cloudflare being down
      if (_simulateCloudflareDown) {
        return ApiResult.failure('Cloudflare API disabled for testing');
      }
      
      final response = await _dio.get('/api/profile/$id');
      
      if (response.statusCode == 200) {
        final missionary = EnhancedMissionary.fromJson(response.data);
        
        // Cache the profile for offline use
        await CacheService().cacheProfile(missionary);
        
        return ApiResult.success(missionary);
      } else {
        return ApiResult.failure('Cloudflare profile API failed: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResult.failure('Cloudflare profile API error: $e');
    }
  }

  /// Get fallback profile from GitHub + cached data
  Future<ApiResult<EnhancedMissionary>> _getFallbackProfile(String id) async {
    try {
      // 1. Check cached profile first
      final cached = await CacheService().getCachedProfile(id);
      if (cached != null) {
        return ApiResult.success(cached);
      }

      // 2. Try GitHub custom profiles
      try {
        final customResponse = await _dio.get('$_githubFallbackUrl/custom-profiles.json');
        if (customResponse.statusCode == 200) {
          final customData = customResponse.data;
          if (customData['detailed_profiles'] != null) {
            final profiles = customData['detailed_profiles'] as List;
            final profile = profiles.firstWhere(
              (p) => p['id'] == id,
              orElse: () => null,
            );
            if (profile != null) {
              final missionary = EnhancedMissionary.fromJson(profile);
              return ApiResult.success(missionary);
            }
          }
        }
      } catch (e) {
        print('GitHub detailed profiles unavailable: $e');
      }

      // 3. Create fallback profile from system message
      return ApiResult.success(_createFallbackEnhancedProfile(id));
      
    } catch (e) {
      return await _getOfflineProfile(id);
    }
  }

  /// Get completely offline profile (cached only)
  Future<ApiResult<EnhancedMissionary>> _getOfflineProfile(String id) async {
    try {
      final cached = await CacheService().getCachedProfile(id);
      if (cached != null) {
        return ApiResult.success(cached);
      }
    } catch (e) {
      print('Cache retrieval failed: $e');
    }
    
    // Ultimate fallback
    return ApiResult.success(_createFallbackEnhancedProfile(id));
  }

  /// Create fallback enhanced profile for when all else fails
  EnhancedMissionary _createFallbackEnhancedProfile(String id) {
    return EnhancedMissionary(
      id: id,
      name: 'Profile Unavailable',
      displayName: 'Profile Unavailable',
      image: null,
      dates: MissionaryDates(
        birth: null,
        death: null,
        display: 'Information not available offline',
      ),
      summary: 'This missionary profile is currently unavailable. Please check your internet connection and try again later.',
      biography: [
        BiographySection(
          title: 'Service Notice',
          content: 'This missionary profile is currently unavailable. Please check your internet connection and try again later. We apologize for the inconvenience.',
        ),
      ],
      timeline: [],
      locations: [],
      categories: ['System Message'],
      quiz: [],
      source: 'system',
      sourceUrl: 'internal://system',
      attribution: 'Heroes of Faith App',
      lastModified: DateTime.now().toIso8601String(),
    );
  }

  /// Get list of missionary profiles with fallback support
  Future<ApiResult<ProfilesListResponse>> getProfiles({
    int limit = 20,
    int offset = 0,
    String category = 'all',
  }) async {
    try {
      if (!await _hasNetworkConnection()) {
        return await _getOfflineProfiles(limit, offset, category);
      }

      // Try primary Cloudflare Workers API
      final primaryResult = await _tryCloudflareProfiles(limit, offset, category);
      if (primaryResult.isSuccess) {
        return primaryResult;
      }

      // Fallback to GitHub + cached data
      return await _getFallbackProfiles(limit, offset, category);
      
    } catch (e) {
      return await _getFallbackProfiles(limit, offset, category);
    }
  }

  /// Try primary Cloudflare Workers API
  Future<ApiResult<ProfilesListResponse>> _tryCloudflareProfiles(
    int limit, int offset, String category
  ) async {
    try {
      // Test mode: simulate Cloudflare being down
      if (_simulateCloudflareDown) {
        return ApiResult.failure('Test mode: Cloudflare simulated as down');
      }

      final queryParameters = {
        'limit': limit.toString(),
        'offset': offset.toString(),
        'category': category,
      };

      final response = await _dio.get(
        '/api/profiles',
        queryParameters: queryParameters,
      );
      
      if (response.statusCode == 200) {
        final profilesList = ProfilesListResponse.fromJson(response.data);
        
        // Cache the profiles list for offline use
        await CacheService().cacheProfilesList(profilesList, limit, offset, category);
        
        return ApiResult.success(profilesList);
      } else {
        return ApiResult.failure('Cloudflare API failed: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResult.failure('Cloudflare API error: $e');
    }
  }

  /// Get fallback profiles from GitHub + cached data
  Future<ApiResult<ProfilesListResponse>> _getFallbackProfiles(
    int limit, int offset, String category
  ) async {
    try {
      final List<ProfileSummary> fallbackProfiles = [];
      
      // 1. Try GitHub custom profiles
      try {
        final customResponse = await _dio.get('$_githubFallbackUrl/custom-profiles.json');
        if (customResponse.statusCode == 200) {
          final customData = customResponse.data;
          if (customData['profiles'] != null) {
            final profiles = (customData['profiles'] as List)
                .map((e) => ProfileSummary.fromJson(e))
                .toList();
            fallbackProfiles.addAll(profiles);
          }
        }
      } catch (e) {
        print('GitHub custom profiles unavailable: $e');
      }

      // 2. Try GitHub essential profiles  
      try {
        final essentialResponse = await _dio.get('$_githubFallbackUrl/essential.json');
        if (essentialResponse.statusCode == 200) {
          final essentialData = essentialResponse.data;
          if (essentialData['profiles'] != null) {
            final profiles = (essentialData['profiles'] as List)
                .map((e) => ProfileSummary.fromJson(e))
                .toList();
            fallbackProfiles.addAll(profiles);
          }
        }
      } catch (e) {
        print('GitHub essential profiles unavailable: $e');
      }

      // 3. Add cached data if available
      // TODO: Add cached data retrieval

      // 4. Add system message if we have limited data
      if (fallbackProfiles.isEmpty) {
        fallbackProfiles.add(_getSystemFallbackProfile());
      }

      final response = ProfilesListResponse(
        profiles: fallbackProfiles.take(limit).toList(),
        pagination: Pagination(
          total: fallbackProfiles.length,
          offset: offset,
          limit: limit,
          hasMore: fallbackProfiles.length > (offset + limit),
        ),
        category: category,
      );

      return ApiResult.success(response);
      
    } catch (e) {
      return await _getOfflineProfiles(limit, offset, category);
    }
  }

  /// Get completely offline profiles (cached only)
  Future<ApiResult<ProfilesListResponse>> _getOfflineProfiles(
    int limit, int offset, String category
  ) async {
    // Try cached data first
    // TODO: Implement cached data retrieval
    
    // Ultimate fallback - system message
    final systemProfile = _getSystemFallbackProfile();
    final response = ProfilesListResponse(
      profiles: [systemProfile],
      pagination: Pagination(
        total: 1,
        offset: 0,
        limit: limit,
        hasMore: false,
      ),
      category: category,
    );

    return ApiResult.success(response);
  }

  /// Create system fallback profile for when all else fails
  ProfileSummary _getSystemFallbackProfile() {
    return ProfileSummary(
      id: 'system-fallback',
      name: 'Service Temporarily Unavailable',
      displayName: 'Service Temporarily Unavailable',
      summary: 'We are experiencing connectivity issues. Please check your internet connection and try again. Some cached profiles may be available.',
      image: '',
      dates: MissionaryDates(
        birth: null,
        death: null,
        display: 'System Message',
      ),
      categories: ['System'],
      source: 'system',
      sourceUrl: 'internal://system',
      lastModified: DateTime.now().toIso8601String(),
    );
  }

  /// Search missionary profiles
  Future<ApiResult<List<ProfileSummary>>> searchProfiles(
    String query, {
    int limit = 10,
  }) async {
    try {
      if (!await _hasNetworkConnection()) {
        return ApiResult.failure('No internet connection available');
      }

      if (query.trim().length < 2) {
        return ApiResult.failure('Search query must be at least 2 characters');
      }

      final queryParameters = {
        'limit': limit.toString(),
      };

      final response = await _dio.get(
        '/api/search/${Uri.encodeComponent(query)}',
        queryParameters: queryParameters,
      );
      
      if (response.statusCode == 200) {
        final searchData = response.data;
        final results = (searchData['results'] as List<dynamic>?)
            ?.map((e) => ProfileSummary.fromJson(e))
            .toList() ?? [];
        
        return ApiResult.success(results);
      } else {
        return ApiResult.failure('Search failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      return ApiResult.failure(_handleDioError(e));
    } catch (e) {
      return ApiResult.failure('Error processing search results: $e');
    }
  }

  /// Get locations for map display
  Future<ApiResult<List<MapLocation>>> getLocations() async {
    try {
      if (!await _hasNetworkConnection()) {
        return ApiResult.failure('No internet connection available');
      }

      final response = await _dio.get('/api/locations');
      
      if (response.statusCode == 200) {
        final locationsData = response.data;
        final locations = (locationsData['locations'] as List<dynamic>?)
            ?.map((e) => MapLocation.fromJson(e))
            .toList() ?? [];
        
        return ApiResult.success(locations);
      } else {
        return ApiResult.failure('Failed to fetch locations: ${response.statusCode}');
      }
    } on DioException catch (e) {
      return ApiResult.failure(_handleDioError(e));
    } catch (e) {
      return ApiResult.failure('Error parsing locations data: $e');
    }
  }

  /// Handle Dio errors with user-friendly messages
  String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.sendTimeout:
        return 'Request timeout. Please try again.';
      case DioExceptionType.receiveTimeout:
        return 'Server response timeout. Please try again.';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        switch (statusCode) {
          case 400:
            return 'Invalid request. Please try again.';
          case 404:
            return 'The requested missionary profile was not found.';
          case 429:
            return 'Too many requests. Please wait a moment and try again.';
          case 500:
            return 'Server error. Please try again later.';
          case 503:
            return 'Service temporarily unavailable. Please try again later.';
          default:
            return 'Server error (${statusCode}). Please try again later.';
        }
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.unknown:
        if (error.message?.contains('SocketException') == true) {
          return 'No internet connection. Please check your network settings.';
        }
        return 'Network error. Please check your connection and try again.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  // Test methods for ApiTestScreen
  
  /// Check if fallback test mode is enabled
  bool get isInFallbackTestMode => _simulateCloudflareDown;
  
  /// Enable fallback test mode (simulates Cloudflare being down)
  void enableFallbackTest() {
    _simulateCloudflareDown = true;
    print('🧪 Fallback test mode enabled - Cloudflare API disabled');
  }
  
  /// Disable fallback test mode (re-enables Cloudflare API)
  void disableFallbackTest() {
    _simulateCloudflareDown = false;
    print('✅ Cloudflare API re-enabled');
  }
}

/// Result wrapper for API operations
class ApiResult<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  ApiResult.success(this.data) : error = null, isSuccess = true;
  ApiResult.failure(this.error) : data = null, isSuccess = false;

  /// Execute action if successful
  void onSuccess(void Function(T data) action) {
    if (isSuccess && data != null) {
      action(data!);
    }
  }

  /// Execute action if failed
  void onFailure(void Function(String error) action) {
    if (!isSuccess && error != null) {
      action(error!);
    }
  }

  /// Transform the data if successful
  ApiResult<R> map<R>(R Function(T data) transform) {
    if (isSuccess && data != null) {
      try {
        return ApiResult.success(transform(data!));
      } catch (e) {
        return ApiResult.failure('Data transformation failed: $e');
      }
    }
    return ApiResult.failure(error ?? 'Unknown error');
  }
}

/// Map location for displaying missionary locations
class MapLocation {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final String type;
  final String country;
  final List<MissionaryAtLocation> missionaries;
  final String significance;

  MapLocation({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.type,
    required this.country,
    required this.missionaries,
    required this.significance,
  });

  factory MapLocation.fromJson(Map<String, dynamic> json) {
    return MapLocation(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      lat: (json['lat'] ?? 0.0).toDouble(),
      lng: (json['lng'] ?? 0.0).toDouble(),
      type: json['type'] ?? '',
      country: json['country'] ?? '',
      missionaries: (json['missionaries'] as List<dynamic>?)
          ?.map((e) => MissionaryAtLocation.fromJson(e))
          .toList() ?? [],
      significance: json['significance'] ?? '',
    );
  }

  /// Get spiritual display name based on type
  String get spiritualDisplayName {
    switch (type.toLowerCase()) {
      case 'birthplace':
        return 'Birthplace of Faith';
      case 'mission_field':
        return 'Field of Service';
      case 'final_resting_place':
        return 'Eternal Rest';
      default:
        return name;
    }
  }
}

/// Missionary information at a specific location
class MissionaryAtLocation {
  final String id;
  final String name;
  final String years;
  final String description;
  final String role;

  MissionaryAtLocation({
    required this.id,
    required this.name,
    required this.years,
    required this.description,
    required this.role,
  });

  factory MissionaryAtLocation.fromJson(Map<String, dynamic> json) {
    return MissionaryAtLocation(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      years: json['years'] ?? '',
      description: json['description'] ?? '',
      role: json['role'] ?? '',
    );
  }
}

/// API service configuration
class ApiConfig {
  static const String baseUrl = 'https://missionary-profiles-api.jbr01061981.workers.dev';
  static const Duration connectionTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 15);
  
  /// Spiritual loading messages
  static const List<String> spiritualLoadingMessages = [
    'Gathering testimonies of faith...',
    'Seeking among the saints...',
    'Preparing hearts for inspiration...',
    'Collecting stories of grace...',
    'Walking through fields of service...',
    'Discovering paths of righteousness...',
  ];
  
  /// Get random spiritual loading message
  static String get randomLoadingMessage {
    return (spiritualLoadingMessages..shuffle()).first;
  }

}
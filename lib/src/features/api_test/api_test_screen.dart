import 'package:flutter/material.dart';
import '../../core/services/missionary_api_service.dart';
import '../../core/services/cache_service.dart';
import '../../core/constants/spiritual_strings.dart';
import '../../../models/enhanced_missionary.dart';

/// Test screen to verify API integration is working
class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({super.key});

  @override
  State<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  final MissionaryApiService _apiService = MissionaryApiService();
  final CacheService _cacheService = CacheService();
  
  bool _isLoading = false;
  String? _status;
  List<ProfileSummary> _profiles = [];
  EnhancedMissionary? _selectedMissionary;
  Map<String, dynamic>? _healthData;

  @override
  void initState() {
    super.initState();
    _performHealthCheck();
  }

  Future<void> _performHealthCheck() async {
    setState(() {
      _isLoading = true;
      _status = SpiritualStrings.randomLoadingMessage;
    });

    final result = await _apiService.healthCheck();
    result.onSuccess((data) {
      setState(() {
        _healthData = data;
        _status = 'API is healthy! ✅';
        _isLoading = false;
      });
    });

    result.onFailure((error) {
      setState(() {
        _status = 'API health check failed: $error ❌';
        _isLoading = false;
      });
    });
  }

  Future<void> _testGetProfiles() async {
    setState(() {
      _isLoading = true;
      _status = 'Gathering testimonies of faithful servants...';
    });

    final result = await _apiService.getProfiles(limit: 10);
    result.onSuccess((response) {
      setState(() {
        _profiles = response.profiles;
        _status = 'Found ${response.profiles.length} saints! ✅';
        _isLoading = false;
      });
    });

    result.onFailure((error) {
      setState(() {
        _status = 'Failed to fetch profiles: $error ❌';
        _isLoading = false;
      });
    });
  }

  Future<void> _testGetSingleProfile(String id) async {
    setState(() {
      _isLoading = true;
      _status = 'Witnessing testament of $id...';
    });

    final result = await _apiService.getProfile(id);
    result.onSuccess((missionary) {
      setState(() {
        _selectedMissionary = missionary;
        _status = 'Loaded ${missionary.name}\'s testament! ✅';
        _isLoading = false;
      });
    });

    result.onFailure((error) {
      setState(() {
        _status = 'Failed to load missionary: $error ❌';
        _isLoading = false;
      });
    });
  }

  Future<void> _testSearchProfiles(String query) async {
    setState(() {
      _isLoading = true;
      _status = 'Seeking among saints for "$query"...';
    });

    final result = await _apiService.searchProfiles(query);
    result.onSuccess((results) {
      setState(() {
        _profiles = results;
        _status = 'Found ${results.length} saints matching "$query" ✅';
        _isLoading = false;
      });
    });

    result.onFailure((error) {
      setState(() {
        _status = 'Search failed: $error ❌';
        _isLoading = false;
      });
    });
  }

  Future<void> _testCacheStats() async {
    final stats = await _cacheService.getCacheStats();
    setState(() {
      _status = 'Cache stats: ${stats.toString()} 📊';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Integration Test'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'API Status',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    if (_isLoading)
                      Row(
                        children: [
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(_status ?? '')),
                        ],
                      )
                    else
                      Text(_status ?? 'Ready to test API'),
                    if (_healthData != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Health Data: ${_healthData.toString()}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Test Buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : _performHealthCheck,
                  child: const Text('Health Check'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _testGetProfiles,
                  child: const Text('Get Profiles'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : () => _testGetSingleProfile('william-carey'),
                  child: const Text('Get William Carey'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : () => _testSearchProfiles('India'),
                  child: const Text('Search "India"'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _testCacheStats,
                  child: const Text('Cache Stats'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _toggleFallbackTest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _apiService.isInFallbackTestMode 
                        ? Colors.orange 
                        : Colors.blue,
                  ),
                  child: Text(_apiService.isInFallbackTestMode 
                      ? 'Disable Fallback Test' 
                      : 'Enable Fallback Test'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Results
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Results',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Selected missionary details
                              if (_selectedMissionary != null) ...[
                                Text(
                                  'Selected Missionary:',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                const SizedBox(height: 4),
                                Text('Name: ${_selectedMissionary!.name}'),
                                Text('Display: ${_selectedMissionary!.displayName}'),
                                Text('Dates: ${_selectedMissionary!.dates.display}'),
                                Text('Summary: ${_selectedMissionary!.summary}'),
                                Text('Timeline Events: ${_selectedMissionary!.timeline.length}'),
                                Text('Quiz Questions: ${_selectedMissionary!.quiz.length}'),
                                Text('Locations: ${_selectedMissionary!.locations.length}'),
                                Text('Categories: ${_selectedMissionary!.categories.join(', ')}'),
                                Text('Source: ${_selectedMissionary!.source}'),
                                const Divider(),
                              ],

                              // Profiles list
                              if (_profiles.isNotEmpty) ...[
                                Text(
                                  'Profiles (${_profiles.length}):',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                const SizedBox(height: 4),
                                ..._profiles.map((profile) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Card(
                                    margin: EdgeInsets.zero,
                                    child: ListTile(
                                      leading: profile.image != null
                                          ? CircleAvatar(
                                              backgroundImage: NetworkImage(profile.image!),
                                              onBackgroundImageError: (_, __) {},
                                            )
                                          : const CircleAvatar(
                                              child: Icon(Icons.person),
                                            ),
                                      title: Text(profile.name),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(profile.dates.display),
                                          Text(
                                            profile.summary,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text('Categories: ${profile.categories.join(', ')}'),
                                        ],
                                      ),
                                      onTap: () => _testGetSingleProfile(profile.id),
                                    ),
                                  ),
                                )).toList(),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleFallbackTest() {
    setState(() {
      if (_apiService.isInFallbackTestMode) {
        _apiService.disableFallbackTest();
        _status = '✅ Cloudflare API re-enabled';
      } else {
        _apiService.enableFallbackTest();
        _status = '🧪 Fallback test mode enabled - Cloudflare API disabled';
      }
    });
  }
}
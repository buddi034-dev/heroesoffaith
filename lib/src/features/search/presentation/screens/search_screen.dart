import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../models/enhanced_missionary.dart';
import '../../../../core/services/missionary_api_service.dart';
import '../../../../core/constants/spiritual_strings.dart';
import '../../../../core/widgets/missionary_image.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'Most Viewed';
  int _selectedIndex = 0;
  
  // API service and data
  final MissionaryApiService _apiService = MissionaryApiService();
  List<ProfileSummary> _profiles = [];
  bool _isLoading = false;
  String? _error;
  
  // Available filter options
  final List<String> _filters = [
    'Most Viewed',
    'Recent',
    'Alphabetical',
  ];

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProfiles() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _apiService.getProfiles(limit: 50);
    result.onSuccess((response) {
      setState(() {
        _profiles = response.profiles;
        _isLoading = false;
      });
    });

    result.onFailure((error) {
      setState(() {
        _error = error;
        _isLoading = false;
      });
    });
  }

  Future<void> _performSearch() async {
    if (_searchQuery.isEmpty) {
      await _loadProfiles();
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _apiService.searchProfiles(_searchQuery);
    result.onSuccess((results) {
      setState(() {
        _profiles = results;
        _isLoading = false;
      });
    });

    result.onFailure((error) {
      setState(() {
        _error = error;
        _isLoading = false;
      });
    });
  }

  List<ProfileSummary> _filterProfiles(List<ProfileSummary> profiles) {
    var filtered = profiles;
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((profile) {
        final nameMatch = profile.name.toLowerCase().contains(_searchQuery.toLowerCase());
        final summaryMatch = profile.summary.toLowerCase().contains(_searchQuery.toLowerCase());
        final categoryMatch = profile.categories.any((cat) => cat.toLowerCase().contains(_searchQuery.toLowerCase()));
        
        return nameMatch || summaryMatch || categoryMatch;
      }).toList();
    }
    
    // Apply sorting based on selected filter
    switch (_selectedFilter) {
      case 'Most Viewed':
        // For now, just return as is since we don't have view count data
        break;
      case 'Recent':
        // Sort by birth year (most recent first)
        filtered.sort((a, b) {
          final aBirth = a.dates.birth ?? 0;
          final bBirth = b.dates.birth ?? 0;
          return bBirth.compareTo(aBirth);
        });
        break;
      case 'Alphabetical':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
    }
    
    return filtered;
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      // Home - navigate back to home screen
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _selectedIndex = index;
      });
      // For other tabs, show coming soon message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${["Home", "Stats", "Favorites", "Profile"][index]} feature coming soon!'),
          backgroundColor: const Color(0xFF667eea),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
              Color(0xFFf093fb),
              Color(0xFFf5576c),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Section
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Search header
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Search Missionaries',
                            style: GoogleFonts.lato(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Search field
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                          _performSearch();
                        },
                        decoration: InputDecoration(
                          hintText: SpiritualStrings.searchHint,
                          hintStyle: GoogleFonts.lato(
                            color: Colors.grey[500],
                            fontSize: 16,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey[500],
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Filter chips
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _filters.length,
                        itemBuilder: (context, index) {
                          final filter = _filters[index];
                          final isSelected = filter == _selectedFilter;
                          
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedFilter = filter;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected 
                                      ? Colors.white 
                                      : Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  filter,
                                  style: GoogleFonts.lato(
                                    fontSize: 14,
                                    color: isSelected 
                                        ? const Color(0xFF667eea) 
                                        : Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              
              // Results Section
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Builder(
                    builder: (context) {
                      if (_error != null) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.cloud_off,
                                size: 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Connection Challenge',
                                style: GoogleFonts.lato(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                _error!,
                                style: GoogleFonts.lato(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadProfiles,
                                child: Text(SpiritualStrings.seekAgain),
                              ),
                            ],
                          ),
                        );
                      }
                      
                      if (_isLoading) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(color: Color(0xFF667eea)),
                              const SizedBox(height: 16),
                              Text(
                                SpiritualStrings.randomLoadingMessage,
                                style: GoogleFonts.lato(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }
                      
                      if (_profiles.isEmpty) {
                        return Center(
                          child: Text(
                            'No faithful servants found.',
                            style: GoogleFonts.lato(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        );
                      }

                      final filteredProfiles = _filterProfiles(_profiles);
                      
                      if (filteredProfiles.isEmpty && _searchQuery.isNotEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.search_off, 
                                size: 64, 
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No missionaries found for "$_searchQuery"',
                                style: GoogleFonts.lato(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                'Try a different search term',
                                style: GoogleFonts.lato(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: filteredProfiles.length,
                        itemBuilder: (context, index) {
                          final profile = filteredProfiles[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: MissionaryImage(
                                    primaryImageUrl: profile.image,
                                    missionaryId: profile.id,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              title: Text(
                                profile.name,
                                style: GoogleFonts.lato(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    profile.dates.display,
                                    style: GoogleFonts.lato(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    profile.summary.length > 80 
                                      ? '${profile.summary.substring(0, 80)}...'
                                      : profile.summary,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.lato(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  if (profile.categories.isNotEmpty)
                                    Text(
                                      profile.categories.join(', '),
                                      style: GoogleFonts.lato(
                                        fontSize: 11,
                                        color: const Color(0xFF667eea),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                ],
                              ),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.grey,
                              ),
                              onTap: () {
                                // TODO: Navigate to missionary profile
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFF667eea),
          unselectedItemColor: Colors.grey[400],
          selectedLabelStyle: GoogleFonts.lato(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.lato(
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.house, size: 20),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.chartLine, size: 20),
              label: 'Stats',
            ),
            BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.heart, size: 20),
              label: 'Favorites',
            ),
            BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.user, size: 20),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
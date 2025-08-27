import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' as math;
import 'missionary_profile_screen.dart';
import '../../../models/enhanced_missionary.dart';
import '../../../src/core/routes/route_names.dart';
import '../../../src/core/services/missionary_api_service.dart';
import '../../../src/core/services/cache_service.dart';
import '../../../src/core/constants/spiritual_strings.dart';
import '../../../src/core/widgets/missionary_image.dart';

class MissionaryListScreen extends StatefulWidget {
  const MissionaryListScreen({super.key});

  @override
  State<MissionaryListScreen> createState() => _MissionaryListScreenState();
}

class _MissionaryListScreenState extends State<MissionaryListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'Most Viewed';
  int _selectedIndex = 0;
  
  // Advanced filter options
  String? _selectedCountry;
  String? _selectedCentury;
  String? _selectedFieldOfService;
  
  // Store card colors to prevent changing during swipe animations
  final Map<String, LinearGradient> _cardColors = {};
  PageController? _pageController;
  
  // API service and data
  final MissionaryApiService _apiService = MissionaryApiService();
  final CacheService _cacheService = CacheService();
  List<ProfileSummary> _profiles = [];
  bool _isLoading = true;
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
    _pageController?.dispose();
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
    
    // Apply category filter (using categories from API instead of old fields)
    if (_selectedCountry != null) {
      filtered = filtered.where((profile) {
        return profile.categories.any((cat) => cat.toLowerCase().contains(_selectedCountry!.toLowerCase()));
      }).toList();
    }
    
    if (_selectedCentury != null) {
      filtered = filtered.where((profile) {
        final birthYear = profile.dates.birth;
        if (birthYear == null) return false;
        final century = (birthYear ~/ 100) + 1;
        return century.toString().contains(_selectedCentury!.replaceAll(RegExp(r'[^0-9]'), ''));
      }).toList();
    }
    
    if (_selectedFieldOfService != null) {
      filtered = filtered.where((profile) {
        return profile.categories.any((cat) => cat.toLowerCase().contains(_selectedFieldOfService!.toLowerCase()));
      }).toList();
    }
    
    // Apply sorting based on selected filter
    switch (_selectedFilter) {
      case 'Most Viewed':
        // Sort by summary length as proxy for rich content
        filtered.sort((a, b) {
          final aScore = a.name.length + a.summary.length;
          final bScore = b.name.length + b.summary.length;
          return bScore.compareTo(aScore);
        });
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
  
  int _getCenturyOrder(String? century) {
    if (century == null) return 0;
    
    // Extract century number from strings like "20th Century", "19th Century", etc.
    final centuryRegex = RegExp(r'(\d+)');
    final match = centuryRegex.firstMatch(century);
    if (match != null) {
      return int.tryParse(match.group(1) ?? '0') ?? 0;
    }
    
    // Handle text-based centuries
    switch (century.toLowerCase()) {
      case '21st century':
      case 'modern':
      case 'contemporary':
        return 21;
      case '20th century':
        return 20;
      case '19th century':
        return 19;
      case '18th century':
        return 18;
      case '17th century':
        return 17;
      default:
        return 0;
    }
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      // Home - navigate back to home screen
      Navigator.of(context).pop();
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



  String _formatUserName(String name) {
    // Split by space and capitalize first letter of each part
    return name.split(' ')
        .map((part) => part.isNotEmpty ? part[0].toUpperCase() + part.substring(1).toLowerCase() : '')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final rawUserName = user?.displayName ?? user?.email?.split('@')[0] ?? 'User';
    final userName = _formatUserName(rawUserName);
    
    
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
          child: Stack(
            children: [
              // Main content
              Column(
                children: [
              // Header Section
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    
                    // Filter tabs
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          SpiritualStrings.faithfulServants,
                          style: GoogleFonts.lato(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'View all',
                          style: GoogleFonts.lato(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Search Bar
                    Container(
                      height: 44, // Fixed height to make it smaller
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        style: GoogleFonts.lato(
                          color: Colors.white,
                          fontSize: 14, // Smaller font size
                        ),
                        decoration: InputDecoration(
                          hintText: SpiritualStrings.searchHint,
                          hintStyle: GoogleFonts.lato(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 14, // Smaller hint text
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.white.withValues(alpha: 0.8),
                            size: 20, // Smaller icon
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: Colors.white.withValues(alpha: 0.8),
                                    size: 18, // Smaller clear icon
                                  ),
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
                            horizontal: 16, // Reduced horizontal padding
                            vertical: 12,  // Reduced vertical padding
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Filter chips and advanced filter button
                    Row(
                      children: [
                        // Filter chips
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: _filters.map((filter) {
                              final isSelected = filter == _selectedFilter;
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 2),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedFilter = filter;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected 
                                            ? Colors.white 
                                            : Colors.white.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        filter,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.lato(
                                          fontSize: 10,
                                          color: isSelected 
                                              ? const Color(0xFF667eea) 
                                              : Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        
                        const SizedBox(width: 8),
                        
                        // Advanced filter button
                        GestureDetector(
                          onTap: _showAdvancedFilters,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _hasAdvancedFilters() 
                                  ? const Color(0xFFf5576c) 
                                  : Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              Icons.tune,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    // Search results count
                    if (_searchQuery.isNotEmpty) ...[
                      Builder(
                        builder: (context) {
                          final filteredCount = _filterProfiles(_profiles).length;
                          return Text(
                            'Found $filteredCount faithful servant${filteredCount != 1 ? 's' : ''} for "$_searchQuery"',
                            style: GoogleFonts.lato(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w400,
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
              
              // Cards Section
              Expanded(
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
                              color: Colors.white,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Connection Challenge',
                              style: GoogleFonts.lato(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              _error!,
                              style: GoogleFonts.lato(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.8),
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
                            const CircularProgressIndicator(color: Colors.white),
                            const SizedBox(height: 16),
                            Text(
                              SpiritualStrings.randomLoadingMessage,
                              style: GoogleFonts.lato(
                                color: Colors.white,
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
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }
                        
                    final filteredProfiles = _filterProfiles(_profiles);
                    
                    if (filteredProfiles.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.search_off, 
                              size: 64, 
                              color: Colors.white,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No faithful servants found',
                              style: GoogleFonts.lato(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Try adjusting your search',
                              style: GoogleFonts.lato(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Vertical scrolling carousel
                    return _buildVerticalCarouselFromApi(filteredProfiles);
                  },
                ),
              ),
                ],
              ),
              
              // Top action buttons like detailed missionary page
              Positioned(
                top: 15,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back button (left side)
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back, color: Colors.black87),
                        iconSize: 18,
                      ),
                    ),
                    
                    // Close button (right side)
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.black87),
                        iconSize: 18,
                      ),
                    ),
                  ],
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
          items: [
            const BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.house, size: 20),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.chartLine, size: 20),
              label: 'Stats',
            ),
            const BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.heart, size: 20),
              label: 'Favorites',
            ),
            BottomNavigationBarItem(
              icon: _buildProfileIcon(user, userName),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileIcon(User? user, String userName) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF667eea),
        border: Border.all(
          color: _selectedIndex == 3 ? const Color(0xFF667eea) : Colors.grey[400]!,
          width: 2,
        ),
      ),
      child: user?.photoURL != null && user!.photoURL!.isNotEmpty
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: user.photoURL!,
                fit: BoxFit.cover,
                width: 20,
                height: 20,
                placeholder: (context, url) => Container(
                  color: const Color(0xFF667eea),
                  child: Center(
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                      style: GoogleFonts.lato(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: const Color(0xFF667eea),
                  child: Center(
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                      style: GoogleFonts.lato(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            )
          : Center(
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                style: GoogleFonts.lato(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
    );
  }


  // LEGACY METHODS REMOVED - replaced with API versions


  // Generate stable gradient colors for cards - dark backgrounds for better white text readability
  LinearGradient _getCardGradient(String missionaryName, int index) {
    final gradients = [
      LinearGradient(colors: [Colors.blue[600]!, Colors.blue[900]!], begin: Alignment.topLeft, end: Alignment.bottomRight),
      LinearGradient(colors: [Colors.green[600]!, Colors.green[900]!], begin: Alignment.topLeft, end: Alignment.bottomRight),
      LinearGradient(colors: [Colors.orange[600]!, Colors.orange[900]!], begin: Alignment.topLeft, end: Alignment.bottomRight),
      LinearGradient(colors: [Colors.purple[600]!, Colors.purple[900]!], begin: Alignment.topLeft, end: Alignment.bottomRight),
      LinearGradient(colors: [Colors.pink[600]!, Colors.pink[900]!], begin: Alignment.topLeft, end: Alignment.bottomRight),
      LinearGradient(colors: [Colors.teal[600]!, Colors.teal[900]!], begin: Alignment.topLeft, end: Alignment.bottomRight),
      LinearGradient(colors: [Colors.indigo[600]!, Colors.indigo[900]!], begin: Alignment.topLeft, end: Alignment.bottomRight),
      LinearGradient(colors: [Colors.cyan[600]!, Colors.cyan[900]!], begin: Alignment.topLeft, end: Alignment.bottomRight),
      LinearGradient(colors: [Colors.deepOrange[600]!, Colors.deepOrange[900]!], begin: Alignment.topLeft, end: Alignment.bottomRight),
      LinearGradient(colors: [Colors.red[700]!, Colors.red[900]!], begin: Alignment.topLeft, end: Alignment.bottomRight),
      LinearGradient(colors: [Colors.lightBlue[600]!, Colors.lightBlue[900]!], begin: Alignment.topLeft, end: Alignment.bottomRight),
      LinearGradient(colors: [Colors.deepPurple[600]!, Colors.deepPurple[900]!], begin: Alignment.topLeft, end: Alignment.bottomRight),
      LinearGradient(colors: [Colors.brown[600]!, Colors.brown[800]!], begin: Alignment.topLeft, end: Alignment.bottomRight),
      LinearGradient(colors: [Colors.blueGrey[700]!, Colors.blueGrey[900]!], begin: Alignment.topLeft, end: Alignment.bottomRight),
      LinearGradient(colors: [const Color(0xFF2D3748), const Color(0xFF1A202C)], begin: Alignment.topLeft, end: Alignment.bottomRight), // Dark slate
      LinearGradient(colors: [const Color(0xFF7C3AED), const Color(0xFF4C1D95)], begin: Alignment.topLeft, end: Alignment.bottomRight), // Rich purple
      LinearGradient(colors: [const Color(0xFF059669), const Color(0xFF064E3B)], begin: Alignment.topLeft, end: Alignment.bottomRight), // Emerald
      LinearGradient(colors: [const Color(0xFFDC2626), const Color(0xFF7F1D1D)], begin: Alignment.topLeft, end: Alignment.bottomRight), // Rich red
    ];
    
    // Check if this card is the current focused card
    final isFocusedCard = _pageController?.hasClients == true && 
        _pageController?.page != null && 
        _pageController!.page!.round() == index;
    
    // Only assign new random color when card becomes the main focus
    if (isFocusedCard && !_cardColors.containsKey(missionaryName)) {
      final random = math.Random();
      _cardColors[missionaryName] = gradients[random.nextInt(gradients.length)];
    }
    
    // Return assigned color or default if not yet assigned
    return _cardColors[missionaryName] ?? gradients[index % gradients.length];
  }


  // Helper function to convert text to Title Case
  String _toTitleCase(String text) {
    return text
        .toLowerCase()
        .split(' ')
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : word)
        .join(' ');
  }

  // Helper function to convert text to Sentence case
  String _toSentenceCase(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  void _navigateToProfile(ProfileSummary profile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MissionaryProfileScreen(
          missionaryId: profile.id,
        ),
      ),
    );
  }


  bool _hasAdvancedFilters() {
    return _selectedCountry != null || 
           _selectedCentury != null || 
           _selectedFieldOfService != null;
  }

  void _showAdvancedFilters() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildAdvancedFilterModal(),
    );
  }

  Widget _buildAdvancedFilterModal() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Advanced Filters',
                  style: GoogleFonts.lato(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Row(
                  children: [
                    if (_hasAdvancedFilters())
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedCountry = null;
                            _selectedCentury = null;
                            _selectedFieldOfService = null;
                          });
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Clear All',
                          style: GoogleFonts.lato(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Filter options
          Expanded(
            child: FutureBuilder<List<ProfileSummary>>(
              future: _loadAllProfilesForFilters(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final profiles = snapshot.data!;
                
                // Extract filter options from API data
                final countries = profiles
                    .expand((p) => p.categories) // Use categories as country equivalents
                    .where((c) => c.isNotEmpty)
                    .toSet()
                    .toList()..sort();
                
                final centuries = profiles
                    .map((p) => _extractCentury(p.dates.display))
                    .where((c) => c.isNotEmpty)
                    .toSet()
                    .toList()..sort();
                
                final fieldsOfService = profiles
                    .expand((p) => p.categories)
                    .where((f) => f.isNotEmpty)
                    .toSet()
                    .toList()..sort();
                
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFilterSection('Category', countries, _selectedCountry, (value) {
                        setState(() {
                          _selectedCountry = value;
                        });
                      }),
                      
                      const SizedBox(height: 24),
                      
                      _buildFilterSection('Century', centuries, _selectedCentury, (value) {
                        setState(() {
                          _selectedCentury = value;
                        });
                      }),
                      
                      const SizedBox(height: 24),
                      
                      _buildFilterSection('Field of Service', fieldsOfService, _selectedFieldOfService, (value) {
                        setState(() {
                          _selectedFieldOfService = value;
                        });
                      }),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(String title, List<String> options, String? selectedValue, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.lato(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // Clear option
            GestureDetector(
              onTap: () => onChanged(null),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: selectedValue == null ? const Color(0xFF667eea) : Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selectedValue == null ? const Color(0xFF667eea) : Colors.grey[300]!,
                  ),
                ),
                child: Text(
                  'All',
                  style: GoogleFonts.lato(
                    color: selectedValue == null ? Colors.white : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            // Options
            ...options.map((option) {
              final isSelected = selectedValue == option;
              return GestureDetector(
                onTap: () => onChanged(option),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF667eea) : Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF667eea) : Colors.grey[300]!,
                    ),
                  ),
                  child: Text(
                    option,
                    style: GoogleFonts.lato(
                      color: isSelected ? Colors.white : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ],
    );
  }

  // NEW API VERSION METHODS

  Widget _buildVerticalCarouselFromApi(List<ProfileSummary> profiles) {
    _pageController ??= PageController(
      viewportFraction: 1.0,
      initialPage: 0,
    );
    final PageController pageController = _pageController!;

    return PageView.builder(
      controller: pageController,
      scrollDirection: Axis.vertical,
      itemCount: profiles.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: pageController,
          builder: (context, child) {
            double value = 1.0;
            if (pageController.position.haveDimensions) {
              value = pageController.page! - index;
              value = (1 - (value.abs() * 0.15)).clamp(0.85, 1.0);
            }
            return _buildAnimatedCardFromApi(profiles[index], value, pageController, index);
          },
        );
      },
    );
  }

  Future<List<ProfileSummary>> _loadAllProfilesForFilters() async {
    final result = await _apiService.getProfiles(limit: 100);
    if (result.isSuccess && result.data != null) {
      return result.data!.profiles;
    }
    return [];
  }

  String _extractCentury(String dateDisplay) {
    final regex = RegExp(r'\b(\d{4})\b');
    final matches = regex.allMatches(dateDisplay);
    if (matches.isNotEmpty) {
      final year = int.parse(matches.first.group(0)!);
      final century = ((year - 1) ~/ 100) + 1;
      return '${century}th Century';
    }
    return '';
  }

  Widget _buildAnimatedCardFromApi(ProfileSummary profile, double scale, PageController pageController, int index) {
    return GestureDetector(
      onTap: () => _navigateToProfile(profile),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            height: constraints.maxHeight,
            decoration: BoxDecoration(
              gradient: pageController.page?.round() == index ? _getCardGradient(profile.name, index) : const LinearGradient(
                colors: [Colors.grey, Colors.grey],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: _buildPortraitCardLayoutFromApi(profile, index),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPortraitCardLayoutFromApi(ProfileSummary profile, int index) {
    return Column(
      children: [
        // Image section - 55%
        Expanded(
          flex: 55,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: MissionaryImage(
                primaryImageUrl: profile.image,
                missionaryId: profile.id,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        
        // Text section - 35%
        Expanded(
          flex: 35,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Name
                Text(
                  _toTitleCase(profile.name),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.lato(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.1,
                    letterSpacing: 0.5,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Categories
                Text(
                  profile.categories.isNotEmpty ? profile.categories.join(', ') : 'Faithful Service',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.95),
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
                
                const SizedBox(height: 10),
                
                // Summary
                if (profile.summary.isNotEmpty)
                  Text(
                    profile.summary.length > 120 
                      ? '${profile.summary.substring(0, 120)}...'
                      : profile.summary,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.lato(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w400,
                      height: 1.3,
                    ),
                  ),
              ],
            ),
          ),
        ),
        
        // Icons section - 10%
        Expanded(
          flex: 10,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left group
                Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          gradient: _getCardGradient(profile.name, index),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            profile.name.isNotEmpty ? profile.name[0] : 'M',
                            style: GoogleFonts.lato(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          _toSentenceCase(profile.dates.display),
                          style: GoogleFonts.lato(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Center: Branding
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Heroes of Faith',
                      style: GoogleFonts.lato(
                        fontSize: 10,
                        color: Colors.white.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                
                // Right group: Action icons
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.bookmark_border,
                        size: 18,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.headphones_outlined,
                        size: 18,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _navigateToApiProfile(ProfileSummary profile) {
    // For now, show a message - later we'll create enhanced profile screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${SpiritualStrings.witnessTestament} ${profile.name} - Enhanced profile coming soon!'),
        backgroundColor: const Color(0xFF667eea),
      ),
    );
  }
}
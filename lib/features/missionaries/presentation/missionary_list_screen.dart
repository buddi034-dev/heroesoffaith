import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' as math;
import '../../../models/missionary.dart';
import '../../../src/core/routes/route_names.dart';

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
  
  // Available filter options
  final List<String> _filters = [
    'Most Viewed',
    'Recent',
    'Alphabetical',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _pageController?.dispose();
    super.dispose();
  }

  List<Missionary> _filterMissionaries(List<Missionary> missionaries) {
    var filtered = missionaries;
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((missionary) {
        final nameMatch = missionary.fullName.toLowerCase().contains(_searchQuery.toLowerCase());
        final bioMatch = missionary.bio?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false;
        final fieldMatch = missionary.fieldOfService?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false;
        final countryMatch = missionary.countryOfService?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false;
        final centuryMatch = missionary.century?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false;
        
        return nameMatch || bioMatch || fieldMatch || countryMatch || centuryMatch;
      }).toList();
    }
    
    // Apply advanced filters
    if (_selectedCountry != null) {
      filtered = filtered.where((missionary) {
        return missionary.countryOfService?.toLowerCase() == _selectedCountry!.toLowerCase();
      }).toList();
    }
    
    if (_selectedCentury != null) {
      filtered = filtered.where((missionary) {
        return missionary.century?.toLowerCase().contains(_selectedCentury!.toLowerCase()) ?? false;
      }).toList();
    }
    
    if (_selectedFieldOfService != null) {
      filtered = filtered.where((missionary) {
        return missionary.fieldOfService?.toLowerCase().contains(_selectedFieldOfService!.toLowerCase()) ?? false;
      }).toList();
    }
    
    // Apply sorting based on selected filter
    switch (_selectedFilter) {
      case 'Most Viewed':
        // Sort by name length as a proxy for "popularity" since we don't have view count data
        filtered.sort((a, b) {
          final aScore = a.fullName.length + (a.bio?.length ?? 0);
          final bScore = b.fullName.length + (b.bio?.length ?? 0);
          return bScore.compareTo(aScore);
        });
        break;
      case 'Recent':
        // Sort by century (most recent first), then alphabetically
        filtered.sort((a, b) {
          final aCentury = _getCenturyOrder(a.century);
          final bCentury = _getCenturyOrder(b.century);
          if (aCentury != bCentury) {
            return bCentury.compareTo(aCentury); // Most recent first
          }
          return a.fullName.compareTo(b.fullName);
        });
        break;
      case 'Alphabetical':
        filtered.sort((a, b) => a.fullName.compareTo(b.fullName));
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
                          'Popular missionaries',
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
                          hintText: 'Search missionaries...',
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
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection('missionaries').limit(50).snapshots(), // Limit results
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final allMissionaries = snapshot.data!.docs
                                .map((doc) => Missionary.fromFirestore(doc))
                                .toList();
                            final filteredCount = _filterMissionaries(allMissionaries).length;
                            return Text(
                              'Found $filteredCount result${filteredCount != 1 ? 's' : ''} for "$_searchQuery"',
                              style: GoogleFonts.lato(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w400,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ],
                ),
              ),
              
              // Cards Section
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('missionaries').limit(50).snapshots(), // Limit results for performance
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: GoogleFonts.lato(color: Colors.white),
                        ),
                      );
                    }
                    
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }
                    
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text(
                          'No missionaries found.',
                          style: GoogleFonts.lato(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }

                    final allMissionaries = snapshot.data!.docs
                        .map((doc) => Missionary.fromFirestore(doc))
                        .toList();
                        
                    final filteredMissionaries = _filterMissionaries(allMissionaries);
                    
                    if (filteredMissionaries.isEmpty) {
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
                              'No missionaries found',
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
                    return _buildVerticalCarousel(filteredMissionaries);
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


  Widget _buildPortraitCardLayout(Missionary missionary, int index) {
    return Column(
      children: [
              // Image section - 55%
              Expanded(
                flex: 55,
                child: Padding(
                  padding: const EdgeInsets.all(8.0), // 2% padding for frame effect
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: Container(
                      width: double.infinity,
                      child: missionary.heroImageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: missionary.heroImageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              memCacheHeight: 300, // Cache optimization
                              memCacheWidth: 300, // Cache optimization
                              placeholder: (context, url) => Container(
                                decoration: BoxDecoration(
                                  gradient: _getCardGradient(missionary.fullName, index),
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                decoration: BoxDecoration(
                                  gradient: _getCardGradient(missionary.fullName, index),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                gradient: _getCardGradient(missionary.fullName, index),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              
              // Text section - 35% for more text space
              Expanded(
                flex: 35,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 4), // No top padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start, // Align to top
                    children: [
                      // Missionary name - BOLD and prominent
                      Text(
                        _toTitleCase(missionary.fullName),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.lato(
                          fontSize: 20,
                          fontWeight: FontWeight.w900, // Extra bold
                          color: Colors.white,
                          height: 1.1,
                          letterSpacing: 0.5,
                        ),
                      ),
                      
                      const SizedBox(height: 12), // Increased spacing after name
                      
                      // Field of Service
                      Text(
                        missionary.fieldOfService ?? 'Missionary Work',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.95),
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                      
                      const SizedBox(height: 10), // Increased spacing after field of service
                      
                      // Bio - readable but smaller
                      if (missionary.bio != null && missionary.bio!.isNotEmpty)
                        Text(
                          missionary.bio!.length > 120 
                            ? '${missionary.bio!.substring(0, 120)}...'
                            : missionary.bio!,
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
                      // Left group: Author info
                      Expanded(
                        flex: 2,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                gradient: _getCardGradient(missionary.fullName, index),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  missionary.fullName.isNotEmpty ? missionary.fullName[0] : 'M',
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
                                _toSentenceCase(missionary.century ?? 'Historical'),
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
                      
                      // Center: Heroes of Faith branding
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

  // Build vertical carousel with sneak peek animation
  Widget _buildVerticalCarousel(List<Missionary> missionaries) {
    _pageController ??= PageController(
      viewportFraction: 1.0, // Full height for cards
      initialPage: 0,
    );
    final PageController pageController = _pageController!;

    return PageView.builder(
      controller: pageController,
      scrollDirection: Axis.vertical, // Vertical scrolling
      itemCount: missionaries.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: pageController,
          builder: (context, child) {
            double value = 1.0;
            if (pageController.position.haveDimensions) {
              value = pageController.page! - index;
              // More dramatic scaling: main card = 1.0, side cards = 0.85
              value = (1 - (value.abs() * 0.15)).clamp(0.85, 1.0);
            }
            return _buildAnimatedCard(missionaries[index], value, pageController, index);
          },
        );
      },
    );
  }

  // Build animated card with scaling effect
  Widget _buildAnimatedCard(Missionary missionary, double scale, PageController pageController, int index) {
    return GestureDetector(
      onTap: () => _navigateToProfile(missionary),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            height: constraints.maxHeight,
            decoration: BoxDecoration(
              gradient: pageController.page?.round() == index ? _getCardGradient(missionary.fullName, index) : const LinearGradient(
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
              child: _buildPortraitCardLayout(missionary, index),
            ),
          );
        },
      ),
    );
  }


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

  void _navigateToProfile(Missionary missionary) {
    Navigator.of(context).pushNamed(
      RouteNames.missionaryProfile,
      arguments: missionary,
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
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('missionaries').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final missionaries = snapshot.data!.docs
                    .map((doc) => Missionary.fromFirestore(doc))
                    .toList();
                
                final countries = missionaries
                    .map((m) => m.countryOfService)
                    .where((c) => c != null && c.isNotEmpty)
                    .cast<String>()
                    .toSet()
                    .toList()..sort();
                
                final centuries = missionaries
                    .map((m) => m.century)
                    .where((c) => c != null && c.isNotEmpty)
                    .cast<String>()
                    .toSet()
                    .toList()..sort();
                
                final fieldsOfService = missionaries
                    .map((m) => m.fieldOfService)
                    .where((f) => f != null && f.isNotEmpty)
                    .cast<String>()
                    .toSet()
                    .toList()..sort();
                
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFilterSection('Country', countries, _selectedCountry, (value) {
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
}
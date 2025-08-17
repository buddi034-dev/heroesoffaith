import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../models/missionary.dart';

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
  
  // Available filter options
  final List<String> _filters = [
    'Most Viewed',
    'Recent',
    'Alphabetical',
  ];

  @override
  void dispose() {
    _searchController.dispose();
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
        
        return nameMatch || bioMatch || fieldMatch || countryMatch;
      }).toList();
    }
    
    // Apply sorting based on selected filter
    switch (_selectedFilter) {
      case 'Most Viewed':
        // For now, just return as is since we don't have view count data
        break;
      case 'Recent':
        // Sort by some criteria - for now just reverse alphabetical
        filtered.sort((a, b) => b.fullName.compareTo(a.fullName));
        break;
      case 'Alphabetical':
        filtered.sort((a, b) => a.fullName.compareTo(b.fullName));
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
                        decoration: InputDecoration(
                          hintText: 'Search by name, country, field...',
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
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
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
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('missionaries').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error: ${snapshot.error}',
                            style: GoogleFonts.lato(color: Colors.grey[600]),
                          ),
                        );
                      }
                      
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(color: Color(0xFF667eea)),
                        );
                      }
                      
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Text(
                            'No missionaries found.',
                            style: GoogleFonts.lato(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        );
                      }

                      final allMissionaries = snapshot.data!.docs
                          .map((doc) => Missionary.fromFirestore(doc))
                          .toList();
                          
                      final filteredMissionaries = _filterMissionaries(allMissionaries);
                      
                      if (filteredMissionaries.isEmpty && _searchQuery.isNotEmpty) {
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
                        itemCount: filteredMissionaries.length,
                        itemBuilder: (context, index) {
                          final missionary = filteredMissionaries[index];
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
                                  child: missionary.heroImageUrl.isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: missionary.heroImageUrl,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => Container(
                                            color: Colors.grey[300],
                                            child: const Center(
                                              child: CircularProgressIndicator(),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) => Container(
                                            color: const Color(0xFF667eea),
                                            child: const Icon(
                                              Icons.person,
                                              color: Colors.white,
                                              size: 30,
                                            ),
                                          ),
                                        )
                                      : Container(
                                          color: const Color(0xFF667eea),
                                          child: const Icon(
                                            Icons.person,
                                            color: Colors.white,
                                            size: 30,
                                          ),
                                        ),
                                ),
                              ),
                              title: Text(
                                missionary.fullName,
                                style: GoogleFonts.lato(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (missionary.fieldOfService?.isNotEmpty == true)
                                    Text(
                                      missionary.fieldOfService!,
                                      style: GoogleFonts.lato(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  if (missionary.countryOfService?.isNotEmpty == true)
                                    Text(
                                      missionary.countryOfService!,
                                      style: GoogleFonts.lato(
                                        fontSize: 12,
                                        color: Colors.grey[500],
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
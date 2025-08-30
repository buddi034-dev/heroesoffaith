import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../../models/enhanced_missionary.dart';
import '../../../src/core/services/missionary_api_service.dart';
import '../../../src/core/constants/spiritual_strings.dart';
import '../../../src/features/favorites/presentation/widgets/favorite_button.dart';

class MissionaryProfileScreen extends StatefulWidget {
  final String missionaryId;

  const MissionaryProfileScreen({
    super.key,
    required this.missionaryId,
  });

  @override
  State<MissionaryProfileScreen> createState() => _MissionaryProfileScreenState();
}

class _MissionaryProfileScreenState extends State<MissionaryProfileScreen>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _fadeController;
  late AnimationController _timelineAnimationController;
  bool _isScrolled = false;
  bool _isAudioPlaying = false;
  int _selectedTimelineIndex = 0;
  PageController _galleryController = PageController();
  
  final MissionaryApiService _apiService = MissionaryApiService();
  EnhancedMissionary? _missionary;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _timelineAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scrollController.addListener(() {
      if (_scrollController.offset > 100 && !_isScrolled) {
        setState(() => _isScrolled = true);
        _fadeController.forward();
      } else if (_scrollController.offset <= 100 && _isScrolled) {
        setState(() => _isScrolled = false);
        _fadeController.reverse();
      }
    });
    
    _loadMissionaryProfile();
    _timelineAnimationController.forward();
  }

  Future<void> _loadMissionaryProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _apiService.getProfile(widget.missionaryId);
    result.onSuccess((missionary) {
      setState(() {
        _missionary = missionary;
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


  @override
  void dispose() {
    _scrollController.dispose();
    _fadeController.dispose();
    _timelineAnimationController.dispose();
    _galleryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF667eea),
                Color(0xFF764ba2),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
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
                Expanded(
                  child: Center(
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
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    if (_error != null) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF667eea),
                Color(0xFF764ba2),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
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
                Expanded(
                  child: Center(
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
                          onPressed: _loadMissionaryProfile,
                          child: Text(SpiritualStrings.seekAgain),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    if (_missionary == null) {
      return const Scaffold(
        body: Center(
          child: Text('Missionary not found'),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Main content
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Custom App Bar with Hero Image
              SliverAppBar(
                expandedHeight: 400,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: const SizedBox.shrink(), // Remove default leading
                actions: const [], // Remove all actions
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Hero Image
                      (_missionary!.image?.isNotEmpty ?? false)
                          ? CachedNetworkImage(
                              imageUrl: _missionary!.image!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF667eea),
                                      Color(0xFF764ba2),
                                    ],
                                  ),
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(color: Colors.white),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF667eea),
                                      Color(0xFF764ba2),
                                    ],
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(Icons.person, size: 100, color: Colors.white),
                                ),
                              ),
                            )
                          : Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF667eea),
                                    Color(0xFF764ba2),
                                  ],
                                ),
                              ),
                              child: const Center(
                                child: Icon(Icons.person, size: 100, color: Colors.white),
                              ),
                            ),
                      
                      // Gradient Overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                      ),
                      
                      // Title and basic info overlay
                      Positioned(
                        bottom: 20,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _missionary!.name,
                              style: GoogleFonts.lato(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Colors.white.withValues(alpha: 0.9),
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    _missionary!.locations.isNotEmpty ? _missionary!.locations.first.name : 'Unknown Location',
                                    style: GoogleFonts.lato(
                                      fontSize: 16,
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_missionary!.categories.isNotEmpty ? _missionary!.categories.first : 'Missionary Work'} • ${_missionary!.dates.display}',
                              style: GoogleFonts.lato(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Content Sections
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Biography Section
                      _buildBiographySection(),
                      
                      // Timeline Section
                      _buildTimelineSection(),
                      
                      // Gallery Section
                      _buildGallerySection(),
                      
                      // References Section
                      _buildReferencesSection(),
                      
                      // Bottom padding for FABs
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Top action bar like reference image
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Close button (left side)
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
                
                // Action buttons (right side)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      margin: const EdgeInsets.only(right: 8),
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
                      child: Center(
                        child: FavoriteButton(
                          missionaryId: widget.missionaryId,
                          missionaryName: _missionary?.name ?? '',
                          heroImageUrl: _missionary?.image,
                          bio: _missionary?.summary ?? _missionary?.biography?.first.content,
                          size: 18,
                          favoriteColor: Colors.red,
                          unfavoriteColor: Colors.black87,
                          showTooltip: false,
                        ),
                      ),
                    ),
                    Container(
                      width: 36,
                      height: 36,
                      margin: const EdgeInsets.only(right: 8),
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
                        onPressed: () {
                          // TODO: Implement audio functionality later
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Audio feature coming soon!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.volume_up, color: Colors.black87),
                        iconSize: 18,
                      ),
                    ),
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
                        onPressed: () => _shareMissionary(),
                        icon: const Icon(Icons.share, color: Colors.black87),
                        iconSize: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBiographySection() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Biography',
            style: GoogleFonts.lato(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _missionary!.biography.isNotEmpty
                ? _missionary!.biography.map((section) => section.content).join('\n\n')
                : 'This missionary dedicated their life to spreading the Gospel and serving communities. Their work has left a lasting impact on the regions they served, bringing hope and faith to countless individuals.',
            style: GoogleFonts.lato(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineSection() {
    final timelineEvents = _missionary!.timeline.isNotEmpty 
        ? _missionary!.timeline.asMap().entries.map((entry) {
            final index = entry.key;
            final event = entry.value;
            final colors = [
              const Color(0xFF667eea),
              const Color(0xFF764ba2),
              const Color(0xFFf093fb),
              const Color(0xFFf5576c),
            ];
            final icons = [Icons.child_care, Icons.church, Icons.star, Icons.favorite];
            
            return {
              'year': event.year.toString(),
              'title': event.event,
              'description': event.description,
              'color': colors[index % colors.length],
              'icon': icons[index % icons.length],
            };
          }).toList()
        : [
            {
              'year': _missionary!.dates.birth?.toString() ?? '1800',
              'title': 'Early Life',
              'description': 'Born and raised in a Christian family, showing early signs of calling to missionary work.',
              'color': const Color(0xFF667eea),
              'icon': Icons.child_care,
            },
            {
              'year': (_missionary!.dates.birth != null ? (_missionary!.dates.birth! + 25).toString() : '1825'), 
              'title': 'Ministry Begins',
              'description': 'Started missionary work and began spreading the Gospel to local communities.',
              'color': const Color(0xFF764ba2),
              'icon': Icons.church,
            },
            {
              'year': (_missionary!.dates.birth != null ? (_missionary!.dates.birth! + 30).toString() : '1830'),
              'title': 'Major Impact', 
              'description': 'Established churches and educational institutions that continue to serve today.',
              'color': const Color(0xFFf093fb),
              'icon': Icons.star,
            },
            {
              'year': _missionary!.dates.death?.toString() ?? '1840',
              'title': 'Legacy',
              'description': 'Their influence spread across regions, inspiring generations of future missionaries.',
              'color': const Color(0xFFf5576c),
              'icon': Icons.favorite,
            },
          ];

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Life Timeline',
                style: GoogleFonts.lato(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${timelineEvents.length} Events',
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Interactive Timeline
          ...timelineEvents.asMap().entries.map((entry) {
            final index = entry.key;
            final event = entry.value;
            
            return AnimatedBuilder(
              animation: _timelineAnimationController,
              builder: (context, child) {
                final delay = (index * 0.2).clamp(0.0, 0.8);
                final progress = (_timelineAnimationController.value - delay).clamp(0.0, 1.0);
                final normalizedProgress = delay < 1.0 ? progress / (1.0 - delay) : progress;
                final animationValue = Curves.easeOutBack.transform(normalizedProgress.clamp(0.0, 1.0)).clamp(0.0, 1.0);
                
                return Transform.translate(
                  offset: Offset((1 - animationValue) * 100, 0),
                  child: Opacity(
                    opacity: animationValue,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTimelineIndex = index;
                        });
                        HapticFeedback.lightImpact();
                      },
                      child: _buildInteractiveTimelineEvent(
                        event,
                        index,
                        index == _selectedTimelineIndex,
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildInteractiveTimelineEvent(Map<String, dynamic> event, int index, bool isSelected) {
    final color = event['color'] as Color;
    final icon = event['icon'] as IconData;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          // Timeline line connector
          SizedBox(
            width: 40,
            child: Column(
              children: [
                if (index > 0) 
                  Container(
                    width: 2,
                    height: 20,
                    color: Colors.grey[300],
                  ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: isSelected ? 16 : 12,
                  height: isSelected ? 16 : 12,
                  decoration: BoxDecoration(
                    color: isSelected ? color : Colors.grey[300],
                    shape: BoxShape.circle,
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ] : null,
                  ),
                  child: isSelected 
                      ? Icon(icon, size: 8, color: Colors.white)
                      : null,
                ),
                if (index < 3) // Not last item
                  Container(
                    width: 2,
                    height: 20,
                    color: Colors.grey[300],
                  ),
              ],
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Event content
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? color.withValues(alpha: 0.1) : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? color : Colors.grey[200]!,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          event['year'],
                          style: GoogleFonts.lato(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        icon,
                        size: 16,
                        color: color,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event['title'],
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: isSelected ? null : 40,
                    child: Text(
                      event['description'],
                      style: GoogleFonts.lato(
                        fontSize: 13,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                      overflow: isSelected ? TextOverflow.visible : TextOverflow.ellipsis,
                      maxLines: isSelected ? null : 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGallerySection() {
    final galleryImages = <String>[];
    
    final sampleImages = [
      if (_missionary!.image?.isNotEmpty ?? false) _missionary!.image!,
      ...galleryImages,
      if (galleryImages.isEmpty) ...[  // Fallback images only if no gallery
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300',
        'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=300', 
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=300',
        'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=300',
      ],
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Photo Gallery',
                style: GoogleFonts.lato(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF667eea).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: const Color(0xFF667eea).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  '${sampleImages.length} Photos',
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF667eea),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Enhanced Gallery with zoom
          SizedBox(
            height: 160,
            child: PageView.builder(
              controller: _galleryController,
              itemCount: sampleImages.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: GestureDetector(
                    onTap: () => _showImageZoom(sampleImages.cast<String>(), index),
                    child: Hero(
                      tag: 'gallery_image_$index',
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: CachedNetworkImage(
                            imageUrl: sampleImages[index],
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[200],
                              child: Icon(
                                Icons.image,
                                size: 40,
                                color: Colors.grey[400],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Gallery indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              sampleImages.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFF667eea).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showImageZoom(List<String> images, int initialIndex) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: PageController(initialPage: initialIndex),
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        return Center(
                          child: Hero(
                            tag: 'gallery_image_$index',
                            child: InteractiveViewer(
                              panEnabled: true,
                              scaleEnabled: true,
                              minScale: 1.0,
                              maxScale: 4.0,
                              child: CachedNetworkImage(
                                imageUrl: images[index],
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReferencesSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'References',
            style: GoogleFonts.lato(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '• Historical Archives of Christian Missions\n'
            '• Biographical Records of Missionaries in India\n'
            '• Church Historical Society Documentation\n'
            '• Local Historical Records',
            style: GoogleFonts.lato(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  void _shareMissionary() {
    final missionaryInfo = '''
🙏 *${_missionary!.name}* - A Hero of Faith

📍 Served in: ${_missionary!.locations.isNotEmpty ? _missionary!.locations.first.name : 'Unknown'}
⛪ Ministry: ${_missionary!.categories.isNotEmpty ? _missionary!.categories.first : 'Missionary Work'}
📅 Era: ${_missionary!.dates.display}

${_missionary!.biography.isNotEmpty ? 
  '📖 ${_getBiographyText(_missionary!.biography).length > 150 ? 
    '${_getBiographyText(_missionary!.biography).substring(0, 150)}...' : 
    _getBiographyText(_missionary!.biography)}' : 
  'A dedicated servant of God who made a lasting impact through their missionary work.'}

🔥 Discover more Heroes of Faith in our app!
#HeroesOfFaith #Missionary #Faith #Christian #Inspiration
    '''.trim();

    HapticFeedback.mediumImpact();
    
    Share.share(
      missionaryInfo,
      subject: '${_missionary!.name} - Hero of Faith',
    );
  }



  void _toggleAudioNarration() {
    if (!mounted) return;
    
    setState(() {
      _isAudioPlaying = !_isAudioPlaying;
    });

    HapticFeedback.mediumImpact();

    if (_isAudioPlaying) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Playing audio biography...',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF667eea),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'STOP',
              textColor: Colors.white,
              onPressed: () {
                if (mounted) {
                  setState(() {
                    _isAudioPlaying = false;
                  });
                }
              },
            ),
          ),
        );
      }

      // Simulate audio playback - in real app, integrate with TTS or audio player
      Future.delayed(const Duration(seconds: 10), () {
        if (mounted && _isAudioPlaying) {
          setState(() {
            _isAudioPlaying = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Audio narration completed'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Audio narration stopped'),
            backgroundColor: Colors.grey,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }


  String _getBiographyText(List<BiographySection> biography) {
    if (biography.isEmpty) return '';
    return biography.map((section) => section.content).join('\n\n');
  }
}
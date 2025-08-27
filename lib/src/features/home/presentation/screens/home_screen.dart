import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:herosoffaith/src/core/routes/route_names.dart';
import 'package:herosoffaith/src/features/common/presentation/widgets/animated_avatar.dart';
import 'package:herosoffaith/src/core/utils/direct_uploader.dart';
import 'package:herosoffaith/src/core/utils/file_uploader.dart';
import 'package:herosoffaith/src/core/utils/image_url_validator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;


  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      // Already on Home - no action needed
      return;
    }
    
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
          child: Column(
            children: [
              // Header Section
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Top bar with greeting and profile
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_getGreeting()},',
                              style: GoogleFonts.lato(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.6),
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            Text(
                              userName,
                              style: GoogleFonts.lato(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            AnimatedAvatar(
                              user: user,
                              userName: userName,
                              radius: 22,
                              backgroundColor: Colors.white.withValues(alpha: 0.2),
                              textStyle: GoogleFonts.lato(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                  ],
                ),
              ),
              
              // Main content area with white background
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
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        
                        // Features text
                        Text(
                          'Discover Missionaries',
                          style: GoogleFonts.lato(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.grey[900],
                            letterSpacing: 0.5,
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Services grid
                        Expanded(
                          child: GridView.count(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 1.0,
                            children: [
                              _buildServiceCard(
                                'Missionary\nDirectory',
                                FontAwesomeIcons.users,
                                const Color(0xFF667eea),
                                () => Navigator.pushNamed(context, RouteNames.missionaryDirectory),
                              ),
                              _buildServiceCard(
                                'Biographies',
                                FontAwesomeIcons.book,
                                const Color(0xFF764ba2),
                                () => _showComingSoon(context, 'Biographies'),
                              ),
                              _buildServiceCard(
                                'Timeline\nEvents',
                                FontAwesomeIcons.clock,
                                const Color(0xFFf093fb),
                                () => _showComingSoon(context, 'Timeline Events'),
                              ),
                              _buildServiceCard(
                                'Favorites',
                                FontAwesomeIcons.heart,
                                const Color(0xFFf5576c),
                                () => _showComingSoon(context, 'Favorites'),
                              ),
                              _buildServiceCard(
                                'Donations',
                                FontAwesomeIcons.handHoldingHeart,
                                const Color(0xFF43A047),
                                () => _showComingSoon(context, 'Donations'),
                              ),
                              _buildServiceCard(
                                'Contribute',
                                FontAwesomeIcons.camera,
                                const Color(0xFFFF7043),
                                () => _showComingSoon(context, 'Contribute'),
                              ),
                              _buildServiceCard(
                                'Admin\nUpload',
                                FontAwesomeIcons.upload,
                                const Color(0xFF9C27B0),
                                () => _showComprehensiveUploadOptions(context),
                              ),
                              _buildServiceCard(
                                'API Test',
                                FontAwesomeIcons.flask,
                                const Color(0xFF00BCD4),
                                () => Navigator.pushNamed(context, '/api-test'),
                              ),
                            ],
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

  Widget _buildServiceCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: FaIcon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon!'),
        backgroundColor: const Color(0xFF667eea),
      ),
    );
  }

  void _showComprehensiveUploadOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(FontAwesomeIcons.upload, color: const Color(0xFF9C27B0), size: 20),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Admin Upload Center',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Comprehensive missionary data management:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text('📂 Upload from JSON files'),
            Text('🔍 Validate image URLs'),
            Text('✅ Check data format'),
            Text('🚀 Batch upload to Firestore'),
            SizedBox(height: 12),
            Text(
              'Built-in data includes 28 missionaries:\nWilliam Carey, Mother Teresa, Amy Carmichael,\nHudson Taylor, David Livingstone, and 23 more.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        DirectUploader.showTestUpload(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Test Upload'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        FileUploader.showFileUpload(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Upload File'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        ImageUrlValidator.showValidation(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Check Images'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    DirectUploader.showDirectUpload(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9C27B0),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Upload All Built-in Data'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

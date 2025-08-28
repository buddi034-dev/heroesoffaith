/// Fallback image URLs for missionaries when Wikipedia URLs return 404
/// These are working Wikipedia Commons URLs as of current date
class FallbackImages {
  static const Map<String, String> missionaryImages = {
    // William Carey - Father of Modern Missions
    'william-carey': 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3c/William_Carey.jpg/250px-William_Carey.jpg',
    
    // Hudson Taylor - China Inland Mission founder  
    'hudson-taylor': 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d1/HudsonTaylorin1893.jpg/250px-HudsonTaylorin1893.jpg',
    
    // Amy Carmichael - India missionary
    'amy-carmichael': 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cb/Amy_Carmichael_with_children2.jpg/250px-Amy_Carmichael_with_children2.jpg',
    
    // Dr. Ida Scudder - Medical missionary and educator
    'ida-scudder': 'https://upload.wikimedia.org/wikipedia/commons/6/6d/Ida_S._Scudder_1899.jpg',
    
    // Alexander Duff - Educational missionary
    'alexander-duff': 'https://upload.wikimedia.org/wikipedia/en/4/44/Alexduff.jpeg',
    
    // Pandita Ramabai - Social reformer and women's rights pioneer
    'pandita-ramabai': 'https://upload.wikimedia.org/wikipedia/commons/a/a1/Pandita_Ramabai_Sarasvati_1858-1922_front-page-portrait.jpg',
  };
  
  /// Get fallback image URL for a missionary by ID
  static String? getFallbackImageUrl(String missionaryId) {
    return missionaryImages[missionaryId.toLowerCase()];
  }
  
  /// Check if we have a fallback image for this missionary
  static bool hasFallbackImage(String missionaryId) {
    return missionaryImages.containsKey(missionaryId.toLowerCase());
  }
  
  /// Get all available missionary IDs with fallback images
  static List<String> getAvailableMissionaryIds() {
    return missionaryImages.keys.toList();
  }
}
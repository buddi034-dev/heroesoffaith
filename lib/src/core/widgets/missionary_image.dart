import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/fallback_images.dart';

/// Custom widget for displaying missionary images with fallback support
/// Tries the primary image URL first, then falls back to working Wikipedia URLs
class MissionaryImage extends StatelessWidget {
  final String? primaryImageUrl;
  final String missionaryId;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget Function(BuildContext, String)? placeholder;
  final Widget Function(BuildContext, String, dynamic)? errorWidget;
  final BorderRadius? borderRadius;

  const MissionaryImage({
    super.key,
    required this.primaryImageUrl,
    required this.missionaryId,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    // Build the widget with image URL priority:
    // 1. Primary URL from API
    // 2. Fallback URL from our constants
    // 3. Default gradient placeholder

    String? imageUrl = primaryImageUrl;
    
    // If primary URL is null or empty, use fallback
    if (imageUrl == null || imageUrl.isEmpty) {
      imageUrl = FallbackImages.getFallbackImageUrl(missionaryId);
    }

    Widget imageWidget;

    if (imageUrl != null && imageUrl.isNotEmpty) {
      imageWidget = CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: placeholder ?? (context, url) => _buildLoadingWidget(),
        errorWidget: (context, url, error) {
          // If the primary URL failed, try the fallback URL
          final fallbackUrl = FallbackImages.getFallbackImageUrl(missionaryId);
          if (fallbackUrl != null && url != fallbackUrl) {
            return CachedNetworkImage(
              imageUrl: fallbackUrl,
              width: width,
              height: height,
              fit: fit,
              placeholder: (context, url) => _buildLoadingWidget(),
              errorWidget: (context, url, error) => errorWidget?.call(context, url, error) ?? _buildErrorWidget(),
            );
          }
          return errorWidget?.call(context, url, error) ?? _buildErrorWidget();
        },
      );
    } else {
      imageWidget = _buildErrorWidget();
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildLoadingWidget() {
    return Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.person,
          size: 32,
          color: Colors.white,
        ),
      ),
    );
  }
}
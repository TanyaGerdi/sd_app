import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sd_institute/services/api_service.dart';

/// Normalizes an image URL so it always points to the reachable API host.
/// The dashboard stores URLs with "localhost:8000" which is unreachable
/// from Android emulators (which use 10.0.2.2) and from real devices
/// (which use the server's LAN IP). This function rewrites the host
/// portion of the URL to match [ApiService.baseUrl].
String _normalizeImageUrl(String url) {
  String cleanUrl = url.trim();
  if (cleanUrl.isEmpty) return '';

  // If the path contains the dashboard proxy prefix, strip it
  if (cleanUrl.contains('/api/laravel-proxy/')) {
    cleanUrl = cleanUrl.replaceAll('/api/laravel-proxy/', '/');
  } else if (cleanUrl.startsWith('api/laravel-proxy/')) {
    cleanUrl = cleanUrl.replaceFirst('api/laravel-proxy/', '');
  }

  // Extract the API host (e.g. "http://10.0.2.2:8000")
  final apiHost = ApiService.baseUrl.replaceAll('/api', '');

  // If it's a relative path, prepend the API host
  if (!cleanUrl.startsWith('http://') && !cleanUrl.startsWith('https://')) {
    if (cleanUrl.startsWith('/')) {
      return '$apiHost$cleanUrl';
    }
    return '$apiHost/$cleanUrl';
  }

  // Replace any localhost/127.0.0.1 references with the actual host
  // This fixes images stored by the dashboard using localhost:8000
  try {
    final imageUri = Uri.parse(cleanUrl);
    final apiUri = Uri.parse(apiHost);

    // If the image URL points to localhost or 127.0.0.1, rewrite to API host
    if (imageUri.host == 'localhost' ||
        imageUri.host == '127.0.0.1' ||
        imageUri.host == '10.0.2.2') {
      cleanUrl = cleanUrl.replaceFirst(
        '${imageUri.scheme}://${imageUri.host}:${imageUri.port}',
        '${apiUri.scheme}://${apiUri.host}:${apiUri.port}',
      );
    }
  } catch (_) {}

  return cleanUrl;
}

/// Reusable cached network image widget.
/// Images are automatically stored on disk for offline use.
class CachedImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;

  const CachedImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return errorWidget ?? _defaultError();
    }

    final cleanUrl = _normalizeImageUrl(imageUrl);
    if (cleanUrl.isEmpty) return errorWidget ?? _defaultError();

    try {
      final uri = Uri.parse(cleanUrl);
      if (!uri.hasScheme || uri.host.isEmpty) {
        return errorWidget ?? _defaultError();
      }
    } catch (_) {
      return errorWidget ?? _defaultError();
    }

    return CachedNetworkImage(
      imageUrl: cleanUrl,
      fit: fit,
      width: width,
      height: height,
      placeholder: (context, url) =>
          placeholder ?? _defaultPlaceholder(),
      errorWidget: (context, url, error) =>
          errorWidget ?? _defaultError(),
    );
  }

  Widget _defaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.withValues(alpha: 0.1),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }

  Widget _defaultError() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.withValues(alpha: 0.1),
      child: const Icon(Icons.image_not_supported_rounded, color: Colors.grey),
    );
  }
}

/// Use this as a drop-in replacement for NetworkImage in DecorationImage.
/// It caches the image to disk for offline availability.
ImageProvider<Object> cachedProvider(String? url) {
  if (url == null || url.trim().isEmpty) {
    return const AssetImage('assets/img/sd_logo.png');
  }

  final cleanUrl = _normalizeImageUrl(url);
  if (cleanUrl.isEmpty) return const AssetImage('assets/img/sd_logo.png');

  try {
    final uri = Uri.parse(cleanUrl);
    if (!uri.hasScheme || uri.host.isEmpty) {
      return const AssetImage('assets/img/sd_logo.png');
    }
  } catch (_) {
    return const AssetImage('assets/img/sd_logo.png');
  }

  return CachedNetworkImageProvider(cleanUrl);
}

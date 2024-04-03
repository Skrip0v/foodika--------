import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';

class CachedImageWidget extends StatelessWidget {
  const CachedImageWidget({
    super.key,
    required this.imageUrl,
    this.height,
    this.width,
    this.fit,
  });

  final String imageUrl;
  final double? height;
  final double? width;
  final BoxFit? fit;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fadeInDuration: 300.milliseconds,
      filterQuality: FilterQuality.low,
      width: width,
      height: height,
      fit: fit,
      cacheManager: CacheManager(
        Config(
          'key_cache',
          stalePeriod: const Duration(days: 2),
        ),
      ),
    );
  }
}

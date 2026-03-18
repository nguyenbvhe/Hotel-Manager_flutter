import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CachedNetworkImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget Function(BuildContext, String)? placeholder;
  final Widget Function(BuildContext, String, dynamic)? errorWidget;
  final Color? color;
  final BlendMode? colorBlendMode;

  const CachedNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
    this.color,
    this.colorBlendMode,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _buildError(context);
    }
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      color: color,
      colorBlendMode: colorBlendMode,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        if (placeholder != null) {
          return placeholder!(context, imageUrl);
        }
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(color: Colors.white, width: width, height: height),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return _buildError(context);
      },
    );
  }

  Widget _buildError(BuildContext context) {
    if (errorWidget != null) {
      return errorWidget!(context, imageUrl, 'error');
    }
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Icon(Icons.error_outline, color: Colors.grey),
    );
  }
}

typedef CachedNetworkImageProvider = NetworkImage;

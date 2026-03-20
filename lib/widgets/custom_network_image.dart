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

    // Try to map remote URL to local asset if possible
    final String effectiveUrl = _mapUrlToAsset(imageUrl);
    final bool isAsset = !effectiveUrl.startsWith('http') && !effectiveUrl.startsWith('https');

    if (isAsset) {
      return Image.asset(
        effectiveUrl,
        width: width,
        height: height,
        fit: fit,
        color: color,
        colorBlendMode: colorBlendMode,
        errorBuilder: (context, error, stackTrace) {
          return _buildError(context);
        },
      );
    }

    return Image.network(
      effectiveUrl,
      width: width,
      height: height,
      fit: fit,
      color: color,
      colorBlendMode: colorBlendMode,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        if (placeholder != null) {
          return placeholder!(context, effectiveUrl);
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

  String _mapUrlToAsset(String url) {
    if (url.startsWith('assets/')) return url;

    debugPrint('DEBUG: Mapping URL: $url');

    // Mapping Unsplash IDs to local files
    final Map<String, String> mapping = {
      '1542314831-068cd1dbfeeb': 'assets/images/lobby.jpg',
      '1571896349842-33c89424de2d': 'assets/images/location.jpg',
      '1631049307264-da0ec9d70304': 'assets/images/room_101.jpg',
      '1560448204-e02f11c3d0e2': 'assets/images/room_102.jpg',
      '1618773928121-c32242e63f39': 'assets/images/room_103.jpg',
      '1598928506311-c55ded91a20c': 'assets/images/room_104.jpg',
      '1590490360182-c33d57733427': 'assets/images/room_201.jpg',
      '1584132967334-10e028bd69f7': 'assets/images/room_202.jpg',
      '1582719478250-c89cae4dc85b': 'assets/images/room_301.jpg',
      '1591088398332-8a7791972843': 'assets/images/room_302.jpg',
      '1555244162-803834f70033': 'assets/images/service_buffet.jpg',
      '1544148103-0773bf10d330': 'assets/images/service_tea.jpg',
      '1533473359331-0135ef1b58bf': 'assets/images/service_limousine.jpg',
      '1554284126-aa88f22d8b74': 'assets/images/service_gym.jpg',
      '1583417319070-4a69db38a482': 'assets/images/service_tour.jpg',
      '1554995207-c18c203602cb': 'assets/images/room_std_1.jpg',
      '1596394516093-501ba68a0ba6': 'assets/images/room_std_2.jpg',
      '1563911302283-d2bc129e7570': 'assets/images/room_std_3.jpg',
      '1618221118493-9cfa1a1c00da': 'assets/images/room_dlx_3.jpg',
      '1501117716987-19794d2ba74a': 'assets/images/room_vip_2.jpg',
      '1610641818989-c2051b5e2cfd': 'assets/images/room_vip_3.jpg',
      '1510798831971-661eb04b3739': 'assets/images/room_vip_4.jpg',
    };

    // Check Unsplash IDs
    for (var entry in mapping.entries) {
      if (url.contains(entry.key)) {
        return entry.value;
      }
    }

    // Direct mapping for non-Unsplash known URLs
    if (url.contains('vinpearlresortvietnam.com')) return 'assets/images/service_spa.jpg';
    if (url.contains('lasinfoniavietnam.com')) return 'assets/images/service_finedining.jpg';
    if (url.contains('vcdn1-vnexpress.vnecdn.net')) return 'assets/images/service_pool.jpg';
    if (url.contains('cdn.nhatrangbooking.com.vn')) return 'assets/images/service_airport.jpg';
    if (url.contains('miamihotel.vn')) return 'assets/images/service_decor.jpg';

    return url;
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

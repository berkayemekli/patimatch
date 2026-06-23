import 'package:flutter/material.dart';

class SmartPetImage extends StatelessWidget {
  const SmartPetImage({
    super.key,
    required this.source,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.errorBuilder,
  });

  final String source;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  @override
  Widget build(BuildContext context) {
    if (source.startsWith('asset:')) {
      return Image.asset(
        source.substring('asset:'.length),
        fit: fit,
        width: width,
        height: height,
      );
    }
    return Image.network(
      source,
      fit: fit,
      width: width,
      height: height,
      errorBuilder:
          errorBuilder ??
          (context, error, stackTrace) => const ColoredBox(
            color: Color(0xFFE2E8F0),
            child: Center(child: Icon(Icons.pets_rounded)),
          ),
    );
  }
}

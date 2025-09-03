import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ResponsiveHelper {
  // Detectar si es una plataforma de escritorio
  static bool get isDesktop {
    return defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux;
  }

  // Detectar si es web
  static bool get isWeb {
    return kIsWeb;
  }

  // Detectar si es móvil
  static bool get isMobile {
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  // Detectar si es web o escritorio (para layouts más amplios)
  static bool get isWideScreen {
    return isWeb || isDesktop;
  }

  // Obtener el número de columnas según el ancho de pantalla
  static int getGridColumns(double screenWidth) {
    if (screenWidth > 1200) return 4; // Pantallas muy grandes
    if (screenWidth > 800) return 3; // Tablets y pantallas medianas
    if (screenWidth > 600) return 2; // Tablets pequeñas
    return 2; // Móviles
  }

  // Obtener el ancho máximo del contenido
  static double getMaxContentWidth(double screenWidth) {
    if (screenWidth > 1400) return 1200;
    if (screenWidth > 1000) return 900;
    if (screenWidth > 600) return 600;
    return screenWidth;
  }

  // Obtener padding responsivo
  static EdgeInsets getResponsivePadding(double screenWidth) {
    if (screenWidth > 1200) return const EdgeInsets.all(32);
    if (screenWidth > 800) return const EdgeInsets.all(24);
    return const EdgeInsets.all(16);
  }

  // Obtener aspect ratio responsivo para tarjetas
  static double getCardAspectRatio(double screenWidth) {
    if (screenWidth > 1000) return 1.1; // Más cuadradas en pantallas grandes
    if (screenWidth > 600) return 0.9;
    return 0.75; // Más altas en móviles
  }
}

// Widget para crear layouts responsivos
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, BoxConstraints constraints)
  builder;

  const ResponsiveBuilder({Key? key, required this.builder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return builder(context, constraints);
      },
    );
  }
}

// Widget para centrar contenido en pantallas grandes
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;

  const ResponsiveContainer({Key? key, required this.child, this.maxWidth})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final contentWidth =
            maxWidth ?? ResponsiveHelper.getMaxContentWidth(screenWidth);

        if (ResponsiveHelper.isWideScreen && screenWidth > contentWidth) {
          return Center(child: Container(width: contentWidth, child: child));
        }

        return child;
      },
    );
  }
}

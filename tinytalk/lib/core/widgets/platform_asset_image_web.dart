// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'dart:ui_web' as ui_web;
import 'package:flutter/widgets.dart';

final _registeredViewTypes = <String>{};

Widget buildPlatformAssetImage({
  required String path,
  required double width,
  required double height,
  required BoxFit fit,
  required Widget fallback,
}) {
  final viewType = 'asset-image-$path-$width-$height';

  if (_registeredViewTypes.add(viewType)) {
    ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      return html.ImageElement()
        ..src = 'assets/$path'
        ..style.width = '${width}px'
        ..style.height = '${height}px'
        ..style.objectFit = _objectFit(fit)
        ..style.display = 'block'
        ..style.pointerEvents = 'none';
    });
  }

  return IgnorePointer(
    child: SizedBox(
      width: width,
      height: height,
      child: HtmlElementView(
        key: ValueKey(viewType),
        viewType: viewType,
      ),
    ),
  );
}

String _objectFit(BoxFit fit) {
  return switch (fit) {
    BoxFit.cover => 'cover',
    BoxFit.fill => 'fill',
    BoxFit.fitHeight => 'contain',
    BoxFit.fitWidth => 'contain',
    BoxFit.none => 'none',
    BoxFit.scaleDown => 'scale-down',
    BoxFit.contain => 'contain',
  };
}

import 'package:flutter/material.dart';

import '../config/styling.dart';

class DialogWrapper extends Dialog {
  final Widget _child;

  const DialogWrapper({required Widget child, super.key}) : _child = child;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxContentWidth),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              defaultPadding, 60, defaultPadding, defaultPadding),
          child: Card(
            color:
                Theme.of(context).cardColor.withOpacity(defaultOverlayOpacity),
            elevation: defaultMenuElevation,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(preferredBorderRadius),
            ),
            child: Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: _child,
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';

import '../config/theme.dart';

enum AppToastType { success, error, info }

class AppToast {
  AppToast._();

  static OverlayEntry? _currentEntry;
  static Timer? _dismissTimer;
  static const double _horizontalMargin = 24;
  static const double _toastBottomGap = 20;
  static const double _keyboardClearance = 16;
  static const double _navigationClearance = 88;

  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(context, message, type: AppToastType.success, duration: duration);
  }

  static void showError(
    BuildContext context,
    String message, {
    int? statusCode,
    String? fallbackMessage,
    bool normalizeUnauthorized = true,
    Duration duration = const Duration(seconds: 4),
  }) {
    _show(
      context,
      _normalizeErrorMessage(
        message,
        statusCode: statusCode,
        fallbackMessage: fallbackMessage,
        normalizeUnauthorized: normalizeUnauthorized,
      ),
      type: AppToastType.error,
      duration: duration,
    );
  }

  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(context, message, type: AppToastType.info, duration: duration);
  }

  static void dismiss() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _currentEntry?.remove();
    _currentEntry = null;
  }

  static void _show(
    BuildContext context,
    String message, {
    required AppToastType type,
    required Duration duration,
  }) {
    final normalizedMessage = message.trim();
    if (normalizedMessage.isEmpty) {
      return;
    }

    final overlay = Overlay.of(context, rootOverlay: true);

    dismiss();

    final entry = OverlayEntry(
      builder: (context) {
        final mediaQuery = MediaQuery.of(context);
        final viewInsetsBottom = mediaQuery.viewInsets.bottom;
        final safeBottom = mediaQuery.padding.bottom;
        final bottomOffset = viewInsetsBottom > 0
            ? viewInsetsBottom + _keyboardClearance
            : safeBottom + _navigationClearance;

        return IgnorePointer(
          ignoring: false,
          child: SafeArea(
            child: Stack(
              children: [
                Positioned(
                  left: _horizontalMargin,
                  right: _horizontalMargin,
                  bottom: bottomOffset + _toastBottomGap,
                  child: _ToastCard(
                    message: normalizedMessage,
                    type: type,
                    onDismiss: dismiss,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    _currentEntry = entry;
    overlay.insert(entry);

    _dismissTimer = Timer(duration, dismiss);
  }

  static String _normalizeErrorMessage(
    String message, {
    int? statusCode,
    String? fallbackMessage,
    bool normalizeUnauthorized = true,
  }) {
    final normalizedMessage = message.trim();
    final normalizedFallback = (fallbackMessage ?? 'Something went wrong. Please try again.').trim();
    final lowercaseMessage = normalizedMessage.toLowerCase();

    if (statusCode == 408) {
      return 'The request timed out. Please check your connection and try again.';
    }

    if (statusCode == 503) {
      return 'We could not reach the server. Please check your connection and try again.';
    }

    if (normalizeUnauthorized && (statusCode == 401 || statusCode == 403)) {
      return 'Your session is no longer valid. Please sign in again.';
    }

    if (statusCode != null && statusCode >= 500) {
      return 'Something went wrong on our server. Please try again shortly.';
    }

    if (normalizedMessage.isEmpty) {
      return normalizedFallback;
    }

    if (lowercaseMessage.contains('internal server error') ||
        lowercaseMessage.contains('server error') ||
        lowercaseMessage.contains('unexpected error')) {
      return 'Something went wrong on our server. Please try again shortly.';
    }

    if (lowercaseMessage.contains('socketexception') ||
        lowercaseMessage.contains('network error')) {
      return 'We could not reach the server. Please check your connection and try again.';
    }

    return normalizedMessage;
  }
}

class _ToastCard extends StatefulWidget {
  const _ToastCard({
    required this.message,
    required this.type,
    required this.onDismiss,
  });

  final String message;
  final AppToastType type;
  final VoidCallback onDismiss;

  @override
  State<_ToastCard> createState() => _ToastCardState();
}

class _ToastCardState extends State<_ToastCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.14),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tone = switch (widget.type) {
      AppToastType.success => const _ToastTone(
        background: BabyCareTheme.universalWhite,
        foreground: BabyCareTheme.primaryBerry,
        border: BabyCareTheme.lightPink,
        accent: BabyCareTheme.primaryBerry,
        iconBackground: BabyCareTheme.lightPink,
        accentGlow: BabyCareTheme.lightPink,
        icon: Icons.check_circle_rounded,
      ),
      AppToastType.error => const _ToastTone(
        background: Color(0xFFFFF7F8),
        foreground: BabyCareTheme.darkGrey,
        border: BabyCareTheme.lightRed,
        accent: Color(0xFFD96A7C),
        iconBackground: BabyCareTheme.lightRed,
        accentGlow: Color(0xFFF7C6D0),
        icon: Icons.error_rounded,
      ),
      AppToastType.info => const _ToastTone(
        background: BabyCareTheme.lightGrey,
        foreground: BabyCareTheme.darkGrey,
        border: BabyCareTheme.lightPink,
        accent: BabyCareTheme.primaryBerry,
        iconBackground: BabyCareTheme.universalWhite,
        accentGlow: BabyCareTheme.lightPurple,
        icon: Icons.info_rounded,
      ),
    };

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: widget.onDismiss,
            behavior: HitTestBehavior.opaque,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: tone.background,
                borderRadius: BorderRadius.circular(BabyCareTheme.radiusMedium),
                border: Border.all(color: tone.border, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: BabyCareTheme.darkGrey.withValues(alpha: 0.14),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                  BoxShadow(
                    color: tone.accentGlow.withValues(alpha: 0.18),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(BabyCareTheme.radiusMedium),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 7,
                      constraints: const BoxConstraints(minHeight: 76),
                      color: tone.accent,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: tone.iconBackground,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                tone.icon,
                                color: tone.accent,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.message,
                                textAlign: TextAlign.left,
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  color: tone.foreground,
                                  fontWeight: FontWeight.w600,
                                  height: 1.35,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.close_rounded,
                              color: tone.accent.withValues(alpha: 0.7),
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ToastTone {
  const _ToastTone({
    required this.background,
    required this.foreground,
    required this.border,
    required this.accent,
    required this.accentGlow,
    required this.iconBackground,
    required this.icon,
  });

  final Color background;
  final Color foreground;
  final Color border;
  final Color accent;
  final Color accentGlow;
  final Color iconBackground;
  final IconData icon;
}
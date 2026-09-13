import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_theme.dart';

/// A friendly "nothing here yet" placeholder used across list-style screens
/// (bookings, trips, wallet, etc). Shows a bundled SVG illustration above a
/// title and an optional subtitle/action, so empty lists never just show a
/// blank screen or a lone line of grey text.
class EmptyState extends StatelessWidget {
  final String illustrationAsset;
  final String title;
  final String? subtitle;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.illustrationAsset,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              illustrationAsset,
              height: 160,
              placeholderBuilder: (context) => const SizedBox(
                height: 160,
                child: Icon(Icons.inbox_outlined, size: 64, color: AppColors.textGrey),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textGrey, fontSize: 13),
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 20),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

/// Distinct from personal notes: slate, labeled, never themed like a sticky.
class SponsoredCard extends StatelessWidget {
  const SponsoredCard({super.key, this.compact = false, this.onTap});

  final bool compact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Sponsored advertisement',
      button: true,
      child: Material(
        color: AppColors.adSlate,
        borderRadius: BorderRadius.circular(compact ? 22 : 26),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(compact ? 22 : 26),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, compact ? 12 : 16, 16, compact ? 12 : 16),
            child: compact ? _compact() : _full(),
          ),
        ),
      ),
    );
  }

  Widget _full() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _AdBadge(),
        const SizedBox(height: 14),
        Text(
          'A partner could live here',
          style: GoogleFonts.fraunces(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Advertisement · clearly labeled, never a fake note.',
          style: GoogleFonts.figtree(
            fontSize: 13,
            height: 1.35,
            color: Colors.white.withValues(alpha: 0.72),
          ),
        ),
        const Spacer(),
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.adMint,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Sponsored placement',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.figtree(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.adMint,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _compact() {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.adMint,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const _AdBadge(),
              const SizedBox(height: 4),
              Text(
                'Advertisement',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.figtree(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Icon(Icons.north_east_rounded, color: Colors.white.withValues(alpha: 0.5), size: 18),
      ],
    );
  }
}

class _AdBadge extends StatelessWidget {
  const _AdBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'SPONSORED',
        style: GoogleFonts.figtree(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.4,
          color: AppColors.adMint,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';

class CustomFooter extends StatelessWidget {
  const CustomFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo
          Image.asset(
            'assets/images/logo.png',
            width: 60,
            height: 60,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.track_changes, size: 60, color: Colors.white);
            },
          ),
          const SizedBox(height: 16),
          
          // Company Name
          Text(
            'Habitly',
            style: GoogleFonts.urbanist(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 8),
          
          // Address
          Text(
            'Jl. Kebiasaan Baik No. 123\nJakarta Selatan, Indonesia',
            textAlign: TextAlign.center,
            style: GoogleFonts.urbanist(
              fontSize: 14,
              color: AppColors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 8),
          
          // Phone
          Text(
            '📞 +62 812-3456-7890',
            style: GoogleFonts.urbanist(
              fontSize: 14,
              color: AppColors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 16),
          
          // Divider
          Divider(color: AppColors.white.withOpacity(0.3), thickness: 1),
          const SizedBox(height: 12),
          
          // Company & Community
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text(
                    'Perusahaan',
                    style: GoogleFonts.urbanist(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Habitly Inc.',
                    style: GoogleFonts.urbanist(
                      fontSize: 11,
                      color: AppColors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
              Container(
                height: 30,
                width: 1,
                color: AppColors.white.withOpacity(0.3),
              ),
              Column(
                children: [
                  Text(
                    'Komunitas',
                    style: GoogleFonts.urbanist(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Habitly Community',
                    style: GoogleFonts.urbanist(
                      fontSize: 11,
                      color: AppColors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Owner/Creator
          Text(
            'Created by: [Your Name]',
            style: GoogleFonts.urbanist(
              fontSize: 12,
              color: AppColors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          
          // Copyright
          Text(
            '© 2026 Habitly. All rights reserved.',
            style: GoogleFonts.urbanist(
              fontSize: 10,
              color: AppColors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
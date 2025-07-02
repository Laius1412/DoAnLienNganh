import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  Widget _section(String title, String content, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null)
                Icon(icon, size: 22, color: Colors.deepOrange),
              if (icon != null) const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 15.5, height: 1.6),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.aboutTitle),
        backgroundColor: const Color(0xFFF36C21), // Màu cam FLASH TRAVEL
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.aboutHeadline,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.aboutIntro,
              style: const TextStyle(fontSize: 15.5, height: 1.6),
            ),
            const SizedBox(height: 24),

            _section(
              AppLocalizations.of(context)!.aboutServiceTitle,
              AppLocalizations.of(context)!.aboutServiceContent,
              icon: Icons.directions_bus,
            ),

            _section(
              AppLocalizations.of(context)!.aboutFeatureTitle,
              AppLocalizations.of(context)!.aboutFeatureContent,
              icon: Icons.smartphone,
            ),

            _section(
              AppLocalizations.of(context)!.aboutReasonTitle,
              AppLocalizations.of(context)!.aboutReasonContent,
              icon: Icons.star,
            ),

            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/app_icon/icon_App.png',
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                AppLocalizations.of(context)!.aboutCompany,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onBackground,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 18),

            _section(
              AppLocalizations.of(context)!.aboutCompanyInfoTitle,
              AppLocalizations.of(context)!.aboutCompanyInfoContent,
              icon: Icons.business,
            ),
            _section(
              AppLocalizations.of(context)!.aboutMissionTitle,
              AppLocalizations.of(context)!.aboutMissionContent,
              icon: Icons.flag,
            ),

            _section(
              AppLocalizations.of(context)!.aboutCoreValueTitle,
              AppLocalizations.of(context)!.aboutCoreValueContent,
              icon: Icons.verified,
            ),

            _section(
              AppLocalizations.of(context)!.aboutFollowTitle,
              AppLocalizations.of(context)!.aboutFollowContent,
              icon: Icons.public,
            ),

            // const SizedBox(height: 20),

            

            // Hình ảnh giới thiệu ở cuối bài viết
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/app_icon/hinh_anh_gioi_thieu_1.png',
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/datasources/tips_datasource.dart';
import '../../../data/models/tip_article.dart';
import '../../../shared/widgets/glass_card.dart';

class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              'Skincare Tips',
              style: Theme.of(context).textTheme.displayMedium,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Text(
              'Learn how to care for your skin better',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 20),
              itemCount: TipsDataSource.articles.length,
              itemBuilder: (context, index) {
                final article = TipsDataSource.articles[index];
                return _buildArticleCard(context, article, isDark);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard(
      BuildContext context, TipArticle article, bool isDark) {
    return GlassCard(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) =>
                TipDetailScreen(article: article),
            transitionsBuilder: (_, animation, __, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      },
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  AppColors.deepPurple.withValues(alpha: 0.3),
                  AppColors.dustyRose.withValues(alpha: 0.3),
                ],
              ),
            ),
            child: Center(
              child: Text(
                article.icon,
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  article.subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.coral.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    article.category,
                    style: const TextStyle(
                      color: AppColors.coral,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
          ),
        ],
      ),
    );
  }
}

class TipDetailScreen extends StatelessWidget {
  final TipArticle article;

  const TipDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    AppColors.deepPurple.withValues(alpha: 0.5),
                    AppColors.darkBackground,
                  ]
                : [
                    AppColors.softPeach.withValues(alpha: 0.3),
                    AppColors.lightBackground,
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: isDark
                            ? AppColors.textPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.coral.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        article.category,
                        style: const TextStyle(
                          color: AppColors.coral,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon & title
                      Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.deepPurple.withValues(alpha: 0.3),
                                AppColors.dustyRose.withValues(alpha: 0.3),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              article.icon,
                              style: const TextStyle(fontSize: 40),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        article.title,
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        article.subtitle,
                        style: TextStyle(
                          color: AppColors.coral,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Content
                      _buildFormattedContent(context, article.content, isDark),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormattedContent(
      BuildContext context, String content, bool isDark) {
    final paragraphs = content.split('\n\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: paragraphs.map((paragraph) {
        final trimmed = paragraph.trim();
        if (trimmed.startsWith('**') && trimmed.endsWith('**')) {
          // Header
          return Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Text(
              trimmed.replaceAll('**', ''),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.coral,
              ),
            ),
          );
        }
        // Regular paragraph or bullet points
        final lines = trimmed.split('\n');
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: lines.map((line) {
            final lineTrimmed = line.trim();
            if (lineTrimmed.startsWith('•')) {
              return Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '•  ',
                      style: TextStyle(
                        color: AppColors.coral,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        lineTrimmed.substring(1).trim(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            if (lineTrimmed.startsWith('**') && lineTrimmed.endsWith('**')) {
              return Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 6),
                child: Text(
                  lineTrimmed.replaceAll('**', ''),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.coral,
                  ),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                lineTrimmed,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}

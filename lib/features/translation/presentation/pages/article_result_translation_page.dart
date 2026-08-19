import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:harmonyos_flutter_empty/core/theme/app_colors.dart';
import 'package:harmonyos_flutter_empty/features/translation/domain/article_correction_result.dart';
import 'package:harmonyos_flutter_empty/features/translation/domain/english_result.dart';

/// 文章批改结果页
///
/// 对应原 Android `ArticleResultTranslationActivity`，保真还原 Compose UI：
/// 蓝色顶栏（返回 + "文章批改结果"）+ 综合评分卡片（背景 ic_text_bg）+
/// 四个得分项（词汇/语法/逻辑/内容）+ 点评 + 错误列表。
class ArticleResultTranslationPage extends StatelessWidget {
  const ArticleResultTranslationPage({super.key, this.result});

  /// 批改结果（null 时显示错误页）
  final EnglishResult? result;

  @override
  Widget build(BuildContext context) {
    if (result == null) {
      return _ErrorScreen();
    }
    final uiModel = ArticleCorrectionResult.fromEnglishResult(result!);
    return Scaffold(
      backgroundColor: const Color(0xFFEDF6FF),
      body: Column(
        children: [
          _buildAppBar(context),
          Expanded(
            child: _buildContent(uiModel),
          ),
        ],
      ),
    );
  }

  /// 顶部标题栏
  Widget _buildAppBar(BuildContext context) {
    return Container(
      color: AppColors.primaryBlue,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 50,
          child: Stack(
            children: [
              Positioned(
                left: 18,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () => context.pop(),
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
              const Center(
                child: Text(
                  '文章批改结果',
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 内容区
  Widget _buildContent(ArticleCorrectionResult result) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      children: [
        _ScoreCard(result: result),
        if (result.errorList.isEmpty)
          _NoErrorCard()
        else
          ...result.errorList.asMap().entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: _ErrorItemCard(
                    index: entry.key + 1,
                    errorItem: entry.value,
                  ),
                ),
              ),
        const SizedBox(height: 20),
      ],
    );
  }
}

/// 综合评分卡片
class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.result});

  final ArticleCorrectionResult result;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 4,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/ic_text_bg.png',
                  fit: BoxFit.fill,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // 综合评分
                    const Text(
                      '综合评分',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: AppColors.langSwitchText,
                      ),
                    ),
                    // 大分数 + "分"
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${result.overallScore.toInt()}',
                          style: const TextStyle(
                            fontSize: 75,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 20),
                          child: Text(
                            '分',
                            style: TextStyle(
                              fontSize: 20,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // 四个得分项
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _ScoreRow(
                                label: '词汇得分',
                                score: result.vocabularyScore,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _ScoreRow(
                                label: '语法得分',
                                score: result.grammarScore,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _ScoreRow(
                                label: '逻辑得分',
                                score: result.logicScore,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _ScoreRow(
                                label: '内容得分',
                                score: result.contentScore,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    // 点评
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '点评',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: AppColors.langSwitchText,
                            ),
                          ),
                          SizedBox(height: 6),
                          // 点评内容在下方 _buildComment
                        ],
                      ),
                    ),
                    // 点评内容
                    Text(
                      result.comment,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF4D4D4D),
                        height: 20 / 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 单个得分项（标签 + 分数 + 进度条）
class _ScoreRow extends StatelessWidget {
  const _ScoreRow({required this.label, required this.score});

  final String label;
  final double score;

  @override
  Widget build(BuildContext context) {
    final progress = (score / 100).clamp(0.0, 1.0);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.langSwitchText,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          score.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.primaryBlue,
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 2, top: 2),
          child: Text(
            '分',
            style: TextStyle(fontSize: 8, color: AppColors.primaryBlue),
          ),
        ),
        const Spacer(),
        _ScoreProgressBar(progress: progress),
        const SizedBox(width: 4),
      ],
    );
  }
}

/// 得分进度条
class _ScoreProgressBar extends StatelessWidget {
  const _ScoreProgressBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(9),
      child: SizedBox(
        width: 50,
        height: 4,
        child: Stack(
          children: [
            Container(color: const Color(0xFFE7E7E7)),
            FractionallySizedBox(
              widthFactor: progress,
              heightFactor: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.loadingIndicator,
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 无错误提示卡片
class _NoErrorCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            '作文没有发现明显错误',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.loadingIndicator,
            ),
          ),
        ),
      ),
    );
  }
}

/// 错误项卡片
class _ErrorItemCard extends StatelessWidget {
  const _ErrorItemCard({required this.index, required this.errorItem});

  final int index;
  final ErrorItem errorItem;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.primaryBlue, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _ErrorItemRow(
            label: '原句$index',
            content: errorItem.originalSentence,
            contentColor: const Color(0xFF4D4D4D),
          ),
          _ErrorItemRow(
            label: '错误原因',
            content: errorItem.errorReason,
            contentColor: const Color(0xFF4D4D4D),
          ),
          _ErrorItemRow(
            label: '正确句子',
            content: errorItem.correctedSentence,
            contentColor: AppColors.loadingIndicator,
          ),
        ],
      ),
    );
  }
}

/// 错误项行
class _ErrorItemRow extends StatelessWidget {
  const _ErrorItemRow({
    required this.label,
    required this.content,
    required this.contentColor,
  });

  final String label;
  final String content;
  final Color contentColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.langSwitchText,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(
              fontSize: 12,
              color: contentColor,
              height: 18 / 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// 错误页（result 为 null）
class _ErrorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FE),
      body: Column(
        children: [
          Container(
            color: AppColors.primaryBlue,
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                height: 50,
                child: Stack(
                  children: [
                    Positioned(
                      left: 18,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: GestureDetector(
                          onTap: () => context.pop(),
                          child: const Padding(
                            padding: EdgeInsets.all(12),
                            child: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Center(
                      child: Text(
                        '文章批改结果',
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                '无法加载批改结果',
                style: TextStyle(fontSize: 16, color: Color(0xFF4D4D4D)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

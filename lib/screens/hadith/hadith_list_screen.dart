import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/hadith_model.dart';
import '../../providers/hadith_provider.dart';
import '../../core/widgets/hadith_card.dart';
import '../../core/widgets/loading_error_widget.dart';

class HadithListScreen extends StatelessWidget {
  final HadithBook book;
  final HadithChapter chapter;

  const HadithListScreen({
    super.key,
    required this.book,
    required this.chapter,
  });

  @override
  Widget build(BuildContext context) {
    final hadithProvider = context.watch<HadithProvider>();
    final hadiths = hadithProvider.hadiths;

    return Scaffold(
      appBar: AppBar(
        title: Text(chapter.title),
      ),
      body: LoadingErrorWidget(
        isLoading: hadithProvider.isLoading,
        errorMessage: hadithProvider.errorMessage,
        onRetry: () => hadithProvider.selectChapter(book, chapter),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: hadiths.length,
          itemBuilder: (context, index) {
            final item = hadiths[index];
            return HadithCard(hadith: item);
          },
        ),
      ),
    );
  }
}

class JobModel {
  final String id;
  final String filename;
  final String status; // queued | processing | done | failed
  final double? globalSimilarityScore; // 0.0 - 1.0
  final DateTime createdAt;
  final String? errorMessage;

  JobModel({
    required this.id,
    required this.filename,
    required this.status,
    required this.createdAt,
    this.globalSimilarityScore,
    this.errorMessage,
  });

  bool get isDone => status == 'done';
  bool get isFailed => status == 'failed';
  bool get isProcessing => status == 'processing' || status == 'queued';

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id'].toString(),
      filename: json['filename'] ?? 'Untitled document',
      status: json['status'] ?? 'queued',
      globalSimilarityScore: json['global_similarity_score'] != null
          ? (json['global_similarity_score'] as num).toDouble()
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      errorMessage: json['error_message'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'filename': filename,
        'status': status,
        'global_similarity_score': globalSimilarityScore,
        'created_at': createdAt.toIso8601String(),
        'error_message': errorMessage,
      };
}

class FlaggedSpanModel {
  final String id;
  final String text;
  final double similarityScore; // 0.0 - 1.0
  final String? sourceTitle;
  final String? sourceUrl;
  final int startOffset;
  final int endOffset;
  final String? rewrittenText;
  final bool resolved;
  final double? finalScoreAfterRewrite;

  FlaggedSpanModel({
    required this.id,
    required this.text,
    required this.similarityScore,
    required this.startOffset,
    required this.endOffset,
    this.sourceTitle,
    this.sourceUrl,
    this.rewrittenText,
    this.resolved = false,
    this.finalScoreAfterRewrite,
  });

  factory FlaggedSpanModel.fromJson(Map<String, dynamic> json) {
    return FlaggedSpanModel(
      id: json['id'].toString(),
      text: json['text'] ?? json['original_text'] ?? '',
      similarityScore: (json['similarity_score'] as num? ?? json['combined_score'] as num? ?? 0).toDouble(),
      startOffset: json['start_offset'] ?? json['start_char'] ?? 0,
      endOffset: json['end_offset'] ?? json['end_char'] ?? 0,
      sourceTitle: json['source_title'] ?? json['matched_source_title'],
      sourceUrl: json['source_url'],
      rewrittenText: json['rewritten_text'],
      resolved: (json['resolved'] == 1 || json['resolved'] == true),
      finalScoreAfterRewrite: (json['final_score_after_rewrite'] as num?)?.toDouble(),
    );
  }
}

class ReportModel {
  final String jobId;
  final String filename;
  final double globalSimilarityScore;
  final List<FlaggedSpanModel> flaggedSpans;
  final String? fullText;
  final String? rewrittenFullText;
  final DateTime? createdAt;

  ReportModel({
    required this.jobId,
    required this.filename,
    required this.globalSimilarityScore,
    required this.flaggedSpans,
    this.fullText,
    this.rewrittenFullText,
    this.createdAt,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      jobId: (json['job_id'] ?? json['id'] ?? '').toString(),
      filename: json['filename'] ?? 'Untitled document',
      globalSimilarityScore: (json['global_similarity_score'] as num? ?? 0).toDouble(),
      flaggedSpans: (json['flagged_spans'] as List? ?? [])
          .map((s) => FlaggedSpanModel.fromJson(s))
          .toList(),
      fullText: json['full_text'],
      rewrittenFullText: json['rewritten_full_text'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  /// Deduplicated list of source titles, in order of first appearance.
  List<String> get uniqueSources {
    final seen = <String>{};
    final result = <String>[];
    for (final span in flaggedSpans) {
      final title = span.sourceTitle;
      if (title != null && title.isNotEmpty && !seen.contains(title)) {
        seen.add(title);
        result.add(title);
      }
    }
    return result;
  }
}
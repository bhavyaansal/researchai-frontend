import 'dart:async';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../models/job_model.dart';

/// Handles all authenticated calls to the FastAPI backend.
///
/// IMPORTANT: on Flutter Windows desktop, use 127.0.0.1 rather than
/// "localhost" — some Windows setups resolve localhost slowly or not
/// at all for loopback sockets opened by uvicorn.
class ApiService {
  static const String baseUrl = 'https://researchai-backend-75ow.onrender.com';

  final String token;
  late final Dio _dio;

  ApiService(this.token) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(minutes: 5), // rewriting can be slow on CPU/Colab
      headers: {
        'Authorization': 'Bearer $token',
      },
    ));
  }

  Future<JobModel> uploadDocument({
    String? filePath,
    Uint8List? bytes,
    required String filename,
  }) async {
    MultipartFile multipartFile;
    if (bytes != null) {
      multipartFile = MultipartFile.fromBytes(bytes, filename: filename);
    } else if (filePath != null && filePath.isNotEmpty) {
      multipartFile = await MultipartFile.fromFile(filePath, filename: filename);
    } else {
      throw Exception('No file data provided for upload');
    }

    final formData = FormData.fromMap({
      'file': multipartFile,
    });
    final response = await _dio.post('/upload', data: formData);
    return _jobFromUploadResponse(response.data, filename);
  }


  Future<JobModel> uploadText({required String text, required String title}) async {
    final response = await _dio.post('/upload/text', data: {
      'text': text,
      'title': title,
    });
    return _jobFromUploadResponse(response.data, title);
  }

  JobModel _jobFromUploadResponse(dynamic data, String fallbackFilename) {
    // The backend's /upload response may just be {"job_id": "..."} or a
    // full job object depending on stage of implementation — handle both.
    if (data is Map && data.containsKey('status')) {
      return JobModel.fromJson(Map<String, dynamic>.from(data));
    }
    return JobModel(
      id: data['job_id'].toString(),
      filename: fallbackFilename,
      status: 'queued',
      createdAt: DateTime.now(),
    );
  }

  Future<JobModel> getScanStatus(String jobId) async {
    final response = await _dio.get('/scan/$jobId');
    return JobModel.fromJson(response.data);
  }

  /// Polls GET /scan/{jobId} every 2 seconds and emits each JobModel.
  /// The stream closes itself once the job is done or failed.
  Stream<JobModel> pollJobStatus(String jobId) {
    late StreamController<JobModel> controller;
    Timer? timer;

    Future<void> poll() async {
      try {
        final job = await getScanStatus(jobId);
        controller.add(job);
        if (job.isDone || job.isFailed) {
          await controller.close();
          timer?.cancel();
        }
      } catch (e) {
        controller.addError(e);
      }
    }

    controller = StreamController<JobModel>(
      onListen: () {
        poll(); // fire immediately, then on an interval
        timer = Timer.periodic(const Duration(seconds: 2), (_) => poll());
      },
      onCancel: () => timer?.cancel(),
    );

    return controller.stream;
  }

  Future<ReportModel> getReport(String jobId) async {
    final response = await _dio.get('/report/$jobId');
    return ReportModel.fromJson(response.data);
  }

  Future<List<JobModel>> listJobs() async {
    final response = await _dio.get('/jobs');
    final List data = response.data;
    return data.map((j) => JobModel.fromJson(j)).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> triggerMitigation(String jobId) async {
    try {
      await _dio.post('/rewrite/$jobId');
    } catch (_) {
      // Graceful fallback if pipeline already ran or rewrite endpoint differs
    }
  }

    Future<String> downloadReportFile(String jobId) async {
    final response = await _dio.get(
      '/download/report/$jobId',
      options: Options(responseType: ResponseType.plain),
    );
    return response.data.toString();
  }

  Future<Uint8List> downloadRewrittenFile(String jobId) async {
    final response = await _dio.get(
      '/download/rewritten/$jobId',
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(response.data);
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await _dio.get('/auth/me');
    return response.data;
  }

  Future<Map<String, dynamic>> paraphraseText({
    required String text,
    String tone = 'academic',
  }) async {
    final response = await _dio.post('/paraphrase', data: {
      'text': text,
      'tone': tone,
    });
    return Map<String, dynamic>.from(response.data);
  }
}

import 'dart:async';

import 'package:dio/dio.dart';

import '../models/question.dart';
import '../models/user.dart';
import '../models/user_answer.dart';
import 'auth_service.dart';

const Duration _kNormalTimeout = Duration(seconds: 10);
const Duration _kColdStartTimeout = Duration(seconds: 45);

class _ColdStartRetryInterceptor extends Interceptor {
  _ColdStartRetryInterceptor({
    required this.dio,
    required this.getColdStartPhase,
    required this.setColdStartEnded,
    this.onWakingRetry,
  });

  final Dio dio;
  final bool Function() getColdStartPhase;
  final void Function() setColdStartEnded;
  final void Function()? onWakingRetry;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.requestOptions.extra['noRetry'] == true) {
      return handler.next(err);
    }
    if (!_isRetryableForColdStart(err)) {
      return handler.next(err);
    }
    // Dio requires handler to be completed via the chain; use .then, not "async void" + unawaited.
    _runRetries(err, handler, 0);
  }

  static bool _isRetryableForColdStart(DioException e) {
    final t = e.type;
    if (t == DioExceptionType.connectionTimeout ||
        t == DioExceptionType.sendTimeout ||
        t == DioExceptionType.receiveTimeout ||
        t == DioExceptionType.connectionError) {
      return true;
    }
    final c = e.response?.statusCode;
    return c == 502 || c == 503 || c == 504;
  }

  void _runRetries(DioException err, ErrorInterceptorHandler handler, int k) {
    if (k >= 2) {
      return handler.next(err);
    }
    if (k == 0 && err.requestOptions.extra['skipWaking'] != true) {
      onWakingRetry?.call();
    }
    err.requestOptions.extra['retry'] = k + 1;
    dio.fetch<dynamic>(err.requestOptions).then(
      (response) {
        if (getColdStartPhase()) {
          setColdStartEnded();
        }
        handler.resolve(response);
      },
      onError: (Object e) {
        if (e is! DioException) {
          return handler.reject(
            DioException(
              requestOptions: err.requestOptions,
              error: e,
              type: DioExceptionType.unknown,
            ),
          );
        }
        if (e.requestOptions.extra['noRetry'] == true ||
            !_isRetryableForColdStart(e)) {
          return handler.next(e);
        }
        _runRetries(e, handler, k + 1);
      },
    );
  }
}

class ApiService {
  final Dio _dio;
  final AuthService _authService;
  String _lang = 'zh';
  bool _coldStartPhase = true;

  ApiService({
    required String baseUrl,
    required AuthService authService,
    void Function()? onWakingRetry,
  })  : _authService = authService,
        _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: _kNormalTimeout,
          receiveTimeout: _kNormalTimeout,
          sendTimeout: _kNormalTimeout,
          headers: {'Content-Type': 'application/json'},
        )) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _authService.token;
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          options.headers['X-App-Language'] = _lang;
          if (_coldStartPhase) {
            options.connectTimeout = _kColdStartTimeout;
            options.receiveTimeout = _kColdStartTimeout;
            options.sendTimeout = _kColdStartTimeout;
          }
          handler.next(options);
        },
        onResponse: (r, h) {
          if (_coldStartPhase) {
            _coldStartPhase = false;
          }
          h.next(r);
        },
      ),
    );
    _dio.interceptors.add(
      _ColdStartRetryInterceptor(
        dio: _dio,
        getColdStartPhase: () => _coldStartPhase,
        setColdStartEnded: () {
          _coldStartPhase = false;
        },
        onWakingRetry: onWakingRetry,
      ),
    );
  }

  void setLanguage(String lang) {
    _lang = lang;
  }

  /// Fires a minimal GET to wake cold hosts (e.g. Render) without retry UX or blocking the UI.
  void warmupInBackground() {
    unawaited(
      (() async {
        try {
          await _dio.get<dynamic>(
            '/health',
            options: Options(
              extra: const {
                'noRetry': true,
                'skipWaking': true,
              },
            ),
          );
        } catch (_) {
          // Background ping only; app logic uses retry + long timeout.
        }
      })(),
    );
  }

  Future<List<Question>> getQuestions({int page = 1, String? category, String? search}) async {
    final queryParams = <String, dynamic>{'page': page};
    if (category != null && category != '全部') {
      queryParams['category'] = category;
    }
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    final response = await _dio.get('/questions', queryParameters: queryParams);
    final list = response.data['items'] as List<dynamic>;
    return list
        .map((e) => Question.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Question> getQuestion(int id) async {
    final response = await _dio.get('/questions/$id');
    return Question.fromJson(response.data as Map<String, dynamic>);
  }

  /// Choice question: vote count and percentage per option.
  Future<List<Map<String, dynamic>>> getChoiceStats(int questionId) async {
    final response = await _dio.get('/questions/$questionId/choice-stats');
    return (response.data['items'] as List<dynamic>)
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }

  Future<UserAnswer> submitAnswer({
    required int questionId,
    required String answerType,
    required String content,
  }) async {
    final response = await _dio.post('/answers', data: {
      'question_id': questionId,
      'answer_type': answerType,
      'answer_content': content,
    });
    return UserAnswer.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserAnswer> getAnswerResult(String answerId) async {
    final response = await _dio.get('/answers/$answerId');
    return UserAnswer.fromJson(response.data as Map<String, dynamic>);
  }

  Future<String> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return response.data['access_token'] as String;
  }

  Future<User> getMe() async {
    final response = await _dio.get('/users/me');
    return User.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> getUserStats() async {
    final response = await _dio.get('/users/me/stats');
    return response.data as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getAnswerHistory() async {
    final response = await _dio.get('/answers/history');
    return (response.data as List<dynamic>)
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }

  Future<String> register({
    required String email,
    required String password,
    required String nickname,
  }) async {
    final response = await _dio.post('/auth/register', data: {
      'email': email,
      'password': password,
      'nickname': nickname,
    });
    return response.data['access_token'] as String;
  }

  // ── User Question Submission ─────────────────────────────────────────────

  Future<Map<String, dynamic>> submitUserQuestion({
    required String title,
    required String description,
    required String category,
  }) async {
    final response = await _dio.post('/user-questions', data: {
      'title': title,
      'description': description,
      'category': category,
    });
    return response.data as Map<String, dynamic>;
  }

  // ── Forum ────────────────────────────────────────────────────────────────

  /// Questions that have at least one forum post, with post count.
  Future<List<Map<String, dynamic>>> getForumQuestionSummaries() async {
    final response = await _dio.get('/forum/questions');
    return (response.data as List<dynamic>)
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }

  /// sort: 'likes' (default, by like count desc) or 'time' (newest first).
  Future<Map<String, dynamic>> getForumPosts({
    int page = 1,
    int? questionId,
    String sort = 'likes',
  }) async {
    final queryParams = <String, dynamic>{'page': page, 'sort': sort};
    if (questionId != null) queryParams['question_id'] = questionId;
    final response = await _dio.get('/forum', queryParameters: queryParams);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createForumPost({
    required String answerId,
    required String content,
  }) async {
    final response = await _dio.post('/forum', data: {
      'answer_id': answerId,
      'content': content,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<int> toggleLike(String postId) async {
    final response = await _dio.post('/forum/$postId/like');
    return (response.data as Map<String, dynamic>)['like_count'] as int;
  }

  // ── 今日科普 ────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getScienceToday() async {
    final response = await _dio.get('/science/today');
    return response.data as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getScienceArchive() async {
    final response = await _dio.get('/science/archive');
    return (response.data as List<dynamic>).map((e) => e as Map<String, dynamic>).toList();
  }

  Future<Map<String, dynamic>> getScienceByDate(String dateStr) async {
    final response = await _dio.get('/science/$dateStr');
    return response.data as Map<String, dynamic>;
  }

  Future<void> postScienceComment(String dateStr, String content) async {
    await _dio.post('/science/$dateStr/comments', data: {
      'content': content,
    });
  }
}

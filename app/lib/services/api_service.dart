import 'package:dio/dio.dart';

import '../models/question.dart';
import '../models/user.dart';
import '../models/user_answer.dart';
import 'auth_service.dart';

class ApiService {
  final Dio _dio;
  final AuthService _authService;

  ApiService({
    required String baseUrl,
    required AuthService authService,
  }) : _authService = authService,
       _dio = Dio(BaseOptions(
         baseUrl: baseUrl,
         connectTimeout: const Duration(seconds: 10),
         receiveTimeout: const Duration(seconds: 10),
         headers: {'Content-Type': 'application/json'},
       )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = _authService.token;
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));
  }

  Future<List<Question>> getQuestions({int page = 1, String? category}) async {
    final queryParams = <String, dynamic>{'page': page};
    if (category != null && category != '全部') {
      queryParams['category'] = category;
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
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/choice_option.dart';
import '../models/question.dart';
import 'auth_provider.dart';

class QuestionsState {
  final List<Question> questions;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final bool hasMore;
  final String selectedCategory;

  const QuestionsState({
    this.questions = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.hasMore = true,
    this.selectedCategory = '全部',
  });

  QuestionsState copyWith({
    List<Question>? questions,
    bool? isLoading,
    String? error,
    int? currentPage,
    bool? hasMore,
    String? selectedCategory,
  }) {
    return QuestionsState(
      questions: questions ?? this.questions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}

class QuestionsNotifier extends StateNotifier<QuestionsState> {
  final Ref _ref;

  QuestionsNotifier(this._ref) : super(const QuestionsState()) {
    loadQuestions();
  }

  Future<void> loadQuestions({bool refresh = false}) async {
    if (state.isLoading) return;

    final page = refresh ? 1 : state.currentPage;
    state = state.copyWith(isLoading: true, error: null);

    try {
      final api = _ref.read(apiServiceProvider);
      final questions = await api.getQuestions(
        page: page,
        category: state.selectedCategory,
      );

      state = state.copyWith(
        questions: refresh ? questions : [...state.questions, ...questions],
        isLoading: false,
        currentPage: page + 1,
        hasMore: questions.length >= 20,
      );
    } catch (_) {
      _loadDemoData(refresh);
    }
  }

  void _loadDemoData(bool refresh) {
    final demoQuestions = [
      const Question(
        id: 1,
        title: '如果人类能够光合作用，世界会变成什么样？',
        description: '假设人类通过基因改造获得了光合作用的能力，不再需要通过进食获取全部能量。请大胆想象这会如何改变我们的社会、文化和日常生活。',
        type: QuestionType.shortAnswer,
        category: '脑洞',
        difficulty: 3,
      ),
      const Question(
        id: 2,
        title: '以下哪个发明最可能在100年后被淘汰？',
        description: '从技术发展趋势来看，你认为哪项当代技术最可能在未来100年内被完全替代？',
        type: QuestionType.choice,
        category: '科学',
        difficulty: 2,
        options: [
          ChoiceOption(id: 1, questionId: 2, content: '智能手机', aiComment: '有趣的选择！脑机接口确实可能替代它'),
          ChoiceOption(id: 2, questionId: 2, content: '传统汽车', aiComment: '飞行器和传送技术会改变交通'),
          ChoiceOption(id: 3, questionId: 2, content: '纸质书籍', aiComment: '纸质书也许会以收藏品的形式存在'),
          ChoiceOption(id: 4, questionId: 2, content: '键盘鼠标', aiComment: '意念操控或许会成为主流'),
        ],
      ),
      const Question(
        id: 3,
        title: '"我思故我在"能证明什么？',
        description: '笛卡尔的经典命题。在现代AI时代的语境下，重新思考这句话的含义。如果AI也能"思考"，它也"存在"吗？',
        type: QuestionType.shortAnswer,
        category: '哲学',
        difficulty: 4,
      ),
      const Question(
        id: 4,
        title: '你认为哪种超能力最具有实用价值？',
        description: '如果你可以选择一种超能力应用于日常生活中，你觉得哪种最实用？',
        type: QuestionType.choice,
        category: '脑洞',
        difficulty: 1,
        options: [
          ChoiceOption(id: 5, questionId: 4, content: '时间暂停', aiComment: '效率之王！但要小心道德困境'),
          ChoiceOption(id: 6, questionId: 4, content: '瞬间移动', aiComment: '告别通勤！不过你会失去路上的风景'),
          ChoiceOption(id: 7, questionId: 4, content: '读心术', aiComment: '强大但危险，知道太多也是一种负担'),
          ChoiceOption(id: 8, questionId: 4, content: '万能语言', aiComment: '沟通无障碍，一个人就是联合国'),
        ],
      ),
      const Question(
        id: 5,
        title: '用一道菜来形容你的人生，你会选什么？',
        description: '这不只是关于食物，更是关于你如何看待自己的人生——酸甜苦辣咸，丰富还是简单，精致还是朴实。请详细描述这道菜及其背后的含义。',
        type: QuestionType.shortAnswer,
        category: '生活',
        difficulty: 2,
      ),
      const Question(
        id: 6,
        title: '量子纠缠能否用来实现超光速通信？',
        description: '量子纠缠常常被误解为可以传递信息。请从物理学原理出发，分析这个问题，并大胆猜想未来的突破可能性。',
        type: QuestionType.shortAnswer,
        category: '科学',
        difficulty: 5,
      ),
    ];

    state = state.copyWith(
      questions: refresh ? demoQuestions : [...state.questions, ...demoQuestions],
      isLoading: false,
      hasMore: false,
    );
  }

  void setCategory(String category) {
    if (state.selectedCategory == category) return;
    state = QuestionsState(selectedCategory: category);
    loadQuestions(refresh: true);
  }

  Future<void> refresh() => loadQuestions(refresh: true);
}

final questionsProvider =
    StateNotifierProvider<QuestionsNotifier, QuestionsState>((ref) {
  return QuestionsNotifier(ref);
});

final selectedCategoryProvider = Provider<String>((ref) {
  return ref.watch(questionsProvider).selectedCategory;
});

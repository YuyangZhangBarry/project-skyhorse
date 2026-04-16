// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '天马行空';

  @override
  String get appSlogan => '每一个回答，都是一次思维冒险';

  @override
  String get loginTagline => '用创意回答世界的问题';

  @override
  String get navHome => '主页';

  @override
  String get navForum => '论坛';

  @override
  String get navScience => '今日科普';

  @override
  String get categoryAll => '全部';

  @override
  String get categoryScience => '科学';

  @override
  String get categoryPhilosophy => '哲学';

  @override
  String get categoryBrainhole => '脑洞';

  @override
  String get categoryLife => '生活';

  @override
  String get categoryUniverse => '宇宙';

  @override
  String get searchHint => '搜索你感兴趣的问题...';

  @override
  String get noQuestions => '暂无题目';

  @override
  String get fieldEmail => '邮箱';

  @override
  String get fieldPassword => '密码';

  @override
  String get fieldNickname => '昵称';

  @override
  String get actionLogin => '登录';

  @override
  String get actionRegister => '注册';

  @override
  String get loginNoAccount => '还没有账号？';

  @override
  String get registerHasAccount => '已有账号？';

  @override
  String get loginFillPrompt => '请填写邮箱和密码';

  @override
  String get loginFailed => '登录失败，请检查账号密码';

  @override
  String get registerFailed => '注册失败，请稍后重试';

  @override
  String get registerTitle => '创建账号';

  @override
  String get registerSubtitle => '开启你的脑洞之旅';

  @override
  String get registerFillAll => '请填写所有字段';

  @override
  String get registerPasswordHelper => '至少 6 位，含英文字母和数字，仅限字母数字及 _!.@#\$%^&*+-=';

  @override
  String get validationEmailRequired => '请填写邮箱';

  @override
  String get validationEmailInvalid => '请输入有效的邮箱地址';

  @override
  String get validationEmailTooLong => '邮箱地址过长';

  @override
  String get validationPasswordRequired => '请填写密码';

  @override
  String get validationPasswordMinLength => '密码至少需要 6 位';

  @override
  String get validationPasswordNeedsLetter => '密码需包含至少一个英文字母';

  @override
  String get validationPasswordNeedsDigit => '密码需包含至少一个数字';

  @override
  String get validationPasswordAllowedChars => '密码仅允许英文字母、数字及 _!.@#\$%^&*-+=';

  @override
  String get questionLoading => '题目加载中...';

  @override
  String questionNumberLabel(int id) {
    return '第 $id 题';
  }

  @override
  String get questionTypeChoice => '选择题';

  @override
  String get questionTypeShort => '简答题';

  @override
  String get questionBadgeChoice => '选择';

  @override
  String get questionBadgeShort => '简答';

  @override
  String get questionSelectPrompt => '请选择你的答案';

  @override
  String get questionWritePrompt => '写下你的回答';

  @override
  String get questionShortHint => '请大胆发挥你的想象力，写下你的思考...';

  @override
  String get questionSelectSnack => '请选择一个选项';

  @override
  String get questionMinCharsSnack => '请至少写10个字哦';

  @override
  String questionCharCount(int count) {
    return '$count 字';
  }

  @override
  String get actionSubmitAnswer => '提交回答';

  @override
  String get resultAiScore => 'AI 评分';

  @override
  String get resultScoreExceptional => '🌟 非凡的思考者！';

  @override
  String get resultScoreImpressive => '✨ 令人印象深刻！';

  @override
  String get resultScoreThoughtful => '💡 很有想法！';

  @override
  String get resultScoreGoodStart => '🎯 不错的开始！';

  @override
  String get resultScoreKeepExploring => '🌱 继续探索吧！';

  @override
  String get dimensionImagination => '想象力';

  @override
  String get dimensionLogic => '逻辑性';

  @override
  String get dimensionKnowledge => '知识面';

  @override
  String get dimensionFun => '趣味性';

  @override
  String get resultFourDimensions => '四维评估';

  @override
  String get resultAiFeedback => 'AI 点评';

  @override
  String get resultNoFeedback => '暂无点评';

  @override
  String get actionPublishToForum => '发表到论坛';

  @override
  String get snackPublishedToForum => '已发表到论坛';

  @override
  String get actionBackToHome => '返回首页';

  @override
  String get actionNextQuestion => '下一题';

  @override
  String choiceYouSelected(String option) {
    return '你选择了：$option';
  }

  @override
  String get choiceVoteDistribution => '投票分布';

  @override
  String get choicePublishReasonPrompt => '是否要发表选择该选项的原因？';

  @override
  String get choiceReasonHint => '写下你选择该选项的原因...';

  @override
  String choicePeoplePercent(int count, String percent) {
    return '$count 人 · $percent%';
  }

  @override
  String get choiceEnterReason => '请输入原因';

  @override
  String get sectionUserComments => '用户评论';

  @override
  String get noComments => '暂无评论';

  @override
  String forumSelectedOption(String option) {
    return '选择了：$option';
  }

  @override
  String get forumTitle => '讨论广场';

  @override
  String get forumNoShares => '还没有人分享回答';

  @override
  String get forumEmptyCta => '去答题，成为第一个分享精彩回答的人吧！';

  @override
  String get forumSortLabel => '排序：';

  @override
  String get sortNewest => '最新';

  @override
  String get sortHottest => '最热';

  @override
  String get forumNoDiscussion => '暂无讨论';

  @override
  String get forumDetailTitle => '讨论详情';

  @override
  String get scienceToday => '今日科普';

  @override
  String get scienceViewArchive => '查看往期科普';

  @override
  String get scienceArchiveTitle => '往期科普';

  @override
  String get scienceArchiveEmpty => '暂无往期';

  @override
  String get scienceNoArticle => '暂无今日科普';

  @override
  String get scienceDiscussion => '讨论区';

  @override
  String get scienceCommentHint => '写下你的想法…';

  @override
  String get actionPublish => '发表';

  @override
  String get sciencePastDiscussion => '历史讨论（往期不可再回复）';

  @override
  String get profileTitle => '个人主页';

  @override
  String get profileLogin => '请先登录';

  @override
  String get profileTotalAnswers => '答题总数';

  @override
  String get profileAverageScore => '平均分';

  @override
  String get profileRecentAnswers => '最近回答';

  @override
  String get profileNoHistory => '还没有答题记录';

  @override
  String get profileSubmitQuestion => '投稿问题';

  @override
  String get actionLogout => '退出登录';

  @override
  String get submitTitle => '投稿问题';

  @override
  String get submitPrompt => '想一个天马行空的问题';

  @override
  String get submitPromptSub => '好的问题能引发思考、激发想象力';

  @override
  String get submitFieldTitle => '问题标题';

  @override
  String get submitFieldTitleExample => '例如：如果人类能光合作用，世界会变成什么样？';

  @override
  String get submitFieldDescription => '问题描述';

  @override
  String get submitFieldDescriptionHint => '给出一些背景信息，帮助回答者理解这个问题...';

  @override
  String get labelCategory => '分类';

  @override
  String get actionSubmitReview => '提交审核';

  @override
  String get submitTitleMin => '标题至少需要5个字';

  @override
  String get submitDescMin => '描述至少需要10个字';

  @override
  String get submitFailed => '提交失败，请稍后重试';

  @override
  String get submitSuccessTitle => '提交成功！';

  @override
  String get submitSuccessQueue => '你的问题已进入审核队列';

  @override
  String get submitSuccessAppear => '审核通过后将出现在题库中';

  @override
  String get actionBack => '返回';

  @override
  String get snackPostSuccess => '发表成功';

  @override
  String get snackPostFailed => '发表失败，请重试';

  @override
  String get errorLoadFailed => '加载失败';

  @override
  String get errorLoadFailedNetwork => '加载失败，请检查网络后重试';

  @override
  String get errorLoadResultFailed => '加载结果失败';

  @override
  String get actionRetry => '重试';

  @override
  String get labelGuest => '游客';

  @override
  String get demoFeedback1 =>
      '你的回答展现了独特的思维角度！对于这个问题，你能够跳出常规框架，从一个新颖的视角进行分析，这很有价值。';

  @override
  String get demoFeedback2 =>
      '非常有创意的回答！你的想象力令人印象深刻，同时又保持了一定的逻辑性。如果能再深入挖掘一些细节，会更加精彩。';

  @override
  String get demoFeedback3 =>
      '很棒的思考！你对这个问题的理解比较深入，论述也很有条理。建议可以更多地联系实际案例来增强说服力。';

  @override
  String get demoFeedback4 =>
      '有意思的回答！可以看出你对这个话题有自己独到的见解。不过某些论点可以进一步展开，给出更有力的支撑。';
}

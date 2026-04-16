import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In zh, this message translates to:
  /// **'天马行空'**
  String get appTitle;

  /// No description provided for @appSlogan.
  ///
  /// In zh, this message translates to:
  /// **'每一个回答，都是一次思维冒险'**
  String get appSlogan;

  /// No description provided for @loginTagline.
  ///
  /// In zh, this message translates to:
  /// **'用创意回答世界的问题'**
  String get loginTagline;

  /// No description provided for @navHome.
  ///
  /// In zh, this message translates to:
  /// **'主页'**
  String get navHome;

  /// No description provided for @navForum.
  ///
  /// In zh, this message translates to:
  /// **'论坛'**
  String get navForum;

  /// No description provided for @navScience.
  ///
  /// In zh, this message translates to:
  /// **'今日科普'**
  String get navScience;

  /// No description provided for @categoryAll.
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get categoryAll;

  /// No description provided for @categoryScience.
  ///
  /// In zh, this message translates to:
  /// **'科学'**
  String get categoryScience;

  /// No description provided for @categoryPhilosophy.
  ///
  /// In zh, this message translates to:
  /// **'哲学'**
  String get categoryPhilosophy;

  /// No description provided for @categoryBrainhole.
  ///
  /// In zh, this message translates to:
  /// **'脑洞'**
  String get categoryBrainhole;

  /// No description provided for @categoryLife.
  ///
  /// In zh, this message translates to:
  /// **'生活'**
  String get categoryLife;

  /// No description provided for @categoryUniverse.
  ///
  /// In zh, this message translates to:
  /// **'宇宙'**
  String get categoryUniverse;

  /// No description provided for @searchHint.
  ///
  /// In zh, this message translates to:
  /// **'搜索你感兴趣的问题...'**
  String get searchHint;

  /// No description provided for @noQuestions.
  ///
  /// In zh, this message translates to:
  /// **'暂无题目'**
  String get noQuestions;

  /// No description provided for @fieldEmail.
  ///
  /// In zh, this message translates to:
  /// **'邮箱'**
  String get fieldEmail;

  /// No description provided for @fieldPassword.
  ///
  /// In zh, this message translates to:
  /// **'密码'**
  String get fieldPassword;

  /// No description provided for @fieldNickname.
  ///
  /// In zh, this message translates to:
  /// **'昵称'**
  String get fieldNickname;

  /// No description provided for @actionLogin.
  ///
  /// In zh, this message translates to:
  /// **'登录'**
  String get actionLogin;

  /// No description provided for @actionRegister.
  ///
  /// In zh, this message translates to:
  /// **'注册'**
  String get actionRegister;

  /// No description provided for @loginNoAccount.
  ///
  /// In zh, this message translates to:
  /// **'还没有账号？'**
  String get loginNoAccount;

  /// No description provided for @registerHasAccount.
  ///
  /// In zh, this message translates to:
  /// **'已有账号？'**
  String get registerHasAccount;

  /// No description provided for @loginFillPrompt.
  ///
  /// In zh, this message translates to:
  /// **'请填写邮箱和密码'**
  String get loginFillPrompt;

  /// No description provided for @loginFailed.
  ///
  /// In zh, this message translates to:
  /// **'登录失败，请检查账号密码'**
  String get loginFailed;

  /// No description provided for @registerFailed.
  ///
  /// In zh, this message translates to:
  /// **'注册失败，请稍后重试'**
  String get registerFailed;

  /// No description provided for @registerTitle.
  ///
  /// In zh, this message translates to:
  /// **'创建账号'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'开启你的脑洞之旅'**
  String get registerSubtitle;

  /// No description provided for @registerFillAll.
  ///
  /// In zh, this message translates to:
  /// **'请填写所有字段'**
  String get registerFillAll;

  /// No description provided for @registerPasswordHelper.
  ///
  /// In zh, this message translates to:
  /// **'至少 6 位，含英文字母和数字，仅限字母数字及 _!.@#\$%^&*+-='**
  String get registerPasswordHelper;

  /// No description provided for @validationEmailRequired.
  ///
  /// In zh, this message translates to:
  /// **'请填写邮箱'**
  String get validationEmailRequired;

  /// No description provided for @validationEmailInvalid.
  ///
  /// In zh, this message translates to:
  /// **'请输入有效的邮箱地址'**
  String get validationEmailInvalid;

  /// No description provided for @validationEmailTooLong.
  ///
  /// In zh, this message translates to:
  /// **'邮箱地址过长'**
  String get validationEmailTooLong;

  /// No description provided for @validationPasswordRequired.
  ///
  /// In zh, this message translates to:
  /// **'请填写密码'**
  String get validationPasswordRequired;

  /// No description provided for @validationPasswordMinLength.
  ///
  /// In zh, this message translates to:
  /// **'密码至少需要 6 位'**
  String get validationPasswordMinLength;

  /// No description provided for @validationPasswordNeedsLetter.
  ///
  /// In zh, this message translates to:
  /// **'密码需包含至少一个英文字母'**
  String get validationPasswordNeedsLetter;

  /// No description provided for @validationPasswordNeedsDigit.
  ///
  /// In zh, this message translates to:
  /// **'密码需包含至少一个数字'**
  String get validationPasswordNeedsDigit;

  /// No description provided for @validationPasswordAllowedChars.
  ///
  /// In zh, this message translates to:
  /// **'密码仅允许英文字母、数字及 _!.@#\$%^&*-+='**
  String get validationPasswordAllowedChars;

  /// No description provided for @questionLoading.
  ///
  /// In zh, this message translates to:
  /// **'题目加载中...'**
  String get questionLoading;

  /// No description provided for @questionNumberLabel.
  ///
  /// In zh, this message translates to:
  /// **'第 {id} 题'**
  String questionNumberLabel(int id);

  /// No description provided for @questionTypeChoice.
  ///
  /// In zh, this message translates to:
  /// **'选择题'**
  String get questionTypeChoice;

  /// No description provided for @questionTypeShort.
  ///
  /// In zh, this message translates to:
  /// **'简答题'**
  String get questionTypeShort;

  /// No description provided for @questionBadgeChoice.
  ///
  /// In zh, this message translates to:
  /// **'选择'**
  String get questionBadgeChoice;

  /// No description provided for @questionBadgeShort.
  ///
  /// In zh, this message translates to:
  /// **'简答'**
  String get questionBadgeShort;

  /// No description provided for @questionSelectPrompt.
  ///
  /// In zh, this message translates to:
  /// **'请选择你的答案'**
  String get questionSelectPrompt;

  /// No description provided for @questionWritePrompt.
  ///
  /// In zh, this message translates to:
  /// **'写下你的回答'**
  String get questionWritePrompt;

  /// No description provided for @questionShortHint.
  ///
  /// In zh, this message translates to:
  /// **'请大胆发挥你的想象力，写下你的思考...'**
  String get questionShortHint;

  /// No description provided for @questionSelectSnack.
  ///
  /// In zh, this message translates to:
  /// **'请选择一个选项'**
  String get questionSelectSnack;

  /// No description provided for @questionMinCharsSnack.
  ///
  /// In zh, this message translates to:
  /// **'请至少写10个字哦'**
  String get questionMinCharsSnack;

  /// No description provided for @questionCharCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 字'**
  String questionCharCount(int count);

  /// No description provided for @actionSubmitAnswer.
  ///
  /// In zh, this message translates to:
  /// **'提交回答'**
  String get actionSubmitAnswer;

  /// No description provided for @resultAiScore.
  ///
  /// In zh, this message translates to:
  /// **'AI 评分'**
  String get resultAiScore;

  /// No description provided for @resultScoreExceptional.
  ///
  /// In zh, this message translates to:
  /// **'🌟 非凡的思考者！'**
  String get resultScoreExceptional;

  /// No description provided for @resultScoreImpressive.
  ///
  /// In zh, this message translates to:
  /// **'✨ 令人印象深刻！'**
  String get resultScoreImpressive;

  /// No description provided for @resultScoreThoughtful.
  ///
  /// In zh, this message translates to:
  /// **'💡 很有想法！'**
  String get resultScoreThoughtful;

  /// No description provided for @resultScoreGoodStart.
  ///
  /// In zh, this message translates to:
  /// **'🎯 不错的开始！'**
  String get resultScoreGoodStart;

  /// No description provided for @resultScoreKeepExploring.
  ///
  /// In zh, this message translates to:
  /// **'🌱 继续探索吧！'**
  String get resultScoreKeepExploring;

  /// No description provided for @dimensionImagination.
  ///
  /// In zh, this message translates to:
  /// **'想象力'**
  String get dimensionImagination;

  /// No description provided for @dimensionLogic.
  ///
  /// In zh, this message translates to:
  /// **'逻辑性'**
  String get dimensionLogic;

  /// No description provided for @dimensionKnowledge.
  ///
  /// In zh, this message translates to:
  /// **'知识面'**
  String get dimensionKnowledge;

  /// No description provided for @dimensionFun.
  ///
  /// In zh, this message translates to:
  /// **'趣味性'**
  String get dimensionFun;

  /// No description provided for @resultFourDimensions.
  ///
  /// In zh, this message translates to:
  /// **'四维评估'**
  String get resultFourDimensions;

  /// No description provided for @resultAiFeedback.
  ///
  /// In zh, this message translates to:
  /// **'AI 点评'**
  String get resultAiFeedback;

  /// No description provided for @resultNoFeedback.
  ///
  /// In zh, this message translates to:
  /// **'暂无点评'**
  String get resultNoFeedback;

  /// No description provided for @actionPublishToForum.
  ///
  /// In zh, this message translates to:
  /// **'发表到论坛'**
  String get actionPublishToForum;

  /// No description provided for @snackPublishedToForum.
  ///
  /// In zh, this message translates to:
  /// **'已发表到论坛'**
  String get snackPublishedToForum;

  /// No description provided for @actionBackToHome.
  ///
  /// In zh, this message translates to:
  /// **'返回首页'**
  String get actionBackToHome;

  /// No description provided for @actionNextQuestion.
  ///
  /// In zh, this message translates to:
  /// **'下一题'**
  String get actionNextQuestion;

  /// No description provided for @choiceYouSelected.
  ///
  /// In zh, this message translates to:
  /// **'你选择了：{option}'**
  String choiceYouSelected(String option);

  /// No description provided for @choiceVoteDistribution.
  ///
  /// In zh, this message translates to:
  /// **'投票分布'**
  String get choiceVoteDistribution;

  /// No description provided for @choicePublishReasonPrompt.
  ///
  /// In zh, this message translates to:
  /// **'是否要发表选择该选项的原因？'**
  String get choicePublishReasonPrompt;

  /// No description provided for @choiceReasonHint.
  ///
  /// In zh, this message translates to:
  /// **'写下你选择该选项的原因...'**
  String get choiceReasonHint;

  /// No description provided for @choicePeoplePercent.
  ///
  /// In zh, this message translates to:
  /// **'{count} 人 · {percent}%'**
  String choicePeoplePercent(int count, String percent);

  /// No description provided for @choiceEnterReason.
  ///
  /// In zh, this message translates to:
  /// **'请输入原因'**
  String get choiceEnterReason;

  /// No description provided for @sectionUserComments.
  ///
  /// In zh, this message translates to:
  /// **'用户评论'**
  String get sectionUserComments;

  /// No description provided for @noComments.
  ///
  /// In zh, this message translates to:
  /// **'暂无评论'**
  String get noComments;

  /// No description provided for @forumSelectedOption.
  ///
  /// In zh, this message translates to:
  /// **'选择了：{option}'**
  String forumSelectedOption(String option);

  /// No description provided for @forumTitle.
  ///
  /// In zh, this message translates to:
  /// **'讨论广场'**
  String get forumTitle;

  /// No description provided for @forumNoShares.
  ///
  /// In zh, this message translates to:
  /// **'还没有人分享回答'**
  String get forumNoShares;

  /// No description provided for @forumEmptyCta.
  ///
  /// In zh, this message translates to:
  /// **'去答题，成为第一个分享精彩回答的人吧！'**
  String get forumEmptyCta;

  /// No description provided for @forumSortLabel.
  ///
  /// In zh, this message translates to:
  /// **'排序：'**
  String get forumSortLabel;

  /// No description provided for @sortNewest.
  ///
  /// In zh, this message translates to:
  /// **'最新'**
  String get sortNewest;

  /// No description provided for @sortHottest.
  ///
  /// In zh, this message translates to:
  /// **'最热'**
  String get sortHottest;

  /// No description provided for @forumNoDiscussion.
  ///
  /// In zh, this message translates to:
  /// **'暂无讨论'**
  String get forumNoDiscussion;

  /// No description provided for @forumDetailTitle.
  ///
  /// In zh, this message translates to:
  /// **'讨论详情'**
  String get forumDetailTitle;

  /// No description provided for @scienceToday.
  ///
  /// In zh, this message translates to:
  /// **'今日科普'**
  String get scienceToday;

  /// No description provided for @scienceViewArchive.
  ///
  /// In zh, this message translates to:
  /// **'查看往期科普'**
  String get scienceViewArchive;

  /// No description provided for @scienceArchiveTitle.
  ///
  /// In zh, this message translates to:
  /// **'往期科普'**
  String get scienceArchiveTitle;

  /// No description provided for @scienceArchiveEmpty.
  ///
  /// In zh, this message translates to:
  /// **'暂无往期'**
  String get scienceArchiveEmpty;

  /// No description provided for @scienceNoArticle.
  ///
  /// In zh, this message translates to:
  /// **'暂无今日科普'**
  String get scienceNoArticle;

  /// No description provided for @scienceDiscussion.
  ///
  /// In zh, this message translates to:
  /// **'讨论区'**
  String get scienceDiscussion;

  /// No description provided for @scienceCommentHint.
  ///
  /// In zh, this message translates to:
  /// **'写下你的想法…'**
  String get scienceCommentHint;

  /// No description provided for @actionPublish.
  ///
  /// In zh, this message translates to:
  /// **'发表'**
  String get actionPublish;

  /// No description provided for @sciencePastDiscussion.
  ///
  /// In zh, this message translates to:
  /// **'历史讨论（往期不可再回复）'**
  String get sciencePastDiscussion;

  /// No description provided for @profileTitle.
  ///
  /// In zh, this message translates to:
  /// **'个人主页'**
  String get profileTitle;

  /// No description provided for @profileLogin.
  ///
  /// In zh, this message translates to:
  /// **'请先登录'**
  String get profileLogin;

  /// No description provided for @profileTotalAnswers.
  ///
  /// In zh, this message translates to:
  /// **'答题总数'**
  String get profileTotalAnswers;

  /// No description provided for @profileAverageScore.
  ///
  /// In zh, this message translates to:
  /// **'平均分'**
  String get profileAverageScore;

  /// No description provided for @profileRecentAnswers.
  ///
  /// In zh, this message translates to:
  /// **'最近回答'**
  String get profileRecentAnswers;

  /// No description provided for @profileNoHistory.
  ///
  /// In zh, this message translates to:
  /// **'还没有答题记录'**
  String get profileNoHistory;

  /// No description provided for @profileSubmitQuestion.
  ///
  /// In zh, this message translates to:
  /// **'投稿问题'**
  String get profileSubmitQuestion;

  /// No description provided for @actionLogout.
  ///
  /// In zh, this message translates to:
  /// **'退出登录'**
  String get actionLogout;

  /// No description provided for @submitTitle.
  ///
  /// In zh, this message translates to:
  /// **'投稿问题'**
  String get submitTitle;

  /// No description provided for @submitPrompt.
  ///
  /// In zh, this message translates to:
  /// **'想一个天马行空的问题'**
  String get submitPrompt;

  /// No description provided for @submitPromptSub.
  ///
  /// In zh, this message translates to:
  /// **'好的问题能引发思考、激发想象力'**
  String get submitPromptSub;

  /// No description provided for @submitFieldTitle.
  ///
  /// In zh, this message translates to:
  /// **'问题标题'**
  String get submitFieldTitle;

  /// No description provided for @submitFieldTitleExample.
  ///
  /// In zh, this message translates to:
  /// **'例如：如果人类能光合作用，世界会变成什么样？'**
  String get submitFieldTitleExample;

  /// No description provided for @submitFieldDescription.
  ///
  /// In zh, this message translates to:
  /// **'问题描述'**
  String get submitFieldDescription;

  /// No description provided for @submitFieldDescriptionHint.
  ///
  /// In zh, this message translates to:
  /// **'给出一些背景信息，帮助回答者理解这个问题...'**
  String get submitFieldDescriptionHint;

  /// No description provided for @labelCategory.
  ///
  /// In zh, this message translates to:
  /// **'分类'**
  String get labelCategory;

  /// No description provided for @actionSubmitReview.
  ///
  /// In zh, this message translates to:
  /// **'提交审核'**
  String get actionSubmitReview;

  /// No description provided for @submitTitleMin.
  ///
  /// In zh, this message translates to:
  /// **'标题至少需要5个字'**
  String get submitTitleMin;

  /// No description provided for @submitDescMin.
  ///
  /// In zh, this message translates to:
  /// **'描述至少需要10个字'**
  String get submitDescMin;

  /// No description provided for @submitFailed.
  ///
  /// In zh, this message translates to:
  /// **'提交失败，请稍后重试'**
  String get submitFailed;

  /// No description provided for @submitSuccessTitle.
  ///
  /// In zh, this message translates to:
  /// **'提交成功！'**
  String get submitSuccessTitle;

  /// No description provided for @submitSuccessQueue.
  ///
  /// In zh, this message translates to:
  /// **'你的问题已进入审核队列'**
  String get submitSuccessQueue;

  /// No description provided for @submitSuccessAppear.
  ///
  /// In zh, this message translates to:
  /// **'审核通过后将出现在题库中'**
  String get submitSuccessAppear;

  /// No description provided for @actionBack.
  ///
  /// In zh, this message translates to:
  /// **'返回'**
  String get actionBack;

  /// No description provided for @snackPostSuccess.
  ///
  /// In zh, this message translates to:
  /// **'发表成功'**
  String get snackPostSuccess;

  /// No description provided for @snackPostFailed.
  ///
  /// In zh, this message translates to:
  /// **'发表失败，请重试'**
  String get snackPostFailed;

  /// No description provided for @errorLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'加载失败'**
  String get errorLoadFailed;

  /// No description provided for @errorLoadFailedNetwork.
  ///
  /// In zh, this message translates to:
  /// **'加载失败，请检查网络后重试'**
  String get errorLoadFailedNetwork;

  /// No description provided for @errorLoadResultFailed.
  ///
  /// In zh, this message translates to:
  /// **'加载结果失败'**
  String get errorLoadResultFailed;

  /// No description provided for @actionRetry.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get actionRetry;

  /// No description provided for @labelGuest.
  ///
  /// In zh, this message translates to:
  /// **'游客'**
  String get labelGuest;

  /// No description provided for @demoFeedback1.
  ///
  /// In zh, this message translates to:
  /// **'你的回答展现了独特的思维角度！对于这个问题，你能够跳出常规框架，从一个新颖的视角进行分析，这很有价值。'**
  String get demoFeedback1;

  /// No description provided for @demoFeedback2.
  ///
  /// In zh, this message translates to:
  /// **'非常有创意的回答！你的想象力令人印象深刻，同时又保持了一定的逻辑性。如果能再深入挖掘一些细节，会更加精彩。'**
  String get demoFeedback2;

  /// No description provided for @demoFeedback3.
  ///
  /// In zh, this message translates to:
  /// **'很棒的思考！你对这个问题的理解比较深入，论述也很有条理。建议可以更多地联系实际案例来增强说服力。'**
  String get demoFeedback3;

  /// No description provided for @demoFeedback4.
  ///
  /// In zh, this message translates to:
  /// **'有意思的回答！可以看出你对这个话题有自己独到的见解。不过某些论点可以进一步展开，给出更有力的支撑。'**
  String get demoFeedback4;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

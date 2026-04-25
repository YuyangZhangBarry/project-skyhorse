// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Skyhorse';

  @override
  String get appSlogan => 'Every answer is an adventure in thinking';

  @override
  String get loginTagline => 'Answer the world\'s questions with creativity';

  @override
  String get navHome => 'Home';

  @override
  String get navForum => 'Forum';

  @override
  String get navScience => 'Science Today';

  @override
  String get categoryAll => 'All';

  @override
  String get categoryScience => 'Science';

  @override
  String get categoryPhilosophy => 'Philosophy';

  @override
  String get categoryBrainhole => 'Wild Ideas';

  @override
  String get categoryLife => 'Life';

  @override
  String get categoryUniverse => 'Universe';

  @override
  String get searchHint => 'Search for questions you\'re interested in…';

  @override
  String get noQuestions => 'No questions yet';

  @override
  String get fieldEmail => 'Email';

  @override
  String get fieldPassword => 'Password';

  @override
  String get fieldNickname => 'Nickname';

  @override
  String get actionLogin => 'Log in';

  @override
  String get actionRegister => 'Register';

  @override
  String get loginNoAccount => 'Don\'t have an account?';

  @override
  String get registerHasAccount => 'Already have an account?';

  @override
  String get loginFillPrompt => 'Please enter your email and password';

  @override
  String get loginFailed => 'Login failed. Please check your credentials.';

  @override
  String get registerFailed => 'Registration failed. Please try again later.';

  @override
  String get registerTitle => 'Create an account';

  @override
  String get registerSubtitle => 'Start your imaginative journey';

  @override
  String get registerFillAll => 'Please fill in all fields';

  @override
  String get registerPasswordHelper =>
      'At least 6 chars with letters & digits; only letters, digits, and _!.@#\$%^&*+-=';

  @override
  String get validationEmailRequired => 'Please enter your email';

  @override
  String get validationEmailInvalid => 'Please enter a valid email address';

  @override
  String get validationEmailTooLong => 'Email address is too long';

  @override
  String get validationPasswordRequired => 'Please enter your password';

  @override
  String get validationPasswordMinLength =>
      'Password must be at least 6 characters';

  @override
  String get validationPasswordNeedsLetter =>
      'Password must contain at least one letter';

  @override
  String get validationPasswordNeedsDigit =>
      'Password must contain at least one digit';

  @override
  String get validationPasswordAllowedChars =>
      'Password may only contain letters, digits, and _!.@#\$%^&*-+=';

  @override
  String get questionLoading => 'Loading question…';

  @override
  String questionNumberLabel(int id) {
    return 'Question $id';
  }

  @override
  String get questionTypeChoice => 'Multiple choice';

  @override
  String get questionTypeShort => 'Short answer';

  @override
  String get questionBadgeChoice => 'Choice';

  @override
  String get questionBadgeShort => 'Short';

  @override
  String get questionSelectPrompt => 'Choose your answer';

  @override
  String get questionWritePrompt => 'Write your answer';

  @override
  String get questionShortHint =>
      'Let your imagination run wild — share your thoughts…';

  @override
  String get questionSelectSnack => 'Please select an option';

  @override
  String get questionMinCharsSnack => 'Please write at least 10 characters';

  @override
  String questionCharCount(int count) {
    return '$count chars';
  }

  @override
  String get actionSubmitAnswer => 'Submit answer';

  @override
  String get resultAiScore => 'AI Score';

  @override
  String get resultScoreExceptional => '🌟 Exceptional thinker!';

  @override
  String get resultScoreImpressive => '✨ Impressive!';

  @override
  String get resultScoreThoughtful => '💡 Great ideas!';

  @override
  String get resultScoreGoodStart => '🎯 Nice start!';

  @override
  String get resultScoreKeepExploring => '🌱 Keep exploring!';

  @override
  String get dimensionImagination => 'Imagination';

  @override
  String get dimensionLogic => 'Logic';

  @override
  String get dimensionKnowledge => 'Knowledge';

  @override
  String get dimensionFun => 'Fun';

  @override
  String get resultFourDimensions => 'Four-Dimensional Evaluation';

  @override
  String get resultAiFeedback => 'AI Feedback';

  @override
  String get resultNoFeedback => 'No feedback yet';

  @override
  String get actionPublishToForum => 'Publish to forum';

  @override
  String get snackPublishedToForum => 'Published to the forum';

  @override
  String get actionBackToHome => 'Back to home';

  @override
  String get actionNextQuestion => 'Next question';

  @override
  String choiceYouSelected(String option) {
    return 'You selected: $option';
  }

  @override
  String get choiceVoteDistribution => 'Vote distribution';

  @override
  String get choicePublishReasonPrompt => 'Share why you chose this option?';

  @override
  String get choiceReasonHint => 'Write why you chose this option…';

  @override
  String choicePeoplePercent(int count, String percent) {
    return '$count people · $percent%';
  }

  @override
  String get choiceEnterReason => 'Please enter a reason';

  @override
  String get sectionUserComments => 'User comments';

  @override
  String get noComments => 'No comments yet';

  @override
  String forumSelectedOption(String option) {
    return 'Chose: $option';
  }

  @override
  String get forumTitle => 'Discussion Square';

  @override
  String get forumNoShares => 'No one has shared answers yet';

  @override
  String get forumEmptyCta => 'Go answer questions and be the first to share!';

  @override
  String get forumSortLabel => 'Sort: ';

  @override
  String get sortNewest => 'Latest';

  @override
  String get sortHottest => 'Hottest';

  @override
  String get forumNoDiscussion => 'No discussion yet';

  @override
  String get forumDetailTitle => 'Discussion details';

  @override
  String get scienceToday => 'Science Today';

  @override
  String get scienceViewArchive => 'View past articles';

  @override
  String get scienceArchiveTitle => 'Past Articles';

  @override
  String get scienceArchiveEmpty => 'No past articles';

  @override
  String get scienceNoArticle => 'No science article today';

  @override
  String get scienceDiscussion => 'Discussion';

  @override
  String get scienceCommentHint => 'Write your thoughts…';

  @override
  String get actionPublish => 'Post';

  @override
  String get sciencePastDiscussion => 'Past discussion (read-only)';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileLogin => 'Please log in first';

  @override
  String get profileTotalAnswers => 'Total answers';

  @override
  String get profileAverageScore => 'Avg. score';

  @override
  String get profileRecentAnswers => 'Recent answers';

  @override
  String get profileNoHistory => 'No answer history yet';

  @override
  String get profileSubmitQuestion => 'Submit a question';

  @override
  String get actionLogout => 'Log out';

  @override
  String get submitTitle => 'Submit a Question';

  @override
  String get submitPrompt => 'Think of a wildly creative question';

  @override
  String get submitPromptSub => 'Good questions spark thinking and imagination';

  @override
  String get submitFieldTitle => 'Question title';

  @override
  String get submitFieldTitleExample =>
      'e.g. If humans could photosynthesize, how would the world change?';

  @override
  String get submitFieldDescription => 'Question description';

  @override
  String get submitFieldDescriptionHint =>
      'Provide background to help answerers understand…';

  @override
  String get labelCategory => 'Category';

  @override
  String get actionSubmitReview => 'Submit for review';

  @override
  String get submitTitleMin => 'Title must be at least 5 characters';

  @override
  String get submitDescMin => 'Description must be at least 10 characters';

  @override
  String get submitFailed => 'Submission failed. Please try again later.';

  @override
  String get submitSuccessTitle => 'Submitted successfully!';

  @override
  String get submitSuccessQueue => 'Your question is in the review queue';

  @override
  String get submitSuccessAppear =>
      'It will appear in the question bank after approval';

  @override
  String get actionBack => 'Back';

  @override
  String get snackPostSuccess => 'Posted successfully';

  @override
  String get snackPostFailed => 'Failed to post. Please try again.';

  @override
  String get errorLoadFailed => 'Failed to load';

  @override
  String get errorLoadFailedNetwork =>
      'Failed to load. Check your network and try again.';

  @override
  String get errorLoadResultFailed => 'Failed to load result';

  @override
  String get actionRetry => 'Retry';

  @override
  String get labelGuest => 'Guest';

  @override
  String get serverWaking => 'The server is starting. Please wait…';

  @override
  String get demoFeedback1 =>
      'Your answer shows a unique perspective! You stepped outside the usual frame and analyzed this from a fresh angle — that\'s valuable.';

  @override
  String get demoFeedback2 =>
      'Very creative answer! Your imagination is impressive while staying logical. Digging deeper into details would make it even better.';

  @override
  String get demoFeedback3 =>
      'Great thinking! You understand the question well and your argument is clear. Adding real-world examples would strengthen it further.';

  @override
  String get demoFeedback4 =>
      'Interesting answer with your own take! Some points could be expanded with stronger support.';
}

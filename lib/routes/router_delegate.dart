
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../data/db/preference.dart';
import '../data/response/story_response.dart';
import '../pages/detail_page.dart';
import '../pages/list_page.dart';
import '../pages/login_page.dart';
import '../pages/register_page.dart';
import '../pages/splash_page.dart';
import '../pages/upload_page.dart';
import '../utils/const.dart';

class MyRouterDelegate extends RouterDelegate
    with ChangeNotifier, PopNavigatorRouterDelegateMixin {
    final GlobalKey<NavigatorState> _navigatorKey;

    MyRouterDelegate() : _navigatorKey = GlobalKey<NavigatorState>() {
      _init();
    }

    _init() async {
      isLoggedIn = await getStorageBoolean(loginData);
      notifyListeners();
    }

  @override
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  String? selectedStory;

  /// todo 8: add historyStack variable to maintaining the stack
  List<Page> historyStack = [];
  bool? isLoggedIn;
  bool isRegister = false;
  bool addAction = false;
  ListStory? storyId;
  String? selectedId;
  double? latitude;
  double? longitude;
  bool? isUnknown;

  final PagingController<int, StoryResponse> _pagingController =
  PagingController(firstPageKey: 0);

  @override
  Widget build(BuildContext context) {
    if (isLoggedIn == null) {
      historyStack = _splashStack;
    } else if (isLoggedIn == true) {
      historyStack = _loggedInStack;
    } else {
      historyStack = _loggedOutStack;
    }
    return Navigator(
      key: navigatorKey,
      pages: historyStack,
      onPopPage: (route, result) {
        final didPop = route.didPop(result);
        if (!didPop) {
          return false;
        }

        addAction = false;
        isRegister = false;
        storyId = null;
        notifyListeners();

        return true;
      },
    );
  }


  @override
  Future<void> setNewRoutePath(configuration) async {

    if (configuration.isUnknownPage) {
      isUnknown = true;
      isRegister = false;
    } else if (configuration.isRegisterPage) {
      isRegister = true;
    } else if (configuration.isHomePage ||
        configuration.isLoginPage ||
        configuration.isSplashPage) {
      isUnknown = false;
      selectedStory = null;
      isRegister = false;
    } else if (configuration.isDetailPage) {
      isUnknown = false;
      isRegister = false;
      selectedStory = configuration.quoteId.toString();
    } else {
      debugPrint(' Could not set new route');
    }
    notifyListeners();

  }


  List<Page> get _splashStack => const [
    MaterialPage(
      key: ValueKey("SplashScreen"),
      child: SplashPage(),
    ),
  ];

  List<Page> get _loggedOutStack => [
    MaterialPage(
      key: const ValueKey("LoginPage"),
      child: LoginPage(
        /// todo 17: add onLogin and onRegister method to update the state
        onLogin: () {
          isLoggedIn = true;
          notifyListeners();
        },
        onRegister: () {
          isRegister = true;
          notifyListeners();
        },
      ),
    ),
    if (isRegister == true)
      MaterialPage(
        key: const ValueKey("RegisterPage"),
        child: RegisterPage(
          onRegister: () {
            isRegister = false;
            notifyListeners();
          },
          onLogin: () {
            isRegister = false;
            notifyListeners();
          },
        ),
      ),
  ];

  List<Page> get _loggedInStack => [
    MaterialPage(
      key: const ValueKey("ListStoryPage"),
      child: StoryListPage(
        onTapped: (ListStory idStories) {
          storyId= idStories;
          if (storyId != null) {
            debugPrint('id detail ${storyId?.id}');
          }
          notifyListeners();
        },
        onLogout: () {
          isLoggedIn = false;
          notifyListeners();
        },
        onPressed: () {
          addAction = true;
          notifyListeners();

        },
        storyPagingController: _pagingController,
      ),
    ),
    if (storyId != null)
      MaterialPage(
        key: ValueKey(storyId?.id),
        child: StoriesDetailPage(
           storiesId: storyId,
        ),
      ),
    if (addAction == true)
       MaterialPage(
        key: const ValueKey('AddStoryPage'),
        child: UploadPage(
          onAddAction: () {
            addAction = false;
            notifyListeners();
          }

        ),
      ),

  ];
}
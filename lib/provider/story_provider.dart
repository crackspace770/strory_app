import 'dart:io';

import 'package:flutter/material.dart';
import '../data/api/api_service.dart';
import '../data/response/story_response.dart';

enum ResultState {
  initial,
  loading,
  noData,
  hasData,
  error,}

class StoryProvider extends ChangeNotifier {
  final ApiService apiService;

  StoryProvider({required this.apiService}) {
    fetchStory();
     _setControllerListener();
  }

  bool isLoading = false;

  late StoryResponse _storyResult;
  late ResultState _state;
  String _message = '';
  String get message => _message;
  StoryResponse get result => _storyResult;
  StoryResponse get storiesResults => _storyResult;
  ResultState get state => _state;

  final List<ListStory> _listStory = [];
  List<ListStory> get listStory => _listStory;

  bool _hasReachedMax = false;
  final int _currentSize = 10;
  int _currentPage = 1;
  bool _isScrollLoading = false;

  ScrollController get scrollController => _scrollController;
  bool get isScrollLoading => _isScrollLoading;
  final ScrollController _scrollController = ScrollController();

//  get listStory => null;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchStory() async {
    try {
      if (_listStory.isEmpty) {
        _state = ResultState.loading;
      } else {
        _isScrollLoading = true;
      }
      notifyListeners();

      _storyResult = await apiService.getStoriesList(_currentPage, _currentSize);
      if (_storyResult!.listStory!.isEmpty) {
        _listStory.addAll(_storyResult!.listStory ?? []);
        _state = ResultState.hasData;
      } else {
        if (_listStory.isEmpty) {
          _state = ResultState.noData;
        } else {
          _state = ResultState.hasData;
          _hasReachedMax = true;
        }
      }

      _state = ResultState.hasData;
      if (_isScrollLoading) {
        _isScrollLoading = false;
      }
      notifyListeners();

    } catch (e) {
      isLoading = false;
      _state = ResultState.error;
      notifyListeners();
      throw Exception('Error fetch list API : $e');
    }
  }

  void _setControllerListener() {
    _scrollController.addListener(() {
      if (_scrollController.offset >=
          scrollController.position.maxScrollExtent) {
        if (!_hasReachedMax) {
          _currentPage++;
          fetchStory();
        }
      }
    });
  }

}

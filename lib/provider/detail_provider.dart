
import 'dart:io';
import 'package:flutter/material.dart';
import '../data/api/api_service.dart';
import '../data/response/detail_response.dart';

enum ResultState { loading, noData, hasData, error, initialLoad }

class DetailProvider extends ChangeNotifier {
  final ApiService apiService;
  final String? restaurantId;

  DetailProvider(
      {required this.apiService, required this.restaurantId}) {
    fetchDetailRestaurant(restaurantId!);
  }

  late DetailResponse _detailRestaurant;
  String _message = '';
  late ResultState _state;

  String get message => _message;
  DetailResponse get result => _detailRestaurant;
  ResultState get state => _state;

  Future<dynamic> fetchDetailRestaurant(String restaurantId) async {
    try {
      _state = ResultState.loading;
      notifyListeners();
      final restaurants = await apiService.getDetailStory(restaurantId);
      if (restaurants == null) {
        _state = ResultState.noData;
        notifyListeners();
        return _message = 'Empty Data';
      } else {
        _state = ResultState.hasData;
        notifyListeners();
        return _detailRestaurant = restaurants;
      }
    } on SocketException {
      _state = ResultState.error;
      notifyListeners();
      return _message = 'Connection Error';
    } catch (e) {
      _state = ResultState.error;
      notifyListeners();
      return _message = 'Error -> $e';
    }
  }
}
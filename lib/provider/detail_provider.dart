
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../data/api/api_service.dart';
import '../data/response/detail_response.dart';
import '../data/response/story_response.dart';
import 'package:geocoding/geocoding.dart' as geo;

enum ResultState { loading, noData, hasData, error, initialLoad }

class DetailProvider extends ChangeNotifier {
  final ApiService apiService;
  final String? storyId;

  late ListStory _listStory;
  ListStory get listStory => _listStory;

  DetailProvider(
      {required this.apiService, required this.storyId}) {
    fetchDetailRestaurant(storyId!);
  }

  late DetailResponse _detailRestaurant;
  String _message = '';
  late ResultState _state;

  final Set<Marker> markers = {};
  String _currAddress = "Location Unknown";

  String get message => _message;
  DetailResponse get result => _detailRestaurant;
  ResultState get state => _state;

  Future<dynamic> fetchDetailRestaurant(String restaurantId) async {
    _state = ResultState.loading;
    notifyListeners();

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
        _getCurrAddress();
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

  void _createMarker() {
    if (listStory.lat != null && listStory.lon != null) {
      final marker = Marker(
        markerId: const MarkerId("curr_position"),
        infoWindow: InfoWindow(title: _currAddress),
        position: LatLng(listStory.lat!, listStory.lon!),
      );

      markers.add(marker);
      notifyListeners();
    }
  }

  Future<void> _getCurrAddress() async {
    if (listStory.lat != null && listStory.lon != null) {
      final info = await geo.placemarkFromCoordinates(
        listStory.lat!,
        listStory.lon!,
      );

      if (info.isNotEmpty) {
        final place = info[0];
        _currAddress =
        '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
      }

      _createMarker();
    }
  }



}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:story_app/data/response/story_response.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:location/location.dart' as location;
import '../provider/location_provider.dart';



class StoriesDetailPage extends StatefulWidget {
  static const routeName = '/detail_page';
  final ListStory? storiesId;

  const StoriesDetailPage ({required this.storiesId, super.key,});

  @override
  State<StoriesDetailPage> createState() => _StoriesDetailPageState();
}

class _StoriesDetailPageState extends State<StoriesDetailPage> {
  late GoogleMapController mapController;
  final Set<Marker> markers = {};

  MapType selectedMapType = MapType.normal;
  geo.Placemark? placemark;
  final location.Location _location = location.Location();
  bool _serviceEnabled = false;
  location.PermissionStatus? _permissionGranted;
  LatLng? _initialPosition;
  String _currAddress = "Location Unknown";


  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _checkLocationServices() async {


    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == location.PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != location.PermissionStatus.granted) {
        return;
      }
    }

    // var locationData = await _location.getLocation();
    setState(() {
      _initialPosition =
          LatLng( widget.storiesId!.lon, widget.storiesId!.lat);

      final marker = Marker(
        markerId: const MarkerId("curr_position"),
        infoWindow: InfoWindow(title: _currAddress),
        position: LatLng(widget.storiesId!.lon, widget.storiesId!.lat),
      );

      markers.add(marker);
    });
  }


  @override
  void initState() {
    super.initState();
    _checkLocationServices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.storiesId?.name ?? ''),
      ),
      body: _buildBody(data:widget.storiesId),
    );
  }

  Widget _buildBody({ListStory? data}) {


    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 30,
          ),
          Hero(
            tag: data?.id ?? '',
            child: Container(
              margin: const EdgeInsets.only(right: 10, left: 10),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CachedNetworkImage(
                    cacheKey: '${data?.photoUrl}',
                    imageUrl: '${data?.photoUrl}',
                    fit: BoxFit.contain,

                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) =>
                    const Icon(Icons.error),
                    // Optional parameters:
                    cacheManager: CacheManager(
                      Config(
                        'photoUrl-cache',
                        stalePeriod: const Duration(days: 7),
                        maxNrOfCacheObjects: 200,
                      ),
                    ),
                    // maxHeightDiskCache: 100,
                    // maxWidthDiskCache: 100,
                  ),

                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: Center(
              child: Text(
                '${data?.name}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold
                ),
              ),
            )

          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            child:Center(
              child: Text(
                '${data?.description}',
                overflow: TextOverflow.clip,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16.0,
                ),
              ),
            )

          ),
          const SizedBox(
            height: 30,
          ),
          Container(
            margin: const EdgeInsets.only(left: 10),
            child: const Text(
              'Location',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                width: 10,
              ),
              Row(
                children: [
                  Text(
                      '${data?.lat}'
                  ),
                ],
              ),
              const SizedBox(
                width: 10,
              ),
              Row(
                children: [
                  Text(
                      '${data?.lon}'
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(
            height: 10,
          ),
          widget.storiesId?.lon != null || widget.storiesId?.lat != null ?
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 400,

            child: GoogleMap(
              mapType: MapType.normal,
              markers: markers,
              mapToolbarEnabled: false,
              myLocationButtonEnabled: false,
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  data!.lat,
                  data!.lon,
                ),

                zoom: 15,
              ),
            ),
          )
              : Text(
            "Location Not Found",
            style:
            Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(
            height: 10,
          ),

        ],
      ),
    );
  }

  void onLongPressGoogleMap(LatLng latlng) async {
    final info = await geo.placemarkFromCoordinates(latlng.latitude, latlng.longitude);

    final place = info[0];
    final street = place.street!;
    final address =
        '${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';

    setState(() {
      placemark = place;
    });

    final marker = Marker(
        markerId: const MarkerId("currentLocation"),
        position: latlng,
        infoWindow: InfoWindow(
          title: street,
          snippet: address,
        ));

    setState(() {
      markers.clear();
      markers.add(marker);
    });


    List<geo.Placemark> placemarks =
    await geo.placemarkFromCoordinates(latlng.latitude, latlng.longitude);
    if (placemarks.isNotEmpty) {
      String address =
          '${placemarks.first.street}, ${placemarks.first.subAdministrativeArea}';
      Provider.of<LocationProvider>(context, listen: false)
          .setSelectedLocation(address);
      debugPrint(address);
    }

    mapController!.animateCamera(
      CameraUpdate.newLatLng(latlng),
    );
  }


}


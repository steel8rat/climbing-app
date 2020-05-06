import 'package:climbing/enums/sign_in_provider_enum.dart';
import 'package:climbing/models/gym.dart';
import 'package:climbing/models/my_location.dart';
import 'package:climbing/models/user.dart';
import 'package:climbing/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../gym_widget.dart';

class GymsMap extends StatefulWidget {
  final List<Gym> gyms;
  final Coordinates coordinates;
  final Function setCoordinates;
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey;
  final User user;
  final void Function() updateUserCallback;
  final Future<bool> Function(SignInProvider) signIn;
  final Set<SignInProvider> signInProviderSet;

  GymsMap(this.coordinates, this.gyms, this.setCoordinates,
      this.refreshIndicatorKey, this.user, this.updateUserCallback, this.signIn, this.signInProviderSet,
      {Key key})
      : super(key: key);

  @override
  _GymsMapState createState() => _GymsMapState();
}

class _GymsMapState extends State<GymsMap> {
  final Map<String, Marker> _markers = {};
  GoogleMapController mapController;
  Coordinates mapCenterCoordinates;

  createMarkers() async {
    setState(() {
      _markers.clear();
      for (final gym in widget.gyms) {
        final marker = Marker(
          markerId: MarkerId(gym.name),
          position: LatLng(gym.coordinates.latitude, gym.coordinates.longitude),
          infoWindow: InfoWindow(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => GymWidget(
                        gym,
                        this.widget.user,
                        widget.updateUserCallback,
                        widget.signIn,
                        widget.signInProviderSet)),
              );
            },
            title: gym.name,
            snippet: gym.city,
          ),
        );
        _markers[gym.coordinates.toString()] = marker;
      }

      if (mapController != null)
        mapController.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(
                    widget.coordinates.latitude, widget.coordinates.longitude),
                zoom: 10.0)));
    });
  }

  @override
  Widget build(BuildContext context) {
    createMarkers();
    final ThemeData themeData = Theme.of(context);

    return Stack(children: <Widget>[
      GoogleMap(
        onMapCreated: (GoogleMapController controller) async {
          mapController = controller;
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        compassEnabled: true,
        initialCameraPosition: CameraPosition(
          target:
              LatLng(widget.coordinates.latitude, widget.coordinates.longitude),
          zoom: 10,
        ),
        markers: Set<Marker>.of(_markers.values),
      ),
      //SEARCH THIS AREA action button
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
              height: 33.0,
              child: FloatingActionButton.extended(
                backgroundColor: themeData.scaffoldBackgroundColor,
                foregroundColor: themeData.textTheme.bodyText2.color,
                onPressed: () {
                  mapController
                      .getVisibleRegion()
                      .then((LatLngBounds latLngBounds) {
                    widget.setCoordinates(_getCenterCoordinates(latLngBounds));
                    widget.refreshIndicatorKey.currentState?.show();
                  });
                },
                label: Text(
                  S.of(context).searchThisArea,
                  style: TextStyle(letterSpacing: 0.3),
                ),
              )),
        ),
      )
    ]);
  }
}

Coordinates _getCenterCoordinates(LatLngBounds latLngBounds) {
  return Coordinates(
      (latLngBounds.southwest.latitude + latLngBounds.northeast.latitude) / 2,
      (latLngBounds.southwest.longitude + latLngBounds.northeast.longitude) /
          2);
}

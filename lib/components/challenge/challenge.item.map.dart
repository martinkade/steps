import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gpx/gpx.dart';
import 'package:wandr/components/shared/loading.indicator.dart';
import 'package:wandr/model/fit.challenge.dart';
import 'package:latlong2/latlong.dart';

class ChallengeMap extends StatefulWidget {
  ///
  final FitChallenge challenge;

  ///
  ChallengeMap({Key key, this.challenge}) : super(key: key);

  @override
  _ChallengeMapState createState() => _ChallengeMapState();
}

class _ChallengeMapState extends State<ChallengeMap> {
  bool _loading = true;

  Polyline _polyline;
  Marker _marker;
  LatLngBounds _bounds;
  List<LatLngDistance> _polylinePoints = [];

  MapController mapController;
  bool currentPositionZoomed = false;

  Future<Polyline> getPolyline() async {
    final String gpxContent = await DefaultAssetBundle.of(context)
        .loadString(widget.challenge.routeAsset);
    final Gpx gpx = GpxReader().fromString(gpxContent);
    final Distance distance = Distance();

    LatLngDistance lastPoint;
    double lastDistance = 0.0;
    if (gpx.wpts.isNotEmpty) {
      for (Wpt point in gpx.wpts) {
        LatLngDistance currentPoint = LatLngDistance(point.lat, point.lon);
        if (lastPoint != null) {
          lastDistance +=
          (distance.as(LengthUnit.Meter, currentPoint, lastPoint) / 1000.0);
        }
        currentPoint.distanceFromStart = lastDistance;
        _polylinePoints.add(currentPoint);
        lastPoint = currentPoint;
      }
    } else if (gpx.trks.isNotEmpty) {
      for (Trk trk in gpx.trks) {
        for (Trkseg treks in trk.trksegs) {
          for (Wpt point in treks.trkpts) {
            LatLngDistance currentPoint = LatLngDistance(point.lat, point.lon);
            if (lastPoint != null) {
              lastDistance +=
              (distance.as(LengthUnit.Meter, currentPoint, lastPoint) / 1000.0);
            }
            currentPoint.distanceFromStart = lastDistance;
            _polylinePoints.add(currentPoint);
            lastPoint = currentPoint;
          }
        }
      }
    }

    if (gpx.metadata.bounds != null) {
      _bounds = LatLngBounds(
          LatLng(gpx.metadata.bounds.maxlat, gpx.metadata.bounds.maxlon),
          LatLng(gpx.metadata.bounds.minlat, gpx.metadata.bounds.minlon));
    } else {
      _bounds = LatLngBounds.fromPoints(_polylinePoints);
    }

    return Polyline(
      points: _polylinePoints,
      strokeWidth: 4.0,
      color: Colors.blue,
    );
  }

  @override
  void initState() {
    super.initState();

    mapController = MapController();
    _loadPolyline();
  }

  void _loadPolyline() {
    if (_polyline == null) {
      setState(() {
        _loading = true;
      });
    }

    getPolyline().then((polyline) {
      if (!mounted) return;
      _polyline = polyline;
      initMarker();
      setState(() {
        _loading = false;
      });
    });
  }

  void initMarker() async {
    if (_polylinePoints.isEmpty) {
      return null;
    }

    final double ratio =
        _polylinePoints.last.distanceFromStart / widget.challenge.target;
    final double currentProgress =
        min(ratio * widget.challenge.target, ratio * widget.challenge.progress);

    LatLngDistance currentProgressPoint = _polylinePoints
        .firstWhere((element) => element.distanceFromStart >= currentProgress);
    _marker = Marker(
      width: 48.0,
      height: 48.0,
      point: currentProgressPoint,
      anchorPos: AnchorPos.align(AnchorAlign.top),
      builder: (ctx) => new Container(
        child: Image.asset('assets/images/map_marker.png', color: Colors.blue),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? LoadingIndicator()
        : new Stack(children: <Widget>[
            FlutterMap(
              mapController: mapController,
              options: MapOptions(
                  bounds: _bounds,
                  boundsOptions:
                      FitBoundsOptions(padding: EdgeInsets.all(14.0))),
              layers: [
                PolylineLayerOptions(
                    polylines: _polyline != null ? [_polyline] : []),
                MarkerLayerOptions(markers: _marker != null ? [_marker] : [])
              ],
              children: <Widget>[
                TileLayerWidget(
                    options: TileLayerOptions(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.de/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                  attributionBuilder: (_) {
                    return Text(
                      "© OpenStreetMap contributors",
                      style: TextStyle(color: Colors.black),
                    );
                  },
                )),
              ],
            ),
            new Align(
              alignment: Alignment.bottomRight,
              child: Container(
                padding: EdgeInsets.fromLTRB(0, 0, 8, 16),
                width: 50.0,
                height: 58.0,
                child: FloatingActionButton(
                    child: currentPositionZoomed
                        ? Icon(
                            Icons.zoom_out_map_rounded,
                            color: Colors.white,
                          )
                        : Image.asset('assets/images/map_marker.png',
                            color: Colors.white, width: 30.0),
                    onPressed: () {
                      if (currentPositionZoomed && _bounds != null) {
                        mapController.rotate(0);
                        mapController.fitBounds(_bounds);
                        setState(() {
                          currentPositionZoomed = false;
                        });
                      } else if (_marker != null) {
                        mapController.moveAndRotate(_marker.point, 14.0, 0);
                        setState(() {
                          currentPositionZoomed = true;
                        });
                      }
                    }),
              ),
            )
          ]);
  }
}

class LatLngDistance extends LatLng {
  LatLngDistance(double latitude, double longitude)
      : super(latitude, longitude);

  double distanceFromStart = 0;
}

import 'dart:async';
import 'dart:convert';
import 'package:dima_app/server/tables/location.dart';
import 'package:dima_app/widgets/gmaps.dart';
import 'package:dima_app/widgets/loading_spinner.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class SelectLocationAddress extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> setAddress;
  final ValueChanged<List<double>> setCoor;
  final Location defaultLocation;
  final FocusNode focusNode;
  const SelectLocationAddress({
    super.key,
    required this.controller,
    required this.setAddress,
    required this.setCoor,
    required this.defaultLocation,
    required this.focusNode,
  });

  @override
  State<SelectLocationAddress> createState() => _SelectLocationAddressState();
}

class _SelectLocationAddressState extends State<SelectLocationAddress> {
  List<Map<String, dynamic>> locationSuggestions = [];
  Timer? _debounce;
  bool loadingLocations = false;
  bool showMap = false;
  double lat = 0;
  double lon = 0;

  String nullableProperty(obj, property) {
    return (obj.containsKey(property) ? obj[property].toString() : "");
  }

  @override
  void initState() {
    super.initState();
    if (widget.defaultLocation.lat != 0 && widget.defaultLocation.lon != 0) {
      showMap = true;
      lat = widget.defaultLocation.lat;
      lon = widget.defaultLocation.lon;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    showMap = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Container(
            margin: const EdgeInsets.only(bottom: 8, top: 8),
            alignment: Alignment.topLeft,
            child: Text(
              "Address",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          horizontalTitleGap: 0,
          subtitle: TextFormField(
            decoration: InputDecoration(
              hintText: "Search here",
              isDense: true,
              suffixIcon: IconButton(
                iconSize: 25,
                onPressed: () {
                  setState(() {
                    widget.setAddress("");
                    locationSuggestions = [];
                    showMap = false;
                  });
                },
                icon: Icon(widget.controller.text.isEmpty
                    ? Icons.search
                    : Icons.cancel),
              ),
              border: InputBorder.none,
            ),
            autofocus: false,
            focusNode: widget.focusNode,
            controller: widget.controller,
            onChanged: (text) async {
              if (text.isEmpty) {
                setState(() {
                  showMap = false;
                  locationSuggestions = [];
                  loadingLocations = false;
                });
                return;
              }
              // https://stackoverflow.com/questions/51791501/how-to-debounce-textfield-onchange-in-dart
              if (_debounce?.isActive ?? false) _debounce?.cancel();
              _debounce = Timer(const Duration(milliseconds: 300), () async {
                // var countrycode = WidgetsBinding.instance.window.locale.countryCode;
                // &countrycodes=$countrycode
                setState(() {
                  loadingLocations = true;
                });
                var test = await http.get(
                  Uri.parse(
                      'https://nominatim.openstreetmap.org/search/$text?format=json&addressdetails=1&limit=10'),
                );
                var res = jsonDecode(test.body);
                if (res.length > 0) {
                  setState(() {
                    showMap = false;
                    locationSuggestions = List<Map<String, dynamic>>.from(
                      res.map((obj) {
                        String city = nullableProperty(obj["address"], "city");
                        String state =
                            nullableProperty(obj["address"], "state");
                        String country =
                            nullableProperty(obj["address"], "country");
                        String subtitle = "$city, $state $country";
                        subtitle = subtitle.substring(0, 2) == ", "
                            ? subtitle.substring(2)
                            : subtitle;

                        String houseNumber =
                            nullableProperty(obj["address"], "house_number");
                        houseNumber = houseNumber == "" ? "" : ", $houseNumber";
                        String title = nullableProperty(obj["address"], "road");
                        title = title == ""
                            ? obj["display_name"]
                            : "$title$houseNumber";
                        var newObj = {
                          "title": title,
                          "subtitle": subtitle,
                          "lat": double.parse(obj["lat"]),
                          "lon": double.parse(obj["lon"]),
                        };
                        return newObj;
                      }),
                    );
                    loadingLocations = false;
                  });
                } else {
                  setState(() {
                    showMap = false;
                    locationSuggestions = [];
                    loadingLocations = false;
                    widget.setCoor([0, 0]);
                  });
                }
              });
            },
          ),
        ),
        if (showMap)
          GmapFromCoor(lat: lat, lon: lon, address: widget.controller.text)
        else
          loadingLocations
              ? const LoadingSpinner()
              : Column(
                  children: [
                    for (var i = 0; i < locationSuggestions.length; i++)
                      Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              width: 1.0,
                            ),
                          ),
                        ),
                        child: ListTile(
                          title: Text(
                            locationSuggestions[i]["title"]!,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            locationSuggestions[i]["subtitle"]!,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: const Icon(Icons.north_west),
                          onTap: () {
                            setState(() {
                              widget
                                  .setAddress(locationSuggestions[i]["title"]!);
                              lat = locationSuggestions[i]["lat"];
                              lon = locationSuggestions[i]["lon"];
                              widget.setCoor([lat, lon]);
                              locationSuggestions = [];
                              showMap = true;
                              loadingLocations = false;
                            });
                          },
                        ),
                      ),
                  ],
                )
      ],
    );
  }
}

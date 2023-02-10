import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class LocationCategory extends StatefulWidget {
  final Function onSelectLocationCategory;
  final String? previousLocationCategory;

  const LocationCategory({
    super.key,
    required this.onSelectLocationCategory,
    this.previousLocationCategory,
  });

  @override
  State<LocationCategory> createState() => _LocationCategoryState();
}

class _LocationCategoryState extends State<LocationCategory> {
  @override
  void initState() {
    //if we have a previous category, set it as the initial value
    //of the search bar and the selected category
    if (widget.previousLocationCategory != null &&
        widget.previousLocationCategory != 'No location category chosen') {
      _selectedLocationCategory = widget.previousLocationCategory!;
      _searchController.text = _selectedLocationCategory;
    }
    super.initState();
  }

  String? _searchType;
  final _searchController = TextEditingController();
  final List<String> _locationCategories = [
    "accounting",
    "airport",
    "amusement_park",
    "aquarium",
    "art_gallery",
    "atm",
    "bakery",
    "bank",
    "bar",
    "beauty_salon",
    "bicycle_store",
    "book_store",
    "bowling_alley",
    "bus_station",
    "cafe",
    "campground",
    "car_dealer",
    "car_rental",
    "car_repair",
    "car_wash",
    "casino",
    "cemetery",
    "church",
    "city_hall",
    "clothing_store",
    "convenience_store",
    "courthouse",
    "dentist",
    "department_store",
    "doctor",
    "electrician",
    "electronics_store",
    "embassy",
    "fire_station",
    "florist",
    "funeral_home",
    "furniture_store",
    "gas_station",
    "grocery_or_supermarket",
    "gym",
    "hair_care",
    "hardware_store",
    "hindu_temple",
    "home_goods_store",
    "hospital",
    "insurance_agency",
    "jewelry_store",
    "laundry",
    "lawyer",
    "library",
    "liquor_store",
    "local_government_office",
    "locksmith",
    "lodging",
    "meal_delivery",
    "meal_takeaway",
    "mosque",
    "movie_rental",
    "movie_theater",
    "moving_company",
    "museum",
    "night_club",
    "painter",
    "park",
    "parking",
    "pet_store",
    "pharmacy",
    "physiotherapist",
    "plumber",
    "police",
    "post_office",
    "real_estate_agency",
    "restaurant",
    "roofing_contractor",
    "rv_park",
    "school",
    "shoe_store",
    "shopping_mall",
    "spa",
    "stadium",
    "storage",
    "store",
    "subway_station",
    "supermarket",
    "synagogue",
    "taxi_stand",
    "train_station",
    "transit_station",
    "travel_agency",
    "university",
    "veterinary_care",
    "zoo"
  ];
  String _selectedLocationCategory = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "Search location category",
      ),
      content: SizedBox(
        height: 250,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              child: TypeAheadField(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Type',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _handleSearch,
                    ),
                  ),
                ),
                // These are the suggestions that will be shown
                suggestionsCallback: (pattern) {
                  return _locationCategories
                      .where((category) => category.contains(pattern))
                      .toList();
                },
                itemBuilder: (context, suggestion) {
                  // Each suggestion will be displayed using this builder
                  return ListTile(
                    leading: const Icon(Icons.location_on),
                    title: Text(suggestion),
                  );
                },
                // This is the function that will be called when a suggestion is selected
                onSuggestionSelected: (suggestion) {
                  setState(() {
                    //set the selected category and the search bar text
                    _selectedLocationCategory = suggestion;
                    _searchController.text = suggestion;
                    //call the function that will be used to set the category
                    widget.onSelectLocationCategory(suggestion);
                  });
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            //call the function that will be used to set the category
            widget.onSelectLocationCategory(_selectedLocationCategory);
            Navigator.of(context).pop();
          },
          child: const Text("Ok"),
        ),
      ],
    );
  }

  void _handleSearch() {
    //Get the search text
    _searchType = _searchController.text;

    //Search in the list of categories to see if the search text is a valid category
    if (_locationCategories.contains(_searchType)) {
      setState(() {
        //set the selected category and the search bar text
        _selectedLocationCategory = _searchType!;
        _searchController.text = _searchType!;
        //call the function that will be used to set the category
        widget.onSelectLocationCategory(_selectedLocationCategory);
      });
    } else {
      setState(() {
        //if the search text is not a valid category, set the selected category to empty
        _selectedLocationCategory = '';
      });
    }
  }
}

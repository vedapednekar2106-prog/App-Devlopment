import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'destination_details_screen.dart';
import 'bucket_list_screen.dart'; // Make sure BucketListManager is imported from here

class PlacesToVisitScreen extends StatefulWidget {
  const PlacesToVisitScreen({super.key});

  @override
  State<PlacesToVisitScreen> createState() => _PlacesToVisitScreenState();
}

class _PlacesToVisitScreenState extends State<PlacesToVisitScreen> {
  List<String> countries = [];
  List<String> filteredCountries = [];
  Map<int, Map<String, String>> placeData = {};
  bool isLoading = true;

  static const String _pexelsApiKey =
      'HOgbTEgVwLOd5pu939zOooVSEhev40kh9bZSiUS379GJrIPnUpBOmmWW';

  @override
  void initState() {
    super.initState();
    fetchCountries();
  }

  Future<void> fetchCountries() async {
    final url = Uri.parse('https://restcountries.com/v3.1/all?fields=name');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        final tempCountries = data
            .map<String>((e) => (e['name']?['common'] ?? 'Unknown').toString())
            .where((name) => name.toLowerCase() != 'mexico')
            .toList();
        setState(() {
          countries = tempCountries.take(50).toList();
          filteredCountries = countries;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching countries: $e");
      setState(() => isLoading = false);
    }
  }

  Future<Map<String, String>> fetchPlaceInfo(String country, int index) async {
    if (placeData.containsKey(index)) return placeData[index]!;

    String imageUrl = 'https://via.placeholder.com/150?text=No+Image';
    String placeName = country;

    try {
      final pexelsUrl = Uri.parse(
          'https://api.pexels.com/v1/search?query=${Uri.encodeComponent(country + " tourist")}&per_page=1');
      final resp =
          await http.get(pexelsUrl, headers: {"Authorization": _pexelsApiKey});
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        final photos = data['photos'] as List;
        if (photos.isNotEmpty) {
          imageUrl = photos[0]['src']['medium'];
          placeName = photos[0]['alt'] ?? country;
        }
      }
    } catch (e) {
      print("Error fetching image for $country: $e");
    }

    placeData[index] = {'image': imageUrl, 'placeName': placeName};
    return placeData[index]!;
  }

  void filterSearch(String query) {
    final results = query.isEmpty
        ? countries
        : countries
            .where((c) => c.toLowerCase().contains(query.trim().toLowerCase()))
            .toList();

    setState(() {
      filteredCountries = results;
    });
  }

  void addToBucketListLocal(String country, String imageUrl, String placeName) {
    final manager = BucketListManager();

    if (manager.places.any((p) => p["name"] == country)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$country is already in your bucket list")),
      );
      return;
    }

    manager.addPlace({
      "name": country,
      "description": placeName,
      "image": imageUrl,
      "visited": false,
      "favorite": false,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.black87,
        content: Text("$country added to your bucket list!",
            style: const TextStyle(color: Colors.white)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF8F3),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Destinations",
          style: TextStyle(
              fontWeight: FontWeight.w700, fontSize: 18, color: Colors.black87),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.deepOrange))
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: TextField(
                      onChanged: filterSearch,
                      decoration: InputDecoration(
                        hintText: 'Search for a destination...',
                        prefixIcon: const Icon(Icons.search),
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  if (filteredCountries.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        "Destination coming soon 😎",
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    ),
                  if (filteredCountries.isNotEmpty)
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.only(top: 10, bottom: 20),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.65,
                        ),
                        itemCount: filteredCountries.length,
                        itemBuilder: (context, index) {
                          final country = filteredCountries[index];
                          return FutureBuilder<Map<String, String>>(
                            future: fetchPlaceInfo(country, index),
                            builder: (context, snapshot) {
                              final imageUrl = snapshot.data?['image'] ??
                                  'https://via.placeholder.com/150?text=Loading';
                              final placeName =
                                  snapshot.data?['placeName'] ?? country;

                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          DestinationDetailsScreen(
                                              countryName: country),
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(16),
                                          topRight: Radius.circular(16),
                                        ),
                                        child: Image.network(
                                          imageUrl,
                                          height: 140,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Icon(Icons.location_on,
                                                      size: 50,
                                                      color: Colors.grey),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                country,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                    color: Colors.black87),
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                placeName,
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black54),
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                              ),
                                              const Spacer(),
                                              SizedBox(
                                                width: double.infinity,
                                                height: 36,
                                                child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        const Color(0xFFFFE8D5),
                                                    elevation: 0,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                  ),
                                                  onPressed: () => addToBucketListLocal(
                                                      country,
                                                      imageUrl,
                                                      placeName),
                                                  child: const Text(
                                                    "+ Add to List",
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: Color(0xFFFF8C00),
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
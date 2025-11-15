// ================= explore_detail_screen.dart =================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

// NOTE: You must also ensure explore_extras.dart and place_coordinates.dart 
// are correctly imported/accessible. Assuming they are in the same folder.
// Since you provided the content of those files, I will include them at the end.

class ExploreDetailScreen extends StatefulWidget {
  final Map<String, String> place;
  const ExploreDetailScreen({super.key, required this.place});

  @override
  State<ExploreDetailScreen> createState() => _ExploreDetailScreenState();
}

class _ExploreDetailScreenState extends State<ExploreDetailScreen> {
  String temperature = "--";
  String weatherDescription = "--";
  LatLng placeLatLng = const LatLng(0, 0); // Placeholder

  @override
  void initState() {
    super.initState();
    fetchWeather();
    setPlaceCoordinates();
  }

  void fetchWeather() async {
    final apiKey = "9b272f3f61d4d47daa7a661519a4d15f"; // Replace with your key
    final url =
        "https://api.openweathermap.org/data/2.5/weather?q=${widget.place["title"]}&appid=$apiKey&units=metric";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          temperature = "${data["main"]["temp"].round()}°C";
          weatherDescription = data["weather"][0]["description"];
        });
      } else {
        setState(() {
          temperature = "--";
          weatherDescription = "Unavailable";
        });
      }
    } catch (e) {
      setState(() {
        temperature = "--";
        weatherDescription = "Unavailable";
      });
    }
  }

  void setPlaceCoordinates() {
    final coords = placeCoordinates[widget.place["title"]!] ?? LatLng(0, 0);
    setState(() {
      placeLatLng = coords;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Assuming exploreExtras is globally accessible or imported.
    final placeName = widget.place["title"]!;
    // Note: The logic for getting placeData assumes exploreExtras is defined.
    // If you haven't placed the explore_extras.dart content globally or imported it, this line might fail.
    final placeData = exploreExtras[placeName]!; 


    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          placeName,
          style: GoogleFonts.poppins(
              color: Colors.black87, fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            // *** FIX: Changed Image.network to Image.asset ***
            child: Image.asset(
              widget.place["image"]!,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Asset error builder for safety
                return Container(
                    height: 220,
                    color: Colors.grey.shade300,
                    child: const Center(
                        child: Text("Image Not Found (Asset Error)",
                            style: TextStyle(color: Colors.black54))));
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(widget.place["subtitle"]!,
              style: GoogleFonts.poppins(
                  fontSize: 16, color: Colors.grey[700])),
          const SizedBox(height: 20),

          // Discover Button (Premium users)
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8C00),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Discover clicked for $placeName")),
                );
              },
              child: const Text(
                "Discover",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Weather Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Weather",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text("$temperature | $weatherDescription",
                        style: GoogleFonts.poppins(fontSize: 14)),
                  ],
                ),
                const Icon(Icons.wb_sunny, color: Colors.orange, size: 32),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // OpenStreetMap
          Container(
            height: 200,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            child: FlutterMap(
              options: MapOptions(
                initialCenter: placeLatLng,
                initialZoom: 12.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  userAgentPackageName: 'com.example.wanderlist_app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: placeLatLng,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Hidden Gems
          const Text("💎Hidden Gems:", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          ...List<Widget>.from(placeData["hiddenGems"]
              .map((e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text("• $e"),
                  ))),

          const SizedBox(height: 16),
          // Local Tips
          const Text("📝Local Tips:", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          ...List<Widget>.from(placeData["localTips"]
              .map((e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text("• $e"),
                  ))),

          const SizedBox(height: 16),
          // Itinerary
          const Text("📅Itinerary:", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          ...List<Widget>.from(placeData["itinerary"]
              .map((e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text("• $e"),
                  ))),

          const SizedBox(height: 16),
          // Local Food
          const Text("🥣Local Food:", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          ...List<Widget>.from(placeData["localFood"]
              .map((e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text("• $e"),
                  ))),
          const SizedBox(height: 16), // Extra spacing at the bottom
        ],
      ),
    );
  }
}

// NOTE: Please ensure the following data maps are either in a separate file and imported, 
// or defined globally (e.g., in main.dart or in this file if structured differently). 
// I am including them here for completeness based on your provided code structure.

// ================= explore_extras.dart content =================
final Map<String, Map<String, dynamic>> exploreExtras = {
"Bali, Indonesia": {
"hiddenGems": ["Ubud Monkey Forest", "Tegalalang Rice Terrace", "Tirta Empul Temple"],
"localTips": ["Try Nasi Campur at local warung", "Sunset at Uluwatu Temple"],
"itinerary": [
  "Day 1: Ubud & Rice Terraces",
  "Day 2: Seminyak Beach & Spa",
  "Day 3: Tanah Lot Temple & Markets",
  "Day 4: Nusa Penida Island Tour",
  "Day 5: Mount Batur Sunrise Hike"
],
"localFood": ["Lawar 🍛", "Mie Goreng 🍜", "Sate Lilit 🍢"]
},
"Swiss Alps, Switzerland": {
"hiddenGems": ["Zermatt Village", "Gornergrat Railway", "Lake Oeschinen"],
"localTips": ["Wear layers, weather changes fast", "Try Swiss fondue"],
"itinerary": [
  "Day 1: Zermatt & Matterhorn",
  "Day 2: Glacier Express",
  "Day 3: Hiking trails around Interlaken",
  "Day 4: Jungfraujoch & Ice Palace",
  "Day 5: Lake Lucerne & Chapel Bridge"
],
"localFood": ["Swiss Cheese Fondue 🧀", "Rösti 🥔", "Raclette 🧀"]
},
"Kyoto, Japan": {
"hiddenGems": ["Fushimi Inari Shrine", "Arashiyama Bamboo Forest", "Nishiki Market"],
"localTips": ["Try matcha sweets", "Visit temples early morning for less crowd"],
"itinerary": [
  "Day 1: Gion & Temples",
  "Day 2: Bamboo Forest & Arashiyama",
  "Day 3: Nishiki Market & Tea Ceremony",
  "Day 4: Kiyomizu-dera & Philosopher's Path",
  "Day 5: Nijo Castle & Kyoto Imperial Palace"
],
"localFood": ["Kaiseki 🍱", "Yudofu 🍲", "Matcha Desserts 🍵"]
},
"Paris, France": {
"hiddenGems": ["Montmartre alleys", "Canal Saint-Martin", "Palais-Royal Gardens"],
"localTips": ["Try croissants from local boulangeries", "Visit Louvre late afternoon"],
"itinerary": [
  "Day 1: Eiffel Tower & Seine",
  "Day 2: Louvre & Montmartre",
  "Day 3: Versailles or hidden gems tour",
  "Day 4: Notre-Dame & Latin Quarter",
  "Day 5: Musée d'Orsay & Champs-Élysées"
],
"localFood": ["Croissants 🥐", "Escargots 🐌", "Coq au Vin 🍗"]
},
"Machu Picchu, Peru": {
"hiddenGems": ["Inca Trail", "Huayna Picchu hike", "Aguas Calientes town"],
"localTips": ["Acclimatize in Cusco first", "Hire local guide for history insights"],
"itinerary": [
  "Day 1: Cusco exploration",
  "Day 2: Machu Picchu hike",
  "Day 3: Sacred Valley tour",
  "Day 4: Ollantaytambo & local markets",
  "Day 5: Maras Salt Mines & Moray"
],
"localFood": ["Ceviche 🐟", "Lomo Saltado 🥩", "Alpaca Steak 🥩"]
},
"Santorini, Greece": {
"hiddenGems": ["Oia sunset alleys", "Fira cliff walk", "Akrotiri ruins"],
"localTips": ["Try local wines 🍷", "Book sunset spot in advance"],
"itinerary": [
  "Day 1: Fira town & beaches",
  "Day 2: Oia sunset & photo spots",
  "Day 3: Akrotiri ruins & wine tasting",
  "Day 4: Pyrgos & local villages",
  "Day 5: Red Beach & boat tour"
],
"localFood": ["Fava 🍲", "Tomatokeftedes 🍅", "Fresh Seafood 🦞"]
},
"Rocky Mountains, USA": {
"hiddenGems": ["Bear Lake Trail", "Emerald Lake", "Trail Ridge Road"],
"localTips": ["Early morning hikes avoid crowds", "Carry bear spray in some areas"],
"itinerary": [
  "Day 1: Estes Park & Bear Lake",
  "Day 2: Trail Ridge Road scenic drive",
  "Day 3: Hiking around lakes",
  "Day 4: Alberta Falls & Bear Lake Loop",
  "Day 5: Grand Lake & Shadow Mountain Lake"
],
"localFood": ["Rocky Mountain Oysters 🦪", "Trout dishes 🐟", "Colorado Lamb 🥩"]
},
"Maldives": {
"hiddenGems": ["Private island resorts", "Local sandbanks", "Snorkeling spots"],
"localTips": ["Try fresh seafood at local islands", "Avoid peak monsoon"],
"itinerary": [
  "Day 1: Resort & Beach relaxation",
  "Day 2: Snorkeling & Diving",
  "Day 3: Island hopping & spa",
  "Day 4: Submarine tour & Dolphin watching",
  "Day 5: Sunset cruise & local market visit"
],
"localFood": ["Mas Huni 🐟", "Garudhiya 🍲", "Fihunu Mas 🐟"]
},
"Rome, Italy": {
"hiddenGems": ["Trastevere alleys", "Campo de' Fiori market", "Villa Borghese Gardens"],
"localTips": ["Try gelato from artisanal shops", "Visit Colosseum early"],
"itinerary": [
  "Day 1: Colosseum & Roman Forum",
  "Day 2: Vatican & St Peter's Basilica",
  "Day 3: Trastevere & hidden gems",
  "Day 4: Pantheon & Piazza Navona",
  "Day 5: Castel Sant'Angelo & Tiber walk"
],
"localFood": ["Carbonara 🍝", "Supplì 🍚", "Artichokes alla Romana 🥬"]
},
"Great Wall of China": {
"hiddenGems": ["Mutianyu section", "Jinshanling hiking", "Local villages nearby"],
"localTips": ["Go early to avoid crowds", "Wear comfortable shoes for climbing"],
"itinerary": [
  "Day 1: Beijing highlights",
  "Day 2: Great Wall hike",
  "Day 3: Explore nearby villages",
  "Day 4: Summer Palace & Temple of Heaven",
  "Day 5: Beijing Hutongs & local markets"
],
"localFood": ["Peking Duck 🦆", "Jianbing 🥞", "Dumplings 🥟"]
},
"New York City, USA": {
"hiddenGems": ["DUMBO Brooklyn", "High Line", "Roosevelt Island"],
"localTips": ["Try street food from carts", "Use subway to save time"],
"itinerary": [
  "Day 1: Manhattan landmarks",
  "Day 2: Brooklyn & Museums",
  "Day 3: Central Park & neighborhoods",
  "Day 4: Statue of Liberty & Ellis Island",
  "Day 5: Times Square & Broadway Show"
],
"localFood": ["New York Pizza 🍕", "Bagels 🥯", "Pastrami Sandwich 🥪"]
},
"London, UK": {
"hiddenGems": ["Camden Market", "Shoreditch street art", "Little Venice"],
"localTips": ["Take an Oyster card for public transport", "Try local pubs for food"],
"itinerary": [
  "Day 1: Westminster & Big Ben",
  "Day 2: Museums & Camden Market",
  "Day 3: Shoreditch & Hidden Gems",
  "Day 4: Tower of London & Thames Cruise",
  "Day 5: Greenwich & Observatorium"
],
"localFood": ["Fish & Chips 🐟", "Sunday Roast 🍖", "Full English Breakfast 🍳"]
},
};

// ================= place_coordinates.dart content =================

final Map<String, LatLng> placeCoordinates = {
"Bali, Indonesia": LatLng(-8.3405, 115.0920),
"Swiss Alps, Switzerland": LatLng(46.8182, 8.2275),
"Kyoto, Japan": LatLng(35.0116, 135.7681),
"Paris, France": LatLng(48.8566, 2.3522),
"Machu Picchu, Peru": LatLng(-13.1631, -72.5450),
"Santorini, Greece": LatLng(36.3932, 25.4615),
"Rocky Mountains, USA": LatLng(40.3428, -105.6836),
"Maldives": LatLng(3.2028, 73.2207),
"Rome, Italy": LatLng(41.9028, 12.4964),
"Great Wall of China": LatLng(40.4319, 116.5704),
"New York City, USA": LatLng(40.7128, -74.0060),
"London, UK": LatLng(51.5074, -0.1278),
};
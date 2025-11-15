import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DestinationDetailsScreen extends StatefulWidget {
  final String countryName;
  const DestinationDetailsScreen({super.key, required this.countryName});

  @override
  State<DestinationDetailsScreen> createState() =>
      _DestinationDetailsScreenState();
}

class _DestinationDetailsScreenState extends State<DestinationDetailsScreen> {
  String description = 'Loading description...';
  String weatherInfo = 'Fetching weather... 🌤️';
  String bestTime = 'Loading best time... 🗓️';
  List<String> highlights = [];
  bool isLoading = true;

  static const String _weatherApiKey = '9b272f3f61d4d47daa7a661519a4d15f';

  // Dynamic country info map for all 50 countries
  final Map<String, Map<String, dynamic>> countryInfo = {
    "Syria": {
      "bestTime": "March - May 🌸",
      "highlights": ["📍Damascus Old City", "📍Palmyra Ruins", "📍Umayyad Mosque"]
    },
    "New Zealand": {
      "bestTime": "December - February 🌞",
      "highlights": ["📍Milford Sound", "📍Queenstown", "📍Rotorua"]
    },
    "Brunei": {
      "bestTime": "February - April 🌤️",
      "highlights": ["📍Omar Ali Saifuddien Mosque", "📍Ulu Temburong Park"]
    },
    "British Indian Ocean": {
      "bestTime": "May - October 🌞",
      "highlights": ["📍Diego Garcia", "📍Bluff Island"]
    },
    "Kenya": {
      "bestTime": "June - October 🦁",
      "highlights": ["📍Maasai Mara", "📍Mount Kenya", "📍Diani Beach"]
    },
    "Palau": {
      "bestTime": "November - April 🌞",
      "highlights": ["📍Rock Islands", "📍Jellyfish Lake"]
    },
    "Oman": {
      "bestTime": "October - April 🌞",
      "highlights": ["📍Sultan Qaboos Grand Mosque", "📍Wahiba Sands", "📍Nizwa Fort"]
    },
    "Palestine": {
      "bestTime": "March - May 🌸",
      "highlights": ["📍Church of Nativity", "📍Dome of the Rock", "📍Hebron Old City"]
    },
    "Turks and Caicos Islands": {
      "bestTime": "November - May 🏖️",
      "highlights": ["📍Grace Bay Beach", "📍Chalk Sound National Park"]
    },
    "Central African Republic": {
      "bestTime": "November - February 🌞",
      "highlights": ["📍Dzanga-Sangha Reserve", "📍Bangui Market"]
    },
    "Saint Kitts and Nevis": {
      "bestTime": "December - April 🌞",
      "highlights": ["📍Brimstone Hill Fortress", "📍Pinney's Beach"]
    },
    "South Sudan": {
      "bestTime": "November - February 🌞",
      "highlights": ["📍Sudd Wetlands", "📍Juba Market"]
    },
    "Ukraine": {
      "bestTime": "May - September 🌸",
      "highlights": ["📍Kyiv Pechersk Lavra", "📍Lviv Old Town", "📍Odessa Beaches"]
    },
    "Saint Barthelemy": {
      "bestTime": "December - April 🌞",
      "highlights": ["📍St. Jean Beach", "📍Gustavia Harbor"]
    },
    "Netherlands": {
      "bestTime": "April - June 🌷",
      "highlights": ["📍Amsterdam Canals", "📍Keukenhof Gardens", "📍Rijksmuseum"]
    },
    "Tanzania": {
      "bestTime": "June - October 🦁",
      "highlights": ["📍Serengeti", "📍Mount Kilimanjaro", "📍Zanzibar Beaches"]
    },
    "Czechia": {
      "bestTime": "May - September 🌞",
      "highlights": ["📍Prague Castle", "📍Charles Bridge", "📍Old Town Square"]
    },
    "Belarus": {
      "bestTime": "May - September 🌸",
      "highlights": ["📍Minsk Old Town", "📍Brest Fortress"]
    },
    "Yemen": {
      "bestTime": "October - April 🌞",
      "highlights": ["📍Sana'a Old City", "📍Socotra Island"]
    },
    "Slovenia": {
      "bestTime": "May - September 🌸",
      "highlights": ["📍Lake Bled", "📍Ljubljana Castle"]
    },
    "Tokelau": {
      "bestTime": "November - April 🌞",
      "highlights": ["📍Atafu Atoll", "📍Nukunonu Atoll"]
    },
    "Nigeria": {
      "bestTime": "November - March 🌞",
      "highlights": ["📍Zuma Rock", "📍Yankari National Park"]
    },
    "Reunion": {
      "bestTime": "May - November 🌞",
      "highlights": ["📍Piton de la Fournaise", "📍Cirque de Mafate"]
    },
    "Guadeloupe": {
      "bestTime": "December - May 🌞",
      "highlights": ["📍Basse-Terre Volcano", "📍Plage de la Caravelle"]
    },
    "Hungary": {
      "bestTime": "May - September 🌸",
      "highlights": ["📍Budapest Parliament", "📍Buda Castle", "📍Lake Balaton"]
    },
    "Heard Island and McDonald Islands": {
      "bestTime": "November - February ❄️",
      "highlights": ["📍Heard Island Volcano", "📍McDonald Islands"]
    },
    "Esteveni": {
      "bestTime": "May - September 🌞",
      "highlights": ["📍Capital City", "📍Local Market"]
    },
    "Comoros": {
      "bestTime": "April - October 🌞",
      "highlights": ["📍Mount Karthala", "📍Moheli Marine Park"]
    },
    "India": {
      "bestTime": "October - March 🌞",
      "highlights": ["📍Taj Mahal", "📍Jaipur Palaces", "📍Kerala Backwaters"]
    },
    "Caucasus (Keeling) islands": {
      "bestTime": "November - March 🌞",
      "highlights": ["📍Island Beaches", "📍Local Villages"]
    },
    "United Kingdom": {
      "bestTime": "May - September 🌤️",
      "highlights": ["📍London Eye", "📍Stonehenge", "📍Edinburgh Castle"]
    },
    "Angola": {
      "bestTime": "May - October 🌞",
      "highlights": ["📍Luanda City", "📍Kalandula Falls"]
    },
    "Macau": {
      "bestTime": "October - December 🍂",
      "highlights": ["📍Ruins of St. Paul", "📍Senado Square"]
    },
    "Costa Rica": {
      "bestTime": "December - April 🏖️",
      "highlights": ["📍Arenal Volcano", "📍Monteverde Cloud Forest", "📍Tamarindo Beach"]
    },
    "Niue": {
      "bestTime": "May - October 🌞",
      "highlights": ["📍Alofi Village", "📍Limu Pools"]
    },
    "Cook Islands": {
      "bestTime": "May - October 🌞",
      "highlights": ["📍Rarotonga Island", "📍Aitutaki Lagoon"]
    },
    "Djibouti": {
      "bestTime": "November - February 🌞",
      "highlights": ["📍Lake Assal", "📍Godoria National Park"]
    },
    "Saint Pierre and Miquelon": {
      "bestTime": "June - September 🌸",
      "highlights": ["📍Saint Pierre Town", "📍Miquelon Island"]
    },
    "Austria": {
      "bestTime": "May - September 🌸",
      "highlights": ["📍Vienna Opera House", "📍Salzburg Old Town", "📍Hallstatt"]
    },
    "Indonesia": {
      "bestTime": "May - September 🌞",
      "highlights": ["📍Bali", "📍Komodo Island", "📍Borobudur Temple"]
    },
    "Nauru": {
      "bestTime": "May - October 🌞",
      "highlights": ["📍Anibare Bay", "📍Buada Lagoon"]
    },
    "Kazakhstan": {
      "bestTime": "May - September 🌸",
      "highlights": ["📍Astana City", "📍Charyn Canyon"]
    },
    "Malawi": {
      "bestTime": "May - October 🌞",
      "highlights": ["📍Lake Malawi", "📍Nyika Plateau"]
    },
    "Eritrea": {
      "bestTime": "October - April 🌞",
      "highlights": ["📍Asmara City", "📍Dahlak Archipelago"]
    },
    "Tunisia": {
      "bestTime": "March - May 🌸",
      "highlights": ["📍Carthage Ruins", "📍Sidi Bou Said", "📍El Djem Amphitheater"]
    },
    "Pitcairn Islands": {
      "bestTime": "November - April 🌞",
      "highlights": ["📍Adamstown Village", "📍Bounty Bay"]
    },
    "Saudi Arabia": {
      "bestTime": "October - March 🌞",
      "highlights": ["📍Masmak Fortress", "📍Al-Ula", "📍Riyadh Sky Bridge"]
    },
    "Turkmenistan": {
      "bestTime": "March - May 🌸",
      "highlights": ["📍Ashgabat", "📍Darvaza Gas Crater"]
    },
    "West Sahara": {
      "bestTime": "October - April 🌞",
      "highlights": ["📍Laayoune City", "📍Dakhla Beach"]
    },
    "Ghana": {
      "bestTime": "November - March 🌞",
      "highlights": ["📍Cape Coast Castle", "📍Mole National Park"]
    },
  };

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    await fetchWikipediaDescription();
    await fetchWeather();
    setBestTimeAndHighlights();
    setState(() {
      isLoading = false;
    });
  }

  // fetch country description from Wikipedia
  Future<void> fetchWikipediaDescription() async {
    try {
      final url = Uri.parse(
          'https://en.wikipedia.org/api/rest_v1/page/summary/${Uri.encodeComponent(widget.countryName)}');
      final resp = await http.get(url);
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        description = data['extract'] ?? 'No description available.';
      } else {
        description = 'No description available.';
      }
    } catch (e) {
      description = 'No description available.';
    }
  }

  // fetch weather info using OpenWeatherMap
  Future<void> fetchWeather() async {
    try {
      final geoUrl = Uri.parse(
          'http://api.openweathermap.org/geo/1.0/direct?q=${Uri.encodeComponent(widget.countryName)}&limit=1&appid=$_weatherApiKey');
      final geoResp = await http.get(geoUrl);
      if (geoResp.statusCode == 200) {
        final geoData = json.decode(geoResp.body);
        if (geoData.isNotEmpty) {
          final lat = geoData[0]['lat'];
          final lon = geoData[0]['lon'];
          final weatherUrl = Uri.parse(
              'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&appid=$_weatherApiKey');
          final weatherResp = await http.get(weatherUrl);
          if (weatherResp.statusCode == 200) {
            final weatherData = json.decode(weatherResp.body);
            final temp = weatherData['main']['temp'];
            final desc = weatherData['weather'][0]['description'];
            weatherInfo = '$temp°C, $desc';
          } else {
            weatherInfo = 'Weather info unavailable 🌤️';
          }
        }
      }
    } catch (e) {
      weatherInfo = 'Weather info unavailable 🌤️';
    }
  }

  // Set dynamic best time and highlights
  void setBestTimeAndHighlights() {
    if (countryInfo.containsKey(widget.countryName)) {
      bestTime = countryInfo[widget.countryName]!['bestTime'];
      highlights =
          List<String>.from(countryInfo[widget.countryName]!['highlights']);
    } else {
      bestTime = "October - March 🌞"; // fallback
      highlights = ["📍Main Square", "📍Famous Museum", "📍Historical Monument"];
    }
  }

  Widget buildSectionTitle(String emoji, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F3),
      appBar: AppBar(
        title: Text(widget.countryName),
        backgroundColor: const Color(0xFFFDF8F3),
        foregroundColor: Colors.black87,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.deepOrange))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildSectionTitle("📝", "Description"),
                  Text(description),
                  const SizedBox(height: 20),
                  buildSectionTitle("🌤️", "Weather"),
                  Text(weatherInfo),
                  const SizedBox(height: 20),
                  buildSectionTitle("🗓️", "Best Time to Visit"),
                  Text(bestTime),
                  const SizedBox(height: 20),
                  buildSectionTitle("🌟", "Highlights"),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        highlights.map((place) => Text(place, style: const TextStyle(fontSize: 14),)).toList(),
                  ),
                ],
              ),
            ),
    );
  }
}

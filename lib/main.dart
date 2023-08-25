import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(HavaDurumuApp());
}

class HavaDurumuApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hava Durumu Uygulaması',
      home: HavaDurumuAnaSayfa(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HavaDurumuAnaSayfa extends StatefulWidget {
  @override
  _HavaDurumuAnaSayfaState createState() => _HavaDurumuAnaSayfaState();
}

class _HavaDurumuAnaSayfaState extends State<HavaDurumuAnaSayfa> {
  List<WeatherData> weatherDataList = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    const apiKey = '2ca3a2b2666c90dd17b6121ef556ce0b';
    final cityList = [
      'Adana',
      'Ankara',
      'Antalya',
      'Aydın',
      'Balıkesir',
      'Bursa',
      'Denizli',
      'Diyarbakır',
      'Erzurum',
      'Eskişehir',
      'Gaziantep',
      'Hatay',
      'İstanbul',
      'İzmir',
      'Kahramanmaraş',
      'Kayseri',
      'Kocaeli',
      'Konya',
      'Malatya',
      'Manisa',
      'Mardin',
      'Mersin',
      'Muğla',
      'Ordu',
      'Sakarya',
      'Samsun',
      'Şanlıurfa',
      'Tekirdağ',
      'Trabzon',
      'Van',
    ]; // Örnek şehirler

    for (var city in cityList) {
      final apiUrl =
          'https://api.openweathermap.org/data/2.5/weather?q=$city,tr&appid=$apiKey&units=metric';
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final weatherData = WeatherData.fromJson(json.decode(response.body));
        setState(() {
          weatherDataList.add(weatherData);
        });
      } else {
        throw Exception('Hava durumu verisi alınamadı.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hava Durumu'),
        centerTitle: true,
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
        ),
        itemCount: weatherDataList.length,
        itemBuilder: (context, index) {
          return WeatherCard(weatherData: weatherDataList[index]);
        },
      ),
    );
  }
}

class WeatherCard extends StatelessWidget {
  final WeatherData weatherData;

  WeatherCard({required this.weatherData});

  IconData getWeatherIcon() {
    if (weatherData.weatherDescription.contains('cloud')) {
      return Icons.cloud; // Bulutlu ikon
    } else if (weatherData.weatherDescription.contains('clear')) {
      return Icons.wb_sunny; // Güneşli ikon
    } else if (weatherData.weatherDescription.contains('rain')) {
      return Icons.beach_access; // Yağmurlu ikon
    } else {
      return Icons.help_outline; // Diğer durumlar için soru işareti ikonu
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Icon(
              getWeatherIcon(),
              size: 35,
              color: Colors.blue,
            ),
          ),
          Text(
            weatherData.cityName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            weatherData.getTranslatedDescription(),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                '${weatherData.temperature.toString()}°C',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WeatherData {
  final String cityName;
  final double temperature;
  final String weatherDescription;

  WeatherData({
    required this.cityName,
    required this.temperature,
    required this.weatherDescription,
  });

  Map<String, String> weatherDescriptionTranslations = {
    'clear sky': 'Güneşli',
    'few clouds': 'Az Bulutlu',
    'scattered clouds': 'Parçalı Bulutlu',
    'broken clouds': 'Çok Bulutlu',
    'shower rain': 'Sağanak Yağışlı',
    'rain': 'Yağmurlu',
    'thunderstorm': 'Gök Gürültülü Fırtına',
    'snow': 'Karlı',
    'mist': 'Sisli',
  };

  String getTranslatedDescription() {
    final englishDescription = weatherDescription.toLowerCase();
    return weatherDescriptionTranslations[englishDescription] ??
        weatherDescription;
  }

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      cityName: json['name'],
      temperature: json['main']['temp'],
      weatherDescription: json['weather'][0]['description'],
    );
  }
}

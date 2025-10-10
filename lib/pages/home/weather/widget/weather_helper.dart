class WeatherHelper {
  static const _defaultDescription = 'N/A';
  static const _defaultIcon = 'assets/images/Cuaca Smart City Icon-01.png';

  static const Map<String, String> _typeTranslations = {
    'CLEAR': 'Cerah',
    'MOSTLY_CLEAR': 'Cerah',
    'PARTLY_CLOUDY': 'Berawan Sebagian',
    'MOSTLY_CLOUDY': 'Berawan',
    'CLOUDY': 'Berawan',
    'OVERCAST': 'Awan Mendung',
    'DRIZZLE': 'Hujan Gerimis',
    'LIGHT_RAIN': 'Hujan Ringan',
    'RAIN': 'Hujan',
    'HEAVY_RAIN': 'Hujan Lebat',
    'RAIN_SHOWERS': 'Hujan Lokal',
    'RAIN_SNOW': 'Hujan Salju',
    'FREEZING_RAIN': 'Hujan Beku',
    'THUNDERSTORM': 'Badai Petir',
    'THUNDERSTORMS': 'Badai Petir',
    'LIGHT_SNOW': 'Salju Ringan',
    'SNOW': 'Salju',
    'HEAVY_SNOW': 'Salju Lebat',
    'SLEET': 'Hujan Salju',
    'HAIL': 'Hujan Es',
    'FOG': 'Kabut',
    'MIST': 'Kabut',
    'HAZE': 'Kabut Asap',
    'SMOKE': 'Asap',
    'DUST': 'Debu',
    'SAND': 'Pasir',
    'ASH': 'Abu Vulkanik',
    'BLOWING_SNOW': 'Badai Salju',
    'BLIZZARD': 'Badai Salju',
    'WIND': 'Berangin',
    'STRONG_WIND': 'Angin Kencang',
    'TORNADO': 'Tornado',
    'FUNNEL_CLOUD': 'Puting Beliung',
    'HURRICANE': 'Badai',
  };

  static const Map<String, String> _descriptionTranslations = {
    'clear': 'Cerah',
    'mainly clear': 'Cerah',
    'mostly clear': 'Cerah',
    'few clouds': 'Sedikit Awan',
    'scattered clouds': 'Awan Tersebar',
    'broken clouds': 'Awan Pecah',
    'overcast clouds': 'Awan Mendung',
    'clouds': 'Berawan',
    'partly cloudy': 'Berawan Sebagian',
    'mostly cloudy': 'Berawan',
    'drizzle': 'Hujan Gerimis',
    'light drizzle': 'Hujan Gerimis',
    'light rain': 'Hujan Ringan',
    'moderate rain': 'Hujan Sedang',
    'rain showers': 'Hujan Lokal',
    'showers': 'Hujan Lokal',
    'rain': 'Hujan',
    'heavy rain': 'Hujan Lebat',
    'very heavy rain': 'Hujan Lebat',
    'extreme rain': 'Hujan Lebat',
    'thunderstorm': 'Badai Petir',
    'thunderstorms': 'Badai Petir',
    'scattered thunderstorms': 'Badai Petir Tersebar',
    'isolated thunderstorms': 'Badai Petir Terisolasi',
    'light snow': 'Salju Ringan',
    'snow': 'Salju',
    'heavy snow': 'Salju Lebat',
    'sleet': 'Hujan Salju',
    'rain and snow': 'Hujan Salju',
    'freezing rain': 'Hujan Beku',
    'hail': 'Hujan Es',
    'mist': 'Kabut',
    'fog': 'Kabut Tebal',
    'haze': 'Kabut Asap',
    'smoke': 'Asap',
    'dust': 'Debu',
    'sand': 'Pasir',
    'ash': 'Abu Vulkanik',
    'squall': 'Angin Kencang',
    'windy': 'Berangin',
    'wind': 'Berangin',
    'tornado': 'Tornado',
  };

  static const Map<String, String> _typeIcons = {
    'CLEAR': 'assets/images/Cuaca Smart City Icon-05.png',
    'MOSTLY_CLEAR': 'assets/images/Cuaca Smart City Icon-05.png',
    'PARTLY_CLOUDY': 'assets/images/Cuaca Smart City Icon-08.png',
    'MOSTLY_CLOUDY': 'assets/images/Cuaca Smart City Icon-07.png',
    'CLOUDY': 'assets/images/Cuaca Smart City Icon-07.png',
    'OVERCAST': 'assets/images/Cuaca Smart City Icon-07.png',
    'DRIZZLE': 'assets/images/Cuaca Smart City Icon-03.png',
    'LIGHT_RAIN': 'assets/images/Cuaca Smart City Icon-03.png',
    'RAIN': 'assets/images/Cuaca Smart City Icon-04.png',
    'HEAVY_RAIN': 'assets/images/Cuaca Smart City Icon-06.png',
    'RAIN_SHOWERS': 'assets/images/Cuaca Smart City Icon-03.png',
    'RAIN_SNOW': 'assets/images/sleet.png',
    'FREEZING_RAIN': 'assets/images/freezing_rain.png',
    'THUNDERSTORM': 'assets/images/Cuaca Smart City Icon-06.png',
    'THUNDERSTORMS': 'assets/images/Cuaca Smart City Icon-06.png',
    'LIGHT_SNOW': 'assets/images/light_snow.png',
    'SNOW': 'assets/images/snow.png',
    'HEAVY_SNOW': 'assets/images/heavy_snow.png',
    'SLEET': 'assets/images/sleet.png',
    'HAIL': 'assets/images/Cuaca Smart City Icon-06.png',
    'FOG': 'assets/images/Cuaca Smart City Icon-09.png',
    'MIST': 'assets/images/Cuaca Smart City Icon-09.png',
    'HAZE': 'assets/images/Cuaca Smart City Icon-13.png',
    'SMOKE': 'assets/images/Cuaca Smart City Icon-12.png',
    'DUST': 'assets/images/Cuaca Smart City Icon-09.png',
    'SAND': 'assets/images/sand.png',
    'ASH': 'assets/images/ash.png',
    'BLOWING_SNOW': 'assets/images/snow.png',
    'BLIZZARD': 'assets/images/heavy_snow.png',
    'WIND': 'assets/images/Cuaca Smart City Icon-01.png',
    'STRONG_WIND': 'assets/images/Cuaca Smart City Icon-01.png',
    'TORNADO': 'assets/images/Cuaca Smart City Icon-09.png',
    'FUNNEL_CLOUD': 'assets/images/Cuaca Smart City Icon-09.png',
    'HURRICANE': 'assets/images/Cuaca Smart City Icon-06.png',
  };

  static const Map<String, String> _descriptionIcons = {
    'clear': 'assets/images/Cuaca Smart City Icon-05.png',
    'mostly clear': 'assets/images/Cuaca Smart City Icon-05.png',
    'few clouds': 'assets/images/Cuaca Smart City Icon-08.png',
    'scattered clouds': 'assets/images/Cuaca Smart City Icon-08.png',
    'broken clouds': 'assets/images/Cuaca Smart City Icon-07.png',
    'overcast clouds': 'assets/images/Cuaca Smart City Icon-07.png',
    'clouds': 'assets/images/Cuaca Smart City Icon-07.png',
    'rain': 'assets/images/Cuaca Smart City Icon-04.png',
    'light rain': 'assets/images/Cuaca Smart City Icon-03.png',
    'moderate rain': 'assets/images/Cuaca Smart City Icon-04.png',
    'heavy rain': 'assets/images/Cuaca Smart City Icon-06.png',
    'very heavy rain': 'assets/images/Cuaca Smart City Icon-06.png',
    'extreme rain': 'assets/images/Cuaca Smart City Icon-06.png',
    'rain showers': 'assets/images/Cuaca Smart City Icon-03.png',
    'drizzle': 'assets/images/Cuaca Smart City Icon-03.png',
    'thunderstorm': 'assets/images/Cuaca Smart City Icon-06.png',
    'thunderstorms': 'assets/images/Cuaca Smart City Icon-06.png',
    'light snow': 'assets/images/light_snow.png',
    'snow': 'assets/images/snow.png',
    'heavy snow': 'assets/images/heavy_snow.png',
    'sleet': 'assets/images/sleet.png',
    'freezing rain': 'assets/images/freezing_rain.png',
    'hail': 'assets/images/Cuaca Smart City Icon-06.png',
    'mist': 'assets/images/Cuaca Smart City Icon-09.png',
    'fog': 'assets/images/Cuaca Smart City Icon-09.png',
    'haze': 'assets/images/Cuaca Smart City Icon-13.png',
    'smoke': 'assets/images/Cuaca Smart City Icon-12.png',
    'dust': 'assets/images/Cuaca Smart City Icon-09.png',
    'sand': 'assets/images/sand.png',
    'ash': 'assets/images/ash.png',
    'squall': 'assets/images/Cuaca Smart City Icon-09.png',
    'tornado': 'assets/images/Cuaca Smart City Icon-09.png',
    'windy': 'assets/images/Cuaca Smart City Icon-01.png',
  };

  static String translateWeather(
    String? description, {
    String? conditionType,
  }) {
    final typeKey = conditionType?.toUpperCase().trim();
    if (typeKey != null && typeKey.isNotEmpty) {
      final mapped = _typeTranslations[typeKey];
      if (mapped != null) return mapped;
    }

    final descKey = description?.toLowerCase().trim();
    if (descKey == null || descKey.isEmpty) {
      return _defaultDescription;
    }

    final mapped = _descriptionTranslations[descKey];
    if (mapped != null) return mapped;

    if (descKey.contains('rain')) return 'Hujan';
    if (descKey.contains('snow')) return 'Salju';
    if (descKey.contains('cloud')) return 'Berawan';
    if (descKey.contains('storm')) return 'Badai';
    if (descKey.contains('fog') || descKey.contains('mist')) return 'Kabut';
    if (descKey.contains('wind')) return 'Berangin';

    return description ?? _defaultDescription;
  }

  static String getImageForWeather(
    String? description, {
    String? conditionType,
  }) {
    final typeKey = conditionType?.toUpperCase().trim();
    if (typeKey != null && typeKey.isNotEmpty) {
      final mapped = _typeIcons[typeKey];
      if (mapped != null) return mapped;
    }

    final descKey = description?.toLowerCase().trim();
    if (descKey == null || descKey.isEmpty) {
      return _defaultIcon;
    }

    final mapped = _descriptionIcons[descKey];
    if (mapped != null) return mapped;

    if (descKey.contains('rain')) {
      return 'assets/images/Cuaca Smart City Icon-04.png';
    }
    if (descKey.contains('snow')) {
      return 'assets/images/snow.png';
    }
    if (descKey.contains('cloud')) {
      return 'assets/images/Cuaca Smart City Icon-07.png';
    }
    if (descKey.contains('storm')) {
      return 'assets/images/Cuaca Smart City Icon-06.png';
    }
    if (descKey.contains('fog') || descKey.contains('mist')) {
      return 'assets/images/Cuaca Smart City Icon-09.png';
    }

    return _defaultIcon;
  }

  static String getBackgroundImage(int currentHour) {
    if (currentHour >= 6 && currentHour < 12) {
      return 'assets/images/morning.png';
    } else if (currentHour >= 12 && currentHour < 18) {
      return 'assets/images/afternoon.png';
    } else {
      return 'assets/images/night.png';
    }
  }
}

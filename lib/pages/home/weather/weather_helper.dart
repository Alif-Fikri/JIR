class WeatherHelper {
  static String translateWeather(String? description) {
    if (description == null) return "N/A";
    switch (description.toLowerCase()) {
      case "clear":
        return "Cerah";
      case "clouds":
        return "Berawan";
      case "rain":
        return "Hujan";
      case "snow":
        return "Salju";
      case "mist":
        return "Kabut";
      case "haze":
        return "Kabut Asap";
      case "thunderstorm":
        return "Badai Petir";
      case "broken clouds":
        return "Awan Pecah";
      case "scattered clouds":
        return "Awan Tersebar";
      case "few clouds":
        return "Sedikit Awan";
      case "shower rain":
      case "drizzle":
      case "light rain":
        return "Hujan Ringan";
      case "moderate rain":
        return "Hujan Sedang";
      case "heavy intensity rain":
      case "very heavy rain":
      case "extreme rain":
        return "Hujan Lebat";
      case "light snow":
        return "Salju Ringan";
      case "heavy snow":
        return "Salju Lebat";
      case "sleet":
        return "Hujan Salju";
      case "freezing rain":
        return "Hujan Beku";
      case "overcast clouds":
        return "Awan Mendung";
      case "smoke":
        return "Asap";
      case "dust":
        return "Debu";
      case "fog":
        return "Kabut Tebal";
      case "sand":
        return "Pasir";
      case "ash":
        return "Abu Vulkanik";
      case "squall":
        return "Angin Kencang";
      case "tornado":
        return "Tornado";
      default:
        return description;
    }
  }

  static String getImageForWeather(String? description) {
    if (description == null) return 'assets/images/Cuaca Smart City Icon-01.png';
    switch (description.toLowerCase()) {
      case "clear":
        return 'assets/images/Cuaca Smart City Icon-05.png';
      case "clouds":
      case "broken clouds":
      case "overcast clouds":
        return 'assets/images/Cuaca Smart City Icon-07.png';
      case "scattered clouds":
      case "few clouds":
        return 'assets/images/Cuaca Smart City Icon-08.png';
      case "rain":
      case "shower rain":
      case "drizzle":
      case "light rain":
        return 'assets/images/Cuaca Smart City Icon-03.png';
      case "moderate rain":
        return 'assets/images/Cuaca Smart City Icon-04.png';
      case "heavy intensity rain":
      case "very heavy rain":
      case "extreme rain":
        return 'assets/images/Cuaca Smart City Icon-06.png';
      case "snow":
        return 'assets/images/snow.png';
      case "light snow":
        return 'assets/images/light_snow.png';
      case "heavy snow":
        return 'assets/images/heavy_snow.png';
      case "sleet":
        return 'assets/images/sleet.png';
      case "freezing rain":
        return 'assets/images/freezing_rain.png';
      case "mist":
        return 'assets/images/Cuaca Smart City Icon-09.png';
      case "haze":
        return 'assets/images/Cuaca Smart City Icon-13.png';
      case "thunderstorm":
        return 'assets/images/Cuaca Smart City Icon-06.png';
      case "smoke":
        return 'assets/images/Cuaca Smart City Icon-12.png';
      case "dust":
      case "fog":
      case "tornado":
        return 'assets/images/Cuaca Smart City Icon-09.png';
      case "sand":
        return 'assets/images/sand.png';
      case "ash":
        return 'assets/images/ash.png';
      case "squall":
        return 'assets/images/squall.png';
      default:
        return 'assets/images/Cuaca Smart City Icon-01.png';
    }
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

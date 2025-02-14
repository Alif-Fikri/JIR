class BackgroundImageSelector {
  static String getBackgroundImage(int currentHour) {
    if (currentHour >= 6 && currentHour < 12) {
      return 'assets/images/morning.png';
    } else if (currentHour >= 12 && currentHour < 18) {
      return 'assets/images/afternoon.png';
    } else {
      return 'assets/images/night.png';
    }
  }

  static String getImageForWeather(String description) {
    switch (description.toLowerCase()) {
      case "clear":
        return 'assets/images/Cuaca Smart City Icon-05.png';
      case "clouds":
        return 'assets/images/Cuaca Smart City Icon-07.png';
      case "rain":
        return 'assets/images/Cuaca Smart City Icon-04.png';
      case "snow":
        return 'assets/images/snow.png';
      case "mist":
        return 'assets/images/Cuaca Smart City Icon-09.png';
      case "haze":
        return 'assets/images/Cuaca Smart City Icon-13.png';
      case "thunderstorm":
        return 'assets/images/Cuaca Smart City Icon-06.png';
      case "broken clouds":
        return 'assets/images/Cuaca Smart City Icon-07.png';
      case "scattered clouds":
        return 'assets/images/Cuaca Smart City Icon-08.png';
      case "few clouds":
        return 'assets/images/Cuaca Smart City Icon-08.png';
      case "shower rain":
        return 'assets/images/Cuaca Smart City Icon-03.png';
      case "drizzle":
        return 'assets/images/Cuaca Smart City Icon-03.png';
      case "light rain":
        return 'assets/images/Cuaca Smart City Icon-03.png';
      case "moderate rain":
        return 'assets/images/Cuaca Smart City Icon-04.png';
      case "heavy intensity rain":
        return 'assets/images/Cuaca Smart City Icon-06.png';
      case "very heavy rain":
        return 'assets/images/Cuaca Smart City Icon-06.png';
      case "extreme rain":
        return 'assets/images/Cuaca Smart City Icon-06.png';
      case "light snow":
        return 'assets/images/light_snow.png';
      case "heavy snow":
        return 'assets/images/heavy_snow.png';
      case "sleet":
        return 'assets/images/sleet.png';
      case "freezing rain":
        return 'assets/images/freezing_rain.png';
      case "overcast clouds":
        return 'assets/images/oCuaca Smart City Icon-07.png';
      case "smoke":
        return 'assets/images/Cuaca Smart City Icon-12.png';
      case "dust":
        return 'assets/images/Cuaca Smart City Icon-09.png';
      case "fog":
        return 'assets/images/Cuaca Smart City Icon-09.png';
      case "sand":
        return 'assets/images/sand.png';
      case "ash":
        return 'assets/images/ash.png';
      case "squall":
        return 'assets/images/squall.png';
      case "tornado":
        return 'assets/images/Cuaca Smart City Icon-09.png';
      default:
        return 'assets/images/Cuaca Smart City Icon-01.png';
    }
  }
}

class WeatherTranslator {
  static String translate(String? description) {
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
        return "Hujan Gerimis";
      case "drizzle":
        return "Gerimis";
      case "light rain":
        return "Hujan Ringan";
      case "moderate rain":
        return "Hujan Sedang";
      case "heavy intensity rain":
        return "Hujan Lebat";
      case "very heavy rain":
        return "Hujan Sangat Lebat";
      case "extreme rain":
        return "Hujan Ekstrem";
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
}
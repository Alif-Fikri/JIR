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
}
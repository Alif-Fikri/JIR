import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:JIR/pages/home/main/controller/home_controller.dart';
import 'package:JIR/services/news_service/news_service.dart';

class NewsCarousel extends StatelessWidget {
  final HomeController controller;
  final Color primaryColor;

  const NewsCarousel({
    super.key,
    required this.controller,
    this.primaryColor = const Color(0xFF45557B),
  });

  Future<void> _openNewsUrl(String? url) async {
    if (url == null || url.isEmpty) {
      Get.snackbar('Error', 'Tautan tidak tersedia');
      return;
    }
    final uri = Uri.tryParse(url);
    if (uri == null) {
      Get.snackbar('Error', 'Tautan tidak valid');
      return;
    }
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Error', 'Tidak dapat membuka tautan');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isNewsLoading.value) {
        return Container(
          margin: const EdgeInsets.all(16),
          height: 170,
          decoration: BoxDecoration(
              color: Colors.grey[300], borderRadius: BorderRadius.circular(16)),
          child: const Center(child: CircularProgressIndicator()),
        );
      }
      if (controller.newsList.isEmpty) {
        return Container(
          margin: const EdgeInsets.all(16),
          height: 120,
          decoration: BoxDecoration(
              color: Colors.grey[300], borderRadius: BorderRadius.circular(16)),
          child:
              Center(child: Text('Tidak ada berita terkini untuk Indonesia')),
        );
      }

      final items = controller.newsList;
      final showCount = items.length > 15 ? 15 : items.length;

      return Card(
        color: Colors.white,
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(
              height: 160,
              child: CarouselSlider(
                options: CarouselOptions(
                  height: 160,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  viewportFraction: 1.0,
                  autoPlayInterval: const Duration(seconds: 5),
                  onPageChanged: (index, reason) {
                    controller.setNewsIndex(index);
                  },
                ),
                items: items.take(showCount).map((NewsItem news) {
                  return InkWell(
                    onTap: () => _openNewsUrl(news.url),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        color: Colors.white,
                        child: Row(children: [
                          if (news.imageUrl != null &&
                              news.imageUrl!.isNotEmpty)
                            Container(
                              width: 130,
                              height: 160,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(news.imageUrl!),
                                  fit: BoxFit.cover,
                                  colorFilter: ColorFilter.mode(
                                      Colors.black.withOpacity(0.18),
                                      BlendMode.darken),
                                ),
                              ),
                            )
                          else
                            Container(
                              width: 130,
                              height: 160,
                              color: Colors.grey[200],
                              child: const Icon(Icons.article, size: 48),
                            ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(news.title,
                                        maxLines: 4,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14)),
                                    const SizedBox(height: 8),
                                    if (news.source != null)
                                      Text(news.source!,
                                          style: GoogleFonts.inter(
                                              fontSize: 12,
                                              color: Colors.grey[600])),
                                  ]),
                            ),
                          ),
                        ]),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 10),
            Obx(() {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(showCount, (i) {
                  final active = controller.newsIndex.value == i;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 12 : 8,
                    height: active ? 12 : 8,
                    decoration: BoxDecoration(
                      color: active ? primaryColor : Colors.grey,
                      shape: BoxShape.circle,
                      boxShadow: active
                          ? [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.18),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2))
                            ]
                          : null,
                    ),
                  );
                }),
              );
            }),
          ]),
        ),
      );
    });
  }
}

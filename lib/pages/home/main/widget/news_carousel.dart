import 'dart:async';
import 'package:JIR/pages/home/main/widget/home_shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:JIR/pages/home/main/controller/home_controller.dart';
import 'package:JIR/services/news_service/news_service.dart';

class NewsCarousel extends StatefulWidget {
  final HomeController controller;
  final Color primaryColor;
  final double height;
  final Duration autoPlayInterval;

  const NewsCarousel({
    super.key,
    required this.controller,
    this.primaryColor = const Color(0xFF45557B),
    this.height = 200,
    this.autoPlayInterval = const Duration(seconds: 6),
  });

  @override
  State<NewsCarousel> createState() => _NewsCarouselState();
}

class _NewsCarouselState extends State<NewsCarousel> {
  late final PageController _pageController;
  Timer? _autoPlayTimer;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0, viewportFraction: 0.94);
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(widget.autoPlayInterval, (_) {
      final itemCount = widget.controller.newsList.length;
      if (itemCount == 0) return;
      final next = (_current + 1) % itemCount;
      if (mounted) {
        _pageController.animateToPage(
          next,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _openNewsUrl(String? url) async {
    if (url == null || url.isEmpty) {
      Get.snackbar('Gagal', 'Tautan tidak tersedia',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    final uri = Uri.tryParse(url);
    if (uri == null) {
      Get.snackbar('Gagal', 'Tautan tidak valid',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (!await canLaunchUrl(uri)) {
      Get.snackbar('Gagal', 'Tidak dapat membuka tautan',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget _buildCard(BuildContext context, NewsItem item, double pageOffset) {
    final double scale = (1 - (pageOffset.abs() * 0.12)).clamp(0.88, 1.0);
    final borderRadius = BorderRadius.circular(14.r);

    return Transform.scale(
      scale: scale,
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () => _openNewsUrl(item.url),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                CachedNetworkImage(
                  imageUrl: item.imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (c, s) => Container(
                    color: Colors.grey[300],
                    child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2.w)),
                  ),
                  errorWidget: (c, s, e) => Container(
                    color: Colors.grey[200],
                    child:
                        Center(child: Icon(Icons.broken_image, size: 48.r)),
                  ),
                )
              else
                Container(
                  color: Colors.grey[200],
                  child: Center(child: Icon(Icons.article, size: 56.r)),
                ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.58),
                      Colors.black.withOpacity(0.25),
                      Colors.transparent
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    stops: const [0.0, 0.45, 0.9],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  children: [
                    Row(
                      children: [
                        if (item.source != null && item.source!.isNotEmpty)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              item.source!.toUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        const Spacer(),
                        Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.85),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.open_in_new,
                              size: 16.r, color: Colors.black87),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(maxHeight: widget.height.h * 0.55),
                        child: Text(
                          item.title,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 12.w,
                bottom: 12.h,
                child: Material(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(20.r),
                  child: InkWell(
                    onTap: () => _openNewsUrl(item.url),
                    borderRadius: BorderRadius.circular(20.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 12.w, vertical: 8.h),
                      child: Row(
                        children: [
                          Icon(Icons.article, size: 16.r, color: Colors.white),
                          SizedBox(width: 8.w),
                          Text('Baca',
                              style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12.sp)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIndicator(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == _current;
        return GestureDetector(
          onTap: () {
            _pageController.animateToPage(i,
                duration: Duration(milliseconds: 450),
                curve: Curves.easeInOut);
            _startAutoPlay();
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            width: active ? 18.w : 8.w,
            height: 8.h,
            decoration: BoxDecoration(
              color: active ? widget.primaryColor : Colors.grey[400],
              borderRadius: BorderRadius.circular(8.r),
              boxShadow: active
                  ? [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.18),
                          blurRadius: 4.r,
                          offset: Offset(0, 2.h))
                    ]
                  : null,
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = widget.controller.isNewsLoading.value;
      final items = widget.controller.newsList;

      if (isLoading) {
        return SizedBox(
          height: widget.height.h,
          child: _ShimmerNewsList(height: widget.height, count: 3,),
        );
      }

      if (items.isEmpty) {
        return SizedBox(
          height: widget.height.h,
          child: Center(
            child: Text('Tidak ada berita terkini',
                style: GoogleFonts.inter(fontSize: 14.sp)),
          ),
        );
      }

      final showCount = items.length > 15 ? 15 : items.length;

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: widget.height.h,
            child: PageView.builder(
              controller: _pageController,
              itemCount: showCount,
              onPageChanged: (idx) {
                setState(() {
                  _current = idx;
                  widget.controller.setNewsIndex(idx);
                });
                _startAutoPlay();
              },
              itemBuilder: (context, index) {
                final page =
                    (_pageController.hasClients && _pageController.page != null)
                        ? _pageController.page!
                        : _current.toDouble();
                final offset = (page - index);
                final clippedOffset = offset.clamp(-1.0, 1.0);
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                  child: _buildCard(context, items[index], clippedOffset),
                );
              },
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            child: Row(
              children: [
                Expanded(child: _buildIndicator(showCount)),
                SizedBox(width: 8.w),
                Text('$showCount berita',
                    style: GoogleFonts.inter(
                        fontSize: 12.sp, color: Colors.grey[700])),
              ],
            ),
          ),
          SizedBox(height: 8.h),
        ],
      );
    });
  }
}

class _ShimmerNewsList extends StatelessWidget {
  final double height;
  final int count;
  const _ShimmerNewsList({required this.height, required this.count});

  @override
  Widget build(BuildContext context) {
    final cardWidth = 0.86.sw;
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      itemCount: count,
      separatorBuilder: (_, __) => SizedBox(width: 12.w),
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(14.r),
          child: Stack(
            children: [
              HomeShimmer.rect(
                height: height,
                width: cardWidth,
                radius: BorderRadius.circular(14.r),
              ),
              Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  children: [
                    Row(
                      children: [
                        HomeShimmer.rect(
                          height: 20.h,
                          width: 70.w,
                          radius: BorderRadius.circular(12.r),
                        ),
                        Spacer(),
                        HomeShimmer.circle(size: 28.sp),
                      ],
                    ),
                    Spacer(),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          HomeShimmer.rect(
                            height: 16.h,
                            width: cardWidth * 0.6,
                            radius: BorderRadius.circular(6.r),
                          ),
                          SizedBox(height: 8.h),
                          HomeShimmer.rect(
                            height: 14.h,
                            width: cardWidth * 0.45,
                            radius: BorderRadius.circular(6.r),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:JIR/app/routes/app_routes.dart';
import 'package:JIR/pages/auth/controller/logout_controller.dart';
import 'package:JIR/pages/profile/controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  final LogoutController logoutController = Get.put(LogoutController());
  final ProfileController pc = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: 320.h,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/group_38.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 20.w, bottom: 90.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => Text(
                          'Halo, ${pc.name.value} !',
                          style: GoogleFonts.inter(
                            fontSize: 22.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )),
                    SizedBox(height: 5.h),
                    Obx(() => Text(
                          pc.email.value,
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )),
                  ],
                ),
              ),
              Positioned(
                right: 50.w,
                bottom: 15.h,
                child: SizedBox(
                  width: 160.w,
                  height: 160.h,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 74.r,
                      backgroundColor: Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: ListView(
                children: [
                  ProfileMenuItem(
                    icon:
                        Image.asset('assets/images/settings.png', width: 24.w),
                    text: "Pengaturan",
                    onTap: () {
                      Get.toNamed(AppRoutes.settings);
                    },
                  ),
                  ProfileMenuItem(
                    icon: Image.asset('assets/images/about.png', width: 24.w),
                    text: "Tentang JIR",
                    onTap: () {
                      Get.toNamed(AppRoutes.about);
                    },
                  ),
                  ProfileMenuItem(
                    icon: Image.asset('assets/images/privacypolicy.png',
                        width: 24.w),
                    text: "Kebijakan Privasi",
                    onTap: () {
                      Get.toNamed(AppRoutes.privacyPolicy);
                    },
                  ),
                  ProfileMenuItem(
                    icon: Image.asset('assets/images/termsofservice.png',
                        width: 24.w),
                    text: "Syarat dan Ketentuan",
                    onTap: () {
                      Get.toNamed(AppRoutes.termsOfService);
                    },
                  ),
                  ProfileMenuItem(
                    icon: Image.asset('assets/images/logout.png', width: 24.w),
                    text: "Keluar",
                    onTap: () {
                      LogoutDialog.show(
                        context,
                        (context) async {
                          await logoutController.logout();
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileMenuItem extends StatelessWidget {
  final Widget icon;
  final String text;
  final VoidCallback onTap;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: ListTile(
            leading: icon,
            title: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 20.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF435482),
              ),
            ),
          ),
        ),
        const Divider(color: Color(0xffDEDEDE)),
      ],
    );
  }
}

class LogoutDialog {
  static void show(
      BuildContext context, Future<void> Function(BuildContext) onLogout) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.r),
          ),
          title: Text(
            'Keluar?',
            style: GoogleFonts.inter(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          content: Text(
            'Apakah Anda yakin ingin keluar?',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              color: Colors.black,
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.r),
                        color: const Color(0xff4B5C82)),
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                      ),
                      child: FittedBox(
                        child: Text(
                          'Batal',
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.r),
                        border: Border.all(
                            color: const Color(0xff4B5C82), width: 1.5.w)),
                    child: TextButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await onLogout(context);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF435482),
                      ),
                      child: FittedBox(
                        child: Text(
                          'Keluar',
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

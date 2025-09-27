import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        elevation: 5,
        borderRadius: BorderRadius.circular(50),
        shadowColor: Colors.grey.withOpacity(0.5),
        child: TextField(
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
          decoration: InputDecoration(
            hintText: 'Search . . .',
            hintStyle: GoogleFonts.inter(
              fontSize: 15,
              color: Colors.black,
              fontStyle: FontStyle.italic,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(
                bottom: 5,
                top: 5,
                left: 18,
                right: 15,
              ),
              child: Image.asset(
                'assets/images/search.png',
                height: 25,
                width: 25,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: const Color(0xFFEDEDED),
          ),
        ),
      ),
    );
  }
}

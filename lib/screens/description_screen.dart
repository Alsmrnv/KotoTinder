import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/cat_info.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailScreen extends StatelessWidget {
  final Cat cat;

  const DetailScreen({super.key, required this.cat});

  @override
  Widget build(BuildContext context) {
    final breed = cat.breed;
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade100,
      appBar: AppBar(
        title: Text(
          'Details',
          style: GoogleFonts.deliusSwashCaps(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                breed.name,
                style: GoogleFonts.deliusSwashCaps(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [Shadow(blurRadius: 10.0, offset: Offset(2.0, 2.0))],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: CachedNetworkImage(
                    imageUrl: cat.imageUrl,
                    placeholder:
                        (context, url) => const CircularProgressIndicator(),
                    errorWidget:
                        (context, url, error) => const Icon(Icons.error),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                breed.description,
                style: GoogleFonts.rubik(
                  fontSize: 22,
                  color: Colors.white,
                  shadows: [Shadow(blurRadius: 8.0, offset: Offset(2.0, 2.0))],
                ),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Text(
                    'Origin: ',
                    style: GoogleFonts.rubik(
                      fontSize: 22,
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      breed.origin,
                      style: GoogleFonts.rubik(
                        fontSize: 22,
                        color: Colors.white,
                        shadows: [
                          Shadow(blurRadius: 8.0, offset: Offset(2.0, 2.0)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              RichText(
                text: TextSpan(
                  text: 'Temperament: ',
                  style: GoogleFonts.rubik(
                    fontSize: 22,
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: breed.temperament,
                      style: GoogleFonts.rubik(
                        fontSize: 22,
                        color: Colors.white,
                        shadows: [
                          Shadow(blurRadius: 8.0, offset: Offset(2.0, 2.0)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Text(
                    'Life span: ',
                    style: GoogleFonts.rubik(
                      fontSize: 22,
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${breed.lifeSpan} years',
                      style: GoogleFonts.rubik(
                        fontSize: 22,
                        color: Colors.white,
                        shadows: [
                          Shadow(blurRadius: 8.0, offset: Offset(2.0, 2.0)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Text(
                    'Grooming: ',
                    style: GoogleFonts.rubik(
                      fontSize: 22,
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${breed.grooming}/5',
                      style: GoogleFonts.rubik(
                        fontSize: 22,
                        color: Colors.white,
                        shadows: [
                          Shadow(blurRadius: 8.0, offset: Offset(2.0, 2.0)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

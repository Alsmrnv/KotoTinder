import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../Data/models/cat_info.dart';

class LikedCatsScreen extends StatefulWidget {
  final List<Cat> likedCats;

  const LikedCatsScreen({super.key, required this.likedCats});

  @override
  LikedCatsScreenState createState() => LikedCatsScreenState();
}

class LikedCatsScreenState extends State<LikedCatsScreen> {
  String selectedBreed = 'All';

  List<String> getUniqueBreeds() {
    final breeds =
        widget.likedCats.map((cat) => cat.breed.name).toSet().toList();
    breeds.sort();
    return ['All', ...breeds];
  }

  String formatDate(DateTime date) {
    final DateFormat formatter = DateFormat('dd MMM yyyy, HH:mm');
    return formatter.format(date);
  }

  @override
  Widget build(BuildContext context) {
    final uniqueBreeds = getUniqueBreeds();

    final filteredCats =
        selectedBreed == 'All'
            ? widget.likedCats
            : widget.likedCats
                .where((cat) => cat.breed.name == selectedBreed)
                .toList();

    if (!uniqueBreeds.contains(selectedBreed)) {
      selectedBreed = 'All';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Liked Cats',
          style: GoogleFonts.deliusSwashCaps(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              value: selectedBreed,
              decoration: InputDecoration(
                labelText: 'Filter by breed',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items:
                  uniqueBreeds
                      .map(
                        (breed) => DropdownMenuItem<String>(
                          value: breed,
                          child: Text(breed),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                setState(() {
                  selectedBreed = value!;
                });
              },
            ),
          ),
          Expanded(
            child:
                filteredCats.isEmpty
                    ? const Center(
                      child: Text(
                        'No liked cats found.',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    )
                    : ListView.builder(
                      itemCount: filteredCats.length,
                      itemBuilder: (context, index) {
                        final cat = filteredCats[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 16,
                          ),
                          color: Colors.blueGrey.shade200,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(10),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(
                                imageUrl: cat.imageUrl,
                                placeholder:
                                    (context, url) =>
                                        const CircularProgressIndicator(),
                                errorWidget:
                                    (context, url, error) =>
                                        const Icon(Icons.error),
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(
                              cat.breed.name,
                              style: GoogleFonts.rubik(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                            subtitle: Text(
                              'Liked at: ${formatDate(cat.likedAt)}',
                              style: GoogleFonts.rubik(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete_forever,
                                color: Colors.deepOrange,
                              ),
                              onPressed: () {
                                setState(() {
                                  widget.likedCats.remove(cat);
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

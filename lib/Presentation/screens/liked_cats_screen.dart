import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Data/models/cat_info.dart';
import '../../Data/storage/liked_cats_storage.dart';
import 'description_screen.dart';

class LikedCatsScreen extends StatefulWidget {
  final List<Cat> likedCats;

  const LikedCatsScreen({super.key, required this.likedCats});

  @override
  LikedCatsScreenState createState() => LikedCatsScreenState();
}

class LikedCatsScreenState extends State<LikedCatsScreen> {
  late List<Cat> _cats;
  bool _changesMade = false;

  @override
  void initState() {
    super.initState();
    _cats = List.from(widget.likedCats);
  }

  Future<void> _removeCat(int index) async {
    setState(() {
      _cats.removeAt(index);
      _changesMade = true;
    });

    await LikedCatsStorage.saveLikedCats(_cats);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        Navigator.of(context).pop(_changesMade);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Liked Cats',
            style: GoogleFonts.deliusSwashCaps(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.blueGrey,
        ),
        body:
            _cats.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.sentiment_dissatisfied,
                        size: 100,
                        color: Colors.blueGrey.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No liked cats yet',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context, _changesMade);
                        },
                        icon: Icon(Icons.arrow_back),
                        label: Text('Go back and like some cats'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey,
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _cats.length,
                  itemBuilder: (context, index) {
                    final cat = _cats[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailScreen(cat: cat),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(15),
                                ),
                                child: Hero(
                                  tag: 'cat_image_${cat.imageUrl}',
                                  child: CachedNetworkImage(
                                    imageUrl: cat.imageUrl,
                                    height: 250,
                                    fit: BoxFit.cover,
                                    placeholder:
                                        (context, url) => const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                    errorWidget:
                                        (context, url, error) => Image.asset(
                                          'assets/images/placeholder.png',
                                          fit: BoxFit.cover,
                                        ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            cat.breed.name,
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Liked on: ${_formatDate(cat.likedAt)}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => _removeCat(index),
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: 28,
                                      ),
                                      tooltip: 'Remove from liked',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';
  }
}

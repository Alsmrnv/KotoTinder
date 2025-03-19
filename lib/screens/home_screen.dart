import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/cat_info.dart';
import '../services/cat_api.dart';
import '../storage/like_count_storage.dart';
import '../widgets/like_button.dart';
import '../widgets/dislike_button.dart';
import 'description_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  Cat? _currentCat;
  int _likesCount = 0;
  double _swipeDistance = 0;
  double _dragStart = 0.0;

  @override
  void initState() {
    super.initState();
    _loadNewCat();
    _loadLikesCount();
  }

  _loadNewCat() async {
    try {
      Cat newCat = await CatService().fetchRandomCat();
      if (mounted) {
        setState(() {
          _currentCat = newCat;
        });
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Ошибка'),
              content: Text('Не удалось загрузить котика. Попробуйте позже.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Ок'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  _loadLikesCount() async {
    int count = await LikesStorage.getLikesCount();
    setState(() {
      _likesCount = count;
    });
  }

  _onLike() async {
    await LikesStorage.incrementLikesCount();
    _loadLikesCount();
    _loadNewCat();
  }

  _onDislike() {
    _loadNewCat();
  }

  void _onSwipeEnd() {
    if (_swipeDistance > 100) {
      _onLike();
    } else if (_swipeDistance < -100) {
      _onDislike();
    }

    setState(() {
      _swipeDistance = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'KotoTinder',
          style: GoogleFonts.deliusSwashCaps(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
      ),
      body:
          _currentCat == null
              ? const Center(child: CircularProgressIndicator())
              : GestureDetector(
                onHorizontalDragStart: (details) {
                  _dragStart = details.localPosition.dx;
                },
                onHorizontalDragUpdate: (details) {
                  setState(() {
                    _swipeDistance = details.localPosition.dx - _dragStart;
                  });
                },
                onHorizontalDragEnd: (details) {
                  _onSwipeEnd();
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        DetailScreen(cat: _currentCat!),
                              ),
                            );
                          },
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20.0),
                                child: CachedNetworkImage(
                                  imageUrl: _currentCat!.imageUrl,
                                  placeholder:
                                      (context, url) =>
                                          const CircularProgressIndicator(),
                                  errorWidget:
                                      (context, url, error) =>
                                          const Icon(Icons.error),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                bottom: 16,
                                left: 16,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Color.fromRGBO(0, 0, 0, 0.5),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      _currentCat!.breed.name,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          DislikeButton(onTap: _onDislike, size: 80),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ),
                            child: Text(
                              'Likes: $_likesCount',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    blurRadius: 10.0,
                                    offset: Offset(2.0, 2.0),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          LikeButton(onTap: _onLike, size: 80),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}

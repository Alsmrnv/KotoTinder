import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';

import '../../Data/models/cat_info.dart';
import '../../Domain/repositories/cat_repository.dart';
import '../../Data/storage/like_count_storage.dart';

import '../widgets/like_button.dart';
import '../widgets/dislike_button.dart';
import 'liked_cats_screen.dart';
import 'description_screen.dart';

import 'package:get_it/get_it.dart';

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
  bool _isLoading = false;

  final List<Cat> _likedCats = [];
  late final CatRepository _catRepository = GetIt.instance<CatRepository>();

  @override
  void initState() {
    super.initState();
    _loadNewCat();
    _loadLikesCount();
  }

  _loadNewCat() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Cat newCat = await _catRepository.getRandomCat();
      if (mounted) {
        setState(() {
          _currentCat = newCat;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        if (e is SocketException) {
          _showErrorDialog('Please check your network connection.');
        } else {
          _showErrorDialog(
            'There was an error loading the cat. Try again later.',
          );
        }
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

    if (_currentCat != null) {
      setState(() {
        _likedCats.add(
          Cat(
            imageUrl: _currentCat!.imageUrl,
            breed: _currentCat!.breed,
            likedAt: DateTime.now(),
          ),
        );
      });
    }

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

  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Network error'),
          content: Row(
            children: [
              Icon(Icons.wifi_off, color: Colors.deepOrange),
              const SizedBox(width: 10),
              Expanded(child: Text(errorMessage)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
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
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LikedCatsScreen(likedCats: _likedCats),
                ),
              );
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    strokeWidth: 8,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.blueAccent,
                    ),
                  ),
                ),
              )
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
                                    color: const Color.fromRGBO(0, 0, 0, 0.5),
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
                              style: const TextStyle(
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

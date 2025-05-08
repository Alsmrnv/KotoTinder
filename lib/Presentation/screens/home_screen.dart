import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import '../../Data/models/cat_info.dart';
import '../../Domain/repositories/cat_repository.dart';
import '../../Data/storage/like_count_storage.dart';
import '../../Data/storage/liked_cats_storage.dart';
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

class HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  Cat? _currentCat;
  int _likesCount = 0;
  double _swipeDistance = 0;
  double _dragStart = 0.0;
  bool _isLoading = false;
  bool _isOffline = false;
  List<Cat> _likedCats = [];
  late final CatRepository _catRepository = GetIt.instance<CatRepository>();

  late AnimationController _bannerController;
  late Animation<double> _bannerAnimation;

  @override
  void initState() {
    super.initState();

    _bannerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _bannerAnimation = Tween<double>(begin: -50.0, end: 0.0).animate(
      CurvedAnimation(parent: _bannerController, curve: Curves.easeOut),
    );

    _loadLikedCatsFromStorage();
    _loadNewCat();
    _loadLikesCount();
  }

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  _loadLikedCatsFromStorage() async {
    final cats = await LikedCatsStorage.getLikedCats();
    if (mounted) {
      setState(() {
        _likedCats = cats;
      });
    }
  }

  _loadNewCat() async {
    setState(() {
      _isLoading = true;
      _isOffline = false;
    });

    try {
      Cat newCat = await _catRepository.getRandomCat();
      if (mounted) {
        setState(() {
          _currentCat = newCat;
          _isLoading = false;
          _isOffline = false;
        });
        if (_bannerController.isCompleted) {
          _bannerController.reverse();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (e is SocketException) {
            _isOffline = true;
            _bannerController.forward();
          }
        });
      }
    }
  }

  _loadLikesCount() async {
    int count = await LikesStorage.getLikesCount();
    if (mounted) {
      setState(() {
        _likesCount = count;
      });
    }
  }

  _onLike() async {
    if (_isOffline) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cannot like cats while offline. Please check your internet connection.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await LikesStorage.incrementLikesCount();
    _loadLikesCount();
    if (_currentCat != null) {
      final newLikedCat = Cat(
        imageUrl: _currentCat!.imageUrl,
        breed: _currentCat!.breed,
        likedAt: DateTime.now(),
      );

      setState(() {
        _likedCats.add(newLikedCat);
      });

      await LikedCatsStorage.saveLikedCats(_likedCats);
    }
    _loadNewCat();
  }

  _onDislike() {
    if (_isOffline) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cannot dislike cats while offline. Please check your internet connection.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _loadNewCat();
  }

  void _onSwipeEnd() {
    if (_isOffline) {
      setState(() {
        _swipeDistance = 0;
      });
      return;
    }

    if (_swipeDistance > 100) {
      _onLike();
    } else if (_swipeDistance < -100) {
      _onDislike();
    }
    setState(() {
      _swipeDistance = 0;
    });
  }

  void _navigateToLikedCats() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LikedCatsScreen(likedCats: _likedCats),
      ),
    );

    if (result == true) {
      _loadLikedCatsFromStorage();
    }
  }

  Widget _buildNetworkStatusBanner() {
    return AnimatedBuilder(
      animation: _bannerAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _bannerAnimation.value),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 16.0,
            ),
            color: Colors.deepOrangeAccent,

            child: Row(
              children: [
                const Icon(Icons.wifi_off, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No internet connection',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (_likedCats.isNotEmpty)
                  TextButton(
                    onPressed: _navigateToLikedCats,
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                    ),
                    child: Text(
                      'View Liked Cats',
                      style: TextStyle(
                        color: Colors.deepOrange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                IconButton(
                  icon: Icon(Icons.refresh, color: Colors.white),
                  onPressed: _loadNewCat,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainContent() {
    if (_isLoading) {
      return Center(
        child: SizedBox(
          width: 100,
          height: 100,
          child: CircularProgressIndicator(
            strokeWidth: 8,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
          ),
        ),
      );
    }

    if (_currentCat == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pets,
              size: 100,
              color: Colors.blueGrey.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No cats available.',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.signal_wifi_off, color: Colors.blueGrey, size: 30),
                  const SizedBox(width: 8),
                  Text(
                    'Please check your network connection.',
                    style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadNewCat,
              icon: Icon(Icons.refresh),
              label: Text('Try again', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            if (_likedCats.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Or view your ${_likedCats.length} liked cats',
                style: TextStyle(fontSize: 16, color: Colors.blueGrey),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _navigateToLikedCats,
                icon: Icon(Icons.favorite),
                label: Text('View Liked Cats'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.deepOrange,
                  side: BorderSide(color: Colors.deepOrange),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return GestureDetector(
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
              child: Transform.translate(
                offset: Offset(_swipeDistance * 0.5, 0),
                child: Transform.rotate(
                  angle: _swipeDistance * 0.001,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailScreen(cat: _currentCat!),
                        ),
                      );
                    },
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Hero(
                          tag: 'cat_image_${_currentCat!.imageUrl}',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20.0),
                            child: CachedNetworkImage(
                              imageUrl: _currentCat!.imageUrl,
                              placeholder:
                                  (context, url) => Center(
                                    child: CircularProgressIndicator(),
                                  ),
                              errorWidget:
                                  (context, url, error) => Container(
                                    color: Colors.grey.shade300,
                                    child: Icon(
                                      Icons.error,
                                      size: 50,
                                      color: Colors.red,
                                    ),
                                  ),
                              fit: BoxFit.cover,
                            ),
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
                        if (_swipeDistance > 50 && !_isOffline)
                          Positioned(
                            right: 16,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.7),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.favorite,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            ),
                          ),
                        if (_swipeDistance < -50 && !_isOffline)
                          Positioned(
                            left: 16,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.7),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    'Likes: $_likesCount',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(blurRadius: 10.0, offset: Offset(2.0, 2.0)),
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
          GestureDetector(
            onTap: _navigateToLikedCats,
            child: Container(
              margin: EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade700,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  const Icon(Icons.favorite, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Likes ${_likedCats.length}',
                    style: GoogleFonts.rubik(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildMainContent(),

          if (_isOffline && _currentCat != null) _buildNetworkStatusBanner(),
        ],
      ),
    );
  }
}

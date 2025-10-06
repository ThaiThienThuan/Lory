import 'package:flutter/material.dart';
import '../models/manga.dart';

class ReaderScreen extends StatefulWidget {
  @override
  _ReaderScreenState createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  PageController _pageController = PageController();
  int currentPage = 0;
  bool showControls = true;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = 
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final Manga manga = args['manga'];
    final Chapter chapter = args['chapter'];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: showControls
          ? AppBar(
              backgroundColor: Colors.black.withOpacity(0.8),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    manga.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Chapter ${chapter.number}: ${chapter.title}',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              iconTheme: IconThemeData(color: Colors.white),
              actions: [
                IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () {
                    _showSettingsBottomSheet(context);
                  },
                ),
              ],
            )
          : null,
      body: GestureDetector(
        onTap: () {
          setState(() {
            showControls = !showControls;
          });
        },
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: chapter.pages.length,
              onPageChanged: (index) {
                setState(() {
                  currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  child: Center(
                    child: Image.network(
                      chapter.pages[index],
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                );
              },
            ),
            
            // Bottom controls
            if (showControls)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Page indicator
                      Text(
                        '${currentPage + 1} / ${chapter.pages.length}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      
                      // Progress slider
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Color(0xFF06b6d4),
                          inactiveTrackColor: Colors.white30,
                          thumbColor: Color(0xFF06b6d4),
                          overlayColor: Color(0xFF06b6d4).withOpacity(0.2),
                        ),
                        child: Slider(
                          value: currentPage.toDouble(),
                          min: 0,
                          max: (chapter.pages.length - 1).toDouble(),
                          divisions: chapter.pages.length - 1,
                          onChanged: (value) {
                            _pageController.animateToPage(
                              value.round(),
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                        ),
                      ),
                      
                      // Navigation buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: currentPage > 0
                                ? () {
                                    _pageController.previousPage(
                                      duration: Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  }
                                : null,
                            icon: Icon(Icons.arrow_back),
                            label: Text('Previous'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF06b6d4),
                              foregroundColor: Colors.white,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: currentPage < chapter.pages.length - 1
                                ? () {
                                    _pageController.nextPage(
                                      duration: Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  }
                                : () {
                                    _showChapterCompleteDialog(context, manga, chapter);
                                  },
                            icon: Icon(Icons.arrow_forward),
                            label: Text(
                              currentPage < chapter.pages.length - 1 
                                  ? 'Next' 
                                  : 'Finish'
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: currentPage < chapter.pages.length - 1
                                  ? Color(0xFF06b6d4)
                                  : Color(0xFFec4899),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reading Settings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.brightness_6),
                title: Text('Reading Mode'),
                subtitle: Text('Vertical scroll'),
                trailing: Switch(
                  value: false,
                  onChanged: (value) {},
                ),
              ),
              ListTile(
                leading: Icon(Icons.zoom_in),
                title: Text('Auto-fit pages'),
                trailing: Switch(
                  value: true,
                  onChanged: (value) {},
                ),
              ),
              ListTile(
                leading: Icon(Icons.bookmark),
                title: Text('Auto-bookmark'),
                trailing: Switch(
                  value: true,
                  onChanged: (value) {},
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showChapterCompleteDialog(BuildContext context, Manga manga, Chapter chapter) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Chapter Complete!'),
          content: Text('You\'ve finished reading "${chapter.title}". Would you like to continue to the next chapter?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text('Back to Details'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to next chapter if available
                final nextChapterIndex = manga.chapters.indexWhere((c) => c.id == chapter.id) + 1;
                if (nextChapterIndex < manga.chapters.length) {
                  Navigator.pushReplacementNamed(
                    context,
                    '/reader',
                    arguments: {
                      'manga': manga,
                      'chapter': manga.chapters[nextChapterIndex],
                    },
                  );
                } else {
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF06b6d4),
                foregroundColor: Colors.white,
              ),
              child: Text('Next Chapter'),
            ),
          ],
        );
      },
    );
  }
}
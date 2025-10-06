import 'package:flutter/material.dart';
import '../models/manga.dart';

class DetailScreen extends StatefulWidget {
  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool isFollowed = false;
  bool isLiked = false;

  @override
  Widget build(BuildContext context) {
    final Manga manga = ModalRoute.of(context)!.settings.arguments as Manga;
    
    setState(() {
      isFollowed = manga.isFollowed;
      isLiked = manga.isLiked;
    });

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    manga.cover,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.share),
                onPressed: () {},
              ),
            ],
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and basic info
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              manga.title,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1e293b),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'by ${manga.author}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: manga.status == 'ongoing' 
                              ? Color(0xFF06b6d4).withOpacity(0.1)
                              : Color(0xFF10b981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          manga.status.toUpperCase(),
                          style: TextStyle(
                            color: manga.status == 'ongoing' 
                                ? Color(0xFF06b6d4)
                                : Color(0xFF10b981),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  // Rating and views
                  Row(
                    children: [
                      Icon(Icons.star, color: Color(0xFFfbbf24), size: 20),
                      SizedBox(width: 4),
                      Text(
                        manga.rating.toString(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 16),
                      Icon(Icons.visibility, color: Colors.grey[600], size: 20),
                      SizedBox(width: 4),
                      Text(
                        '${manga.views ~/ 1000}K views',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              isFollowed = !isFollowed;
                            });
                          },
                          icon: Icon(
                            isFollowed ? Icons.check : Icons.add,
                            color: Colors.white,
                          ),
                          label: Text(
                            isFollowed ? 'Following' : 'Follow',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isFollowed 
                                ? Colors.grey[600] 
                                : Color(0xFF06b6d4),
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            isLiked = !isLiked;
                          });
                        },
                        icon: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? Colors.white : Color(0xFFec4899),
                        ),
                        label: Text(
                          'Like',
                          style: TextStyle(
                            color: isLiked ? Colors.white : Color(0xFFec4899),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isLiked 
                              ? Color(0xFFec4899) 
                              : Colors.white,
                          side: BorderSide(color: Color(0xFFec4899)),
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24),

                  // Genres
                  Text(
                    'Genres',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1e293b),
                    ),
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: manga.genres.map((genre) {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Color(0xFF06b6d4).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          genre,
                          style: TextStyle(
                            color: Color(0xFF06b6d4),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  SizedBox(height: 24),

                  // Description
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1e293b),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    manga.description,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.grey[700],
                    ),
                  ),

                  SizedBox(height: 24),

                  // Chapters
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Chapters (${manga.chapters.length})',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1e293b),
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text('Sort by'),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: manga.chapters.length,
                    itemBuilder: (context, index) {
                      final chapter = manga.chapters[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Color(0xFF06b6d4).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                chapter.number.toString(),
                                style: TextStyle(
                                  color: Color(0xFF06b6d4),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            chapter.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            chapter.releaseDate,
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          trailing: chapter.isRead
                              ? Icon(Icons.check_circle, color: Color(0xFF10b981))
                              : Icon(Icons.play_arrow, color: Color(0xFF06b6d4)),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/reader',
                              arguments: {
                                'manga': manga,
                                'chapter': chapter,
                              },
                            );
                          },
                        ),
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

import 'package:flutter/material.dart';
import '../models/manga.dart';
import '../data/mock_data.dart';
import '../screens/temp.dart';
import '../screens/location_screen.dart';
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Manga> _filteredManga = MockData.mangaList;

  void _filterManga(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredManga = MockData.mangaList;
      } else {
        _filteredManga = MockData.mangaList
            .where((manga) =>
                manga.title.toLowerCase().contains(query.toLowerCase()) ||
                manga.genres.any((genre) =>
                    genre.toLowerCase().contains(query.toLowerCase())))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Truyện Tranh',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1e293b),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thanh tìm kiếm
            Padding(
              padding: EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: _filterManga,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm truyện tranh...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
            ),

            // Banner nổi bật
            Container(
              height: 200,
              child: PageView.builder(
                itemCount: MockData.featuredManga.length,
                itemBuilder: (context, index) {
                  final manga = MockData.featuredManga[index];
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF06b6d4).withOpacity(0.8),
                          Color(0xFFec4899).withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            manga.cover,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
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
                        Positioned(
                          bottom: 20,
                          left: 20,
                          right: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                manga.title,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                manga.description,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 24),

            // Thể loại phổ biến
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Thể Loại Phổ Biến',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1e293b),
                ),
              ),
            ),
            SizedBox(height: 12),
            Container(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: MockData.popularGenres.length,
                itemBuilder: (context, index) {
                  final genre = MockData.popularGenres[index];
                  return Container(
                    margin: EdgeInsets.only(right: 8),
                    child: Chip(
                      label: Text(genre),
                      backgroundColor: Color(0xFF06b6d4).withOpacity(0.1),
                      labelStyle: TextStyle(
                        color: Color(0xFF06b6d4),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 24),

            // Danh sách truyện tranh
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Tất Cả Truyện Tranh',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1e293b),
                ),
              ),
            ),
            SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _filteredManga.length,
              itemBuilder: (context, index) {
                final manga = _filteredManga[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/detail',
                      arguments: manga,
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: Image.network(
                              manga.cover,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(12),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                manga.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 14,
                                    color: Color(0xFFfbbf24),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    manga.rating.toString(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                    '${manga.views ~/ 1000}K lượt xem', // Đổi text thành tiếng Việt
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Wrap(
                                spacing: 4,
                                children: manga.genres.take(2).map((genre) {
                                  return Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFec4899).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      genre,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFFec4899),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TemperatureConverterScreen()),
              );
            },
            backgroundColor: const Color(0xFF06b6d4),
            child: const Icon(Icons.thermostat, color: Colors.white),
          ),
          const SizedBox(width: 12), // khoảng cách giữa 2 nút
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LocationScreen()),
              );
            },
            backgroundColor: Colors.green,
            child: const Icon(Icons.location_on, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

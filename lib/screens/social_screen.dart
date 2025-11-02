import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:lory/screens/notification_screen.dart';
import 'package:lory/screens/user_profile_screen.dart';
import 'package:lory/screens/widgets/search_and_filter_widget.dart';
import 'package:lory/screens/widgets/post_card_widget.dart';
import 'package:lory/screens/widgets/comment_section_widget.dart';
import 'package:lory/services/notification_service.dart';
import 'package:lory/screens/messaging_screen.dart';
import '../models/notification.dart' as notif_model;
import '../services/cloudinary_service.dart';
import '../services/firestore_service.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../models/user.dart';
import '../utils/time_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SocialScreen extends StatefulWidget {
  @override
  _SocialScreenState createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  late TabController _tabController;
  String _sortBy = 'latest';

  final TextEditingController _searchController = TextEditingController();
  String _selectedTag = '';
  final List<String> _suggestedTags = [
    'thảo_luận',
    'gợi_ý_truyện',
    'spoiler',
    'tin_nhóm_dịch',
    'meme',
    'fanart',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cộng Đồng',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
        elevation: 0,
        actions: [
          StreamBuilder<int>(
            stream: NotificationService()
                .unreadCountStream(_auth.currentUser?.uid ?? ''),
            builder: (context, snapshot) {
              final unreadCount = snapshot.data ?? 0;

              return Stack(
                children: [
                  IconButton(
                    icon: Icon(Icons.notifications_outlined,
                        color: Color(0xFF06b6d4)),
                    onPressed: () => _showNotificationScreen(),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          unreadCount > 99 ? '99+' : unreadCount.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.sort, color: Color(0xFF06b6d4)),
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'latest',
                child: Row(
                  children: [
                    Icon(Icons.access_time, color: Color(0xFF06b6d4)),
                    SizedBox(width: 12),
                    Text('Mới nhất'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'popular',
                child: Row(
                  children: [
                    Icon(Icons.trending_up, color: Color(0xFFec4899)),
                    SizedBox(width: 12),
                    Text('Nhiều tương tác'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.message_outlined, color: Color(0xFF06b6d4)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MessagingScreen()),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Color(0xFF06b6d4),
          labelColor: Color(0xFF06b6d4),
          unselectedLabelColor: isDark ? Colors.white60 : Colors.black54,
          tabs: [
            Tab(icon: Icon(Icons.home), text: 'Bảng tin'),
            Tab(icon: Icon(Icons.person), text: 'Của bạn'),
            Tab(icon: Icon(Icons.group), text: 'Theo dõi'),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_tabController.index < 2)
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('posts')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                final allPosts = snapshot.hasData
                    ? snapshot.data!.docs
                        .map((doc) =>
                            Post.fromJson(doc.data() as Map<String, dynamic>))
                        .toList()
                    : <Post>[]; // ensure typed as List<Post>

                return SearchAndFilterWidget(
                  searchController: _searchController,
                  selectedTag: _selectedTag,
                  suggestedTags: _suggestedTags,
                  allPosts: allPosts,
                  onSearchChanged: (value) {
                    if (value.isEmpty) {
                      setState(() {
                        _selectedTag = '';
                      });
                    } else {
                      setState(() {});
                    }
                  },
                  onTagSelected: (tag) => setState(() => _selectedTag = tag),
                );
              },
            ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFeedTab(),
                _buildMyPostsTab(),
                _buildFollowingTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePostDialog(),
        backgroundColor: Color(0xFF06b6d4),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // ===== TAB 1: BẢNG TIN =====
  Widget _buildFeedTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState('Chưa có bài đăng nào', Icons.post_add);
        }

        final docs = snapshot.data!.docs;
        final posts = docs
            .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
            .toList();

        if (_sortBy == 'popular') {
          posts.sort(
              (a, b) => b.totalInteractions.compareTo(a.totalInteractions));
        }

        final filteredPosts = posts.where((post) {
          final searchText = _searchController.text.toLowerCase();
          
          // If search contains hashtag, filter by tags
          if (searchText.contains('#')) {
            final hashIndex = searchText.lastIndexOf('#');
            final tagQuery = searchText.substring(hashIndex + 1).trim();
            
            final tagMatch = tagQuery.isEmpty || 
                post.tags.any((tag) => tag.toLowerCase().contains(tagQuery));
            
            return tagMatch;
          }
          
          // Otherwise filter by content and user name
          final searchMatch = searchText.isEmpty ||
              post.content.toLowerCase().contains(searchText) ||
              post.user.name.toLowerCase().contains(searchText);
          
          // Filter by selected tag from buttons
          final selectedTagMatch = _selectedTag.isEmpty ||
              post.tags.any((tag) => tag.toLowerCase() == _selectedTag.toLowerCase());
          
          return searchMatch && selectedTagMatch;
        }).toList();

        if (filteredPosts.isEmpty) {
          return _buildEmptyState(
            _searchController.text.isNotEmpty || _selectedTag.isNotEmpty
                ? 'Không tìm thấy bài viết'
                : 'Chưa có bài đăng nào',
            Icons.search,
          );
        }

        return _buildPostList(filteredPosts, isDark);
      },
    );
  }

  // ===== TAB 2: BÀI VIẾT CỦA BẠN =====
  Widget _buildMyPostsTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      return _buildEmptyState('Vui lòng đăng nhập', Icons.login);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('posts')
          .where('user.id', isEqualTo: currentUser.uid)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        List<Post> allPosts = [];

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          allPosts = snapshot.data!.docs
              .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
              .toList();
        }

        // Fetch shared posts from userSharedPosts collection
        return StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('userSharedPosts')
              .where('sharedByUserId', isEqualTo: currentUser.uid)
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, sharedSnapshot) {
            if (sharedSnapshot.hasData) {
              final sharedPosts = sharedSnapshot.data!.docs
                  .map((doc) =>
                      Post.fromJson(doc.data() as Map<String, dynamic>))
                  .toList();
              allPosts.addAll(sharedPosts);
              // Sort combined list by createdAt
              allPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            }

            if (allPosts.isEmpty) {
              return _buildEmptyState(
                'Bạn chưa đăng bài nào\nHãy chia sẻ suy nghĩ của bạn!',
                Icons.edit_note,
              );
            }

            final filteredPosts = allPosts.where((post) {
              final searchText = _searchController.text.toLowerCase();

              if (searchText.contains('#')) {
                final hashIndex = searchText.lastIndexOf('#');
                final tagQuery = searchText.substring(hashIndex + 1).trim();

                final tagMatch = tagQuery.isEmpty ||
                    post.tags.any((tag) =>
                        tag.toLowerCase().contains(tagQuery));

                return tagMatch;
              }

              final searchMatch = searchText.isEmpty ||
                  post.content.toLowerCase().contains(searchText) ||
                  post.user.name.toLowerCase().contains(searchText);

              final selectedTagMatch = _selectedTag.isEmpty ||
                  post.tags.any((tag) =>
                      tag.toLowerCase() == _selectedTag.toLowerCase());

              return searchMatch && selectedTagMatch;
            }).toList();

            if (filteredPosts.isEmpty) {
              return _buildEmptyState(
                'Không tìm thấy bài viết của bạn',
                Icons.search,
              );
            }

            return _buildPostList(filteredPosts, isDark);
          },
        );
      },
    );
  }

  // ===== TAB 3: THEO DÕI =====
  Widget _buildFollowingTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      return _buildEmptyState('Vui lòng đăng nhập', Icons.login);
    }

    return StreamBuilder<List<Post>>(
      stream: FirestoreService().getFollowingPostsStream(currentUser.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState(
            'Theo dõi nhóm dịch hoặc tác giả\nđể xem bài viết của họ ở đây!',
            Icons.group_add,
          );
        }

        final posts = snapshot.data ?? [];
        final filteredPosts = posts.where((post) {
          final searchText = _searchController.text.toLowerCase();

          if (searchText.contains('#')) {
            final hashIndex = searchText.lastIndexOf('#');
            final tagQuery = searchText.substring(hashIndex + 1).trim();

            final tagMatch = tagQuery.isEmpty ||
                post.tags.any((tag) => tag.toLowerCase().contains(tagQuery));

            return tagMatch;
          }

          final searchMatch = searchText.isEmpty ||
              post.content.toLowerCase().contains(searchText) ||
              post.user.name.toLowerCase().contains(searchText);

          final selectedTagMatch = _selectedTag.isEmpty ||
              post.tags.any((tag) =>
                  tag.toLowerCase() == _selectedTag.toLowerCase());

          return searchMatch && selectedTagMatch;
        }).toList();

        if (filteredPosts.isEmpty) {
          return _buildEmptyState(
            'Không tìm thấy bài viết',
            Icons.search,
          );
        }

        return _buildPostList(filteredPosts, isDark);
      },
    );
  }

  // ===== SHARED WIDGETS =====
  Widget _buildPostList(List<Post> posts, bool isDark) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
        await Future.delayed(Duration(milliseconds: 500));
      },
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 8),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return PostCardWidget(
            post: posts[index],
            isDark: isDark,
            onLike: _toggleLike,
            onComment: _showCommentsBottomSheet,
            onMoreOptions: _showPostOptions,
            onUserTap: _navigateToUserProfile,
            onImageTap: _showImageViewer,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ===== ACTION METHODS =====
  void _toggleLike(Post post) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      final firestoreService = FirestoreService();

      final isCurrentlyLiked = await firestoreService.hasUserLikedPost(
        post.id,
        currentUser.uid,
      );

      final success = await firestoreService.togglePostLike(
        post.id,
        currentUser.uid,
        isCurrentlyLiked,
      );

      if (!success) {
        throw Exception('Lỗi cập nhật like');
      }

      if (!isCurrentlyLiked) {
        final notifService = NotificationService();
        await notifService.createLikeNotification(
          postId: post.id,
          postOwnerId: post.user.id,
          fromUser: User(
            id: currentUser.uid,
            name: currentUser.displayName ?? 'Anonymous',
            avatar: currentUser.photoURL ?? '',
            bio: '',
            followers: 0,
            following: 0,
            favoriteGenres: [],
          ),
        );
      }
    } catch (e) {
      print('Error toggling like: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showCreatePostDialog() {
    final TextEditingController contentController = TextEditingController();
    List<String> selectedTags = [];
    List<File> selectedImages = [];
    bool isUploading = false;

    final availableTags = _suggestedTags;
    final cloudinaryService = CloudinaryService();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
              title: Text('Tạo Bài Đăng'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: contentController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Bạn đang nghĩ gì về truyện tranh?',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: isUploading
                              ? null
                              : () async {
                                  try {
                                    final images =
                                        await cloudinaryService
                                            .pickMultipleImagesFromGallery(
                                                limit: 5);
                                    if (images.isNotEmpty) {
                                      setState(() {
                                        selectedImages = images;
                                      });
                                    }
                                  } catch (e) {
                                    print('Error picking images: $e');
                                  }
                                },
                          icon: Icon(Icons.image),
                          label: Text('Chọn ảnh'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF06b6d4),
                            foregroundColor: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        if (selectedImages.isNotEmpty)
                          Text(
                            '${selectedImages.length} ảnh',
                            style: TextStyle(
                              color: Color(0xFF06b6d4),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                    if (selectedImages.isNotEmpty) ...[
                      SizedBox(height: 12),
                      _buildImagePreviewList(selectedImages, setState),
                    ],
                    SizedBox(height: 16),
                    Text('Tags:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Nhập tags (ví dụ: #manga #action #drama). Mỗi tag bắt buộc phải có #',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: Icon(Icons.tag),
                      ),
                      onChanged: (value) {
                        setState(() {
                          // Parse tags từ input: tách theo khoảng trắng và lọc những có #
                          selectedTags = value
                              .split(RegExp(r'\s+'))
                              .where((tag) => tag.startsWith('#') && tag.length > 1)
                              .map((tag) => tag.substring(1)) // Remove # từ tag
                              .toList();
                        });
                      },
                    ),
                    if (selectedTags.isNotEmpty) ...[
                      SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: selectedTags.map((tag) {
                          return Chip(
                            label: Text('#$tag'),
                            onDeleted: () {
                              setState(() {
                                selectedTags.remove(tag);
                              });
                            },
                            backgroundColor: Color(0xFFec4899),
                            labelStyle: TextStyle(color: Colors.white),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: isUploading || contentController.text.isEmpty
                      ? null
                      : () async {
                          setState(() => isUploading = true);
                          try {
                            await _createPost(
                              contentController.text,
                              selectedTags,
                              selectedImages,
                            );
                            if (mounted) {
                              Navigator.pop(context);
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Lỗi: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } finally {
                            if (mounted) {
                              setState(() => isUploading = false);
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF06b6d4),
                    foregroundColor: Colors.white,
                  ),
                  child: isUploading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Text('Đăng'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildImagePreviewList(
    List<File> images,
    StateSetter setState,
  ) {
    return Container(
      height: 100,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(
            images.length,
            (index) {
              return Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    margin: EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: FileImage(images[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 12,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          images.removeAt(index);
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close,
                            color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _createPost(
    String content,
    List<String> tags,
    List<File> imageFiles,
  ) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('Vui lòng đăng nhập');
    }

    try {
      List<String> imageUrls = [];
      if (imageFiles.isNotEmpty) {
        try {
          final cloudinaryService = CloudinaryService();
          imageUrls = await cloudinaryService.uploadPostImages(imageFiles);
        } catch (e) {
          throw Exception('Lỗi upload ảnh: ${e.toString()}');
        }
      }

      final user = User(
        id: currentUser.uid,
        name: currentUser.displayName ?? 'Anonymous',
        avatar: currentUser.photoURL ?? 'https://via.placeholder.com/150',
        bio: '',
        followers: 0,
        following: 0,
        favoriteGenres: [],
      );

      final newPost = Post(
        id: _firestore.collection('posts').doc().id,
        user: user,
        content: content,
        images: imageUrls,
        tags: tags,
        createdAt: DateTime.now(),
      );

      try {
        await _firestore
            .collection('posts')
            .doc(newPost.id)
            .set(newPost.toJson());

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Đã đăng bài thành công!'),
              backgroundColor: Color(0xFF10b981),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        throw Exception('Lỗi lưu bài viết: ${e.toString()}');
      }
    } catch (e) {
      print('Error creating post: $e');
      rethrow;
    }
  }

  void _showPostOptions(Post post) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_auth.currentUser?.uid == post.user.id) ...[
                ListTile(
                  leading: Icon(Icons.edit, color: Color(0xFF06b6d4)),
                  title: Text('Chỉnh sửa'),
                  onTap: () {
                    Navigator.pop(context);
                    _showEditPostDialog(post);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Xóa', style: TextStyle(color: Colors.red)),
                  onTap: () async {
                    Navigator.pop(context);
                    try {
                      await _firestore
                          .collection('posts')
                          .doc(post.id)
                          .delete();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Đã xóa bài viết')),
                      );
                    } catch (e) {
                      print('Error deleting post: $e');
                    }
                  },
                ),
              ] else ...[
                ListTile(
                  leading: Icon(Icons.flag, color: Colors.orange),
                  title: Text('Báo cáo'),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Report post
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _showEditPostDialog(Post post) {
    final contentController = TextEditingController(text: post.content);
    final tagsController = TextEditingController(text: post.tags.join(', '));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Chỉnh sửa bài viết'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: contentController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Nội dung bài viết',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: tagsController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Tags (cách nhau bằng dấu phẩy)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  final updatedTags = tagsController.text
                      .split(',')
                      .map((tag) => tag.trim())
                      .where((tag) => tag.isNotEmpty)
                      .toList();

                  await _firestore
                      .collection('posts')
                      .doc(post.id)
                      .update({
                    'content': contentController.text,
                    'tags': updatedTags,
                  });

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Cập nhật bài viết thành công')),
                    );
                  }
                } catch (e) {
                  print('Error updating post: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi cập nhật bài viết')),
                  );
                }
              },
              child: Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  void _showCommentsBottomSheet(Post post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return Container(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 40,
                        child: IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Bình luận',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                              ),
                            ),
                            SizedBox(height: 4),
                            StreamBuilder<int>(
                              stream: FirestoreService()
                                  .getCommentCountStream(post.id),
                              builder: (context, snapshot) {
                                final totalCount = snapshot.data ?? 0;
                                return Text(
                                  '$totalCount bình luận',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color
                                        ?.withOpacity(0.6),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 40),
                    ],
                  ),
                  SizedBox(height: 16),
                  Divider(height: 1),
                  SizedBox(height: 16),
                  Expanded(
                    child: CommentSectionWidget(
                      postId: post.id,
                      onUserTap: _navigateToUserProfile,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _navigateToUserProfile(User user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfileScreen(user: user),
      ),
    );
  }

  void _showNotificationScreen() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng đăng nhập')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationScreen(userId: currentUser.uid),
      ),
    );
  }

  void _showImageViewer(
      BuildContext context, List<String> images, int initialIndex) {
    final PageController pageController =
        PageController(initialPage: initialIndex);
    int currentPage = initialIndex;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: StatefulBuilder(
          builder: (context, setState) {
            return Stack(
              children: [
                PageView.builder(
                  itemCount: images.length,
                  controller: pageController,
                  onPageChanged: (index) {
                    setState(() {
                      currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: Center(
                        child: CachedNetworkImage(
                          imageUrl: images[index],
                          fit: BoxFit.contain,
                          placeholder: (context, url) =>
                              CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                          errorWidget: (context, url, error) => Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error,
                                  color: Colors.white, size: 64),
                              SizedBox(height: 16),
                              Text('Không tải được ảnh',
                                  style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Positioned(
                  top: 40,
                  right: 16,
                  child: IconButton(
                    icon: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, color: Colors.white, size: 24),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                if (images.length > 1)
                  Positioned(
                    bottom: 40,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${currentPage + 1} / ${images.length}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

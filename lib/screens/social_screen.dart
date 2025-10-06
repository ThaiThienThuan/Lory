import 'package:flutter/material.dart';
import '../models/post.dart';
import '../data/mock_data.dart';

class SocialScreen extends StatefulWidget {
  @override
  _SocialScreenState createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  List<Post> posts = MockData.posts;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Community',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1e293b),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Simulate refresh
          await Future.delayed(Duration(seconds: 1));
          setState(() {
            posts = MockData.posts;
          });
        },
        child: ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 8),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return _buildPostCard(post);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreatePostDialog(context);
        },
        backgroundColor: Color(0xFF06b6d4),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildPostCard(Post post) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info header
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(post.user.avatar),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.user.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _formatTimeAgo(post.createdAt),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.more_vert),
                  onPressed: () {
                    _showPostOptions(context, post);
                  },
                ),
              ],
            ),

            SizedBox(height: 12),

            // Post content
            Text(
              post.content,
              style: TextStyle(
                fontSize: 16,
                height: 1.4,
              ),
            ),

            // Manga reference if exists
            if (post.mangaReference != null) ...[
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFF06b6d4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Color(0xFF06b6d4).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.book,
                      color: Color(0xFF06b6d4),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Referenced: ${_getMangaTitle(post.mangaReference!)}',
                      style: TextStyle(
                        color: Color(0xFF06b6d4),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Post images
            if (post.images.isNotEmpty) ...[
              SizedBox(height: 12),
              Container(
                height: 200,
                child: post.images.length == 1
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          post.images[0],
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: post.images.length,
                        itemBuilder: (context, index) {
                          return Container(
                            width: 200,
                            margin: EdgeInsets.only(right: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                post.images[index],
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],

            SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                _buildActionButton(
                  icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
                  label: post.likes.toString(),
                  color: post.isLiked ? Color(0xFFec4899) : Colors.grey[600]!,
                  onTap: () {
                    setState(() {
                      final index = posts.indexOf(post);
                      posts[index] = Post(
                        id: post.id,
                        user: post.user,
                        content: post.content,
                        images: post.images,
                        createdAt: post.createdAt,
                        likes: post.isLiked ? post.likes - 1 : post.likes + 1,
                        comments: post.comments,
                        shares: post.shares,
                        isLiked: !post.isLiked,
                        mangaReference: post.mangaReference,
                      );
                    });
                  },
                ),
                SizedBox(width: 24),
                _buildActionButton(
                  icon: Icons.chat_bubble_outline,
                  label: post.comments.toString(),
                  color: Colors.grey[600]!,
                  onTap: () {
                    _showCommentsBottomSheet(context, post);
                  },
                ),
                SizedBox(width: 24),
                _buildActionButton(
                  icon: Icons.share_outlined,
                  label: post.shares.toString(),
                  color: Colors.grey[600]!,
                  onTap: () {
                    _showShareOptions(context, post);
                  },
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.bookmark_border),
                  onPressed: () {},
                  color: Colors.grey[600],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String _getMangaTitle(String mangaId) {
    final manga = MockData.mangaList.firstWhere(
      (m) => m.id == mangaId,
      orElse: () => MockData.mangaList[0],
    );
    return manga.title;
  }

  void _showCreatePostDialog(BuildContext context) {
    final TextEditingController contentController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Create Post'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: contentController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'What\'s on your mind about manga?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.image, color: Color(0xFF06b6d4)),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(Icons.book, color: Color(0xFFec4899)),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (contentController.text.isNotEmpty) {
                  // Add new post logic here
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Post created!')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF06b6d4),
                foregroundColor: Colors.white,
              ),
              child: Text('Post'),
            ),
          ],
        );
      },
    );
  }

  void _showPostOptions(BuildContext context, Post post) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.bookmark_outline),
                title: Text('Save Post'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: Icon(Icons.report_outlined),
                title: Text('Report Post'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: Icon(Icons.block),
                title: Text('Hide from ${post.user.name}'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCommentsBottomSheet(BuildContext context, Post post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Comments (${post.comments})',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: 5, // Mock comments
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: CircleAvatar(
                            radius: 16,
                            backgroundImage: NetworkImage(
                              '/placeholder.svg?height=32&width=32',
                            ),
                          ),
                          title: Text('User ${index + 1}'),
                          subtitle: Text('This is a sample comment about the post.'),
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: Colors.grey[300]!)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Write a comment...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.send, color: Color(0xFF06b6d4)),
                          onPressed: () {},
                        ),
                      ],
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

  void _showShareOptions(BuildContext context, Post post) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Share Post',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildShareOption(Icons.copy, 'Copy Link'),
                  _buildShareOption(Icons.message, 'Message'),
                  _buildShareOption(Icons.share, 'More'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShareOption(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFF06b6d4).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Color(0xFF06b6d4)),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
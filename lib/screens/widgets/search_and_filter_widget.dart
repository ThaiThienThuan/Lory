import 'package:flutter/material.dart';
import '../../models/post.dart';

class SearchAndFilterWidget extends StatefulWidget {
  final TextEditingController searchController;
  final String selectedTag;
  final List<String> suggestedTags;
  final List<Post> allPosts;
  final Function(String) onSearchChanged;
  final Function(String) onTagSelected;

  const SearchAndFilterWidget({
    required this.searchController,
    required this.selectedTag,
    required this.suggestedTags,
    required this.allPosts,
    required this.onSearchChanged,
    required this.onTagSelected,
  });

  @override
  State<SearchAndFilterWidget> createState() => _SearchAndFilterWidgetState();
}

class _SearchAndFilterWidgetState extends State<SearchAndFilterWidget> {
  FocusNode? _searchFocusNode;
  List<String> _tagSuggestions = [];
  String _currentTagInput = '';

  @override
  void initState() {
    super.initState();
    _searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _searchFocusNode?.dispose();
    super.dispose();
  }

  List<String> _getAllAvailableTags() {
    final Set<String> allTags = {};
    for (var post in widget.allPosts) {
      allTags.addAll(post.tags);
    }
    return allTags.toList()..sort();
  }

  void _updateTagSuggestions(String input) {
    final searchText = input.toLowerCase();
    final allTags = _getAllAvailableTags();
    
    setState(() {
      _currentTagInput = input;
      if (input.isEmpty) {
        _tagSuggestions = [];
      } else {
        _tagSuggestions = allTags
            .where((tag) => tag.toLowerCase().contains(searchText))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(context),
        _buildTagSuggestionDropdown(),
        _buildTagFilterBar(),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      color: Theme.of(context).cardTheme.color,
      child: Stack(
        children: [
          TextField(
            controller: widget.searchController,
            focusNode: _searchFocusNode,
            onChanged: (value) {
              widget.onSearchChanged(value);
              if (value.contains('#')) {
                final lastHashIndex = value.lastIndexOf('#');
                final afterHash = value.substring(lastHashIndex + 1);
                _updateTagSuggestions(afterHash);
              } else {
                _updateTagSuggestions('');
              }
            },
            decoration: InputDecoration(
              hintText: 'Tìm kiếm bài viết... (dùng #tag để tìm theo tags)',
              prefixIcon: Icon(Icons.search, color: Color(0xFF06b6d4)),
              suffixIcon: widget.searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        widget.searchController.clear();
                        widget.onSearchChanged('');
                        _updateTagSuggestions('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide(color: Color(0xFF06b6d4), width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide(color: Color(0xFF06b6d4), width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide(color: Color(0xFF06b6d4), width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagSuggestionDropdown() {
    if (_tagSuggestions.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      color: Theme.of(context).cardTheme.color,
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFF06b6d4), width: 1),
          ),
        ),
        child: ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _tagSuggestions.length,
          separatorBuilder: (context, index) =>
              Divider(height: 1, color: Colors.grey.withOpacity(0.3)),
          itemBuilder: (context, index) {
            final tag = _tagSuggestions[index];
            return ListTile(
              dense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              leading: Icon(Icons.tag, size: 18, color: Color(0xFFec4899)),
              title: Text(
                '#$tag',
                style: TextStyle(fontSize: 14),
              ),
              onTap: () {
                final currentText = widget.searchController.text;
                final lastHashIndex = currentText.lastIndexOf('#');
                final newText = currentText.substring(0, lastHashIndex) + '#$tag';
                
                widget.searchController.text = newText;
                widget.onSearchChanged(newText);
                widget.onTagSelected(tag);
                _updateTagSuggestions('');
                
                // Unfocus to hide dropdown
                _searchFocusNode?.unfocus();
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildTagFilterBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [],
        ),
      ),
    );
  }

  // Filter posts theo search + tag
  static List<Post> filterPosts(
    List<Post> posts,
    String searchQuery,
    String selectedTag,
  ) {
    return posts.where((post) {
      // Filter theo search query
      final searchMatch = searchQuery.isEmpty ||
          post.content.toLowerCase().contains(searchQuery.toLowerCase()) ||
          post.user.name.toLowerCase().contains(searchQuery.toLowerCase());

      // Filter theo tags
      final tagMatch = selectedTag.isEmpty ||
          post.tags.any((tag) => tag.toLowerCase() == selectedTag.toLowerCase());

      return searchMatch && tagMatch;
    }).toList();
  }
}

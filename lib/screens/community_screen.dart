import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/post_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../config/network_config.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  List<Post> _posts = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _currentUserId;

  // Discord community link - replace with your actual Discord invite
  static const String _discordInviteUrl = 'https://discord.gg/programming';

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadPosts();
  }

  Future<void> _loadCurrentUser() async {
    final userId = await StorageService.getUserId();
    if (mounted) {
      setState(() {
        _currentUserId = userId;
      });
    }
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('🔄 CommunityScreen: Loading posts...');
      final postsData = await ApiService.getCommunityPosts();
      print('📦 CommunityScreen: Received ${postsData.length} posts');

      final posts = postsData.map((json) {
        // Debug: Print author data to see what we're receiving
        print('📄 Post: ${json['_id']} - "${json['title']}"');
        print('   👤 author object: ${json['author']}');
        print('   👤 authorId: ${json['authorId']}');
        print('   👤 authorName (direct): ${json['authorName']}');
        
        final post = Post.fromJson(json);
        print('   ✅ Parsed authorName: ${post.authorName}');
        return post;
      }).toList();

      setState(() {
        _posts = posts;
        _isLoading = false;
      });
      print('✅ CommunityScreen: ${_posts.length} posts loaded successfully');
    } catch (e) {
      print('❌ CommunityScreen: Error loading posts: $e');
      setState(() {
        _errorMessage =
            e.toString().contains('HTTP') || e.toString().contains('Failed')
                ? 'Network error. Please check your connection and try again.'
                : 'Failed to load posts. Please try again later.';
        _isLoading = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '${years}y ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Color _getRoleBadgeColor(String? role) {
    if (role?.toLowerCase() == 'admin') {
      return Colors.red;
    }
    return Colors.blue; // Student (default)
  }

  Future<void> _showCreatePostDialog() async {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Create Post', style: GoogleFonts.poppins()),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                style: GoogleFonts.poppins(),
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: GoogleFonts.poppins(),
                  hintText: 'Enter post title',
                  hintStyle: GoogleFonts.poppins(),
                  border: const OutlineInputBorder(),
                ),
                maxLength: 100,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                style: GoogleFonts.poppins(),
                decoration: InputDecoration(
                  labelText: 'Content',
                  labelStyle: GoogleFonts.poppins(),
                  hintText: 'What\'s on your mind?',
                  hintStyle: GoogleFonts.poppins(),
                  border: const OutlineInputBorder(),
                ),
                maxLines: 5,
                maxLength: 500,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isEmpty ||
                  contentController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please fill in both title and content',
                        style: GoogleFonts.poppins()),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              Navigator.pop(context, true);
            },
            child: Text('Post', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      try {
        await ApiService.createCommunityPost(
          title: titleController.text.trim(),
          content: contentController.text.trim(),
        );

        if (!mounted) return;
        Navigator.pop(context); // Close loading dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Post created successfully!',
                style: GoogleFonts.poppins()),
            backgroundColor: Colors.green,
          ),
        );

        // Reload posts
        _loadPosts();
      } catch (e) {
        if (!mounted) return;
        Navigator.pop(context); // Close loading dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Failed to create post: $e', style: GoogleFonts.poppins()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    titleController.dispose();
    contentController.dispose();
  }

  /// Toggle like on a post
  Future<void> _toggleLike(Post post) async {
    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please log in to like posts', style: GoogleFonts.poppins()),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Optimistic UI update
    final wasLiked = post.isLikedBy(_currentUserId!);
    final postIndex = _posts.indexWhere((p) => p.id == post.id);
    
    if (postIndex != -1) {
      setState(() {
        final updatedLikedBy = List<String>.from(post.likedBy);
        if (wasLiked) {
          updatedLikedBy.remove(_currentUserId);
        } else {
          updatedLikedBy.add(_currentUserId!);
        }
        _posts[postIndex] = post.copyWith(
          likes: wasLiked ? post.likes - 1 : post.likes + 1,
          likedBy: updatedLikedBy,
        );
      });
    }

    try {
      await ApiService.toggleLikePost(post.id);
      // Optionally refresh to sync with server
      // _loadPosts();
    } catch (e) {
      // Revert optimistic update on error
      if (postIndex != -1 && mounted) {
        setState(() {
          final revertedLikedBy = List<String>.from(_posts[postIndex].likedBy);
          if (wasLiked) {
            revertedLikedBy.add(_currentUserId!);
          } else {
            revertedLikedBy.remove(_currentUserId);
          }
          _posts[postIndex] = _posts[postIndex].copyWith(
            likes: wasLiked ? _posts[postIndex].likes + 1 : _posts[postIndex].likes - 1,
            likedBy: revertedLikedBy,
          );
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to like post. Please try again.', style: GoogleFonts.poppins()),
            backgroundColor: Colors.red,
          ),
        );
      }
      debugPrint('Like error: $e');
    }
  }

  /// Show comments dialog
  Future<void> _showCommentsDialog(Post post) async {
    final commentController = TextEditingController();
    bool isSubmitting = false;
    bool isLoadingComments = true;
    List<Comment> loadedComments = List.from(post.commentsList);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          // Load comments from API when dialog opens
          if (isLoadingComments) {
            ApiService.getPostComments(post.id).then((comments) {
              setModalState(() {
                loadedComments = comments;
                isLoadingComments = false;
              });
            }).catchError((e) {
              setModalState(() {
                isLoadingComments = false;
              });
              debugPrint('Failed to load comments: $e');
            });
          }

          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Title
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text(
                        'Comments (${loadedComments.length})',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Comments list
                Expanded(
                  child: isLoadingComments
                      ? const Center(child: CircularProgressIndicator())
                      : loadedComments.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey[400]),
                                  const SizedBox(height: 8),
                                  Text(
                                    'No comments yet',
                                    style: GoogleFonts.poppins(color: Colors.grey[600]),
                                  ),
                                  Text(
                                    'Be the first to comment!',
                                    style: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 12),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: loadedComments.length,
                              itemBuilder: (context, index) {
                                final comment = loadedComments[index];
                                return _buildCommentItem(comment);
                              },
                            ),
                ),
              // Add comment input
              Container(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                  top: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: commentController,
                        style: GoogleFonts.poppins(),
                        decoration: InputDecoration(
                          hintText: 'Write a comment...',
                          hintStyle: GoogleFonts.poppins(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        maxLines: 2,
                        minLines: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              if (commentController.text.trim().isEmpty) return;
                              
                              setModalState(() => isSubmitting = true);
                              
                              try {
                                await ApiService.addCommentToPost(
                                  postId: post.id,
                                  text: commentController.text.trim(),
                                );
                                commentController.clear();
                                Navigator.pop(context);
                                _loadPosts(); // Refresh posts
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Comment added!', style: GoogleFonts.poppins()),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } catch (e) {
                                setModalState(() => isSubmitting = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to add comment', style: GoogleFonts.poppins()),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                      icon: isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(Icons.send, color: Theme.of(context).primaryColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
        },
      ),
    );

    commentController.dispose();
  }

  Widget _buildCommentItem(Comment comment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.blue.withOpacity(0.2),
            backgroundImage: comment.profilePicture != null &&
                    comment.profilePicture!.isNotEmpty
                ? NetworkImage(
                    '${NetworkConfig.baseUrlWithoutApi}${comment.profilePicture}')
                : null,
            child: comment.profilePicture == null ||
                    comment.profilePicture!.isEmpty
                ? Text(
                    comment.userName.isNotEmpty ? comment.userName[0].toUpperCase() : '?',
                    style: GoogleFonts.poppins(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.userName,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(comment.createdAt),
                      style: GoogleFonts.poppins(
                        color: Colors.grey[500],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.text,
                  style: GoogleFonts.poppins(fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Delete a post (only for post owner)
  Future<void> _deletePost(Post post) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Post', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text(
          'Are you sure you want to delete this post? This action cannot be undone.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ApiService.deletePost(post.id);
        _loadPosts();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Post deleted', style: GoogleFonts.poppins()),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete post', style: GoogleFonts.poppins()),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// Open Discord community
  Future<void> _openDiscord() async {
    final uri = Uri.parse(_discordInviteUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open Discord', style: GoogleFonts.poppins()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildPostCard(Post post) {
    final isOwner = _currentUserId != null && post.authorId == _currentUserId;
    final isLiked = _currentUserId != null && post.isLikedBy(_currentUserId!);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author info row
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.blue.withOpacity(0.2),
                  backgroundImage: post.profilePicture != null &&
                          post.profilePicture!.isNotEmpty
                      ? NetworkImage(
                          '${NetworkConfig.baseUrlWithoutApi}${post.profilePicture}')
                      : null,
                  child: post.profilePicture == null ||
                          post.profilePicture!.isEmpty
                      ? Text(
                          post.authorName[0].toUpperCase(),
                          style: GoogleFonts.poppins(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            post.authorName,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (post.authorRole != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getRoleBadgeColor(post.authorRole),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                post.authorRole!.toUpperCase(),
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(post.createdAt),
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Delete button (only for post owner)
                if (isOwner)
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.red[400]),
                    onPressed: () => _deletePost(post),
                    tooltip: 'Delete post',
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // Post title
            Text(
              post.title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Post content preview
            Text(
              post.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: Colors.grey[800],
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            // Action buttons (Like & Comment)
            Row(
              children: [
                // Like button
                InkWell(
                  onTap: () => _toggleLike(post),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isLiked ? Colors.red.withOpacity(0.1) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          size: 20,
                          color: isLiked ? Colors.red : Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${post.likes}',
                          style: GoogleFonts.poppins(
                            color: isLiked ? Colors.red : Colors.grey[600],
                            fontWeight: isLiked ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Comment button
                InkWell(
                  onTap: () => _showCommentsDialog(post),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 20,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${post.comments}',
                          style: GoogleFonts.poppins(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header (matches main screen)
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF2c6894),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            child: Column(
              children: [
                // Centered header
                Text(
                  'COMMUNITY FORUM',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(
                        color: Colors.white.withOpacity(0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Discord Community Button
                InkWell(
                  onTap: _openDiscord,
                  borderRadius: BorderRadius.circular(25),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5865F2), // Discord brand color
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.discord,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Join Discord Community',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.open_in_new,
                          color: Colors.white70,
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _loadPosts,
                              icon: const Icon(Icons.refresh),
                              label:
                                  Text('Retry', style: GoogleFonts.poppins()),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      )
                    : _posts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.forum_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No posts yet',
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey[600],
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Be the first to start a discussion!',
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadPosts,
                            child: ListView.builder(
                              itemCount: _posts.length,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemBuilder: (context, index) {
                                return _buildPostCard(_posts[index]);
                              },
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePostDialog(),
        backgroundColor: const Color(0xFF2c6894),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

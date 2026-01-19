import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';

class GestureDetailScreen extends StatefulWidget {
  final Map<String, String> gestureData;

  const GestureDetailScreen({super.key, required this.gestureData});

  @override
  State<GestureDetailScreen> createState() => _GestureDetailScreenState();
}

class _GestureDetailScreenState extends State<GestureDetailScreen> {
  bool _isPracticeMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceWhite,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(context),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 32),
                      _buildVideoPlaceholder(),
                      const SizedBox(height: 32),
                      _buildPracticeSection(),
                      const SizedBox(height: 32),
                      _buildDescription(),
                      const SizedBox(height: 32),
                      _buildRelatedGestures(),
                       const SizedBox(height: 100), // Bottom padding
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_isPracticeMode) _buildPracticeOverlay(),
        ],
      ),
      floatingActionButton: _isPracticeMode ? null : FloatingActionButton.extended(
        onPressed: () => setState(() => _isPracticeMode = true),
        backgroundColor: AppTheme.logoSage,
        icon: const Icon(LucideIcons.camera),
        label: const Text("Practice Now", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.surfaceWhite,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: const Icon(LucideIcons.arrowLeft, color: AppTheme.primaryDark, size: 20),
        ),
        onPressed: () => context.pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: AppTheme.logoSage.withOpacity(0.1)),
            Center(
              child: Hero(
                tag: 'gesture_icon_${widget.gestureData['id']}',
                child: const Icon(LucideIcons.hand, size: 100, color: AppTheme.logoSage),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.gestureData['title'] ?? "Gesture",
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppTheme.primaryDark),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.logoSage.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.gestureData['category']?.toUpperCase() ?? "GENERAL",
                style: const TextStyle(fontSize: 10, color: AppTheme.logoSage, fontWeight: FontWeight.w800, letterSpacing: 1.2),
              ),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(LucideIcons.bookmark, color: AppTheme.primaryDark),
          onPressed: () {
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Added to bookmarks")));
          },
        ),
      ],
    );
  }

  Widget _buildVideoPlaceholder() {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: AppTheme.logoSage.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: 0.6,
            child: Icon(LucideIcons.playCircle, size: 64, color: Colors.white.withOpacity(0.5)),
          ),
          const Positioned(
            bottom: 16,
            child: Text("Animation Preview", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildPracticeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.logoSage.withOpacity(0.1), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.logoSage.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(LucideIcons.camera, color: AppTheme.logoSage),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Interactive Practice", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryDark)),
                Text("Use your camera to match the gesture.", style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("HOW TO PERFORM", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.5)),
        SizedBox(height: 12),
        Text(
          "1. Start with your hand open, palm facing forward.\n2. Slowly fold your fingers into a loose fist.\n3. Extend your thumb outwards.\n4. Hold the position for 2 seconds.",
          style: TextStyle(fontSize: 16, color: AppTheme.primaryDark, height: 1.6),
        ),
      ],
    );
  }
  
  Widget _buildRelatedGestures() {
     return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("RELATED", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.5)),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildRelatedCard("Thank You"),
              _buildRelatedCard("Please"),
              _buildRelatedCard("Sorry"),
            ],
          ),
        )
      ],
    );
  }
  
  Widget _buildRelatedCard(String title) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.hand, color: Colors.grey),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildPracticeOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black,
        child: Stack(
          children: [
            // Mock Camera Feed
             Center(
              child: Text("Camera Feed Active", style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 24)),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                onPressed: () => setState(() => _isPracticeMode = false),
                icon: const Icon(LucideIcons.x, color: Colors.white, size: 32),
              ),
            ),
            Positioned(
              bottom: 40,
              left: 0, right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text("Align your hand with the outline", style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

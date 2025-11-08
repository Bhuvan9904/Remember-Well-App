import 'package:flutter/material.dart';
import '../../../shared/widgets/gradient_background.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/repositories/memory_repository.dart';
import '../../../data/models/memory.dart';
import '../widgets/memory_list_card.dart';
import '../../memory/screens/memory_detail_screen.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  final _memoryRepo = MemoryRepository();
  final _searchController = TextEditingController();
  List<Memory> _allMemories = [];
  List<Memory> _filteredMemories = [];
  bool _isLoading = true;
  DateTime? _lastRefreshTime;

  @override
  void initState() {
    super.initState();
    _loadMemories();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data when screen becomes visible (for IndexedStack)
    // Only refresh if it's been a while since last refresh to avoid excessive calls
    final now = DateTime.now();
    if (_lastRefreshTime == null || 
        now.difference(_lastRefreshTime!).inSeconds > 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _loadMemories();
          _lastRefreshTime = now;
        }
      });
    }
  }

  void _loadMemories() {
    setState(() {
      _isLoading = false;
      _allMemories = _memoryRepo.getAll();
      _allMemories.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Newest first
      _filteredMemories = _allMemories;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredMemories = _allMemories;
      } else {
        _filteredMemories = _allMemories.where((memory) {
          return memory.text.toLowerCase().contains(query) ||
              (memory.who?.toLowerCase().contains(query) ?? false) ||
              (memory.tags?.any((tag) => tag.toLowerCase().contains(query)) ?? false);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Memory Vault',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          elevation: 0,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () async {
                  _loadMemories();
                },
                child: _buildContent(),
              ),
      ),
    );
  }

  Widget _buildContent() {
    if (_allMemories.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.folder_open,
        title: 'No Memories Yet',
        message: 'Start logging your memories to see them here!',
        buttonText: 'Add Your First Memory',
        onButtonTap: () async {
          await Navigator.of(context).pushNamed(AppRoutes.newMemory);
          _loadMemories();
        },
      );
    }

    return Column(
      children: [
        // Search bar
        _buildSearchBar(),
        
        // Memories list
        Expanded(
          child: _filteredMemories.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 80,
                        color: Colors.white.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No memories found',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try a different search term',
                        style: const TextStyle(
                          color: AppColors.subtext,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: _filteredMemories.length,
                  itemBuilder: (context, index) {
                    final memory = _filteredMemories[index];
                    return Column(
                      children: [
                        MemoryListCard(
                          memory: memory,
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => MemoryDetailScreen(memory: memory),
                              ),
                            );
                            _loadMemories();
                          },
                        ),
                        const SizedBox(height: 12),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.search,
            color: AppColors.subtext,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search memories, tags, people...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                border: InputBorder.none,
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(
                Icons.clear,
                color: AppColors.subtext,
              ),
              onPressed: () {
                _searchController.clear();
              },
            ),
        ],
      ),
    );
  }
}

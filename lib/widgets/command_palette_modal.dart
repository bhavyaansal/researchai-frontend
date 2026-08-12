import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import 'app_sidebar.dart';

class CommandPaletteItem {
  final IconData icon;
  final String title;
  final String category;
  final String shortcut;
  final VoidCallback onTap;

  const CommandPaletteItem({
    required this.icon,
    required this.title,
    required this.category,
    this.shortcut = '',
    required this.onTap,
  });
}

class CommandPaletteModal extends StatefulWidget {
  final ValueChanged<AppScreen> onNavigate;
  final VoidCallback onToggleTheme;
  final VoidCallback onLogout;

  const CommandPaletteModal({
    super.key,
    required this.onNavigate,
    required this.onToggleTheme,
    required this.onLogout,
  });

  static Future<void> show({
    required BuildContext context,
    required ValueChanged<AppScreen> onNavigate,
    required VoidCallback onToggleTheme,
    required VoidCallback onLogout,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (ctx) => CommandPaletteModal(
        onNavigate: onNavigate,
        onToggleTheme: onToggleTheme,
        onLogout: onLogout,
      ),
    );
  }

  @override
  State<CommandPaletteModal> createState() => _CommandPaletteModalState();
}

class _CommandPaletteModalState extends State<CommandPaletteModal> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  int _selectedIndex = 0;

  List<CommandPaletteItem> get _allItems => [
        CommandPaletteItem(
          icon: Icons.dashboard_rounded,
          title: 'Go to Dashboard',
          category: 'Navigation',
          shortcut: 'Ctrl+D',
          onTap: () {
            Navigator.pop(context);
            widget.onNavigate(AppScreen.dashboard);
          },
        ),
        CommandPaletteItem(
          icon: Icons.upload_file_rounded,
          title: 'Upload Document / Direct Text',
          category: 'Navigation',
          shortcut: 'Ctrl+U',
          onTap: () {
            Navigator.pop(context);
            widget.onNavigate(AppScreen.upload);
          },
        ),
        CommandPaletteItem(
          icon: Icons.analytics_rounded,
          title: 'View Plagiarism Report',
          category: 'Navigation',
          shortcut: '',
          onTap: () {
            Navigator.pop(context);
            widget.onNavigate(AppScreen.report);
          },
        ),
        CommandPaletteItem(
          icon: Icons.auto_fix_high_rounded,
          title: 'Open AI Mitigation Engine',
          category: 'Navigation',
          shortcut: 'Ctrl+M',
          onTap: () {
            Navigator.pop(context);
            widget.onNavigate(AppScreen.mitigation);
          },
        ),
        CommandPaletteItem(
          icon: Icons.history_rounded,
          title: 'Browse Reports History Archive',
          category: 'Navigation',
          shortcut: 'Ctrl+R',
          onTap: () {
            Navigator.pop(context);
            widget.onNavigate(AppScreen.reports);
          },
        ),
        CommandPaletteItem(
          icon: Icons.psychology_rounded,
          title: 'Open AI Paraphraser',
          category: 'Navigation',
          shortcut: '',
          onTap: () {
            Navigator.pop(context);
            widget.onNavigate(AppScreen.aichat);
          },
        ),
        CommandPaletteItem(
          icon: Icons.settings_rounded,
          title: 'Engine & Theme Settings',
          category: 'System',
          shortcut: '',
          onTap: () {
            Navigator.pop(context);
            widget.onNavigate(AppScreen.settings);
          },
        ),
        CommandPaletteItem(
          icon: Icons.brightness_6_rounded,
          title: 'Toggle Dark Pro / Warm Light Theme',
          category: 'Preferences',
          shortcut: '',
          onTap: () {
            Navigator.pop(context);
            widget.onToggleTheme();
          },
        ),
        CommandPaletteItem(
          icon: Icons.logout_rounded,
          title: 'Sign Out Account',
          category: 'Account',
          shortcut: 'Esc',
          onTap: () {
            Navigator.pop(context);
            widget.onLogout();
          },
        ),
      ];

  List<CommandPaletteItem> get _filteredItems {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _allItems;
    return _allItems
        .where((item) =>
            item.title.toLowerCase().contains(query) ||
            item.category.toLowerCase().contains(query))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      final items = _filteredItems;
      if (items.isEmpty) return;

      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        setState(() {
          _selectedIndex = (_selectedIndex + 1) % items.length;
        });
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        setState(() {
          _selectedIndex = (_selectedIndex - 1 + items.length) % items.length;
        });
      } else if (event.logicalKey == LogicalKeyboardKey.enter) {
        if (_selectedIndex >= 0 && _selectedIndex < items.length) {
          items[_selectedIndex].onTap();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredItems;
    final accentGreen = AppColors.accentGreen(context);

    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: _onKeyEvent,
      child: Center(
        child: SingleChildScrollView(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              width: 580,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard(context).withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.borderMid(context), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: accentGreen.withValues(alpha: 0.2),
                    blurRadius: 28,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 24,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar Input
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.search_rounded, color: accentGreen, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            autofocus: true,
                            onChanged: (_) => setState(() => _selectedIndex = 0),
                            style: TextStyle(
                              color: AppColors.textPrimary(context),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Type a command or search screens...',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated(context),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.borderSubtle(context)),
                          ),
                          child: const Text(
                            'ESC to close',
                            style: TextStyle(
                              color: Color(0xFF8888BB),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Color(0xFF252545), height: 1),

                  // Actions List
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 320),
                    child: items.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(28),
                            child: Center(
                              child: Text(
                                'No matching commands found',
                                style: TextStyle(color: Color(0xFF8888BB), fontSize: 13),
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: items.length,
                            itemBuilder: (context, i) {
                              final item = items[i];
                              final selected = i == _selectedIndex;

                              return MouseRegion(
                                onEnter: (_) => setState(() => _selectedIndex = i),
                                child: GestureDetector(
                                  onTap: item.onTap,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 100),
                                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                                    decoration: BoxDecoration(
                                      color: selected ? accentGreen.withValues(alpha: 0.15) : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: selected ? accentGreen.withValues(alpha: 0.5) : Colors.transparent,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          item.icon,
                                          size: 18,
                                          color: selected ? accentGreen : AppColors.textSecondary(context),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            item.title,
                                            style: TextStyle(
                                              color: selected ? AppColors.textPrimary(context) : AppColors.textSecondary(context),
                                              fontSize: 13.5,
                                              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                        if (item.shortcut.isNotEmpty)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: AppColors.surfaceElevated(context),
                                              borderRadius: BorderRadius.circular(5),
                                              border: Border.all(color: AppColors.borderSubtle(context)),
                                            ),
                                            child: Text(
                                              item.shortcut,
                                              style: const TextStyle(
                                                color: Color(0xFF8888BB),
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),

                  // Footer Tip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: Color(0xFF252545), width: 1)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('↑↓ to navigate · Enter to select',
                            style: TextStyle(color: Color(0xFF8888BB), fontSize: 10.5)),
                        Text('ResearchAI Command Palette',
                            style: TextStyle(color: accentGreen, fontSize: 10.5, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

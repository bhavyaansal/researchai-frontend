import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'widgets/app_sidebar.dart';
import 'widgets/airyai_header.dart';
import 'widgets/airyai_footer.dart';
import 'models/job_model.dart';
import 'services/auth_service.dart';
import 'services/api_service.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/dashboard_home_screen.dart';
import 'screens/upload_screen.dart';
import 'screens/plagiarism_report_screen.dart';
import 'screens/mitigation_screen.dart';
import 'screens/reports_history_screen.dart';
import 'screens/final_report_screen.dart';
import 'screens/ai_chat_screen.dart';
import 'screens/settings_screen.dart';
import 'widgets/command_palette_modal.dart';
import 'widgets/custom_toast.dart';

void main() {
  runApp(const ResearchAIApp());
}

class ResearchAIApp extends StatefulWidget {
  const ResearchAIApp({super.key});

  @override
  State<ResearchAIApp> createState() => _ResearchAIAppState();
}

class _ResearchAIAppState extends State<ResearchAIApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ResearchAI - Plagiarism Detection & Rewriting Platform',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      debugShowCheckedModeBanner: false,
      home: AuthGate(
        onToggleTheme: _toggleTheme,
        isDarkMode: _themeMode == ThemeMode.dark,
      ),
    );
  }
}

/// Decides whether to show Login/Signup or main app shell.
class AuthGate extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const AuthGate({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final AuthService _authService = AuthService();
  bool _showLogin = true;

  @override
  Widget build(BuildContext context) {
    if (!_authService.isLoggedIn) {
      if (_showLogin) {
        return LoginScreen(
          authService: _authService,
          onLoginSuccess: () => setState(() {}),
          onGoToSignup: () => setState(() => _showLogin = false),
          onGuestAccess: () {
            _authService.loginAsGuest();
            setState(() {});
          },
        );
      } else {
        return SignupScreen(
          authService: _authService,
          onSignupSuccess: () => setState(() {}),
          onGoToLogin: () => setState(() => _showLogin = true),
        );
      }
    }

    return AppShell(
      authService: _authService,
      onToggleTheme: widget.onToggleTheme,
      isDarkMode: widget.isDarkMode,
      onLogout: () {
        _authService.logout();
        setState(() => _showLogin = true);
      },
    );
  }
}

/// Main app shell — owns navigation, active job/report state, and shortcuts.
class AppShell extends StatefulWidget {
  final AuthService authService;
  final VoidCallback onLogout;
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const AppShell({
    super.key,
    required this.authService,
    required this.onLogout,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late final ApiService _api;
  AppScreen _current = AppScreen.upload;
  bool _sidebarCollapsed = false;
  String? _paraphraseInitialText;

  JobModel? _activeJob;
  ReportModel? _activeReport;
  bool _isPolling = false;

  final FocusNode _shellFocusNode = FocusNode();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    _api = ApiService(widget.authService.token);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Token length: ${widget.authService.token.length} | '
            'Logged in: ${widget.authService.isLoggedIn}',
          ),
        ),
     );
    });
  }

  @override
  void dispose() {
    _shellFocusNode.dispose();
    super.dispose();
  }

  void _onUploadSuccess(JobModel job) {
    setState(() {
      _activeJob = job;
      _isPolling = true;
    });
    _pollUntilDone(job.id);
  }

  Future<void> _pollUntilDone(String jobId) async {
    _api.pollJobStatus(jobId).listen((job) async {
      setState(() => _activeJob = job);
      if (job.isDone) {
        try {
          final report = await _api.getReport(jobId);
          setState(() {
            _activeReport = report;
            _isPolling = false;
            _current = AppScreen.report;
          });
        } catch (e) {
          setState(() => _isPolling = false);
          if (mounted) {
            CustomToast.show(
              context,
              title: 'Report Error',
              message: 'Failed to load report: $e',
              type: ToastType.error,
            );
          }
        }
      } else if (job.isFailed) {
        setState(() => _isPolling = false);
        if (mounted) {
          CustomToast.show(
            context,
            title: 'Scan Failed',
            message: job.errorMessage ?? 'Unknown error occurred during analysis.',
            type: ToastType.error,
          );
        }
      }
    });
  }

  void _navigate(AppScreen screen) {
    setState(() => _current = screen);
  }

  Future<void> _loadReportById(String jobId) async {
    try {
      final report = await _api.getReport(jobId);
      setState(() {
        _activeReport = report;
        _current = AppScreen.report;
      });
    } catch (e) {
      if (mounted) {
        CustomToast.show(
          context,
          title: 'Error Loading Report',
          message: e.toString(),
          type: ToastType.error,
        );
      }
    }
  }

  void _openParaphraserWithText(String text) {
    setState(() {
      _paraphraseInitialText = text;
      _current = AppScreen.aichat;
    });
  }

  void _showCommandPalette() {
    CommandPaletteModal.show(
      context: context,
      onNavigate: _navigate,
      onToggleTheme: widget.onToggleTheme,
      onLogout: widget.onLogout,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyK, control: true): _showCommandPalette,
        const SingleActivator(LogicalKeyboardKey.keyK, meta: true): _showCommandPalette,
        const SingleActivator(LogicalKeyboardKey.keyU, control: true): () => _navigate(AppScreen.upload),
        const SingleActivator(LogicalKeyboardKey.keyR, control: true): () => _navigate(AppScreen.reports),
        const SingleActivator(LogicalKeyboardKey.keyM, control: true): () => _navigate(AppScreen.mitigation),
        const SingleActivator(LogicalKeyboardKey.keyD, control: true): () => _navigate(AppScreen.dashboard),
      },
      child: Focus(
        focusNode: _shellFocusNode,
        autofocus: true,
        child: Scaffold(
          key: _scaffoldKey,
          drawer: isMobile
              ? Drawer(
                  backgroundColor: AppColors.bgDeep(context),
                  width: 260,
                  child: AppSidebar(
                    current: _current,
                    isCollapsed: false,
                    onToggleCollapse: () => Navigator.of(context).pop(),
                    onNavigate: _navigate,
                    userEmail: widget.authService.userEmail ?? '',
                    onLogout: widget.onLogout,
                    onOpenCommandPalette: _showCommandPalette,
                  ),
                )
              : null,
          backgroundColor: AppColors.bgDeep(context),
          body: Container(
            decoration: widget.isDarkMode
                ? const BoxDecoration(
                    gradient: AppGradients.darkBgRadial,
                  )
                : null,
            child: Column(
              children: [
                // Top Header
                LemmaHeader(
                  isSidebarCollapsed: _sidebarCollapsed,
                  onToggleSidebar: () {
                    if (isMobile) {
                      _scaffoldKey.currentState?.openDrawer();
                    } else {
                      setState(() => _sidebarCollapsed = !_sidebarCollapsed);
                    }
                  },
                  onNewWorkspace: () => _navigate(AppScreen.upload),
                  userEmail: widget.authService.userEmail ?? '',
                  onLogout: widget.onLogout,
                  onOpenCommandPalette: _showCommandPalette,
                  onToggleTheme: widget.onToggleTheme,
                  isDarkMode: widget.isDarkMode,
                ),

                // Main Workspace Area (Sidebar + Animated Screen Content)
                Expanded(
                  child: Row(
                    children: [
                      if (!isMobile)
                        AppSidebar(
                          current: _current,
                          isCollapsed: _sidebarCollapsed,
                          onToggleCollapse: () => setState(() => _sidebarCollapsed = !_sidebarCollapsed),
                          onNavigate: _navigate,
                          userEmail: widget.authService.userEmail ?? '',
                          onLogout: widget.onLogout,
                          onOpenCommandPalette: _showCommandPalette,
                        ),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(opacity: animation, child: child);
                          },
                          child: ClipRect(
                            key: ValueKey<String>('$_current-$_isPolling'),
                            child: _buildBody(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom Engine Status Footer
                const LemmaFooter(isBackendOnline: true),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isPolling) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentGreen(context).withValues(alpha: 0.12),
                border: Border.all(color: AppColors.accentGreen(context), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentGreen(context).withValues(alpha: 0.25),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentGreen(context)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Analyzing: ${_activeJob?.filename ?? 'Document'}...',
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Running BM25 lexical parsing & ChromaDB vector embeddings matching.',
              style: TextStyle(
                color: AppColors.textSecondary(context),
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    switch (_current) {
      case AppScreen.dashboard:
        return DashboardHomeScreen(
          key: const ValueKey('dashboard_home_screen'),
          onNavigate: _navigate,
        );

      case AppScreen.upload:
      case AppScreen.plagiarism:
        return UploadScreen(
          key: const ValueKey('upload_screen'),
          onUploadSuccess: _onUploadSuccess,
          apiService: _api,
          userEmail: widget.authService.userEmail ?? '',
        );

      case AppScreen.report:
        return PlagiarismReportScreen(
          key: const ValueKey('report_screen'),
          apiService: _api,
          jobId: _activeJob?.id,
          userEmail: widget.authService.userEmail ?? '',
          onGoToUpload: () => _navigate(AppScreen.upload),
          onProceedToMitigation: () => _navigate(AppScreen.mitigation),
          onParaphraseSegment: _openParaphraserWithText,
        );

      case AppScreen.mitigation:
        return _activeJob == null
            ? _emptyState('No active document scan', 'Upload a document first to run AI mitigation.')
            : MitigationScreen(
                key: ValueKey('mitigation_screen_${_activeJob!.id}'),
                jobId: _activeJob!.id,
                apiService: _api,
                userEmail: widget.authService.userEmail ?? '',
                onComplete: () async {
                  try {
                    final r = await _api.getReport(_activeJob!.id);
                    setState(() {
                      _activeReport = r;
                      _current = AppScreen.finalReport;
                    });
                  } catch (_) {
                    setState(() => _current = AppScreen.reports);
                  }
                },
              );

      case AppScreen.reports:
        return ReportsHistoryScreen(
          key: const ValueKey('reports_history_screen'),
          apiService: _api,
          userEmail: widget.authService.userEmail ?? '',
          onViewReport: _loadReportById,
        );

      case AppScreen.finalReport:
        return _activeReport == null
            ? _emptyState('No final report', 'Upload a document to generate a clean final report.')
            : FinalReportScreen(
                key: const ValueKey('final_report_screen'),
                report: _activeReport!,
                apiService: _api,
                onViewSimilarityReport: () => _navigate(AppScreen.report),
              );

      case AppScreen.aichat:
        return AiChatScreen(
          key: ValueKey('ai_chat_screen_$_paraphraseInitialText'),
          apiService: _api,
          initialText: _paraphraseInitialText,
        );


      case AppScreen.settings:
        return SettingsScreen(
          key: const ValueKey('settings_screen'),
          onNavigate: _navigate,
          userEmail: widget.authService.userEmail ?? '',
        );
    }
  }

  Widget _emptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated(context),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderSubtle(context)),
            ),
            child: Icon(
              Icons.article_outlined,
              color: AppColors.textSecondary(context),
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: AppColors.textSecondary(context), fontSize: 13),
          ),
        ],
      ),
    );
  }
}
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackletics/core/services/storage_service.dart';
import 'package:trackletics/core/theme/app_colors.dart';
import 'package:trackletics/features/recommendation/cubit/plan_recommendation_chat_cubit.dart';
import 'package:trackletics/features/recommendation/cubit/plan_recommendation_chat_state.dart';

const _kBubbleLeftKey = 'plan_chat_bubble_left';
const _kBubbleTopKey = 'plan_chat_bubble_top';

const double _kBubbleSize = 56;
const double _kPanelW = 320;
const double _kPanelH = 420;

class DraggablePlanChatBubble extends StatefulWidget {
  const DraggablePlanChatBubble({
    super.key,
    required this.onOpenWorkoutsTab,
  });

  final VoidCallback onOpenWorkoutsTab;

  @override
  State<DraggablePlanChatBubble> createState() =>
      _DraggablePlanChatBubbleState();
}

class _DraggablePlanChatBubbleState extends State<DraggablePlanChatBubble>
    with SingleTickerProviderStateMixin {
  Offset _position = Offset.zero;
  bool _loadedPos = false;
  bool _expanded = false;

  late AnimationController _overlayController;
  late Animation<double> _backdropOpacity;
  late Animation<double> _panelScale;

  @override
  void initState() {
    super.initState();
    _overlayController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
    _backdropOpacity = CurvedAnimation(
      parent: _overlayController,
      curve: Curves.easeOut,
    );
    _panelScale = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _overlayController,
        curve: Curves.easeOutCubic,
      ),
    );
    _loadSavedPosition();
  }

  @override
  void dispose() {
    _overlayController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedPosition() async {
    final storage = StorageService();
    await storage.init();
    final left = await storage.read<double>(key: _kBubbleLeftKey);
    final top = await storage.read<double>(key: _kBubbleTopKey);
    if (!mounted) return;
    if (left != null && top != null) {
      setState(() {
        _position = Offset(left, top);
        _loadedPos = true;
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _applyDefaultBottomRight();
      });
    }
  }

  void _applyDefaultBottomRight() {
    if (!mounted) return;
    final size = MediaQuery.sizeOf(context);
    final pad = MediaQuery.paddingOf(context);
    setState(() {
      _position = Offset(
        size.width - _kBubbleSize - 16,
        size.height - pad.bottom - 88 - _kBubbleSize,
      );
      _clampFabPosition(size, pad);
      _loadedPos = true;
    });
  }

  Future<void> _savePosition() async {
    final storage = StorageService();
    await storage.init();
    await storage.write(key: _kBubbleLeftKey, value: _position.dx);
    await storage.write(key: _kBubbleTopKey, value: _position.dy);
  }

  void _clampFabPosition(Size screen, EdgeInsets padding) {
    final maxLeft = screen.width - _kBubbleSize - 8;
    final maxTop = screen.height - padding.bottom - _kBubbleSize - 8;
    _position = Offset(
      _position.dx.clamp(8, maxLeft),
      _position.dy.clamp(padding.top + 8, maxTop),
    );
  }

  void _openChat() {
    if (!mounted) return;
    context.read<PlanRecommendationChatCubit>().openChat();
    setState(() => _expanded = true);
    _overlayController.forward(from: 0);
  }

  void _closeChat() {
    _overlayController.reverse().then((_) {
      if (!mounted) return;
      setState(() {
        _expanded = false;
        context.read<PlanRecommendationChatCubit>().reset();
      });
    });
  }

  void _onViewPlans() {
    context.read<PlanRecommendationChatCubit>().requestOpenAiPlansTab();
    widget.onOpenWorkoutsTab();
    _overlayController.reverse().then((_) {
      if (!mounted) return;
      setState(() => _expanded = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<PlanRecommendationChatCubit>().reset();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_loadedPos) return const SizedBox.shrink();

    final screen = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (_expanded) ...[
          Positioned.fill(
            child: FadeTransition(
              opacity: _backdropOpacity,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _closeChat,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.45),
                ),
              ),
            ),
          ),
          Center(
            child: ScaleTransition(
              scale: _panelScale,
              alignment: Alignment.center,
              child: _SizedPanelShell(
                width: _kPanelW,
                height: _kPanelH,
                child: _ChatPanel(
                  onClose: _closeChat,
                  onViewPlans: _onViewPlans,
                ),
              ),
            ),
          ),
        ],
        if (!_expanded)
          Positioned(
            left: _position.dx,
            top: _position.dy,
            child: Material(
              color: Colors.transparent,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanUpdate: (details) {
                  setState(() {
                    _position += details.delta;
                    _clampFabPosition(screen, padding);
                  });
                },
                onPanEnd: (_) => _savePosition(),
                onTap: _openChat,
                child: Container(
                  width: _kBubbleSize,
                  height: _kBubbleSize,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withValues(alpha: 0.88),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.22),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.smart_toy_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Gradient chrome matching the old bubble; fixed size for centered overlay.
class _SizedPanelShell extends StatelessWidget {
  const _SizedPanelShell({
    required this.width,
    required this.height,
    required this.child,
  });

  final double width;
  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.88),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.28),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: child,
        ),
      ),
    );
  }
}

class _ChatPanel extends StatefulWidget {
  const _ChatPanel({
    required this.onClose,
    required this.onViewPlans,
  });

  final VoidCallback onClose;
  final VoidCallback onViewPlans;

  @override
  State<_ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends State<_ChatPanel> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final max = _scrollController.position.maxScrollExtent;
      _scrollController.animateTo(
        max,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 4, 4),
          child: Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: Colors.white.withValues(alpha: 0.95),
                size: 18,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'recommendation.panel_title'.tr(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white),
                onPressed: widget.onClose,
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? const Color(0xFF1E1E1E)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: BlocConsumer<PlanRecommendationChatCubit,
                PlanRecommendationChatState>(
              listenWhen: (previous, current) {
                return previous.messages.length != current.messages.length ||
                    previous.step != current.step ||
                    previous.isGenerating != current.isGenerating ||
                    previous.choices.length != current.choices.length;
              },
              listener: (context, state) {
                _scrollToBottom();
              },
              builder: (context, state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(12),
                        itemCount: state.messages.length,
                        itemBuilder: (context, i) {
                          final m = state.messages[i];
                          return _BubbleLine(
                            isUser: m.isUser,
                            text: m.messageKey.tr(),
                          );
                        },
                      ),
                    ),
                    if (state.errorMessage != null &&
                        state.step == RecommendationChatStep.error)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          state.errorMessage!,
                          style: TextStyle(
                            color: theme.colorScheme.error,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    if (state.choices.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: state.choices.map((c) {
                            return ActionChip(
                              label: Text(
                                c.labelKey.tr(),
                                style: const TextStyle(fontSize: 12),
                              ),
                              onPressed: state.isGenerating
                                  ? null
                                  : () {
                                      if (state.step ==
                                              RecommendationChatStep.success &&
                                          c.id == 'view_plans') {
                                        widget.onViewPlans();
                                      } else {
                                        context
                                            .read<PlanRecommendationChatCubit>()
                                            .selectChoice(c.id);
                                      }
                                    },
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _BubbleLine extends StatelessWidget {
  const _BubbleLine({required this.isUser, required this.text});

  final bool isUser;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = isUser
        ? theme.colorScheme.primary.withValues(alpha: 0.2)
        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.65);
    final align = isUser ? Alignment.centerRight : Alignment.centerLeft;

    return Align(
      alignment: align,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: const BoxConstraints(maxWidth: 260),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            height: 1.35,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

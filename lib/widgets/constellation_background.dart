import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ConstellationNode {
  double x, y;
  double vx, vy;
  final double radius;
  final Color color;

  ConstellationNode({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.radius,
    required this.color,
  });

  void update(double width, double height) {
    x += vx;
    y += vy;

    if (x < 0) {
      x = 0;
      vx = -vx;
    } else if (x > width) {
      x = width;
      vx = -vx;
    }

    if (y < 0) {
      y = 0;
      vy = -vy;
    } else if (y > height) {
      y = height;
      vy = -vy;
    }
  }
}

class ConstellationBackground extends StatefulWidget {
  final Widget child;

  const ConstellationBackground({
    super.key,
    required this.child,
  });

  @override
  State<ConstellationBackground> createState() => _ConstellationBackgroundState();
}

class _ConstellationBackgroundState extends State<ConstellationBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<ConstellationNode> _nodes = [];
  final Random _random = Random();
  Offset? _mousePosition;

  static const int _nodeCount = 45;
  static const double _maxDistance = 140.0;
  static const double _gravitationalRadius = 180.0;
  static const double _gravityForce = 0.45;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_onTick)..repeat();
  }

  void _initializeNodes(Size size) {
    if (_nodes.isNotEmpty) return;
    
    final colors = [
      AppColors.darkAccentBlue,
      AppColors.darkAccentPurple,
      AppColors.darkAccentGreen,
      AppColors.darkAccentBlue,
    ];

    for (int i = 0; i < _nodeCount; i++) {
      _nodes.add(ConstellationNode(
        x: _random.nextDouble() * size.width,
        y: _random.nextDouble() * size.height,
        vx: (_random.nextDouble() - 0.5) * 0.9,
        vy: (_random.nextDouble() - 0.5) * 0.9,
        radius: _random.nextDouble() * 2.0 + 1.5,
        color: colors[_random.nextInt(colors.length)],
      ));
    }
  }

  void _onTick() {
    if (!mounted || _nodes.isEmpty) return;
    
    final size = MediaQuery.of(context).size;
    
    for (final node in _nodes) {
      if (_mousePosition != null) {
        final dx = _mousePosition!.dx - node.x;
        final dy = _mousePosition!.dy - node.y;
        final distance = sqrt(dx * dx + dy * dy);
        
        if (distance < _gravitationalRadius) {
          final force = (1.0 - (distance / _gravitationalRadius)) * _gravityForce;
          node.vx += (dx / distance) * force * 0.08;
          node.vy += (dy / distance) * force * 0.08;
          
          const maxVel = 2.0;
          final currentSpeed = sqrt(node.vx * node.vx + node.vy * node.vy);
          if (currentSpeed > maxVel) {
            node.vx = (node.vx / currentSpeed) * maxVel;
            node.vy = (node.vy / currentSpeed) * maxVel;
          }
        }
      }

      node.update(size.width, size.height);
    }
    
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    _initializeNodes(size);

    return MouseRegion(
      onHover: (event) => setState(() => _mousePosition = event.position),
      onExit: (_) => setState(() => _mousePosition = null),
      child: Stack(
        children: [
          Container(color: AppColors.darkBgDeep),
          Positioned.fill(
            child: CustomPaint(
              painter: _ConstellationPainter(
                nodes: _nodes,
                mousePos: _mousePosition,
                maxDistance: _maxDistance,
              ),
            ),
          ),
          Positioned.fill(child: widget.child),
        ],
      ),
    );
  }
}

class _ConstellationPainter extends CustomPainter {
  final List<ConstellationNode> nodes;
  final Offset? mousePos;
  final double maxDistance;

  _ConstellationPainter({
    required this.nodes,
    required this.mousePos,
    required this.maxDistance,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppColors.darkBorderSubtle.withValues(alpha: 0.15)
      ..strokeWidth = 0.5;
    const spacing = 50.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final spotlightPaint = Paint()..style = PaintingStyle.fill;
    for (final node in nodes) {
      final rect = Rect.fromCircle(center: Offset(node.x, node.y), radius: 60);
      final gradient = RadialGradient(
        colors: [
          node.color.withValues(alpha: 0.04),
          Colors.transparent,
        ],
      );
      spotlightPaint.shader = gradient.createShader(rect);
      canvas.drawCircle(Offset(node.x, node.y), 60, spotlightPaint);
    }

    final linePaint = Paint()..strokeWidth = 0.8;
    for (int i = 0; i < nodes.length; i++) {
      for (int j = i + 1; j < nodes.length; j++) {
        final nodeA = nodes[i];
        final nodeB = nodes[j];
        
        final dx = nodeA.x - nodeB.x;
        final dy = nodeA.y - nodeB.y;
        final dist = sqrt(dx * dx + dy * dy);

        if (dist < maxDistance) {
          final alpha = (1.0 - (dist / maxDistance)) * 0.22;
          linePaint.shader = LinearGradient(
            colors: [
              nodeA.color.withValues(alpha: alpha),
              nodeB.color.withValues(alpha: alpha),
            ],
          ).createShader(Rect.fromPoints(Offset(nodeA.x, nodeA.y), Offset(nodeB.x, nodeB.y)));

          canvas.drawLine(Offset(nodeA.x, nodeA.y), Offset(nodeB.x, nodeB.y), linePaint);
        }
      }

      if (mousePos != null) {
        final node = nodes[i];
        final dx = node.x - mousePos!.dx;
        final dy = node.y - mousePos!.dy;
        final dist = sqrt(dx * dx + dy * dy);

        if (dist < maxDistance * 1.2) {
          final alpha = (1.0 - (dist / (maxDistance * 1.2))) * 0.35;
          linePaint.shader = LinearGradient(
            colors: [
              node.color.withValues(alpha: alpha),
              AppColors.darkAccentBlue.withValues(alpha: alpha),
            ],
          ).createShader(Rect.fromPoints(Offset(node.x, node.y), mousePos!));
          
          canvas.drawLine(Offset(node.x, node.y), mousePos!, linePaint);
        }
      }
    }

    final nodePaint = Paint()..style = PaintingStyle.fill;
    for (final node in nodes) {
      nodePaint.color = node.color.withValues(alpha: 0.8);
      canvas.drawCircle(Offset(node.x, node.y), node.radius, nodePaint);

      nodePaint.color = Colors.white;
      canvas.drawCircle(Offset(node.x, node.y), node.radius * 0.4, nodePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConstellationPainter oldDelegate) => true;
}

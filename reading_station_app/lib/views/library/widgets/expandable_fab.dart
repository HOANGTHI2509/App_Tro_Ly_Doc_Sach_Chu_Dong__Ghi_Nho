import 'package:flutter/material.dart';

class ExpandableFab extends StatefulWidget {
  const ExpandableFab({super.key});

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      value: _isExpanded ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_isExpanded) ...[
          _buildFabMenuItem('Thêm ghi chú', Icons.description_outlined),
          const SizedBox(height: 10),
          _buildFabMenuItem('Quét mã Vạch', Icons.qr_code_scanner),
          const SizedBox(height: 10),
          _buildFabMenuItem('Thêm sách', Icons.book),
          const SizedBox(height: 10),
        ],
        FloatingActionButton(
          onPressed: _toggle,
          heroTag: 'menu',
          backgroundColor: const Color(0xFFFF5722),
          child: Icon(_isExpanded ? Icons.close : Icons.add, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildFabMenuItem(String label, IconData icon) {
    return ScaleTransition(
      scale: _expandAnimation,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
             decoration: BoxDecoration(
               color: Colors.white,
               borderRadius: BorderRadius.circular(20),
               boxShadow: [
                 BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2)),
               ]
             ),
             child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          const SizedBox(width: 10),
          FloatingActionButton.small(
            onPressed: () {
               // Handle action
               _toggle();
            },
            heroTag: label,
            backgroundColor: Colors.white,
            child: Icon(icon, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

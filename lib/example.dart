import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drag & Drop Cards',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7986CB)),
        useMaterial3: true,
      ),
      home: const DragDropCardScreen(),
    );
  }
}

class CardItem {
  final String id;
  String title;
  Color color;
  IconData icon;
  int colSpan;
  int rowSpan;

  CardItem({
    required this.id,
    required this.title,
    required this.color,
    required this.icon,
    this.colSpan = 1,
    this.rowSpan = 1,
  });
}

class DragDropCardScreen extends StatefulWidget {
  const DragDropCardScreen({super.key});

  @override
  State<DragDropCardScreen> createState() => _DragDropCardScreenState();
}

class _DragDropCardScreenState extends State<DragDropCardScreen> {
  late List<CardItem> cards;
  int? draggingIndex;
  int? hoveredIndex;

  final int columnCount = 3;
  final double cellHeight = 130.0;
  final double spacing = 10.0;

  @override
  void initState() {
    super.initState();
    _initCards();
  }

  void _initCards() {
    final cardColors = [
      const Color(0xFFE8EAF6),
      const Color(0xFFE3F2FD),
      const Color(0xFFE8F5E9),
      const Color(0xFFFCE4EC),
      const Color(0xFFFFF3E0),
      const Color(0xFFEDE7F6),
      const Color(0xFFE0F7FA),
      const Color(0xFFF3E5F5),
    ];
    final icons = [
      Icons.dashboard,
      Icons.analytics,
      Icons.people,
      Icons.settings,
      Icons.notifications,
      Icons.favorite,
      Icons.star,
      Icons.bookmark,
      Icons.cloud,
      Icons.camera,
      Icons.music_note,
      Icons.map,
    ];
    cards = List.generate(
      12,
      (i) => CardItem(
        id: 'card_$i',
        title: 'Card ${i + 1}',
        color: cardColors[i % cardColors.length],
        icon: icons[i % icons.length],
      ),
    );
  }

  List<Map<String, int>> _buildLayout() {
    final Map<int, Map<int, bool>> grid = {};

    bool isOccupied(int r, int c) => grid[r]?[c] ?? false;

    void occupy(int r, int c) {
      grid.putIfAbsent(r, () => {})[c] = true;
    }

    // ✅ colSpan clamped to columnCount so layout never breaks grid
    bool canPlace(int r, int c, int cSpan, int rSpan) {
      final effective = cSpan.clamp(1, columnCount);
      if (c + effective > columnCount) return false;
      for (int dr = 0; dr < rSpan; dr++) {
        for (int dc = 0; dc < effective; dc++) {
          if (isOccupied(r + dr, c + dc)) return false;
        }
      }
      return true;
    }

    void placeCard(int r, int c, int cSpan, int rSpan) {
      final effective = cSpan.clamp(1, columnCount);
      for (int dr = 0; dr < rSpan; dr++) {
        for (int dc = 0; dc < effective; dc++) {
          occupy(r + dr, c + dc);
        }
      }
    }

    final List<Map<String, int>> layout = [];

    for (int i = 0; i < cards.length; i++) {
      final cSpan = cards[i].colSpan;
      final rSpan = cards[i].rowSpan;

      bool placed = false;
      int searchRow = 0;
      int searchCol = 0;

      while (!placed) {
        if (canPlace(searchRow, searchCol, cSpan, rSpan)) {
          layout.add({
            'cardIndex': i,
            'col': searchCol,
            'row': searchRow,
            'colSpan': cSpan,
            'rowSpan': rSpan,
          });
          placeCard(searchRow, searchCol, cSpan, rSpan);
          placed = true;
        } else {
          searchCol++;
          if (searchCol >= columnCount) {
            searchCol = 0;
            searchRow++;
          }
        }
      }
    }

    return layout;
  }

  // ✅ No upper limit — user can expand as much as they want
  void _expandCol(int index) {
    setState(() => cards[index].colSpan++);
  }

  // ✅ Min 1 — cannot shrink below 1
  void _shrinkCol(int index) {
    setState(() {
      if (cards[index].colSpan > 1) cards[index].colSpan--;
    });
  }

  // ✅ No upper limit
  void _expandRow(int index) {
    setState(() => cards[index].rowSpan++);
  }

  // ✅ Min 1
  void _shrinkRow(int index) {
    setState(() {
      if (cards[index].rowSpan > 1) cards[index].rowSpan--;
    });
  }

  void _onReorder(int fromIndex, int toIndex) {
    if (fromIndex == toIndex) return;
    setState(() {
      final temp = cards[fromIndex];
      cards[fromIndex] = cards[toIndex];
      cards[toIndex] = temp;
      draggingIndex = null;
      hoveredIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final layout = _buildLayout();
    final totalRows = layout.isEmpty
        ? 0
        : layout
              .map((e) => e['row']! + e['rowSpan']!)
              .reduce((a, b) => a > b ? a : b);

    return Scaffold(
      backgroundColor: const Color(0xFFE8EAF6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5C6BC0),
        elevation: 0,
        title: const Text(
          'Drag & Drop · Expand Cards',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => setState(_initCards),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final totalWidth = constraints.maxWidth;
            final cellWidth =
                (totalWidth - spacing * (columnCount - 1)) / columnCount;

            return SingleChildScrollView(
              child: SizedBox(
                width: totalWidth,
                height: totalRows * (cellHeight + spacing) + 20,
                child: Stack(
                  children: layout.map((slot) {
                    final ci = slot['cardIndex']!;
                    final col = slot['col']!;
                    final row = slot['row']!;
                    final cSpan = slot['colSpan']!;
                    final rSpan = slot['rowSpan']!;

                    final left = col * (cellWidth + spacing);
                    final top = row * (cellHeight + spacing);

                    // ✅ Width: clamped so card never exceeds screen
                    final effectiveColSpan = cSpan.clamp(1, columnCount - col);
                    final w =
                        cellWidth * effectiveColSpan +
                        spacing * (effectiveColSpan - 1);
                    final h = cellHeight * rSpan + spacing * (rSpan - 1);

                    return AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      left: left,
                      top: top,
                      width: w,
                      height: h,
                      child: _buildDragTarget(ci, cards[ci], w, h),
                    );
                  }).toList(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDragTarget(int index, CardItem card, double w, double h) {
    return DragTarget<int>(
      onWillAcceptWithDetails: (d) {
        setState(() => hoveredIndex = index);
        return d.data != index;
      },
      onAcceptWithDetails: (d) => _onReorder(d.data, index),
      onLeave: (_) => setState(() => hoveredIndex = null),
      builder: (context, candidate, _) {
        final isHovered = hoveredIndex == index && draggingIndex != index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isHovered ? const Color(0xFF5C6BC0) : Colors.transparent,
              width: 2.5,
            ),
          ),
          child: _buildDraggable(index, card, w, h),
        );
      },
    );
  }

  Widget _buildDraggable(int index, CardItem card, double w, double h) {
    return Draggable<int>(
      data: index,
      onDragStarted: () {
        debugPrint('🔵 DRAG STARTED: ${card.title} (index $index)');
        setState(() => draggingIndex = index);
      },
      onDragEnd: (details) {
        debugPrint('🔴 DRAG ENDED — Accepted: ${details.wasAccepted}');
        setState(() {
          draggingIndex = null;
          hoveredIndex = null;
        });
      },
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: w,
          height: h,
          child: _cardUI(card, isDragging: true),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: _cardUI(card)),
      child: _cardUI(
        card,
        onExpandRight: () => _expandCol(index),
        onExpandDown: () => _expandRow(index),
        onExpandLeft: () => _shrinkCol(index),
        onExpandUp: () => _shrinkRow(index),
      ),
    );
  }

  Widget _cardUI(
    CardItem card, {
    bool isDragging = false,
    VoidCallback? onExpandRight,
    VoidCallback? onExpandDown,
    VoidCallback? onExpandLeft,
    VoidCallback? onExpandUp,
  }) {
    final bool wideActive = card.colSpan > 1;
    final bool tallActive = card.rowSpan > 1;
    final bool hasCallbacks = onExpandRight != null;

    const double handleSize = 22.0;
    const Color activeColor = Color(0xFF5C6BC0);
    const Color inactiveColor = Colors.transparent;

    // ✅ Color saturates gradually (every 4 steps = full dark), no hard cap
    Color colHandleColor() {
      if (card.colSpan == 1) return inactiveColor;
      final t = ((card.colSpan - 1) / 4).clamp(0.0, 1.0);
      return Color.lerp(
        activeColor.withValues(alpha: 0.7),
        const Color(0xFF1A237E),
        t,
      )!;
    }

    Color rowHandleColor() {
      if (card.rowSpan == 1) return inactiveColor;
      final t = ((card.rowSpan - 1) / 4).clamp(0.0, 1.0);
      return Color.lerp(const Color(0xFF7986CB), const Color(0xFF4A148C), t)!;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: card.color,
        borderRadius: BorderRadius.circular(14),
        boxShadow: isDragging
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.28),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.85),
          width: 1.5,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: handleSize,
            right: handleSize,
            top: handleSize,
            bottom: handleSize,
            child: ClipRect(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(card.icon, size: 22, color: activeColor),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          card.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Color(0xFF3949AB),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (card.rowSpan > 1) ...[
                    const SizedBox(height: 8),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Expanded content area.\nMore details visible here.',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF5C6BC0),
                          ),
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  Row(
                    children: [
                      _badge('${card.colSpan}×${card.rowSpan}', activeColor),
                      if (wideActive) ...[
                        const SizedBox(width: 4),
                        _badge('Wide', Colors.indigo),
                      ],
                      if (tallActive) ...[
                        const SizedBox(width: 4),
                        _badge('Tall', Colors.purple),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          if (hasCallbacks)
            Positioned(
              top: 0,
              left: handleSize,
              right: handleSize,
              child: GestureDetector(
                onTap: onExpandUp,
                child: Container(
                  height: handleSize,
                  decoration: BoxDecoration(
                    color: rowHandleColor(),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.keyboard_arrow_up,
                      size: 16,
                      color: tallActive
                          ? Colors.white
                          : activeColor.withValues(alpha: 0.35),
                    ),
                  ),
                ),
              ),
            ),

          if (hasCallbacks)
            Positioned(
              bottom: 0,
              left: handleSize,
              right: handleSize,
              child: GestureDetector(
                onTap: onExpandDown,
                child: Container(
                  height: handleSize,
                  decoration: BoxDecoration(
                    color: rowHandleColor(),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: 16,
                      color: tallActive
                          ? Colors.white
                          : activeColor.withValues(alpha: 0.35),
                    ),
                  ),
                ),
              ),
            ),

          if (hasCallbacks)
            Positioned(
              left: 0,
              top: handleSize,
              bottom: handleSize,
              child: GestureDetector(
                onTap: onExpandLeft,
                child: Container(
                  width: handleSize,
                  decoration: BoxDecoration(
                    color: colHandleColor(),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.keyboard_arrow_left,
                      size: 16,
                      color: wideActive
                          ? Colors.white
                          : activeColor.withValues(alpha: 0.35),
                    ),
                  ),
                ),
              ),
            ),

          if (hasCallbacks)
            Positioned(
              right: 0,
              top: handleSize,
              bottom: handleSize,
              child: GestureDetector(
                onTap: onExpandRight,
                child: Container(
                  width: handleSize,
                  decoration: BoxDecoration(
                    color: colHandleColor(),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.keyboard_arrow_right,
                      size: 16,
                      color: wideActive
                          ? Colors.white
                          : activeColor.withValues(alpha: 0.35),
                    ),
                  ),
                ),
              ),
            ),

          if (hasCallbacks)
            Positioned(
              top: 0,
              left: 0,
              child: GestureDetector(
                onTap: () {
                  onExpandLeft!();
                  onExpandUp!();
                },
                child: Container(
                  width: handleSize,
                  height: handleSize,
                  decoration: BoxDecoration(
                    color: (wideActive && tallActive)
                        ? const Color(0xFF3949AB)
                        : (wideActive || tallActive)
                        ? activeColor.withValues(alpha: 0.45)
                        : activeColor.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                    ),
                  ),
                  child: Icon(
                    Icons.north_west,
                    size: 11,
                    color: (wideActive || tallActive)
                        ? Colors.white
                        : activeColor.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),

          if (hasCallbacks)
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  onExpandRight();
                  onExpandUp!();
                },
                child: Container(
                  width: handleSize,
                  height: handleSize,
                  decoration: BoxDecoration(
                    color: (wideActive && tallActive)
                        ? const Color(0xFF3949AB)
                        : (wideActive || tallActive)
                        ? activeColor.withValues(alpha: 0.45)
                        : activeColor.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(14),
                    ),
                  ),
                  child: Icon(
                    Icons.north_east,
                    size: 11,
                    color: (wideActive || tallActive)
                        ? Colors.white
                        : activeColor.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),

          if (hasCallbacks)
            Positioned(
              bottom: 0,
              left: 0,
              child: GestureDetector(
                onTap: () {
                  onExpandLeft!();
                  onExpandDown!();
                },
                child: Container(
                  width: handleSize,
                  height: handleSize,
                  decoration: BoxDecoration(
                    color: (wideActive && tallActive)
                        ? const Color(0xFF3949AB)
                        : (wideActive || tallActive)
                        ? activeColor.withValues(alpha: 0.45)
                        : activeColor.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(14),
                    ),
                  ),
                  child: Icon(
                    Icons.south_west,
                    size: 11,
                    color: (wideActive || tallActive)
                        ? Colors.white
                        : activeColor.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),

          if (hasCallbacks)
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  onExpandRight();
                  onExpandDown!();
                },
                child: Container(
                  width: handleSize,
                  height: handleSize,
                  decoration: BoxDecoration(
                    color: (wideActive && tallActive)
                        ? const Color(0xFF3949AB)
                        : (wideActive || tallActive)
                        ? activeColor.withValues(alpha: 0.45)
                        : activeColor.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(14),
                    ),
                  ),
                  child: Icon(
                    wideActive && tallActive
                        ? Icons.open_in_full
                        : Icons.south_east,
                    size: 11,
                    color: (wideActive || tallActive)
                        ? Colors.white
                        : activeColor.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

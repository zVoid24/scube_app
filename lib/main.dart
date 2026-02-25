import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Resizable Dashboard',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const DashboardPage(),
    );
  }
}

// ── Data model ──────────────────────────────────────────────────────────────
// Cards are kept in an ordered list. The grid layout is computed fresh each
// build (same flow-pack algorithm as the original code), so every card always
// gets a valid position and resize / reorder just works.

class DashCard {
  final int id;
  int w;
  int h;
  final bool isBlank;

  DashCard({required this.id, this.w = 1, this.h = 1, this.isBlank = false});
}

// ── Page ────────────────────────────────────────────────────────────────────

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static const int columns = 3;
  static const double gap = 12;
  // Extra empty-slot rows shown below the cards so there is always free space
  // to drag cards into.
  static const int extraRows = 4;

  int? activeId;
  int? draggingId;
  late List<DashCard> cards;
  int _nextBlankId = 999;

  @override
  void initState() {
    super.initState();
    // 9 actual cards
    cards = List.generate(9, (i) => DashCard(id: i));
    // Pad with blank cards to allow dropping in empty spaces
    for (int i = 0; i < extraRows * columns; i++) {
      cards.add(DashCard(id: _nextBlankId++, isBlank: true));
    }
  }

  // ── Flow-pack layout (identical to original) ───────────────────────────

  List<Offset> _calculatePositions() {
    final positions = List.filled(cards.length, Offset.zero);
    // occupied[row] = set of occupied column indices
    final Map<int, Set<int>> occupied = {};

    bool isFree(int r, int c, int w, int h) {
      if (c + w > columns) return false;
      for (int i = r; i < r + h; i++) {
        for (int j = c; j < c + w; j++) {
          if (occupied[i]?.contains(j) ?? false) return false;
        }
      }
      return true;
    }

    void place(int r, int c, int w, int h) {
      for (int i = r; i < r + h; i++) {
        occupied.putIfAbsent(i, () => {});
        for (int j = c; j < c + w; j++) {
          occupied[i]!.add(j);
        }
      }
    }

    for (int i = 0; i < cards.length; i++) {
      final card = cards[i];
      bool placed = false;
      for (int r = 0; !placed; r++) {
        for (int c = 0; c <= columns - card.w; c++) {
          if (isFree(r, c, card.w, card.h)) {
            positions[i] = Offset(c.toDouble(), r.toDouble());
            place(r, c, card.w, card.h);
            placed = true;
            break;
          }
        }
      }
    }
    return positions;
  }

  // Highest row used by cards (0-based)
  int _maxRow(List<Offset> positions) {
    int max = 0;
    for (int i = 0; i < cards.length; i++) {
      final bottom = positions[i].dy.toInt() + cards[i].h - 1;
      if (bottom > max) max = bottom;
    }
    return max;
  }

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EAF6),
      appBar: AppBar(
        title: const Text('Resizable Cards'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Guard: on the very first frame the scaffold may report 0 height.
            // Return an empty box — Flutter will call us again with real sizes.
            if (constraints.maxWidth <= 0 || constraints.maxHeight <= 0) {
              return const SizedBox.shrink();
            }

            final double availableWidth = constraints.maxWidth - gap * 2;
            final double cellSize =
                (availableWidth - gap * (columns - 1)) / columns;

            // cellSize must be positive
            if (cellSize <= 0) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.all(gap),
              child: _buildGrid(cellSize),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGrid(double cellSize) {
    final positions = _calculatePositions();
    final int usedRows = _maxRow(positions) + 1;
    final int totalRows = usedRows + extraRows;
    final double gridHeight = totalRows * cellSize + (totalRows - 1) * gap;

    return SingleChildScrollView(
      child: SizedBox(
        // Add a little bottom padding so the last row is not clipped
        height: gridHeight + 24,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // ── Layer 1: empty slot boxes (background) ────────────────────
            ..._buildEmptySlots(cellSize, totalRows, positions),
            // ── Layer 2: cards ────────────────────────────────────────────
            ...List.generate(cards.length, (i) {
              final card = cards[i];
              final pos = positions[i];
              final left = pos.dx * (cellSize + gap);
              final top = pos.dy * (cellSize + gap);
              final width = card.w * cellSize + (card.w - 1) * gap;
              final height = card.h * cellSize + (card.h - 1) * gap;

              if (card.isBlank) {
                // Return an invisible drop target that can be swapped with real cards
                return Positioned(
                  key: ValueKey('card_${card.id}'),
                  left: left,
                  top: top,
                  width: width,
                  height: height,
                  child: DragTarget<int>(
                    onWillAcceptWithDetails: (details) => details.data != i,
                    onAcceptWithDetails: (details) {
                      final from = details.data;
                      setState(() {
                        final temp = cards[from];
                        cards[from] = cards[i];
                        cards[i] = temp;
                        activeId = null;
                      });
                    },
                    builder: (context, candidateData, _) {
                      return const SizedBox.shrink(); // fully invisible
                    },
                  ),
                );
              }

              return AnimatedPositioned(
                key: ValueKey('card_${card.id}'),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left: left,
                top: top,
                width: width,
                height: height,
                child: _buildCard(i, card, cellSize, positions),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ── Empty slot layer ───────────────────────────────────────────────────

  List<Widget> _buildEmptySlots(
    double cellSize,
    int totalRows,
    List<Offset> positions,
  ) {
    final slots = <Widget>[];
    for (int r = 0; r < totalRows; r++) {
      for (int c = 0; c < columns; c++) {
        final left = c * (cellSize + gap);
        final top = r * (cellSize + gap);

        slots.add(
          Positioned(
            left: left,
            top: top,
            width: cellSize,
            height: cellSize,
            child: DragTarget<int>(
              onWillAcceptWithDetails: (details) => true,
              onAcceptWithDetails: (details) {
                final fromIndex = details.data;
                setState(() {
                  final card = cards.removeAt(fromIndex);

                  // Find the target card (which should be a blank card) at the dropped r, c
                  final tempPositions = _calculatePositions();
                  int targetIndex = cards.length;
                  for (int i = 0; i < cards.length; i++) {
                    final pos = tempPositions[i];
                    if (pos.dy == r && pos.dx == c) {
                      targetIndex = i;
                      break;
                    }
                  }

                  if (targetIndex < cards.length) {
                    // Pre-existing card (most likely a blank card) at this exact slot
                    // Let's swap the dragged card with it, inserting it exactly here
                    cards.insert(targetIndex, card);
                  } else {
                    // Fallback just in case
                    cards.insert(targetIndex, card);
                  }

                  activeId = null;
                });
              },
              builder: (context, candidateData, _) {
                final hovering = candidateData.isNotEmpty;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: hovering
                        ? Colors.green.withValues(alpha: 0.35)
                        : const Color(0xFFDDE0F0),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: hovering
                          ? Colors.green.shade400
                          : Colors.white.withValues(alpha: 0.9),
                      width: hovering ? 2 : 1.5,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      }
    }
    return slots;
  }

  // ── Card widget ────────────────────────────────────────────────────────

  Widget _buildCard(
    int index,
    DashCard card,
    double cellSize,
    List<Offset> positions,
  ) {
    final cardWidth = card.w * cellSize + (card.w - 1) * gap;
    final cardHeight = card.h * cellSize + (card.h - 1) * gap;

    return DragTarget<int>(
      onWillAcceptWithDetails: (details) => details.data != index,
      onAcceptWithDetails: (details) {
        final from = details.data;
        setState(() {
          final temp = cards[from];
          cards[from] = cards[index];
          cards[index] = temp;
          activeId = null;
        });
      },
      builder: (context, candidateData, _) {
        return LongPressDraggable<int>(
          data: index,
          onDragStarted: () => setState(() {
            draggingId = card.id;
            activeId = null;
          }),
          onDragEnd: (_) => setState(() => draggingId = null),
          feedback: Material(
            elevation: 12,
            color: Colors.transparent,
            child: Container(
              width: cardWidth,
              height: cardHeight,
              decoration: BoxDecoration(
                color: Colors.blueAccent.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white, width: 2),
              ),
              alignment: Alignment.center,
              child: Text(
                'Card ${card.id}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          childWhenDragging: Opacity(
            opacity: 0.3,
            child: _cardBody(card, false),
          ),
          child: GestureDetector(
            onTap: () => setState(() {
              activeId = activeId == card.id ? null : card.id;
            }),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: _cardBody(card, candidateData.isNotEmpty),
                ),
                if (activeId == card.id && draggingId != card.id)
                  Positioned.fill(child: _resizeHandles(card, index)),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Card body ──────────────────────────────────────────────────────────

  Widget _cardBody(DashCard card, bool isDropTarget) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isDropTarget ? Colors.green.shade400 : Colors.blue.shade500,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: activeId == card.id ? Colors.white : Colors.transparent,
          width: 3,
        ),
        boxShadow: [
          if (activeId == card.id)
            BoxShadow(
              color: Colors.blue.withValues(alpha: 0.5),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth <= 0 || constraints.maxHeight <= 0) {
                return const SizedBox.shrink();
              }
              final double aspect =
                  constraints.maxWidth / constraints.maxHeight;
              final double vw = aspect > 1 ? 300 * aspect : 300;
              final double vh = aspect < 1 ? 300 / aspect : 300;
              return FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: vw,
                  height: vh,
                  child: _buildContent(card),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(DashCard card) {
    if (card.id % 3 == 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.analytics_outlined, color: Colors.white, size: 80),
          const SizedBox(height: 16),
          Text(
            'Analytics ${card.id}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'This content resizes dynamically!',
            style: TextStyle(color: Colors.white70, fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ],
      );
    } else if (card.id % 3 == 1) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: 0.75,
                  strokeWidth: 16,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                ),
                const Center(
                  child: Text(
                    '75%',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 32),
          const Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Storage',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '150 GB / 200 GB Used',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Recent Logs',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Table(
            border: TableBorder.all(color: Colors.white30, width: 2),
            children: [
              TableRow(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
                children: const [
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'Service',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'Status',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'Auth API',
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'OK',
                      style: TextStyle(color: Colors.greenAccent, fontSize: 18),
                    ),
                  ),
                ],
              ),
              const TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'Database',
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'Syncing',
                      style: TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      );
    }
  }

  // ── Resize handles ─────────────────────────────────────────────────────
  // All 8 handles are ALWAYS shown (same as original code).
  // Resizing changes w/h and then the flow-packer re-layouts automatically,
  // pushing other cards aside just like the original.

  Widget _resizeHandles(DashCard card, int index) {
    void moveEarlier(int offset) {
      final newIndex = (index - offset).clamp(0, cards.length - 1);
      if (newIndex != index) {
        cards.removeAt(index);
        cards.insert(newIndex, card);
      }
    }

    void moveLater(int offset) {
      final newIndex = (index + offset).clamp(0, cards.length - 1);
      if (newIndex != index) {
        cards.removeAt(index);
        cards.insert(newIndex, card);
      }
    }

    return Stack(
      children: [
        // ── WIDTH ──────────────────────────────────────────────────────────

        // Expand RIGHT
        if (card.w < columns)
          Positioned(
            right: 6,
            top: 0,
            bottom: 0,
            child: _arrowBtn(
              Icons.arrow_forward_ios,
              () => setState(() => card.w++),
            ),
          ),

        // Expand LEFT
        if (card.w < columns)
          Positioned(
            left: 6,
            top: 0,
            bottom: 0,
            child: _arrowBtn(Icons.arrow_back_ios_new, () {
              setState(() {
                card.w++;
                moveEarlier(1);
              });
            }),
          ),

        // Collapse from RIGHT
        if (card.w > 1)
          Positioned(
            right: 40,
            top: 0,
            bottom: 0,
            child: _arrowBtn(
              Icons.arrow_back_ios_new,
              () => setState(() => card.w--),
            ),
          ),

        // Collapse from LEFT
        if (card.w > 1)
          Positioned(
            left: 40,
            top: 0,
            bottom: 0,
            child: _arrowBtn(Icons.arrow_forward_ios, () {
              setState(() {
                card.w--;
                moveLater(1);
              });
            }),
          ),

        // ── HEIGHT ─────────────────────────────────────────────────────────

        // Expand DOWN
        if (card.h < 4)
          Positioned(
            bottom: 6,
            left: 0,
            right: 0,
            child: _arrowBtn(
              Icons.arrow_downward,
              () => setState(() => card.h++),
            ),
          ),

        // Expand UP
        if (card.h < 4)
          Positioned(
            top: 6,
            left: 0,
            right: 0,
            child: _arrowBtn(Icons.arrow_upward, () {
              setState(() {
                card.h++;
                moveEarlier(columns);
              });
            }),
          ),

        // Collapse from BOTTOM
        if (card.h > 1)
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: _arrowBtn(
              Icons.arrow_upward,
              () => setState(() => card.h--),
            ),
          ),

        // Collapse from TOP
        if (card.h > 1)
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: _arrowBtn(Icons.arrow_downward, () {
              setState(() {
                card.h--;
                moveLater(columns);
              });
            }),
          ),
      ],
    );
  }

  Widget _arrowBtn(IconData icon, VoidCallback onTap) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.orangeAccent,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

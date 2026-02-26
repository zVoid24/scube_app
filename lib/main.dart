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
  final String cardType;

  DashCard({
    required this.id,
    this.w = 1,
    this.h = 1,
    this.isBlank = false,
    this.cardType = 'Type-01',
  });
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
  int? draggingListIndex;
  int? dragHoverListIndex;

  late List<DashCard> cards;
  int _nextBlankId = 999;

  @override
  void initState() {
    super.initState();
    // Initialize with a variety of sizes representing the different types
    cards = [
      DashCard(id: 0, w: 1, h: 1, cardType: 'Type-01'), // Small (1x1)
      DashCard(id: 1, w: 1, h: 2, cardType: 'Type-02'), // Tall (1x2)
      DashCard(id: 2, w: 1, h: 1, cardType: 'Type-05'), // Small (1x1)
      DashCard(id: 3, w: 3, h: 2, cardType: 'Type-03'), // Wide/Large (3x2)
      DashCard(id: 4, w: 1, h: 1, cardType: 'Type-04'), // Small (1x1)
    ];

    // Add dummy blank cards to fill out empty spaces
    for (int i = 0; i < extraRows * columns; i++) {
      cards.add(DashCard(id: _nextBlankId++, isBlank: true));
    }
  }

  // ── Flow-pack layout (identical to original) ───────────────────────────

  List<Offset> _calculatePositions({bool applyDragReflow = false}) {
    List<DashCard> layoutCards = List.from(cards);

    if (applyDragReflow &&
        draggingListIndex != null &&
        dragHoverListIndex != null) {
      if (draggingListIndex != dragHoverListIndex) {
        final card = layoutCards.removeAt(draggingListIndex!);
        int insertIndex = dragHoverListIndex!;
        if (insertIndex > layoutCards.length) insertIndex = layoutCards.length;
        layoutCards.insert(insertIndex, card);
      }
    }

    final positions = List.filled(layoutCards.length, Offset.zero);

    // ── Sequential row-flow layout ──────────────────────────────────────────
    // Works exactly like CSS flex-wrap: wrap.
    // Cards are placed strictly in list order, left-to-right.
    // When a card doesn't fit in the remaining columns of the current row
    // the cursor moves to the start of the next row.
    // Gaps left by tall cards are NEVER backfilled — the order you set is
    // exactly the order you see.

    // For each row, track the highest "floor" column index that is blocked
    // by a tall card placed in a previous row.
    // blocked[row] = list of (startCol, endCol exclusive) spans that are occupied.
    final Map<int, List<(int, int)>> blocked = {};

    void markBlocked(int r, int c, int w, int h) {
      for (int i = r; i < r + h; i++) {
        blocked.putIfAbsent(i, () => []);
        blocked[i]!.add((c, c + w));
      }
    }

    // Returns the first column on row `r` that is free for a card of width `w`,
    // starting the search from column `startCol`.
    // Returns -1 if no such column exists on this row.
    int firstFreeCol(int r, int startCol, int w) {
      int c = startCol;
      while (c + w <= columns) {
        bool fits = true;
        final spans = blocked[r] ?? [];
        for (final (s, e) in spans) {
          if (c < e && c + w > s) {
            // Overlap: skip past this span.
            c = e;
            fits = false;
            break;
          }
        }
        if (fits) return c;
      }
      return -1;
    }

    int cursorRow = 0;
    int cursorCol = 0;

    for (int i = 0; i < layoutCards.length; i++) {
      final card = layoutCards[i];

      // Try to place at the cursor, or advance rightward if blocked.
      int col = firstFreeCol(cursorRow, cursorCol, card.w);

      if (col == -1) {
        // Doesn't fit on this row — move to the next row.
        cursorRow++;
        cursorCol = 0;
        col = firstFreeCol(cursorRow, cursorCol, card.w);

        // Keep advancing rows until we find a fit (handles very wide blockers).
        while (col == -1) {
          cursorRow++;
          col = firstFreeCol(cursorRow, 0, card.w);
        }
        cursorCol = 0;
      }

      // Place the card.
      final origIndex = cards.indexOf(card);
      positions[origIndex] = Offset(col.toDouble(), cursorRow.toDouble());
      markBlocked(cursorRow, col, card.w, card.h);

      // Advance cursor to the column just after this card.
      cursorCol = col + card.w;

      // If the cursor is at or past the end of the row, wrap to next row.
      if (cursorCol >= columns) {
        cursorRow++;
        cursorCol = 0;
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
    final positions = _calculatePositions(applyDragReflow: true);
    final basePositions = _calculatePositions(applyDragReflow: false);
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
                return Positioned(
                  key: ValueKey('card_${card.id}'),
                  left: left,
                  top: top,
                  width: width,
                  height: height,
                  child: const SizedBox.shrink(),
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
            // ── Layer 3: Invisible drag target grid overlay ──────────
            if (draggingId != null)
              ...List.generate(totalRows * columns, (index) {
                final r = index ~/ columns;
                final c = index % columns;
                final left = c * (cellSize + gap);
                final top = r * (cellSize + gap);
                return Positioned(
                  left: left,
                  top: top,
                  width: cellSize,
                  height: cellSize,
                  child: DragTarget<int>(
                    onWillAcceptWithDetails: (details) {
                      int targetIndex = cards.length;
                      for (int i = 0; i < cards.length; i++) {
                        final card = cards[i];
                        final pos = basePositions[i];
                        if (r >= pos.dy &&
                            r < pos.dy + card.h &&
                            c >= pos.dx &&
                            c < pos.dx + card.w) {
                          targetIndex = i;
                          break;
                        }
                      }
                      if (dragHoverListIndex != targetIndex) {
                        setState(() => dragHoverListIndex = targetIndex);
                      }
                      return true;
                    },
                    onAcceptWithDetails: (details) {
                      final fromIndex = details.data;
                      setState(() {
                        final card = cards.removeAt(fromIndex);
                        int targetIndex = dragHoverListIndex ?? cards.length;
                        if (targetIndex > cards.length) {
                          targetIndex = cards.length;
                        }
                        cards.insert(targetIndex, card);

                        activeId = null;
                        draggingListIndex = null;
                        dragHoverListIndex = null;
                        draggingId = null;
                      });
                    },
                    builder: (context, candidateData, _) {
                      return const SizedBox.shrink();
                    },
                  ),
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
            child: Builder(
              builder: (context) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDE0F0),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.9),
                      width: 1.5,
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

    return Builder(
      builder: (context) {
        return LongPressDraggable<int>(
          data: index,
          onDragStarted: () => setState(() {
            draggingId = card.id;
            draggingListIndex = index;
            dragHoverListIndex = index;
            activeId = null;
          }),
          onDragEnd: (_) => setState(() {
            draggingId = null;
            draggingListIndex = null;
            dragHoverListIndex = null;
          }),
          onDraggableCanceled: (_, _) => setState(() {
            draggingId = null;
            draggingListIndex = null;
            dragHoverListIndex = null;
          }),
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
          child: IgnorePointer(
            ignoring: draggingId != null,
            child: GestureDetector(
              onTap: () => setState(() {
                activeId = activeId == card.id ? null : card.id;
              }),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: _cardBody(card, dragHoverListIndex == index),
                  ),
                  if (activeId == card.id && draggingId != card.id)
                    Positioned.fill(child: _resizeHandles(card, index)),
                ],
              ),
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
        color: isDropTarget ? Colors.blue.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: activeId == card.id ? Colors.blue : Colors.grey.shade300,
          width: activeId == card.id ? 2 : 1,
        ),
        boxShadow: [
          if (activeId == card.id)
            BoxShadow(
              color: Colors.blue.withValues(alpha: 0.2),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 24.0,
                left: 16,
                right: 16,
                bottom: 16,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth <= 0 || constraints.maxHeight <= 0) {
                    return const SizedBox.shrink();
                  }

                  // Base logical sizes representing the layout shapes
                  double baseW = 200;
                  double baseH = 200;

                  if (card.cardType == 'Type-02') {
                    baseW = 200;
                    baseH = 400;
                  } else if (card.cardType == 'Type-03') {
                    baseW = 400;
                    baseH = 400;
                  }

                  return FittedBox(
                    fit: BoxFit.contain,
                    child: SizedBox(
                      width: baseW,
                      height: baseH,
                      child: _buildContent(card),
                    ),
                  );
                },
              ),
            ),
          ),
          // Type Tag in top right corner
          Positioned(
            top: 0,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Text(
                card.cardType,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          if (card.cardType == 'Type-03' || card.cardType == 'Type-02')
            Positioned(
              top: 12,
              left: 16,
              child: Text(
                'Card Name',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.indigo.shade900,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDataBlock({double labelSize = 24, double valueSize = 36}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Data Name',
          style: TextStyle(
            fontSize: labelSize,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: labelSize * 0.5),
        Text(
          '000 / Value',
          style: TextStyle(
            fontSize: valueSize,
            color: Colors.indigo.shade900,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildContent(DashCard card) {
    if (card.cardType == 'Type-02') {
      return Column(
        children: [
          Expanded(child: _buildDataBlock(labelSize: 24, valueSize: 36)),
          Divider(color: Colors.grey.shade300, height: 1, thickness: 2),
          Expanded(child: _buildDataBlock(labelSize: 24, valueSize: 36)),
          Divider(color: Colors.grey.shade300, height: 1, thickness: 2),
          Expanded(child: _buildDataBlock(labelSize: 24, valueSize: 36)),
        ],
      );
    } else if (card.cardType == 'Type-03') {
      return Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(child: _buildDataBlock(labelSize: 24, valueSize: 36)),
                Container(width: 2, color: Colors.grey.shade200),
                Expanded(child: _buildDataBlock(labelSize: 24, valueSize: 36)),
              ],
            ),
          ),
          Divider(color: Colors.grey.shade300, height: 1, thickness: 2),
          Expanded(
            child: Row(
              children: [
                Expanded(child: _buildDataBlock(labelSize: 24, valueSize: 36)),
                Container(width: 2, color: Colors.grey.shade200),
                Expanded(child: _buildDataBlock(labelSize: 24, valueSize: 36)),
              ],
            ),
          ),
        ],
      );
    } else if (card.cardType == 'Type-05') {
      // Small 1x1 but packed with two stacked values
      return Column(
        children: [
          Expanded(child: _buildDataBlock(labelSize: 20, valueSize: 28)),
          Divider(color: Colors.grey.shade300, height: 1, thickness: 2),
          Expanded(child: _buildDataBlock(labelSize: 20, valueSize: 28)),
        ],
      );
    } else {
      // Type-01, Type-04, etc.
      return _buildDataBlock(labelSize: 24, valueSize: 36);
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

import 'dart:math';

import 'package:flutter/material.dart';

enum CardType { t1, t2, t3, t4 }

class DashCard {
  final CardType type;
  const DashCard(this.type);
}

/* Height units for algorithm */
int heightUnit(CardType type) {
  switch (type) {
    case CardType.t1:
      return 1;
    case CardType.t2:
      return 2;
    case CardType.t3:
      return 3;
    case CardType.t4:
      return 0; // excluded
  }
}

/* Visual base heights */
double visualHeight(CardType type) {
  switch (type) {
    case CardType.t1:
      return 80;
    case CardType.t2:
      return 160;
    case CardType.t3:
      return 320;
    case CardType.t4:
      return 120;
  }
}

/* ================= APP ================= */

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Dashboard(),
    );
  }
}

/* ================= DASHBOARD ================= */

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  final List<DashCard> cards = const [
    DashCard(CardType.t1),
    DashCard(CardType.t1),
    DashCard(CardType.t3),
    DashCard(CardType.t2),
    // DashCard(CardType.t1),
    // DashCard(CardType.t2),
    // DashCard(CardType.t3),
    // DashCard(CardType.t1),
    // DashCard(CardType.t2),
    // DashCard(CardType.t4),
    // DashCard(CardType.t1),
    // DashCard(CardType.t2),
  ];

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    final smallCards = cards.where((c) => c.type != CardType.t4).toList();
    final fullWidthCards = cards.where((c) => c.type == CardType.t4).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isLandscape)
              ...smallCards.map((c) => buildCard(c))
            else
              _buildSmallCardsLandscape(context, smallCards),

            const SizedBox(height: 16),

            // T4 – full width, always after
            ...fullWidthCards.map((c) => buildCard(c)),
          ],
        ),
      ),
    );
  }

  /* ================= LANDSCAPE SMALL CARDS ================= */

  Widget _buildSmallCardsLandscape(BuildContext context, List<DashCard> cards) {
    final columnCount = computeColumnCount(cards.length);
    final columns = LayoutEngine.buildColumns(cards, columnCount: columnCount);

    // Compute column heights
    final columnHeights = columns
        .map((col) => col.fold<double>(0, (s, c) => s + visualHeight(c.type)))
        .toList();

    final maxHeight = columnHeights.reduce(max);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(columns.length, (i) {
        final col = columns[i];
        final diff = maxHeight - columnHeights[i];

        final stretchables = col
            .where((c) => c.type == CardType.t1 || c.type == CardType.t2)
            .toList();

        final extra = stretchables.isEmpty ? 0 : diff / stretchables.length;

        return Expanded(
          child: Column(
            children: col.map((card) {
              final base = visualHeight(card.type);
              final height =
                  (card.type == CardType.t1 || card.type == CardType.t2)
                  ? base + extra
                  : base;
              return buildCard(card, height: height);
            }).toList(),
          ),
        );
      }),
    );
  }

  /* ================= CARD ================= */

  Widget buildCard(DashCard card, {double? height}) {
    final color = {
      CardType.t1: Colors.blue,
      CardType.t2: Colors.green,
      CardType.t3: Colors.orange,
      CardType.t4: Colors.red,
    }[card.type]!;

    return Container(
      width: double.infinity,
      height: height ?? visualHeight(card.type),
      margin: const EdgeInsets.all(6),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        card.type.name.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }
}

/* ================= LAYOUT ENGINE ================= */

class LayoutEngine {
  static List<List<DashCard>> buildColumns(
    List<DashCard> cards, {
    required int columnCount,
  }) {
    final columns = List.generate(columnCount, (_) => <DashCard>[]);
    final heights = List.filled(columnCount, 0);

    final sorted = [...cards]
      ..sort((a, b) => heightUnit(b.type).compareTo(heightUnit(a.type)));

    for (final card in sorted) {
      final idx = heights.indexOf(heights.reduce(min));
      columns[idx].add(card);
      heights[idx] += heightUnit(card.type);
    }

    return columns;
  }
}

/* ================= HELPERS ================= */

int computeColumnCount(int cardCount) {
  if (cardCount <= 3) return cardCount;
  return 2; // mobile landscape baseline
}

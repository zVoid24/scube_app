import 'package:flutter/material.dart';

class ResponsiveGridPage extends StatelessWidget {
  const ResponsiveGridPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Base width (standard mobile size)
    const baseWidth = 375.0;

    // Scale factor
    final scaleFactor = screenWidth / baseWidth;

    // Responsive font sizes
    final titleFontSize = 16 * scaleFactor;
    final subtitleFontSize = 14 * scaleFactor;

    return Scaffold(
      appBar: AppBar(title: const Text("Responsive Grid"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          itemCount: 20,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemBuilder: (context, index) {
            return ResponsiveCard(
              index: index,
              titleFontSize: titleFontSize,
              subtitleFontSize: subtitleFontSize,
            );
          },
        ),
      ),
    );
  }
}

class ResponsiveCard extends StatelessWidget {
  final int index;
  final double titleFontSize;
  final double subtitleFontSize;

  const ResponsiveCard({
    super.key,
    required this.index,
    required this.titleFontSize,
    required this.subtitleFontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Card Title ${index + 1}",
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "This is some responsive content inside the grid card.",
              style: TextStyle(
                fontSize: subtitleFontSize,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

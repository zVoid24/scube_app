import 'package:flutter/material.dart';
import 'package:flutter_application_1/presentation/extensions/smart_font.dart';
import 'package:flutter_application_1/presentation/pages/product_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844), // 👈 match your design base
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Responsive Grid',
          theme: ThemeData(primarySwatch: Colors.blue),
          home: const ProductPage(),
        );
      },
    );
  }
}

class ResponsiveGridPage extends StatelessWidget {
  const ResponsiveGridPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Responsive Grid", style: TextStyle(fontSize: 18.sp)),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(12.w),
        child: GridView.builder(
          itemCount: 20,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 1.2,
          ),
          itemBuilder: (context, index) {
            return ResponsiveCard(index: index);
          },
        ),
      ),
    );
  }
}

class ResponsiveCard extends StatelessWidget {
  final int index;

  const ResponsiveCard({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Card Title ${index + 1}",
              style: TextStyle(
                fontSize: 16.adaptiveSp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "This is some responsive content inside the grid card.",
              style: TextStyle(
                fontSize: 14.adaptiveSp,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

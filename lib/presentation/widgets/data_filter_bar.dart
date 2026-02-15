import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateFilterBar extends StatefulWidget {
  const DateFilterBar({super.key});

  @override
  State<DateFilterBar> createState() => _DateFilterBarState();
}

class _DateFilterBarState extends State<DateFilterBar> {
  final _fromController = TextEditingController();
  final _toController = TextEditingController();

  DateTime? _fromDate;
  DateTime? _toDate;

  final _dateFormat = DateFormat('dd MMM yyyy');

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final initialDate = isFrom
        ? (_fromDate ?? DateTime.now())
        : (_toDate ?? _fromDate ?? DateTime.now());

    final firstDate = isFrom ? DateTime(2000) : (_fromDate ?? DateTime(2000));

    final lastDate = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF5DA9F6),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF5DA9F6),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;

    setState(() {
      if (isFrom) {
        _fromDate = picked;
        _fromController.text = _dateFormat.format(picked);

        if (_toDate != null && _toDate!.isBefore(picked)) {
          _toDate = null;
          _toController.clear();
        }
      } else {
        _toDate = picked;
        _toController.text = _dateFormat.format(picked);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      //padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: _DateField(
              controller: _fromController,
              hint: 'From Date',
              onTap: () => _pickDate(isFrom: true),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _DateField(
              controller: _toController,
              hint: 'To Date',
              onTap: () => _pickDate(isFrom: false),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              // 🔹 Trigger API / BLoC filter here
              debugPrint('From: $_fromDate | To: $_toDate');
            },
            icon: const Icon(Icons.search),
            style: IconButton.styleFrom(
              backgroundColor: const Color.fromARGB(110, 129, 63, 227),
              foregroundColor: const Color.fromARGB(255, 115, 13, 223),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final VoidCallback onTap;

  const _DateField({
    required this.controller,
    required this.hint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = controller.text.isNotEmpty;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: IgnorePointer(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return TextField(
              controller: controller,
              maxLines: 1,
              //textAlignVertical: TextAlignVertical.center,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: _adaptiveFontSize(
                  text: controller.text,
                  maxWidth: constraints.maxWidth,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              decoration: InputDecoration(
                hintText: hint,
                suffixIcon: hasValue
                    ? null // ✅ hide calendar icon after date selected
                    : const Icon(Icons.calendar_today_outlined, size: 15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                //isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  double _adaptiveFontSize({required String text, required double maxWidth}) {
    if (text.isEmpty) return 12;

    // Simple, safe scaling logic
    if (maxWidth < 120 && text.length > 12) return 10;
    if (text.length > 18) return 9;
    return 11;
  }
}

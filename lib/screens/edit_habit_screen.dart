import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';
import '../models/habit_model.dart';
import '../providers/habit_provider.dart';

// ✅ StatefulWidget → ConsumerStatefulWidget
class EditHabitScreen extends ConsumerStatefulWidget {
  const EditHabitScreen({super.key});

  @override
  ConsumerState<EditHabitScreen> createState() => _EditHabitScreenState();
}

// ✅ State<EditHabitScreen> → ConsumerState<EditHabitScreen>
class _EditHabitScreenState extends ConsumerState<EditHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;

  late TimeOfDay _selectedTime;
  late Habit _habit;
  bool _isInitialized = false;

  String? _selectedCategory;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      // Ambil habit dari arguments (tidak berubah)
      _habit = ModalRoute.of(context)!.settings.arguments as Habit;
      _titleController = TextEditingController(text: _habit.title);
      _selectedCategory = _habit.category;

      // Parse time string → TimeOfDay (supports both 12h and 24h formats)
      _selectedTime = _parseTimeString(_habit.time);
      _isInitialized = true;
    }
  }

  // Robust time parser: supports "9:30 AM", "21:30", etc.
  TimeOfDay _parseTimeString(String timeStr) {
    try {
      final parts = timeStr.split(':');
      int hour = int.parse(parts[0].trim());
      final minuteStr = parts[1].trim();

      // Check if AM/PM is present (12-hour format)
      if (minuteStr.contains(RegExp(r'[AaPp][Mm]'))) {
        final minuteParts = minuteStr.split(RegExp(r'\s+'));
        int minute = int.parse(minuteParts[0].trim());
        final period = minuteParts[1].trim().toUpperCase();

        if (period == 'PM' && hour != 12) hour += 12;
        if (period == 'AM' && hour == 12) hour = 0;

        return TimeOfDay(hour: hour, minute: minute);
      } else {
        // 24-hour format (e.g., "21:30")
        return TimeOfDay(hour: hour, minute: int.parse(minuteStr));
      }
    } catch (_) {
      // Fallback jika parsing gagal
      return TimeOfDay.now();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // ✅ PERUBAHAN UTAMA: Update langsung ke Hive via habitNotifier
  Future<void> _updateHabit() async {
    if (_formKey.currentState!.validate()) {
      final updatedHabit = Habit(
        id: _habit.id,
        title: _titleController.text,
        category: _selectedCategory ?? 'Other',
        time: _selectedTime.format(context),
        isCompleted: _habit.isCompleted,
      );

      // ✅ Update ke Hive lewat provider (bukan pop dengan return value!)
      await ref.read(habitProvider.notifier).updateHabit(_habit.id, updatedHabit);

      // ✅ Kembali ke dashboard (tanpa return value)
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Habit',
          style: GoogleFonts.urbanist(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icon
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit_note,
                      size: 50,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Title Field
                Text(
                  'Habit Title',
                  style: GoogleFonts.urbanist(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'e.g., Morning Exercise',
                    prefixIcon: const Icon(Icons.title),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.lightGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                      const BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter habit title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Category Dropdown
                Text(
                  'Category',
                  style: GoogleFonts.urbanist(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    hintText: 'Select category',
                    prefixIcon: const Icon(Icons.category),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.lightGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                      const BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                  items: habitCategories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Time Picker
                Text(
                  'Time',
                  style: GoogleFonts.urbanist(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => _selectTime(context),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.lightGrey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time, color: AppColors.grey),
                        const SizedBox(width: 12),
                        Text(
                          _selectedTime.format(context),
                          style: GoogleFonts.urbanist(
                            fontSize: 16,
                            color: AppColors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Update Button
                ElevatedButton(
                  onPressed: _updateHabit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Update Habit',
                    style: GoogleFonts.urbanist(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
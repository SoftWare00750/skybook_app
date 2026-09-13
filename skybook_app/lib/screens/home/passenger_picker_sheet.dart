import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';

class PassengerSelection {
  final int adults;
  final int children;
  final String cabinClass;

  const PassengerSelection({required this.adults, required this.children, required this.cabinClass});

  int get total => adults + children;

  String get summary {
    final people = total == 1 ? '1 Adult' : (children == 0 ? '$adults Adults' : '$adults Adults, $children Children');
    return '$people, $cabinClass';
  }
}

const cabinClasses = ['Economy', 'Premium Economy', 'Business', 'First Class'];

/// Opens a modal bottom sheet so the user can adjust adult/children counts
/// and cabin class. Returns the updated [PassengerSelection], or null if
/// dismissed without confirming.
Future<PassengerSelection?> showPassengerPicker(BuildContext context, PassengerSelection initial) {
  return showModalBottomSheet<PassengerSelection>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg))),
    builder: (context) => _PassengerSheet(initial: initial),
  );
}

class _PassengerSheet extends StatefulWidget {
  final PassengerSelection initial;
  const _PassengerSheet({required this.initial});

  @override
  State<_PassengerSheet> createState() => _PassengerSheetState();
}

class _PassengerSheetState extends State<_PassengerSheet> {
  late int _adults = widget.initial.adults;
  late int _children = widget.initial.children;
  late String _cabinClass = widget.initial.cabinClass;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(4)),
            ),
          ),
          const Text('Passengers & Class', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _stepperRow(
            label: 'Adults',
            sublabel: '12 years and above',
            value: _adults,
            onDecrement: _adults > 1 ? () => setState(() => _adults--) : null,
            onIncrement: (_adults + _children) < 9 ? () => setState(() => _adults++) : null,
          ),
          const Divider(height: 28),
          _stepperRow(
            label: 'Children',
            sublabel: 'Below 12 years',
            value: _children,
            onDecrement: _children > 0 ? () => setState(() => _children--) : null,
            onIncrement: (_adults + _children) < 9 ? () => setState(() => _children++) : null,
          ),
          const Divider(height: 28),
          const Text('Cabin Class', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: cabinClasses.map((c) {
              final selected = c == _cabinClass;
              return ChoiceChip(
                label: Text(c),
                selected: selected,
                onSelected: (_) => setState(() => _cabinClass = c),
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(color: selected ? Colors.white : AppColors.textDark, fontSize: 12.5),
                backgroundColor: AppColors.inputFill,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
                side: BorderSide.none,
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Done',
            onPressed: () => Navigator.pop(
              context,
              PassengerSelection(adults: _adults, children: _children, cabinClass: _cabinClass),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepperRow({
    required String label,
    required String sublabel,
    required int value,
    required VoidCallback? onDecrement,
    required VoidCallback? onIncrement,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(sublabel, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
            ],
          ),
        ),
        _circleIconButton(Icons.remove, onDecrement),
        SizedBox(
          width: 32,
          child: Text('$value', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        _circleIconButton(Icons.add, onIncrement),
      ],
    );
  }

  Widget _circleIconButton(IconData icon, VoidCallback? onTap) {
    final enabled = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled ? AppColors.primary.withValues(alpha: 0.1) : AppColors.inputFill,
        ),
        child: Icon(icon, size: 18, color: enabled ? AppColors.primary : AppColors.textGrey),
      ),
    );
  }
}

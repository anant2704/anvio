// 📂 anvio/lib/widgets/icon_picker.dart

import 'package:flutter/material.dart';

class IconPicker extends StatefulWidget {
  final IconData initialIcon;
  final Function(IconData) onIconSelected;

  const IconPicker({
    super.key,
    required this.initialIcon,
    required this.onIconSelected,
  });

  @override
  State<IconPicker> createState() => _IconPickerState();
}

class _IconPickerState extends State<IconPicker> {
  late IconData _selectedIcon;

  final List<IconData> _icons = [
    Icons.fastfood, Icons.directions_car, Icons.shopping_bag, Icons.receipt_long,
    Icons.movie, Icons.local_grocery_store, Icons.medical_services, Icons.attach_money,
    Icons.flight, Icons.school, Icons.pets, Icons.home,
    Icons.fitness_center, Icons.phone_android, Icons.card_giftcard, Icons.build,
  ];

  @override
  void initState() {
    super.initState();
    _selectedIcon = widget.initialIcon;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Icon', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: _icons.map((icon) {
            final isSelected = _selectedIcon == icon;
            return GestureDetector(
              onTap: () {
                setState(() => _selectedIcon = icon);
                widget.onIconSelected(icon);
              },
              child: CircleAvatar(
                radius: 22,
                backgroundColor: isSelected
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                    : Colors.transparent,
                child: Icon(
                  icon,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).iconTheme.color,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
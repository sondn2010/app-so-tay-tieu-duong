import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class BloodSugarNumpad extends StatelessWidget {
  const BloodSugarNumpad({
    super.key,
    required this.value,
    required this.onChanged,
    this.maxLength = 4,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final int maxLength;

  void _handleKey(String key) {
    if (key == '⌫') {
      if (value.isNotEmpty) onChanged(value.substring(0, value.length - 1));
      return;
    }
    if (key == '.' && value.contains('.')) return;
    if (value.length >= maxLength) return;
    if (key == '.' && value.isEmpty) return;
    onChanged(value + key);
  }

  @override
  Widget build(BuildContext context) {
    const keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['.', '0', '⌫'],
    ];

    return Column(
      children: keys
          .map(
            (row) => Row(
              children: row
                  .map(
                    (k) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: _NumpadButton(
                          label: k,
                          onTap: () => _handleKey(k),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          )
          .toList(),
    );
  }
}

class _NumpadButton extends StatelessWidget {
  const _NumpadButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(10),
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(4),
          ),
          border: Border.all(color: AppColors.outline, width: 1.5),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurface,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class TermsCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  const TermsCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      title: const Text(
        'Li e concordo com os Termos e Política de Privacidade',
      ),
      controlAffinity: ListTileControlAffinity.leading,
      dense: true,
    );
  }
}

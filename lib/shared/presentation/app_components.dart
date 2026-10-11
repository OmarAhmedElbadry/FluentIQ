import 'package:flutter/material.dart';

/// Consistent rounded surface for product content.
class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.onTap});
  final Widget child;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Card(child: InkWell(borderRadius: BorderRadius.circular(22), onTap: onTap, child: Padding(padding: const EdgeInsets.all(20), child: child)));
}

/// Primary action button with product-standard sizing.
class AppButton extends StatelessWidget {
  const AppButton({super.key, required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => SizedBox(width: double.infinity, height: 54, child: FilledButton(onPressed: onPressed, child: Text(label)));
}

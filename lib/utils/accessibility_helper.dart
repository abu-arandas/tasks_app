import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// A utility class for improving accessibility throughout the app.
/// This class provides methods for adding semantic labels, hints, and other
/// accessibility features to widgets.
class AccessibilityHelper {
  // Singleton pattern
  static final AccessibilityHelper _instance = AccessibilityHelper._internal();
  factory AccessibilityHelper() => _instance;
  AccessibilityHelper._internal();

  /// Wrap a widget with semantic labels for screen readers
  Widget wrapWithSemantics({
    required Widget child,
    required String label,
    String? hint,
    bool excludeSemantics = false,
    VoidCallback? onTap,
    bool isButton = false,
    bool isTextField = false,
    bool isChecked = false,
    bool isEnabled = true,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      excludeSemantics: excludeSemantics,
      button: isButton,
      textField: isTextField,
      enabled: isEnabled,
      checked: isChecked,
      onTap: onTap,
      child: child,
    );
  }

  /// Create an accessible button with proper semantics
  Widget createAccessibleButton({
    required Widget child,
    required String label,
    String? hint,
    required VoidCallback onPressed,
    bool isEnabled = true,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      button: true,
      enabled: isEnabled,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        child: child,
      ),
    );
  }

  /// Create an accessible icon button with proper semantics
  Widget createAccessibleIconButton({
    required IconData icon,
    required String label,
    String? hint,
    required VoidCallback onPressed,
    bool isEnabled = true,
    Color? color,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      button: true,
      enabled: isEnabled,
      child: IconButton(
        icon: Icon(icon, color: color),
        onPressed: isEnabled ? onPressed : null,
        tooltip: label, // Tooltip also helps with accessibility
      ),
    );
  }

  /// Create an accessible checkbox with proper semantics
  Widget createAccessibleCheckbox({
    required bool value,
    required String label,
    required ValueChanged<bool?> onChanged,
    bool isEnabled = true,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          label: label,
          checked: value,
          enabled: isEnabled,
          child: Checkbox(
            value: value,
            onChanged: isEnabled ? onChanged : null,
          ),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }

  /// Create an accessible text field with proper semantics
  Widget createAccessibleTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool isEnabled = true,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    ValueChanged<String>? onChanged,
    int? maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
      ),
      enabled: isEnabled,
      keyboardType: keyboardType,
      obscureText: obscureText,
      onChanged: onChanged,
      maxLines: maxLines,
      // The TextField widget already has good accessibility support
    );
  }

  /// Announce a message to screen readers
  void announce(String message, [TextDirection textDirection = TextDirection.ltr]) {
    SemanticsService.announce(message, textDirection);
  }

  /// Get the current text scale factor (for font size accessibility)
  double getTextScaleFactor(BuildContext context) {
    return MediaQuery.of(context).textScaler.scale(16);
  }

  /// Check if the device has large fonts enabled
  bool hasLargeFonts(BuildContext context) {
    final textScaleFactor = MediaQuery.of(context).textScaler.scale(16);
    return textScaleFactor > 1.3; // Threshold for "large fonts"
  }

  /// Check if the device has screen reader enabled
  /// Note: This is a placeholder. In a real app, you would use
  /// platform-specific code to detect screen readers.
  bool isScreenReaderEnabled() {
    // Placeholder implementation
    return false;
  }

  /// Get appropriate padding based on accessibility settings
  EdgeInsets getAccessiblePadding(BuildContext context) {
    final textScaleFactor = MediaQuery.of(context).textScaler.scale(16);
    // Increase padding for users with larger text settings
    return EdgeInsets.all(8.0 * textScaleFactor);
  }

  /// Get appropriate icon size based on accessibility settings
  double getAccessibleIconSize(BuildContext context) {
    final textScaleFactor = MediaQuery.of(context).textScaler.scale(16);
    // Increase icon size for users with larger text settings
    return 24.0 * textScaleFactor;
  }
}

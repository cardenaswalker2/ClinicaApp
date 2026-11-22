import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/apple_theme.dart';

class AppleCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double borderRadius;
  final Color? color;
  final Border? border;

  const AppleCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.borderRadius = 20,
    this.color,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: color ?? AppleTheme.surface,
      borderRadius: BorderRadius.circular(borderRadius),
      border: border ?? Border.all(color: AppleTheme.border, width: 0.8),
      boxShadow: AppleTheme.cardShadow,
    );

    final content = Container(
      margin: margin,
      decoration: decoration,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: onTap != null
            ? InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(borderRadius),
                child: Padding(
                  padding: padding ?? const EdgeInsets.all(16),
                  child: child,
                ),
              )
            : Padding(
                padding: padding ?? const EdgeInsets.all(16),
                child: child,
              ),
      ),
    );

    return content;
  }
}

class AppleButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final double height;
  final bool outlined;

  const AppleButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.height = 54,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? AppleTheme.blue;
    final fg = textColor ?? (outlined ? bg : Colors.white);

    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: outlined ? AppleTheme.surface : bg,
          foregroundColor: fg,
          disabledBackgroundColor: bg.withValues(alpha: 0.45),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: outlined
                ? BorderSide(color: bg.withValues(alpha: 0.35), width: 1.2)
                : BorderSide.none,
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: fg,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20, color: fg),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: fg,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class AppleTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;

  const AppleTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: GoogleFonts.plusJakartaSans(
        color: AppleTheme.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: GoogleFonts.plusJakartaSans(
          color: AppleTheme.textSecondary,
          fontSize: 14,
        ),
        hintStyle: GoogleFonts.plusJakartaSans(
          color: AppleTheme.textTertiary,
          fontSize: 14,
        ),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppleTheme.textSecondary, size: 20)
            : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppleTheme.surfaceSecondary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppleTheme.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppleTheme.blue, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppleTheme.red, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppleTheme.red, width: 1.6),
        ),
      ),
    );
  }
}

class AppleIconBox extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final double iconSize;

  const AppleIconBox({
    super.key,
    required this.icon,
    required this.color,
    this.size = 44,
    this.iconSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(icon, color: color, size: iconSize),
    );
  }
}

class AppleBadge extends StatelessWidget {
  final String text;
  final Color color;

  const AppleBadge({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class AppleSectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onAction;

  const AppleSectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: AppleTheme.textPrimary,
            letterSpacing: -0.4,
          ),
        ),
        if (actionText != null && onAction != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionText!,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppleTheme.blue,
              ),
            ),
          ),
      ],
    );
  }
}

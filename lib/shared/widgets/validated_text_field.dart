import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bg_med/core/services/validation_service.dart';
import 'package:bg_med/core/theme/app_theme.dart';

class ValidatedTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final String? initialValue;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final int? maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final FocusNode? focusNode;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final ValidationType validationType;
  final String? customValidationMessage;
  final int? minLength;
  final bool required;

  const ValidatedTextField({
    super.key,
    required this.label,
    this.hint,
    this.initialValue,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.validationType = ValidationType.none,
    this.customValidationMessage,
    this.minLength,
    this.required = false,
  });

  @override
  State<ValidatedTextField> createState() => _ValidatedTextFieldState();
}

class _ValidatedTextFieldState extends State<ValidatedTextField> {
  final TextEditingController _controller = TextEditingController();
  final ValidationService _validationService = ValidationService();
  ValidationResult? _validationResult;
  bool _isValidating = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }
    _validateField(_controller.text);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validateField(String value) {
    if (!mounted) return;

    setState(() {
      _isValidating = true;
    });

    // Usar validator personalizado si se proporciona
    if (widget.validator != null) {
      final error = widget.validator!(value);
      _validationResult = ValidationResult(
        isValid: error == null,
        errors: error != null 
            ? [ValidationError(field: widget.label, message: error)]
            : [],
        warnings: [],
      );
    } else {
      // Usar validación automática basada en el tipo
      _validationResult = _getValidationResult(value);
    }

    setState(() {
      _isValidating = false;
    });
  }

  ValidationResult _getValidationResult(String value) {
    switch (widget.validationType) {
      case ValidationType.required:
        return _validationService.validateRequired(value, widget.label);
      case ValidationType.email:
        return _validationService.validateEmail(value);
      case ValidationType.phone:
        return _validationService.validatePhone(value);
      case ValidationType.age:
        final age = int.tryParse(value);
        return age != null 
            ? _validationService.validateAge(age)
            : ValidationResult(
                isValid: false,
                errors: [ValidationError(field: widget.label, message: 'Edad inválida')],
                warnings: [],
              );
      case ValidationType.minLength:
        if (widget.minLength != null) {
          return _validationService.validateMinLength(value, widget.label, widget.minLength!);
        }
        break;
      case ValidationType.bloodPressure:
        if (value.isNotEmpty) {
          final isValid = _validationService.validateMedicalData({'bloodPressure': value});
          return isValid;
        }
        break;
      case ValidationType.heartRate:
        if (value.isNotEmpty) {
          final isValid = _validationService.validateMedicalData({'heartRate': value});
          return isValid;
        }
        break;
      case ValidationType.temperature:
        if (value.isNotEmpty) {
          final isValid = _validationService.validateMedicalData({'temperature': value});
          return isValid;
        }
        break;
      case ValidationType.glucose:
        if (value.isNotEmpty) {
          final isValid = _validationService.validateMedicalData({'glucose': value});
          return isValid;
        }
        break;
      case ValidationType.painScale:
        if (value.isNotEmpty) {
          final isValid = _validationService.validateMedicalData({'painScale': value});
          return isValid;
        }
        break;
      case ValidationType.none:
        break;
    }

    return ValidationResult(
      isValid: true,
      errors: [],
      warnings: [],
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasErrors = _validationResult?.hasErrors ?? false;
    final hasWarnings = _validationResult?.hasWarnings ?? false;
    final isRequired = widget.required || widget.validationType == ValidationType.required;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label con indicador de requerido
        Row(
          children: [
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: hasErrors ? AppTheme.accentRed : AppTheme.textDark,
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              Text(
                '*',
                style: TextStyle(
                  color: AppTheme.accentRed,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        
        // Campo de texto
        TextFormField(
          controller: _controller,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          obscureText: widget.obscureText,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          inputFormatters: widget.inputFormatters,
          focusNode: widget.focusNode,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          autofocus: widget.autofocus,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon,
            suffixIcon: _buildSuffixIcon(),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _getBorderColor(hasErrors, hasWarnings),
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _getBorderColor(hasErrors, hasWarnings),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasErrors ? AppTheme.accentRed : AppTheme.primaryBlue,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.accentRed,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: widget.enabled 
                ? Colors.white 
                : Colors.grey.shade100,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          onChanged: (value) {
            _validateField(value);
            widget.onChanged?.call(value);
          },
          onFieldSubmitted: widget.onSubmitted,
          validator: (value) {
            if (_validationResult?.hasErrors ?? false) {
              return _validationResult!.errors.first.message;
            }
            return null;
          },
        ),
        
        // Mensajes de validación
        if (_validationResult != null) ...[
          const SizedBox(height: 4),
          _buildValidationMessages(),
        ],
      ],
    );
  }

  Widget _buildSuffixIcon() {
    if (_isValidating) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (_validationResult != null) {
      if (_validationResult!.hasErrors) {
        return Icon(
          Icons.error_outline,
          color: AppTheme.accentRed,
          size: 20,
        );
      } else if (_validationResult!.hasWarnings) {
        return Icon(
          Icons.warning_amber_outlined,
          color: AppTheme.accentOrange,
          size: 20,
        );
      } else if (_validationResult!.isValid) {
        return Icon(
          Icons.check_circle_outline,
          color: AppTheme.primaryGreen,
          size: 20,
        );
      }
    }

    return widget.suffixIcon ?? const SizedBox.shrink();
  }

  Widget _buildValidationMessages() {
    final messages = <Widget>[];

    // Errores
    for (final error in _validationResult!.errors) {
      messages.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Row(
            children: [
              Icon(
                Icons.error_outline,
                size: 14,
                color: AppTheme.accentRed,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  error.message,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.accentRed,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Advertencias
    for (final warning in _validationResult!.warnings) {
      messages.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Row(
            children: [
              Icon(
                Icons.warning_amber_outlined,
                size: 14,
                color: AppTheme.accentOrange,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  warning.message,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.accentOrange,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: messages,
    );
  }

  Color _getBorderColor(bool hasErrors, bool hasWarnings) {
    if (hasErrors) {
      return AppTheme.accentRed;
    } else if (hasWarnings) {
      return AppTheme.accentOrange;
    } else if (_validationResult?.isValid == true) {
      return AppTheme.primaryGreen;
    }
    return Colors.grey.shade400;
  }
}

enum ValidationType {
  none,
  required,
  email,
  phone,
  age,
  minLength,
  bloodPressure,
  heartRate,
  temperature,
  glucose,
  painScale,
} 
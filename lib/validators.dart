class Validators {
  static String? email(String? v) {
    final value = (v ?? '').trim();
    final emailRx = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (value.isEmpty) return 'El correo es obligatorio';
    if (!emailRx.hasMatch(value)) return 'Correo inválido';
    return null;
  }
  static String? password(String? v) {
    final value = v ?? '';
    if (value.length < 6) return 'Mínimo 6 caracteres';
    if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Incluye al menos una mayúscula';
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Incluye al menos un número';
    return null;
  }
}
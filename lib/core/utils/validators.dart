class Validators {
  static String? validateRole(String? value) {
    if (value == null || value.isEmpty) {
      return 'Role tidak boleh kosong';
    }

    return null;
  }

  static String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama lengkap tidak boleh kosong';
    }

    return null;
  }

  static String? validateUniqueName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama Unik tidak boleh kosong';
    }

    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }

    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value)) {
      return 'Email tidak valid';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }

    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }

    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nomor telepon tidak boleh kosong';
    }

    final phoneRegExp = RegExp(r'^[0-9]{10,13}$');
    if (!phoneRegExp.hasMatch(value)) {
      return 'Nomor telepon tidak valid';
    }

    return null;
  }

  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Alamat tidak boleh kosong';
    }

    return null;
  }
}

abstract class Failure {
  final String message;
  
  Failure({required this.message});
}

class ServerFailure extends Failure {
  ServerFailure() : super(message: 'Terjadi kesalahan pada server');
}

class CacheFailure extends Failure {
  CacheFailure() : super(message: 'Gagal mengambil data dari cache');
}

class NetworkFailure extends Failure {
  NetworkFailure() : super(message: 'Tidak ada koneksi internet');
}

class WeakPasswordFailure extends Failure {
  WeakPasswordFailure() : super(message: 'Password terlalu lemah');
}

class EmailAlreadyInUseFailure extends Failure {
  EmailAlreadyInUseFailure() : super(message: 'Email sudah digunakan');
}

class InvalidCredentialsFailure extends Failure {
  InvalidCredentialsFailure() : super(message: 'Email atau password salah');
}

class UserNotFoundFailure extends Failure {
  UserNotFoundFailure() : super(message: 'Pengguna tidak ditemukan');
}
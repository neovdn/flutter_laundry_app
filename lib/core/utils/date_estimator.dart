class DateEstimator {
  static DateTime calculateEstimatedCompletion(String laundrySpeed) {
    final now = DateTime.now();
    
    switch (laundrySpeed.toLowerCase()) {
      case 'express':
        return now.add(const Duration(days: 1));
      case 'reguler':
        return now.add(const Duration(days: 2));
      default:
        // Default ke Reguler jika speed tidak dikenali
        return now.add(const Duration(days: 2));
    }
  }

  // Fungsi tambahan untuk memformat tanggal jika diperlukan
  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
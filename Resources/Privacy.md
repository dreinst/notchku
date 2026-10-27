# Kebijakan Privasi NotchKu

NotchKu tidak mengumpulkan data apa pun. Tidak ada analitik, pelacakan, atau server milik NotchKu.

Semua yang diproses NotchKu tetap di Mac kamu:

- File di tray dan screenshot disimpan di `~/Library/Application Support/NotchKu` dan dihapus otomatis setelah masa simpannya habis.
- Status Bluetooth dan Spotify dibaca langsung dari macOS dan tidak disimpan.
- Pengaturan disimpan di preferensi aplikasi.

Plaud bersifat opsional. Kalau kamu menghubungkan akun Plaud, NotchKu menyimpan token login di Keychain macOS dan memakainya hanya untuk mengecek daftar rekaman di server Plaud tiap 2 menit. Integrasi ini memakai endpoint web Plaud yang tidak resmi dan bisa berhenti bekerja kalau Plaud mengubahnya. Pilih "Putuskan Plaud" di menu notch untuk menghapus token.

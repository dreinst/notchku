# NotchKu

Notch di MacBook kamu selama ini cuma potongan hitam di tengah layar. NotchKu mengubahnya jadi pusat kecil yang hidup, mirip Dynamic Island di iPhone. Arahkan kursor ke notch dan panelnya langsung mengembang. Geser kursor menjauh dan panelnya menyusut lagi. Tidak perlu klik.

Gratis, open source (MIT), dan semua datanya tetap di Mac kamu.

## Kenapa NotchKu

Kebanyakan aplikasi notch hanya bisa satu hal. NotchKu menggabungkan hal-hal kecil yang sering dipakai seharian ke satu tempat yang selalu ada di atas layar.

### Terasa seperti Dynamic Island

Panel terbuka begitu kursor menyentuh notch, dengan animasi pegas yang memantul sedikit dan isi yang muncul dari buram ke tajam. Saat dibuka lewat hover, NotchKu tidak merebut fokus, jadi ketikanmu di aplikasi lain tidak terputus.

### Tray file sementara

Seret file apa pun ke notch untuk menyimpannya sebentar, lalu seret keluar lagi ke aplikasi tujuan. Cocok untuk memindahkan file antar jendela, antar Space, atau ke AirDrop tanpa menumpuk isi Desktop. File di tray dibersihkan otomatis setelah masa simpannya habis (bisa diatur).

### Screenshot langsung tertangkap

Setiap screenshot baru di folder screenshot macOS dipindah ke tray dan notch terbuka sekilas selama 4 detik supaya kamu bisa langsung menyeretnya ke chat, email, atau dokumen. Kalau tidak dipakai, setelah 1 jam file itu dikembalikan ke folder asalnya. Desktop tetap bersih dan tidak ada screenshot yang hilang.

### Kabar Bluetooth

AirPods, mouse, atau keyboard tersambung dan terputus muncul sebagai kabar singkat di samping notch.

### Timer fokus dengan Spotify

Mulai sesi fokus 25, 50, atau 90 menit dari notch. Sisa waktunya tampil di samping notch selama sesi berjalan. Lagu yang sedang diputar di Spotify (judul, artwork, putar, jeda, lewati) bisa dikendalikan dari panel yang sama.

### Kabar rekaman Plaud

Pengguna Plaud Note bisa menghubungkan akunnya dari menu notch. NotchKu mengecek akun Plaud tiap 2 menit dan memberi tahu kalau ada rekaman baru yang masuk. Token login disimpan di Keychain macOS.

## Kebutuhan

- macOS 14 Sonoma atau lebih baru
- Paling pas di MacBook yang punya notch

## Pasang dari kode sumber

Cara tercepat, tanpa Xcode, cukup Command Line Tools (`xcode-select --install`):

```bash
git clone https://github.com/dreinst/notchku.git
cd notchku
zsh scripts/dev-build.sh
```

Skrip ini membangun `build/NotchKu.app` dengan Swift Package Manager lalu langsung membukanya. Pindahkan ke folder Applications kalau mau dipakai sehari-hari.

Kalau kamu punya Xcode, buka `NotchDrop.xcodeproj`, pilih skema `NotchDrop`, lalu Run.

### Tanda tangan lokal (opsional)

Build tanpa sertifikat ditandatangani ad-hoc, jadi macOS bisa menanyakan ulang izin Bluetooth dan Automation tiap kali build. Supaya izin itu tetap tersimpan, buat sertifikat penandatanganan kode bernama `NotchKu Local` lewat Keychain Access (Certificate Assistant, Create a Certificate, tipe Code Signing). `dev-build.sh` otomatis memakainya kalau ada.

### Menghentikan NotchKu

Jalankan `Resources/KillNotchKu.command` atau `pkill -x NotchKu`.

## Izin yang diminta

| Izin | Untuk apa |
| --- | --- |
| Bluetooth | Kabar perangkat tersambung dan terputus |
| Automation (Spotify) | Membaca lagu yang diputar dan mengendalikannya |
| Akses folder screenshot | Memindahkan screenshot baru ke tray |

## Privasi

NotchKu tidak mengirim data ke mana pun. Tidak ada analitik dan tidak ada server milik NotchKu. Satu-satunya koneksi keluar adalah ke server Plaud, dan itu hanya terjadi kalau kamu sendiri menghubungkan akun Plaud. Detailnya ada di [Resources/Privacy.md](Resources/Privacy.md).

## Ikut mengembangkan

Issue dan pull request terbuka. Panduan gaya kode ada di [AGENTS.md](AGENTS.md). File Swift baru perlu didaftarkan ke proyek Xcode lewat `python3 scripts/add_swift.py`.

## Lisensi

MIT. Lihat [LICENSE](LICENSE).

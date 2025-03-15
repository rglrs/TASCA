# Cara Menjalankan Program

### 1. Clone Repository
```bash
git clone -b web https://github.com/rglrs/TASCA.git
```


### 2. Install Dependencies
Pastikan Anda berada di direktori proyek, kemudian jalankan:
```bash
npm install
```

### 3. Install React Router
Tambahkan React Router ke dalam proyek:
```bash
npm install react-router-dom
```

### 4. Konfigurasi Tailwind CSS (Opsional)
Jika belum ada file konfigurasi Tailwind, inisialisasi dengan:
```bash
npx tailwindcss init -p
```

### 5. Update File tailwind.config.js (Lakukan jika tailwind belum di inisiasi)
Sesuaikan konfigurasi content untuk memastikan Tailwind bekerja dengan benar:
```js
// tailwind.config.js
module.exports = {
  content: [
    './index.html',
    './src/**/*.{js,jsx,ts,tsx}',
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
```

### 6. Jalankan Proyek
```bash
npm run dev
```
Proyek akan berjalan di `http://localhost:5173` atau sesuai output terminal.

### 7. Troubleshooting
- Jika ada masalah dengan module, coba hapus node_modules dan instal ulang:

```bash
rm -rf node_modules
npm install
```
- Jika Vite tidak dapat menemukan alias `@`, pastikan konfigurasi di `vite.config.js` sudah benar.

### 8. Happy Coding!
Semangatt Gesss!!


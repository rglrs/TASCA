import React, { useEffect } from 'react';
import { motion } from 'framer-motion';

const Terms = () => {
  useEffect(() => {
    // Smooth scroll to sections when clicking on links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
      anchor.addEventListener('click', function (e) {
        e.preventDefault();
        document.querySelector(this.getAttribute('href')).scrollIntoView({
          behavior: 'smooth'
        });
      });
    });
  }, []);

  const fadeIn = {
    hidden: { opacity: 0, y: 20 },
    visible: { 
      opacity: 1, 
      y: 0,
      transition: { duration: 0.6 }
    }
  };

  const staggerContainer = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.2
      }
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-b from-gray-50 to-gray-100 dark:from-gray-900 dark:to-gray-800 text-gray-800 dark:text-gray-200">
      <motion.div 
        initial="hidden"
        animate="visible"
        variants={fadeIn}
        className="container mx-auto px-4 py-12 max-w-4xl"
      >
        {/* Header with animated gradient */}
        <div className="relative overflow-hidden mb-16 rounded-xl shadow-xl">
          <div className="absolute inset-0 bg-gradient-to-r from-green-500 to-blue-600 animate-gradient-x"></div>
          <div className="relative z-10 px-8 py-12 backdrop-blur-sm bg-white/10">
            <motion.h1 
              className="text-4xl md:text-5xl font-bold mb-3 text-white text-center"
              initial={{ opacity: 0, scale: 0.9 }}
              animate={{ opacity: 1, scale: 1 }}
              transition={{ duration: 0.8, delay: 0.2 }}
            >
              Syarat dan Ketentuan Tasca
            </motion.h1>
            <motion.p 
              className="text-lg text-center text-white/90"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              transition={{ duration: 0.8, delay: 0.5 }}
            >
              Terakhir diperbarui: 27 Maret 2025
            </motion.p>
          </div>
        </div>
        
        {/* Table of Contents */}
        <motion.div 
          className="mb-12 p-6 bg-white dark:bg-gray-800 rounded-xl shadow-lg"
          variants={fadeIn}
        >
          <h2 className="text-xl font-semibold mb-4 text-green-600 dark:text-green-400">Daftar Isi</h2>
          <ul className="space-y-2">
            {[
              { id: "pengantar", text: "Pengantar" },
              { id: "penggunaan", text: "Penggunaan Layanan" },
              { id: "akun", text: "Akun Pengguna" },
              { id: "konten", text: "Konten Pengguna" },
              { id: "pembayaran", text: "Pembayaran dan Berlangganan" },
              { id: "hakcipta", text: "Hak Kekayaan Intelektual" },
              { id: "batasan", text: "Batasan Penggunaan" },
              { id: "penolakan", text: "Penolakan Jaminan" },
              { id: "tanggung-jawab", text: "Batasan Tanggung Jawab" },
              { id: "pembaruan", text: "Pembaruan Syarat" },
              { id: "hukum", text: "Hukum yang Berlaku" },
              { id: "kontak", text: "Hubungi Kami" }
            ].map((item, index) => (
              <motion.li 
                key={item.id}
                initial={{ opacity: 0, x: -20 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ duration: 0.4, delay: 0.1 * index }}
              >
                <a 
                  href={`#${item.id}`} 
                  className="text-green-500 hover:text-green-700 dark:text-green-400 dark:hover:text-green-300 transition-colors duration-200 flex items-center group"
                >
                  <span className="w-6 h-6 flex items-center justify-center rounded-full bg-green-100 dark:bg-green-900 text-green-600 dark:text-green-400 mr-2 group-hover:bg-green-200 dark:group-hover:bg-green-800 transition-colors duration-200">
                    {index + 1}
                  </span>
                  {item.text}
                </a>
              </motion.li>
            ))}
          </ul>
        </motion.div>
        
        <motion.div 
          variants={staggerContainer}
          initial="hidden"
          animate="visible"
          className="space-y-8"
        >
          {/* Content Sections */}
          <Section 
            id="pengantar"
            title="Pengantar"
            variants={fadeIn}
            colorClass="from-green-500 to-blue-600"
          >
            <p className="leading-relaxed">
              Selamat datang di Tasca. Aplikasi dan layanan ini disediakan oleh Tim Tasca ("kami") dan dapat diakses melalui situs web, aplikasi seluler, atau platform lainnya. Dengan mengakses atau menggunakan Tasca, Anda menyetujui untuk terikat oleh Syarat dan Ketentuan ini ("Syarat").
            </p>
            <p className="leading-relaxed mt-4">
              Harap membaca Syarat ini dengan seksama sebelum menggunakan aplikasi Tasca. Jika Anda tidak menyetujui sebagian atau seluruh syarat ini, Anda tidak boleh menggunakan layanan kami.
            </p>
          </Section>
          
          <Section 
            id="penggunaan"
            title="Penggunaan Layanan"
            variants={fadeIn}
            colorClass="from-green-500 to-blue-600"
          >
            <p className="mb-4 leading-relaxed">
              Tasca adalah aplikasi manajemen tugas dan proyek yang menggunakan metode Pomodoro untuk membantu pengguna mengelola waktu dan meningkatkan produktivitas. Layanan kami mencakup namun tidak terbatas pada:
            </p>
            <ul className="space-y-3">
              {[
                "Pembuatan dan pengelolaan tugas serta proyek",
                "Pelacakan waktu dengan metode Pomodoro",
                "Analisis dan pelaporan produktivitas",
                "Sinkronisasi data di berbagai perangkat",
                "Fitur kolaborasi (jika tersedia)"
              ].map((item, index) => (
                <motion.li 
                  key={index}
                  className="p-4 bg-white dark:bg-gray-800 rounded-lg shadow-sm hover:shadow-md transition-shadow duration-300 flex items-start"
                  initial={{ opacity: 0, y: 10 }}
                  whileInView={{ opacity: 1, y: 0 }}
                  viewport={{ once: true }}
                  transition={{ duration: 0.4, delay: 0.1 * index }}
                >
                  <div className="flex-shrink-0 w-6 h-6 rounded-full bg-green-100 dark:bg-green-900 flex items-center justify-center mr-3 mt-0.5">
                    <svg className="w-4 h-4 text-green-600 dark:text-green-400" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M5 13l4 4L19 7"></path>
                    </svg>
                  </div>
                  <p>{item}</p>
                </motion.li>
              ))}
            </ul>
            <p className="mt-4 leading-relaxed">
              Kami berhak untuk memodifikasi atau menghentikan, sementara atau permanen, sebagian atau seluruh layanan kami dengan atau tanpa pemberitahuan sebelumnya dan tanpa kewajiban kepada Anda.
            </p>
          </Section>
          
          <Section 
            id="akun"
            title="Akun Pengguna"
            variants={fadeIn}
            colorClass="from-green-500 to-blue-600"
          >
            <div className="space-y-4">
              <motion.div 
                className="p-5 bg-white dark:bg-gray-800 rounded-lg shadow-md"
                initial={{ opacity: 0 }}
                whileInView={{ opacity: 1 }}
                viewport={{ once: true }}
                transition={{ duration: 0.5 }}
              >
                <h3 className="text-lg font-semibold mb-2 text-green-600 dark:text-green-400">Pembuatan Akun</h3>
                <p className="leading-relaxed">
                  Untuk menggunakan beberapa fitur Tasca, Anda mungkin perlu membuat akun. Anda harus memberikan informasi yang akurat, lengkap, dan terbaru. Anda bertanggung jawab untuk menjaga kerahasiaan kata sandi dan keamanan akun Anda.
                </p>
              </motion.div>

              <motion.div 
                className="p-5 bg-white dark:bg-gray-800 rounded-lg shadow-md"
                initial={{ opacity: 0 }}
                whileInView={{ opacity: 1 }}
                viewport={{ once: true }}
                transition={{ duration: 0.5, delay: 0.2 }}
              >
                <h3 className="text-lg font-semibold mb-2 text-green-600 dark:text-green-400">Keamanan Akun</h3>
                <p className="leading-relaxed">
                  Anda setuju untuk segera memberi tahu kami tentang penggunaan yang tidak sah dari akun atau kata sandi Anda. Anda bertanggung jawab sepenuhnya atas semua aktivitas yang terjadi di akun Anda.
                </p>
              </motion.div>

              <motion.div 
                className="p-5 bg-white dark:bg-gray-800 rounded-lg shadow-md"
                initial={{ opacity: 0 }}
                whileInView={{ opacity: 1 }}
                viewport={{ once: true }}
                transition={{ duration: 0.5, delay: 0.4 }}
              >
                <h3 className="text-lg font-semibold mb-2 text-green-600 dark:text-green-400">Penangguhan Akun</h3>
                <p className="leading-relaxed">
                  Kami berhak untuk menangguhkan atau menghentikan akun Anda dan akses ke layanan jika, menurut kebijaksanaan kami, Anda melanggar Syarat ini atau jika aktivitas Anda merugikan reputasi dan niat baik kami atau pengguna lain.
                </p>
              </motion.div>
            </div>
          </Section>
          
          <Section 
            id="konten"
            title="Konten Pengguna"
            variants={fadeIn}
            colorClass="from-green-500 to-blue-600"
          >
            <p className="mb-4 leading-relaxed">
              Anda mempertahankan semua hak dan kepemilikan atas konten yang Anda buat, unggah, atau sediakan saat menggunakan layanan kami ("Konten Pengguna"). Dengan mengirimkan Konten Pengguna, Anda memberikan kami lisensi non-eksklusif, bebas royalti, dapat disublisensikan, dan dapat dialihkan untuk menggunakan, menyalin, memodifikasi, mendistribusikan, dan menampilkan Konten Pengguna tersebut semata-mata untuk tujuan:
            </p>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mt-4">
              {[
                {
                  title: "Penyediaan Layanan",
                  content: "Mengoperasikan dan menyediakan layanan Tasca kepada Anda"
                },
                {
                  title: "Perbaikan Layanan",
                  content: "Mengembangkan dan meningkatkan layanan kami"
                },
                {
                  title: "Penyimpanan",
                  content: "Menyimpan dan mencadangkan data Anda"
                },
                {
                  title: "Dukungan Teknis",
                  content: "Memberikan dukungan teknis dan pemecahan masalah"
                }
              ].map((item, index) => (
                <motion.div 
                  key={index}
                  className="p-4 bg-white dark:bg-gray-800 rounded-lg shadow-sm border border-gray-200 dark:border-gray-700"
                  initial={{ opacity: 0, y: 10 }}
                  whileInView={{ opacity: 1, y: 0 }}
                  viewport={{ once: true }}
                  transition={{ duration: 0.4, delay: 0.1 * index }}
                >
                  <h3 className="font-semibold text-green-600 dark:text-green-400 mb-2">{item.title}</h3>
                  <p>{item.content}</p>
                </motion.div>
              ))}
            </div>
          </Section>
          
          <Section 
            id="pembayaran"
            title="Pembayaran dan Berlangganan"
            variants={fadeIn}
            colorClass="from-green-500 to-blue-600"
          >
            <div className="space-y-4">
              <motion.div 
                className="p-6 bg-white dark:bg-gray-800 rounded-lg shadow-md"
                initial={{ opacity: 0 }}
                whileInView={{ opacity: 1 }}
                viewport={{ once: true }}
                transition={{ duration: 0.5 }}
              >
                <h3 className="text-lg font-semibold mb-2 text-green-600 dark:text-green-400">Paket Layanan</h3>
                <p className="leading-relaxed">
                  Tasca mungkin menawarkan berbagai paket layanan, termasuk versi gratis dan berbayar dengan fitur tambahan. Detail paket, termasuk harga dan fitur, akan tercantum di situs web atau aplikasi kami.
                </p>
              </motion.div>

              <motion.div 
                className="p-6 bg-white dark:bg-gray-800 rounded-lg shadow-md"
                initial={{ opacity: 0 }}
                whileInView={{ opacity: 1 }}
                viewport={{ once: true }}
                transition={{ duration: 0.5, delay: 0.2 }}
              >
                <h3 className="text-lg font-semibold mb-2 text-green-600 dark:text-green-400">Pemrosesan Pembayaran</h3>
                <p className="leading-relaxed">
                  Pembayaran diproses melalui penyedia layanan pembayaran pihak ketiga. Kami tidak menyimpan atau memproses informasi kartu kredit Anda secara langsung. Penggunaan layanan pembayaran pihak ketiga tunduk pada syarat dan ketentuan mereka.
                </p>
              </motion.div>

              <motion.div 
                className="p-6 bg-white dark:bg-gray-800 rounded-lg shadow-md"
                initial={{ opacity: 0 }}
                whileInView={{ opacity: 1 }}
                viewport={{ once: true }}
                transition={{ duration: 0.5, delay: 0.4 }}
              >
                <h3 className="text-lg font-semibold mb-2 text-green-600 dark:text-green-400">Pembaruan Berlangganan</h3>
                <p className="leading-relaxed">
                  Berlangganan akan diperbarui secara otomatis untuk periode yang sama kecuali jika Anda membatalkan setidaknya 24 jam sebelum akhir periode saat ini. Anda dapat mengelola berlangganan dan membatalkan pembaruan otomatis melalui pengaturan akun Anda.
                </p>
              </motion.div>

              <motion.div 
                className="p-6 bg-white dark:bg-gray-800 rounded-lg shadow-md"
                initial={{ opacity: 0 }}
                whileInView={{ opacity: 1 }}
                viewport={{ once: true }}
                transition={{ duration: 0.5, delay: 0.6 }}
              >
                <h3 className="text-lg font-semibold mb-2 text-green-600 dark:text-green-400">Kebijakan Pengembalian Dana</h3>
                <p className="leading-relaxed">
                  Pengembalian dana dapat diberikan menurut kebijaksanaan kami. Harap hubungi layanan pelanggan untuk informasi lebih lanjut tentang kebijakan pengembalian dana kami.
                </p>
              </motion.div>
            </div>
          </Section>
          
          <Section 
            id="hakcipta"
            title="Hak Kekayaan Intelektual"
            variants={fadeIn}
            colorClass="from-green-500 to-blue-600"
          >
            <motion.div 
              className="p-6 bg-white dark:bg-gray-800 rounded-lg shadow-md"
              initial={{ opacity: 0 }}
              whileInView={{ opacity: 1 }}
              viewport={{ once: true }}
              transition={{ duration: 0.6 }}
            >
              <p className="leading-relaxed mb-4">
                Tasca dan kontennya, termasuk namun tidak terbatas pada teks, grafik, logo, ikon, gambar, klip audio, unduhan digital, kompilasi data, dan perangkat lunak, adalah milik Tim Tasca atau pemberi lisensinya dan dilindungi oleh hukum hak cipta dan kekayaan intelektual lainnya.
              </p>
              <p className="leading-relaxed">
                Anda tidak boleh mereproduksi, mendistribusikan, memodifikasi, membuat karya turunan, menampilkan secara publik, atau mengeksploitasi konten atau aplikasi Tasca tanpa izin tertulis dari kami, kecuali diizinkan secara tegas dalam Syarat ini.
              </p>
            </motion.div>
          </Section>
          
          <Section 
            id="batasan"
            title="Batasan Penggunaan"
            variants={fadeIn}
            colorClass="from-green-500 to-blue-600"
          >
            <p className="mb-4 leading-relaxed">
              Saat menggunakan Tasca, Anda setuju untuk tidak:
            </p>
            <ul className="space-y-3">
              {[
                "Melanggar hukum atau peraturan yang berlaku",
                "Mengirim atau menyimpan materi yang melanggar hukum, menyinggung, mengancam, memfitnah, atau melanggar",
                "Melakukan tindakan yang dapat merusak, menonaktifkan, membebani, atau mengganggu infrastruktur kami",
                "Menggunakan robot, spider, scraper, atau cara otomatis lain untuk mengakses layanan",
                "Menyalin, memodifikasi, mendistribusikan, menjual, atau menyewakan layanan atau bagiannya",
                "Melakukan rekayasa balik, mendekompilasi, atau membongkar perangkat lunak kami",
                "Mengupload virus, worm, atau kode berbahaya lainnya",
                "Mengganggu atau menginterupsi integritas atau kinerja layanan",
                "Mengumpulkan atau memanen informasi pengguna lain tanpa persetujuan mereka"
              ].map((item, index) => (
                <motion.li 
                  key={index}
                  className="p-4 bg-white dark:bg-gray-800 rounded-lg shadow-sm hover:shadow-md transition-shadow duration-300 flex items-start"
                  initial={{ opacity: 0, y: 10 }}
                  whileInView={{ opacity: 1, y: 0 }}
                  viewport={{ once: true }}
                  transition={{ duration: 0.4, delay: 0.1 * index }}
                >
                  <div className="flex-shrink-0 w-6 h-6 rounded-full bg-red-100 dark:bg-red-900 flex items-center justify-center mr-3 mt-0.5">
                    <svg className="w-4 h-4 text-red-600 dark:text-red-400" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M6 18L18 6M6 6l12 12"></path>
                    </svg>
                  </div>
                  <p>{item}</p>
                </motion.li>
              ))}
            </ul>
          </Section>
          
          <Section 
            id="penolakan"
            title="Penolakan Jaminan"
            variants={fadeIn}
            colorClass="from-green-500 to-blue-600"
          >
            <motion.div 
              className="p-6 bg-white dark:bg-gray-800 rounded-lg shadow-md border-l-4 border-yellow-500"
              initial={{ opacity: 0 }}
              whileInView={{ opacity: 1 }}
              viewport={{ once: true }}
              transition={{ duration: 0.6 }}
            >
              <p className="leading-relaxed mb-4">
                LAYANAN DISEDIAKAN "SEBAGAIMANA ADANYA" DAN "SEBAGAIMANA TERSEDIA" TANPA JAMINAN DALAM BENTUK APAPUN, BAIK TERSURAT MAUPUN TERSIRAT, TERMASUK NAMUN TIDAK TERBATAS PADA JAMINAN TERSIRAT TENTANG KELAYAKAN UNTUK DIPERDAGANGKAN, KESESUAIAN UNTUK TUJUAN TERTENTU, DAN NON-PELANGGARAN.
              </p>
              <p className="leading-relaxed">
                KAMI TIDAK MENJAMIN BAHWA LAYANAN AKAN MEMENUHI PERSYARATAN ANDA, ATAU BAHWA LAYANAN AKAN TIDAK TERGANGGU, TEPAT WAKTU, AMAN, ATAU BEBAS DARI KESALAHAN; JUGA TIDAK ADA JAMINAN MENGENAI HASIL YANG MUNGKIN DIPEROLEH DARI PENGGUNAAN LAYANAN ATAU KEAKURATAN ATAU KEANDALAN INFORMASI YANG DIPEROLEH MELALUI LAYANAN.
              </p>
            </motion.div>
          </Section>
          
          <Section 
            id="tanggung-jawab"
            title="Batasan Tanggung Jawab"
            variants={fadeIn}
            colorClass="from-green-500 to-blue-600"
          >
            <motion.div 
              className="p-6 bg-white dark:bg-gray-800 rounded-lg shadow-md border-l-4 border-yellow-500"
              initial={{ opacity: 0 }}
              whileInView={{ opacity: 1 }}
              viewport={{ once: true }}
              transition={{ duration: 0.6 }}
            >
              <p className="leading-relaxed">
                DALAM KEADAAN APAPUN, KAMI, DIREKTUR, KARYAWAN, AGEN, ATAU AFILIASI KAMI TIDAK BERTANGGUNG JAWAB ATAS KERUSAKAN LANGSUNG, TIDAK LANGSUNG, INSIDENTAL, KHUSUS, KONSEKUENSIAL, ATAU KERUSAKAN CONTOH YANG TIMBUL DARI PENGGUNAAN ANDA ATAU KETIDAKMAMPUAN UNTUK MENGGUNAKAN LAYANAN KAMI, TERMASUK NAMUN TIDAK TERBATAS PADA KEHILANGAN KEUNTUNGAN, DATA, PENGGUNAAN, NIAT BAIK, ATAU KERUGIAN TIDAK BERWUJUD LAINNYA, BAHKAN JIKA KAMI TELAH DIBERITAHU TENTANG KEMUNGKINAN KERUSAKAN TERSEBUT.
              </p>
            </motion.div>
          </Section>
          
          <Section 
            id="pembaruan"
            title="Pembaruan Syarat"
            variants={fadeIn}
            colorClass="from-green-500 to-blue-600"
          >
            <motion.div 
              className="p-6 bg-white dark:bg-gray-800 rounded-lg shadow-md"
              initial={{ opacity: 0 }}
              whileInView={{ opacity: 1 }}
              viewport={{ once: true }}
              transition={{ duration: 0.6 }}
            >
              <p className="leading-relaxed">
                Kami berhak, atas kebijakan kami sendiri, untuk mengubah atau mengganti Syarat ini kapan saja. Jika perubahan bersifat substansial, kami akan memberi tahu Anda melalui email atau dengan pemberitahuan melalui aplikasi setidaknya 30 hari sebelum perubahan baru berlaku. Penggunaan berkelanjutan atas layanan kami setelah perubahan tersebut menunjukkan penerimaan Anda terhadap syarat yang direvisi.
              </p>
            </motion.div>
          </Section>
          
          <Section 
            id="hukum"
            title="Hukum yang Berlaku"
            variants={fadeIn}
            colorClass="from-green-500 to-blue-600"
          >
            <motion.div 
              className="p-6 bg-white dark:bg-gray-800 rounded-lg shadow-md"
              initial={{ opacity: 0 }}
              whileInView={{ opacity: 1 }}
              viewport={{ once: true }}
              transition={{ duration: 0.6 }}
            >
              <p className="leading-relaxed">
                Syarat ini akan diatur dan ditafsirkan sesuai dengan hukum Indonesia, tanpa memperhatikan ketentuan konflik hukumnya. Setiap tindakan hukum atau proses yang timbul dari Syarat ini atau layanan kami akan diajukan secara eksklusif dalam yurisdiksi pengadilan Indonesia, dan Anda dengan ini menyetujui yurisdiksi dan tempat pengadilan tersebut.
              </p>
            </motion.div>
          </Section>
          
          <Section 
            id="kontak"
            title="Hubungi Kami"
            variants={fadeIn}
            colorClass="from-green-500 to-blue-600"
          >
            <motion.div 
              className="p-8 bg-gradient-to-r from-green-500 to-blue-600 rounded-lg shadow-lg text-white"
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.6 }}
              whileHover={{ scale: 1.02 }}
            >
              <div className="flex flex-col md:flex-row items-center justify-between">
                <div>
                  <h3 className="text-xl font-bold mb-2">Ada Pertanyaan?</h3>
                  <p className="leading-relaxed mb-4 md:mb-0">
                    Jika Anda memiliki pertanyaan atau kekhawatiran tentang Syarat dan Ketentuan ini, silakan hubungi kami.
                  </p>
                </div>
                <a 
                  href="mailto:tascakap@gmail.com" 
                  className="px-6 py-3 bg-white text-green-600 font-medium rounded-lg shadow-md hover:shadow-lg transition-shadow duration-300 flex items-center"
                >
                  <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"></path>
                  </svg>
                  tascakap@gmail.com
                </a>
              </div>
            </motion.div>
          </Section>
        </motion.div>
        
        {/* Footer Manual */}
        <motion.div 
          className="mt-16 text-center text-gray-500 dark:text-gray-400 py-6"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 1, duration: 1 }}
        >
          <p>© 2025 A4 Product Team - All Rights Reserved</p>
        </motion.div>
      </motion.div>
    </div>
  );
};

// Reusable Section Component
const Section = ({ id, title, children, variants, colorClass }) => {
  return (
    <motion.section 
      id={id}
      className="scroll-mt-16"
      variants={variants}
      whileInView="visible"
      initial="hidden"
      viewport={{ once: true, margin: "-100px" }}
    >
      <div className="mb-6">
        <div className="flex items-center">
          <div className="h-px bg-gradient-to-r from-transparent via-gray-300 dark:via-gray-700 to-transparent flex-grow"></div>
          <h2 className="text-2xl font-bold px-4 py-2 bg-gradient-to-r text-white rounded-lg" style={{backgroundImage: `linear-gradient(to right, var(--tw-gradient-stops))`, "--tw-gradient-from": "#10b981", "--tw-gradient-to": "#2563eb", "--tw-gradient-stops": "var(--tw-gradient-from), var(--tw-gradient-to)"}}>
            {title}
          </h2>
          <div className="h-px bg-gradient-to-r from-transparent via-gray-300 dark:via-gray-700 to-transparent flex-grow"></div>
        </div>
      </div>
      <div className="pl-4 border-l-4 border-green-500">
        {children}
      </div>
    </motion.section>
  );
};

export default Terms;
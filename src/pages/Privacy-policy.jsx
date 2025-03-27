import React, { useEffect } from 'react';
import { motion } from 'framer-motion';

const PrivacyPolicy = () => {
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
          <div className="absolute inset-0 bg-gradient-to-r from-blue-500 to-purple-600 animate-gradient-x"></div>
          <div className="relative z-10 px-8 py-12 backdrop-blur-sm bg-white/10">
            <motion.h1 
              className="text-4xl md:text-5xl font-bold mb-3 text-white text-center"
              initial={{ opacity: 0, scale: 0.9 }}
              animate={{ opacity: 1, scale: 1 }}
              transition={{ duration: 0.8, delay: 0.2 }}
            >
              Kebijakan Privasi Tasca
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
          <h2 className="text-xl font-semibold mb-4 text-blue-600 dark:text-blue-400">Daftar Isi</h2>
          <ul className="space-y-2">
            {[
              { id: "pengantar", text: "Pengantar" },
              { id: "informasi", text: "Informasi yang Kami Kumpulkan" },
              { id: "penggunaan", text: "Bagaimana Kami Menggunakan Informasi" },
              { id: "penyimpanan", text: "Penyimpanan dan Keamanan Data" },
              { id: "berbagi", text: "Berbagi Data" },
              { id: "kontrol", text: "Pilihan dan Kontrol Anda" },
              { id: "cookie", text: "Penggunaan Cookie" },
              { id: "anak", text: "Privasi Anak-Anak" },
              { id: "perubahan", text: "Perubahan pada Kebijakan" },
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
                  className="text-blue-500 hover:text-blue-700 dark:text-blue-400 dark:hover:text-blue-300 transition-colors duration-200 flex items-center group"
                >
                  <span className="w-6 h-6 flex items-center justify-center rounded-full bg-blue-100 dark:bg-blue-900 text-blue-600 dark:text-blue-400 mr-2 group-hover:bg-blue-200 dark:group-hover:bg-blue-800 transition-colors duration-200">
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
          >
            <p className="leading-relaxed">
              Selamat datang di Tasca, aplikasi manajemen tugas dan proyek dengan metode Pomodoro. 
              Kami menghargai kepercayaan Anda dan berkomitmen untuk melindungi privasi dan keamanan 
              data pribadi Anda. Kebijakan Privasi ini menjelaskan bagaimana kami mengumpulkan, 
              menggunakan, menyimpan, dan melindungi informasi Anda saat Anda menggunakan aplikasi Tasca.
            </p>
          </Section>
          
          <Section 
            id="informasi"
            title="Informasi yang Kami Kumpulkan"
            variants={fadeIn}
          >
            <p className="mb-4 leading-relaxed">Kami dapat mengumpulkan jenis informasi berikut:</p>
            <ul className="space-y-3">
              {[
                {
                  title: "Informasi Akun",
                  content: "Nama, alamat email, dan kata sandi yang dienkripsi saat Anda membuat akun."
                },
                {
                  title: "Data Penggunaan",
                  content: "Informasi tentang tugas dan proyek yang Anda buat, sesi Pomodoro, dan statistik penggunaan."
                },
                {
                  title: "Informasi Perangkat",
                  content: "Jenis perangkat, sistem operasi, pengidentifikasi unik perangkat, dan informasi jaringan."
                },
                {
                  title: "Data Log",
                  content: "Informasi yang dikirim oleh perangkat Anda saat menggunakan aplikasi, termasuk waktu akses dan aktivitas dalam aplikasi."
                }
              ].map((item, index) => (
                <motion.li 
                  key={index}
                  className="p-4 bg-white dark:bg-gray-800 rounded-lg shadow-sm hover:shadow-md transition-shadow duration-300"
                  initial={{ opacity: 0, y: 10 }}
                  whileInView={{ opacity: 1, y: 0 }}
                  viewport={{ once: true }}
                  transition={{ duration: 0.4, delay: 0.1 * index }}
                >
                  <h3 className="font-semibold text-blue-600 dark:text-blue-400 mb-1">{item.title}</h3>
                  <p>{item.content}</p>
                </motion.li>
              ))}
            </ul>
          </Section>
          
          <Section 
            id="penggunaan"
            title="Bagaimana Kami Menggunakan Informasi Anda"
            variants={fadeIn}
          >
            <p className="mb-4 leading-relaxed">Kami menggunakan informasi yang dikumpulkan untuk:</p>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {[
                "Menyediakan, memelihara, dan meningkatkan Tasca",
                "Menyinkronkan data tugas dan proyek Anda di berbagai perangkat",
                "Membuat statistik dan wawasan tentang produktivitas Anda",
                "Mengirim pembaruan aplikasi dan pemberitahuan",
                "Mengidentifikasi dan mengatasi masalah teknis",
                "Melindungi keamanan dan integritas aplikasi kami"
              ].map((item, index) => (
                <motion.div 
                  key={index}
                  className="p-4 bg-white dark:bg-gray-800 rounded-lg shadow-sm flex items-center"
                  initial={{ opacity: 0, scale: 0.95 }}
                  whileInView={{ opacity: 1, scale: 1 }}
                  viewport={{ once: true }}
                  transition={{ duration: 0.4, delay: 0.1 * index }}
                >
                  <div className="flex-shrink-0 w-10 h-10 rounded-full bg-blue-100 dark:bg-blue-900 flex items-center justify-center mr-3">
                    <svg className="w-5 h-5 text-blue-600 dark:text-blue-400" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M5 13l4 4L19 7"></path>
                    </svg>
                  </div>
                  <p>{item}</p>
                </motion.div>
              ))}
            </div>
          </Section>
          
          <Section 
            id="penyimpanan"
            title="Penyimpanan dan Keamanan Data"
            variants={fadeIn}
          >
            <div className="flex flex-col md:flex-row gap-6">
              <motion.div 
                className="flex-1 p-6 bg-white dark:bg-gray-800 rounded-lg shadow-md"
                initial={{ opacity: 0, x: -20 }}
                whileInView={{ opacity: 1, x: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.5 }}
              >
                <div className="rounded-full w-12 h-12 bg-green-100 dark:bg-green-900 flex items-center justify-center mb-4">
                  <svg className="w-6 h-6 text-green-600 dark:text-green-400" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"></path>
                  </svg>
                </div>
                <h3 className="text-lg font-semibold mb-2">Keamanan</h3>
                <p className="leading-relaxed">
                  Kami menyimpan data Anda di server aman dengan tindakan keamanan teknis dan 
                  organisasi yang sesuai untuk melindungi informasi pribadi Anda dari akses, 
                  penggunaan, atau pengungkapan yang tidak sah. Data Anda dienkripsi selama transmisi 
                  dan penyimpanan.
                </p>
              </motion.div>
              
              <motion.div 
                className="flex-1 p-6 bg-white dark:bg-gray-800 rounded-lg shadow-md"
                initial={{ opacity: 0, x: 20 }}
                whileInView={{ opacity: 1, x: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.5, delay: 0.2 }}
              >
                <div className="rounded-full w-12 h-12 bg-purple-100 dark:bg-purple-900 flex items-center justify-center mb-4">
                  <svg className="w-6 h-6 text-purple-600 dark:text-purple-400" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                  </svg>
                </div>
                <h3 className="text-lg font-semibold mb-2">Retensi Data</h3>
                <p className="leading-relaxed">
                  Kami menyimpan data Anda selama akun Anda aktif atau seperlunya untuk menyediakan 
                  layanan kami. Jika Anda menghapus akun, kami akan menghapus data Anda dari server 
                  kami dalam waktu 30 hari, kecuali jika diwajibkan oleh hukum untuk menyimpannya.
                </p>
              </motion.div>
            </div>
          </Section>
          
          <Section 
            id="berbagi"
            title="Berbagi Data"
            variants={fadeIn}
          >
            <p className="mb-4 leading-relaxed">
              Kami tidak menjual informasi pribadi Anda kepada pihak ketiga. Kami dapat berbagi 
              informasi dalam keadaan berikut:
            </p>
            <div className="space-y-4">
              {[
                {
                  title: "Penyedia Layanan",
                  content: "Kami bekerja dengan perusahaan pihak ketiga yang terpercaya untuk membantu kami menyediakan, memelihara, dan meningkatkan layanan kami.",
                  icon: (
                    <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M21 13.255A23.931 23.931 0 0112 15c-3.183 0-6.22-.62-9-1.745M16 6V4a2 2 0 00-2-2h-4a2 2 0 00-2 2v2m4 6h.01M5 20h14a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"></path>
                    </svg>
                  )
                },
                {
                  title: "Kepatuhan Hukum",
                  content: "Jika diperlukan oleh hukum atau dalam menanggapi permintaan yang sah dari otoritas publik.",
                  icon: (
                    <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M3 6l3 1m0 0l-3 9a5.002 5.002 0 006.001 0M6 7l3 9M6 7l6-2m6 2l3-1m-3 1l-3 9a5.002 5.002 0 006.001 0M18 7l3 9m-3-9l-6-2m0-2v2m0 16V5m0 16H9m3 0h3"></path>
                    </svg>
                  )
                },
                {
                  title: "Perlindungan Hak",
                  content: "Untuk melindungi hak, properti, atau keselamatan kami, pengguna kami, atau orang lain.",
                  icon: (
                    <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"></path>
                    </svg>
                  )
                }
              ].map((item, index) => (
                <motion.div 
                  key={index}
                  className="p-4 border border-gray-200 dark:border-gray-700 rounded-lg flex items-start"
                  initial={{ opacity: 0, y: 20 }}
                  whileInView={{ opacity: 1, y: 0 }}
                  viewport={{ once: true }}
                  transition={{ duration: 0.4, delay: 0.1 * index }}
                  whileHover={{ 
                    scale: 1.02, 
                    boxShadow: "0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05)" 
                  }}
                >
                  <div className="mr-4 p-2 bg-blue-100 dark:bg-blue-900 rounded-md text-blue-600 dark:text-blue-400">
                    {item.icon}
                  </div>
                  <div>
                    <h3 className="font-medium text-lg mb-1">{item.title}</h3>
                    <p className="text-gray-600 dark:text-gray-400">{item.content}</p>
                  </div>
                </motion.div>
              ))}
            </div>
          </Section>
          
          <Section 
            id="kontrol"
            title="Pilihan dan Kontrol Anda"
            variants={fadeIn}
          >
            <p className="mb-4 leading-relaxed">Anda memiliki beberapa hak terkait data pribadi Anda:</p>
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
              {[
                {
                  title: "Akses Data",
                  content: "Mengakses dan memperbarui informasi akun Anda melalui pengaturan aplikasi"
                },
                {
                  title: "Minta Salinan",
                  content: "Meminta salinan data yang kami simpan tentang Anda"
                },
                {
                  title: "Hapus Data",
                  content: "Meminta penghapusan data Anda (dengan menghapus akun Anda)"
                },
                {
                  title: "Notifikasi",
                  content: "Mengelola preferensi notifikasi Anda"
                },
                {
                  title: "Analitik",
                  content: "Memilih keluar dari pengumpulan data analitik tertentu"
                }
              ].map((item, index) => (
                <motion.div 
                  key={index}
                  className="p-5 bg-white dark:bg-gray-800 rounded-lg shadow-sm hover:shadow-md transition-shadow duration-300 text-center"
                  initial={{ opacity: 0, scale: 0.9 }}
                  whileInView={{ opacity: 1, scale: 1 }}
                  viewport={{ once: true }}
                  transition={{ duration: 0.4, delay: 0.1 * index }}
                >
                  <h3 className="text-lg font-medium mb-2 text-blue-600 dark:text-blue-400">{item.title}</h3>
                  <p className="text-gray-600 dark:text-gray-400">{item.content}</p>
                </motion.div>
              ))}
            </div>
          </Section>
          
          <Section 
            id="cookie"
            title="Penggunaan Cookie dan Teknologi Serupa"
            variants={fadeIn}
          >
            <motion.div 
              className="p-6 bg-white dark:bg-gray-800 rounded-lg shadow-md"
              initial={{ opacity: 0 }}
              whileInView={{ opacity: 1 }}
              viewport={{ once: true }}
              transition={{ duration: 0.6 }}
            >
              <p className="leading-relaxed">
                Tasca dapat menggunakan cookie dan teknologi pelacakan serupa untuk meningkatkan 
                pengalaman Anda dan mengumpulkan informasi tentang bagaimana Anda berinteraksi 
                dengan aplikasi kami. Anda dapat mengatur perangkat Anda untuk menolak cookie, 
                tetapi ini mungkin memengaruhi fungsionalitas aplikasi.
              </p>
            </motion.div>
          </Section>
          
          <Section 
            id="anak"
            title="Privasi Anak-Anak"
            variants={fadeIn}
          >
            <motion.div 
              className="p-6 bg-white dark:bg-gray-800 rounded-lg shadow-md"
              initial={{ opacity: 0 }}
              whileInView={{ opacity: 1 }}
              viewport={{ once: true }}
              transition={{ duration: 0.6 }}
            >
              <p className="leading-relaxed">
                Tasca tidak ditujukan untuk anak-anak di bawah 13 tahun, dan kami tidak secara 
                sadar mengumpulkan informasi dari anak-anak di bawah 13 tahun. Jika Anda adalah 
                orang tua atau wali dan percaya bahwa anak Anda telah memberikan informasi pribadi, 
                silakan hubungi kami agar kami dapat mengambil tindakan yang sesuai.
              </p>
            </motion.div>
          </Section>
          
          <Section 
            id="perubahan"
            title="Perubahan pada Kebijakan Privasi Ini"
            variants={fadeIn}
          >
            <motion.div 
              className="p-6 bg-white dark:bg-gray-800 rounded-lg shadow-md"
              initial={{ opacity: 0 }}
              whileInView={{ opacity: 1 }}
              viewport={{ once: true }}
              transition={{ duration: 0.6 }}
            >
              <p className="leading-relaxed">
                Kami dapat memperbarui Kebijakan Privasi ini dari waktu ke waktu. Jika kami membuat 
                perubahan yang signifikan, kami akan memberi tahu Anda melalui aplikasi atau melalui 
                email. Kami mendorong Anda untuk meninjau Kebijakan Privasi ini secara berkala 
                untuk tetap mendapatkan informasi terbaru tentang praktik privasi kami.
              </p>
            </motion.div>
          </Section>
          
          <Section 
            id="kontak"
            title="Hubungi Kami"
            variants={fadeIn}
          >
            <motion.div 
              className="p-8 bg-gradient-to-r from-blue-500 to-purple-600 rounded-lg shadow-lg text-white"
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
                    Jika Anda memiliki pertanyaan atau kekhawatiran tentang Kebijakan Privasi ini atau 
                    praktik data kami, silakan hubungi kami.
                  </p>
                </div>
                <a 
                  href="mailto:tascakap@gmail.com" 
                  className="px-6 py-3 bg-white text-blue-600 font-medium rounded-lg shadow-md hover:shadow-lg transition-shadow duration-300 flex items-center"
                >
                  <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"></path>
                  </svg>
                  tascakap@gmail.com.
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
            transition={{ delay: 1, duration: 1 }}>
              <p>© 2025 A4 Product Team - All Rights Reserved</p>
            </motion.div>
          </motion.div>
        </div>
      );
    };

// Reusable Section Component
const Section = ({ id, title, children, variants }) => {
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
          <h2 className="text-2xl font-bold px-4 py-2 bg-blue-100 dark:bg-blue-900 text-blue-800 dark:text-blue-200 rounded-lg">
            {title}
          </h2>
          <div className="h-px bg-gradient-to-r from-transparent via-gray-300 dark:via-gray-700 to-transparent flex-grow"></div>
        </div>
      </div>
      <div className="pl-4 border-l-4 border-blue-500">
        {children}
      </div>
    </motion.section>
  );
};

export default PrivacyPolicy;
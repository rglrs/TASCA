import React, { useRef } from "react";
import { motion, useInView } from "framer-motion";
import { Clock, Check, Zap, BarChart } from "lucide-react";
import heroImage from "../assets/image/1.svg";
import mockupImage from "../assets/image/mockup.svg";

const LandingPage = () => {
  // Ref untuk memantau elemen di viewport
  const heroRef = useRef(null);
  const pomodoroRef = useRef(null);

  // Animasi diputar setiap kali elemen masuk viewport
  const isHeroInView = useInView(heroRef, { triggerOnce: false, threshold: 0.2 });
  const isPomodoroInView = useInView(pomodoroRef, { triggerOnce: false, threshold: 0.2 });

  return (
    <div className="min-h-screen bg-gray-100 flex flex-col items-center text-center p-6">
      {/* Hero Section */}
      <motion.section
        ref={heroRef}
        initial={{ opacity: 0, y: -50 }}
        animate={isHeroInView ? { opacity: 1, y: 0 } : { opacity: 0, y: -50 }}
        transition={{ duration: 0.5 }}
        className="mt-8 max-w-6xl flex flex-col md:flex-row items-center text-center md:text-left"
      >
        <div className="md:w-1/2 order-2 md:order-1">
          <h2 className="text-4xl font-bold text-blue-600 leading-tight">
            Tingkatkan Produktivitasmu dengan TASCA
          </h2>
          <p className="text-lg text-gray-600 mt-4">
            Manajemen tugas dan proyek lebih efektif dengan metode Pomodoro. Tasca hadir sebagai solusi untuk meningkatkan fokus belajar dan manajemen tugas kamu agar lebih terstruktur.
          </p>
          <motion.button 
            whileHover={{ scale: 1.1 }}
            whileTap={{ scale: 0.9 }}
            className="mt-6 bg-blue-600 text-white px-6 py-3 rounded-xl shadow-md text-lg hover:bg-blue-700 transition"
          >
            Coba Sekarang
          </motion.button>
        </div>
        <motion.div 
          initial={{ opacity: 0, x: 50 }}
          animate={isHeroInView ? { opacity: 1, x: 0 } : { opacity: 0, x: 50 }}
          transition={{ duration: 0.5 }}
          whileHover={{ scale: 1.1 }}
          className="md:w-1/2 order-1 md:order-2 flex justify-end"
        >
          <img src={heroImage} alt="Hero TASCA" className="w-full max-w-md rounded-xl" />
        </motion.div>
      </motion.section>

      {/* Penjelasan Pomodoro */}
      <div ref={pomodoroRef} className="mt-16 max-w-6xl w-full flex flex-col md:flex-row items-center md:items-start text-center md:text-left">
        <motion.div 
          initial={{ opacity: 0, x: -50 }}
          animate={isPomodoroInView ? { opacity: 1, x: 0 } : { opacity: 0, x: -50 }}
          transition={{ duration: 0.5 }}
          whileHover={{ scale: 1.1 }}
          className="md:w-1/2 flex justify-center"
        >
          <img src={mockupImage} alt="Mockup TASCA" className="w-full max-w-md rounded-xl" />
        </motion.div>
        <motion.div 
          initial={{ opacity: 0, y: 50 }}
          animate={isPomodoroInView ? { opacity: 1, y: 0 } : { opacity: 0, y: 50 }}
          transition={{ duration: 0.5 }}
          className="md:w-1/2 md:pl-16 mt-6 md:mt-0"
        >
          <h3 className="text-2xl font-semibold text-gray-700">
            Mengapa Pomodoro?
          </h3>
          <p className="text-gray-600 mt-2">
            Metode Pomodoro membantu meningkatkan fokus dan produktivitas dengan bekerja dalam interval 25 menit, diikuti dengan istirahat singkat. Ini efektif untuk menghindari kelelahan dan mempertahankan konsentrasi lebih lama.
          </p>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mt-4">
            {[
              { icon: <Clock className="h-8 w-8 p-1.5 bg-red-100 text-red-600 rounded-lg" />, title: "Manajemen Waktu", description: "Bekerja dalam sesi fokus dengan istirahat terjadwal.", bgHover: "bg-red-200" },
              { icon: <Check className="h-8 w-8 p-1.5 bg-green-100 text-green-600 rounded-lg" />, title: "Integrasi Tugas", description: "Hubungkan Pomodoro dengan manajemen tugasmu.", bgHover: "bg-green-200" },
              { icon: <Zap className="h-8 w-8 p-1.5 bg-yellow-100 text-yellow-600 rounded-lg" />, title: "Mode Fokus", description: "Hilangkan gangguan dan tingkatkan produktivitas.", bgHover: "bg-yellow-200" },
              { icon: <BarChart className="h-8 w-8 p-1.5 bg-blue-100 text-blue-600 rounded-lg" />, title: "Analisis Produktivitas", description: "Lacak sesi fokus dan optimalkan kebiasaan kerjamu.", bgHover: "bg-blue-200" }
            ].map((item, i) => (
              <motion.div 
                key={i} 
                initial={{ opacity: 0, scale: 0.8 }}
                animate={isPomodoroInView ? { opacity: 1, scale: 1 } : { opacity: 0, scale: 0.8 }}
                transition={{ duration: 0.4, delay: i * 0.1 }}
                whileHover={{ scale: 1.1, backgroundColor: item.bgHover }}
                className="flex gap-4 p-4 rounded-lg transition-colors"
              >
                <div className="flex-shrink-0 mt-1">{item.icon}</div>
                <div>
                  <h3 className="font-semibold mb-1">{item.title}</h3>
                  <p className="text-sm text-gray-600">{item.description}</p>
                </div>
              </motion.div>
            ))}
          </div>
        </motion.div>
      </div>
    </div>
  );
};

export default LandingPage;

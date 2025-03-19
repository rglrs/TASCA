import React, { useRef } from "react";
import { motion, useInView } from "framer-motion";
import { Clock, Check, Zap, BarChart } from "lucide-react";
import mockupImage from "../assets/image/mockup.svg";

const PomodoroSection = () => {
  const mockupRef = useRef(null);
  const featuresRef = useRef(null);
  const isMockupInView = useInView(mockupRef, { triggerOnce: true });
  const isFeaturesInView = useInView(featuresRef, { triggerOnce: true });

  return (
    <div className="mt-16 max-w-6xl w-full flex flex-col md:flex-row items-center md:items-start text-center md:text-left gap-12">
      {/* Mockup Image */}
      <motion.div
        ref={mockupRef}
        initial={{ opacity: 0, x: -50 }}
        animate={isMockupInView ? { opacity: 1, x: 0 } : {}}
        transition={{ duration: 0.5 }}
        whileHover={{ scale: 1.05 }}
        className="w-full md:w-1/2 flex justify-start"
      >
        <img
          src={mockupImage}
          alt="Mockup TASCA"
          className="w-full max-w-[500px] md:max-w-[600px] lg:max-w-[700px] xl:max-w-[800px] rounded-xl"
        />
      </motion.div>

      {/* Teks Penjelasan */}
      <motion.div
        ref={featuresRef}
        initial={{ opacity: 0, y: 50 }}
        animate={isFeaturesInView ? { opacity: 1, y: 0 } : {}}
        transition={{ duration: 0.5 }}
        className="w-full md:w-1/2 flex flex-col items-center md:items-start"
      >
        <motion.h3
          initial={{ opacity: 0, y: 20 }}
          animate={isFeaturesInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.5 }}
          className="text-2xl font-semibold text-gray-700"
        >
          Mengapa Pomodoro?
        </motion.h3>
        <motion.p
          initial={{ opacity: 0, y: 20 }}
          animate={isFeaturesInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6 }}
          className="text-gray-600 mt-2 max-w-lg"
        >
          Metode Pomodoro membantu meningkatkan fokus dan produktivitas dengan bekerja dalam interval 25 menit, diikuti dengan istirahat singkat. Ini efektif untuk menghindari kelelahan dan mempertahankan konsentrasi lebih lama.
        </motion.p>

        {/* Fitur Pomodoro */}
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 mt-4 w-full">
          {[
            {
              icon: <Clock className="h-8 w-8 p-1.5 bg-red-100 text-red-600 rounded-lg " />,
              title: "Manajemen Waktu",
              description: "Bekerja dalam sesi fokus dengan istirahat terjadwal.",
              bgHover: "bg-red-200"
            },
            {
              icon: <Check className="h-8 w-8 p-1.5 bg-green-100 text-green-600 rounded-lg" />,
              title: "Integrasi Tugas",
              description: "Hubungkan Pomodoro dengan manajemen tugasmu.",
              bgHover: "bg-green-200"
            },
            {
              icon: <Zap className="h-8 w-8 p-1.5 bg-yellow-100 text-yellow-600 rounded-lg" />,
              title: "Mode Fokus",
              description: "Hilangkan gangguan dan tingkatkan produktivitas.",
              bgHover: "bg-yellow-200"
            },
            {
              icon: <BarChart className="h-8 w-8 p-1.5 bg-blue-100 text-blue-600 rounded-lg" />,
              title: "Analisis Produktivitas",
              description: "Lacak sesi fokus dan optimalkan kebiasaan kerjamu.",
              bgHover: "bg-blue-200"
            }
          ].map((item, i) => (
            <motion.div
              key={i}
              initial={{ opacity: 0, scale: 0.8 }}
              animate={isFeaturesInView ? { opacity: 1, scale: 1 } : {}}
              transition={{ duration: 0.4, delay: i * 0.1 }}
              whileHover={{ scale: 1.05, backgroundColor: item.bgHover }}
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
  );
};

export default PomodoroSection;

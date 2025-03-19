import React, { useRef } from "react";
import { motion, useInView } from "framer-motion";
import { Clock, Check, Zap, BarChart } from "lucide-react";
import heroImage from "../assets/image/pict_home.svg";
import mockupImage from "../assets/image/mockup.svg";
import gpImage from "../assets/image/gp.png";
import bgImage from "../assets/image/bgweb3.svg";

const LandingPage = () => {
  const heroRef = useRef(null);
  const mockupRef = useRef(null);
  const featuresRef = useRef(null);

  const isHeroInView = useInView(heroRef, { triggerOnce: true });
  const isMockupInView = useInView(mockupRef, { triggerOnce: true });
  const isFeaturesInView = useInView(featuresRef, { triggerOnce: true });

  return (
    <div
      className="min-h-screen flex flex-col items-center text-center scroll-smooth pt-40 w-full"
      style={{
        backgroundImage: `url(${bgImage})`,
        backgroundSize: "cover",
        backgroundPosition: "center",
      }}
    >
      {/* Hero Section */}
      <motion.section
        ref={heroRef}
        initial={{ opacity: 0, y: -50 }}
        animate={isHeroInView ? { opacity: 1, y: 0 } : {}}
        transition={{ duration: 0.5 }}
        className="mt-2 max-w-6xl flex flex-col md:flex-row items-center text-center md:text-left"
      >
        <div className="md:w-1/2 order-2 md:order-1">
          <motion.h2
            initial={{ opacity: 0, y: 20 }}
            animate={isHeroInView ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 0.5 }}
            className="text-4xl font-bold leading-tight"
          >
            <span style={{ color: "#007BFF" }}>Master</span> Your{" "}
            <span style={{ color: "#007BFF" }}>Time</span>
            <br />
            <span style={{ color: "#FD7E14" }}>Maximize</span> Your{" "}
            <span style={{ color: "#FD7E14" }}>Potential</span>
          </motion.h2>

          <motion.p
            initial={{ opacity: 0, y: 20 }}
            animate={isHeroInView ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 0.6 }}
            className="text-lg text-gray-600 mt-4"
          >
            Helping you to be productive and healthy in your learning, through a
            structured and technology-based approach.
          </motion.p>
          <motion.img
            src={gpImage}
            alt="Google Play"
            initial={{ opacity: 0, y: 20 }}
            animate={isHeroInView ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 0.5 }}
            className="mt-6 w-48 cursor-pointer shadow-md rounded-xl mx-auto md:mx-0"
          />
        </div>
        <motion.div
          initial={{ opacity: 0, x: 50 }}
          animate={isHeroInView ? { opacity: 1, x: 0 } : {}}
          transition={{ duration: 0.5 }}
          whileHover={{ scale: 1.1 }}
          className="md:w-1/2 order-1 md:order-2 flex justify-center md:justify-end"
        >
          <img
            src={heroImage}
            alt="Hero TASCA"
            className="w-2/3 sm:w-3/4 md:w-3/4 max-w-sm rounded-xl"
          />
        </motion.div>
      </motion.section>

      {/* Penjelasan Pomodoro */}
      <div className="mt-24 md:mt-32 max-w-6xl w-full flex flex-col md:flex-row items-center md:items-start text-center md:text-left py-10">
        <motion.div
          ref={mockupRef}
          initial={{ opacity: 0, x: -50 }}
          animate={isMockupInView ? { opacity: 1, x: 0 } : {}}
          transition={{ duration: 0.5 }}
          whileHover={{ scale: 1.1 }}
          className="md:w-1/2 flex justify-center mt-4"
        >
          <img
            src={mockupImage}
            alt="Mockup TASCA"
            className="w-auto max-w-xl sm:max-w-2xl md:max-w-3xl h-auto rounded-xl mx-auto"
          />
        </motion.div>

        <motion.div
          ref={featuresRef}
          initial={{ opacity: 0, y: 50 }}
          animate={isFeaturesInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.5 }}
          className="md:w-1/2 md:pl-16 mt-12 md:mt-24 mx-auto text-center md:text-left"
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
            className="text-gray-600 mt-2"
          >
            Metode Pomodoro membantu meningkatkan fokus dan produktivitas dengan
            bekerja dalam interval 25 menit, diikuti dengan istirahat singkat.
            Ini efektif untuk menghindari kelelahan dan mempertahankan
            konsentrasi lebih lama.
          </motion.p>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mt-6 items-center">
            {[
              {
                icon: (
                  <Clock className="h-8 w-8 p-1.5 bg-red-100 text-red-600 rounded-lg" />
                ),
                title: "Manajemen Waktu",
                description:
                  "Bekerja dalam sesi fokus dengan istirahat terjadwal.",
                bgHover: "bg-red-200",
              },
              {
                icon: (
                  <Check className="h-8 w-8 p-1.5 bg-green-100 text-green-600 rounded-lg" />
                ),
                title: "Integrasi Tugas",
                description: "Hubungkan Pomodoro dengan manajemen tugasmu.",
                bgHover: "bg-green-200",
              },
              {
                icon: (
                  <Zap className="h-8 w-8 p-1.5 bg-yellow-100 text-yellow-600 rounded-lg" />
                ),
                title: "Mode Fokus",
                description: "Hilangkan gangguan dan tingkatkan produktivitas.",
                bgHover: "bg-yellow-200",
              },
              {
                icon: (
                  <BarChart className="h-8 w-8 p-1.5 bg-blue-100 text-blue-600 rounded-lg" />
                ),
                title: "Analisis Produktivitas",
                description:
                  "Lacak sesi fokus dan optimalkan kebiasaan kerjamu.",
                bgHover: "bg-blue-200",
              },
            ].map((item, i) => (
              <motion.div
                key={i}
                initial={{ opacity: 0, scale: 0.8 }}
                animate={isFeaturesInView ? { opacity: 1, scale: 1 } : {}}
                transition={{ duration: 0.4, delay: i * 0.1 }}
                whileHover={{ scale: 1.1, backgroundColor: item.bgHover }}
                className="flex gap-4 p-4 rounded-lg transition-colors justify-center md:justify-start"
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
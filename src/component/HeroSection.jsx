import React, { useRef } from "react";
import { motion, useInView } from "framer-motion";
import { useNavigate } from "react-router-dom";
import heroImage from "https://res.cloudinary.com/dqrazyfpm/image/upload/v1744365450/1_fk65lm.svg";

const HeroSection = () => {
  const heroRef = useRef(null);
  const isHeroInView = useInView(heroRef, { triggerOnce: true });
  const navigate = useNavigate();

  return (
    <motion.section
      ref={heroRef}
      initial={{ opacity: 0, y: -50 }}
      animate={isHeroInView ? { opacity: 1, y: 0 } : {}}
      transition={{ duration: 0.5 }}
      className="mt-8 max-w-6xl flex flex-col md:flex-row items-center text-center md:text-left"
    >
      <div className="md:w-1/2 order-2 md:order-1">
        <motion.h2
          initial={{ opacity: 0, y: 20 }}
          animate={isHeroInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.5 }}
          className="text-4xl font-bold text-blue-600 leading-tight"
        >
          Tingkatkan Produktivitasmu dengan TASCA
        </motion.h2>
        <motion.p
          initial={{ opacity: 0, y: 20 }}
          animate={isHeroInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6 }}
          className="text-lg text-gray-600 mt-4"
        >
          Manajemen tugas dan proyek lebih efektif dengan metode Pomodoro. Tasca hadir sebagai solusi untuk meningkatkan fokus belajar dan manajemen tugas kamu agar lebih terstruktur.
        </motion.p>
        <motion.button
          whileHover={{ scale: 1.05 }}
          whileTap={{ scale: 0.97 }}
          transition={{ duration: 0.3, ease: "easeInOut" }}
          onClick={() => navigate("/pomodoro")}
          className="mt-6 bg-blue-600 text-white px-6 py-3 rounded-xl shadow-md text-lg"
        >
          Coba Sekarang
        </motion.button>
      </div>
      <motion.div
        initial={{ opacity: 0, x: 50 }}
        animate={isHeroInView ? { opacity: 1, x: 0 } : {}}
        transition={{ duration: 0.5 }}
        whileHover={{ scale: 1.1 }}
        className="md:w-1/2 order-1 md:order-2 flex justify-end"
      >
        <img src={heroImage} alt="Hero TASCA" className="w-full max-w-md rounded-xl" />
      </motion.div>
    </motion.section>
  );
};

export default HeroSection;

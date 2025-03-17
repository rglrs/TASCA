import React from "react";
import clockIcon from "../assets/image/clock.svg";
import musicIcon from "../assets/image/music.svg";
import notesIcon from "../assets/image/notes.svg";
import calendarIcon from "../assets/image/calendar.svg";
import mockupImage from "../assets/image/tes.svg";
import { motion } from "framer-motion";

const features = [
  {
    icon: clockIcon,
    title: "Pomodoro",
    description: "Atur waktu belajarmu lebih efisien dengan teknik Pomodoro.",
  },
  {
    icon: musicIcon,
    title: "Music Relaxation",
    description: "Tingkatkan konsentrasi dengan musik yang menenangkan.",
  },
  {
    icon: notesIcon,
    title: "Todolist",
    description: "Kelola tugas-tugasmu jadi lebih terstruktur dan terorganisir.",
  },
  {
    icon: calendarIcon,
    title: "Calendar",
    description: "Tidak perlu khawatir terlewat deadline tugas.",
  },
];

const Features = () => {
  return (
    <section className="flex flex-col md:flex-row items-center justify-between px-6 md:px-16 lg:px-32 py-16 bg-[#F7F1FE] font-poppins">
      {/* Kiri - Fitur Cards */}
      <div className="w-full md:w-1/2 space-y-6">
        {features.map((feature, index) => (
          <motion.div
            key={index}
            className="flex items-center bg-white p-4 rounded-xl shadow-md transition-all duration-500 hover:bg-[#e0e7ff] w-full"
            whileHover={{ scale: 1.05 }}
          >
            <img src={feature.icon} alt="icon" className="w-10 h-10 mr-4" />
            <div>
              <h3 className="font-semibold text-base md:text-lg">{feature.title}</h3>
              <p className="text-sm text-gray-600">{feature.description}</p>
            </div>
          </motion.div>
        ))}
      </div>

      {/* Kanan - Mockup Image Diperbesar */}
      <div className="w-full md:w-[60%] lg:w-[27%] flex justify-center mt-12 md:mt-0 mr-5">
        <img
          src={mockupImage}
          alt="Mockup"
          className="w-full max-w-[500px] md:max-w-[600px] lg:max-w-[700px] h-auto"
        />
      </div>
    </section>
  );
};

export default Features;

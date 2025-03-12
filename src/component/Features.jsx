import React from "react";
import clockIcon from "../assets/image/clock.svg";
import musicIcon from "../assets/image/music.svg";
import notesIcon from "../assets/image/notes.svg";
import calendarIcon from "../assets/image/calendar.svg";
import { motion } from "framer-motion";

const features = [
  {
    icon: clockIcon,
    title: "Pomodoro",
    description: "Mengelola waktu belajar dengan teknik Pomodoro untuk meningkatkan produktivitas dan fokus.",
  },
  {
    icon: musicIcon,
    title: "Music Relaxation",
    description: "Dengarkan musik yang menenangkan untuk meningkatkan konsentrasi dan relaksasi selama belajar.",
  },
  {
    icon: notesIcon,
    title: "Todolist",
    description: "Buat daftar tugas dan tetap terorganisir untuk mencapai target harian dengan lebih mudah.",
  },
  {
    icon: calendarIcon,
    title: "Calendar",
    description: "Lihat jadwal dan deadline tugasmu secara praktis agar tidak ada yang terlewat.",
  },
];

const Features = () => {
  return (
    <section className="flex flex-col items-center px-6 md:px-12 lg:px-36 py-16 bg-[#F7F1FE] font-poppins">
      <h2 className="text-2xl md:text-3xl font-semibold mb-14">Features</h2>

      <div className="grid grid-cols-2 md:grid-cols-4 gap-6">
        {features.map((feature, index) => (
          <motion.div
            key={index}
            className="flex flex-col items-start bg-white p-4 rounded-xl shadow-md transition-all duration-500 hover:bg-[#e0e7ff]"
            whileHover={{ scale: 1.05 }}
          >
            <img src={feature.icon} alt="icon" className="w-8 h-8 mb-2" />
            <h3 className="font-semibold text-base md:text-lg mb-1">
              {feature.title}
            </h3>
            <p className="text-xs md:text-sm text-gray-600">
              {feature.description}
            </p>
          </motion.div>
        ))}
      </div>
    </section>
  );
};

export default Features;
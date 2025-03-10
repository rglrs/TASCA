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
    <section className="flex flex-col items-center px-6 md:px-12 lg:px-36 py-16 bg-[#f4f3ff] font-poppins">
      <h2 className="text-2xl md:text-4xl font-semibold mb-16 text-blue-600">
        Features Tasca
      </h2>

      <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 gap-8">
        {features.map((feature, index) => (
          <motion.div
            key={index}
            className="flex flex-col items-center bg-white p-6 rounded-2xl shadow-lg shadow-gray-200 transition-all duration-500 
                      hover:bg-gradient-to-br from-blue-100 to-indigo-200"
            whileHover={{ scale: 1.05 }}
          >
            <div className="p-2 rounded-full mb-3">
              <img src={feature.icon} alt="icon" className="w-20 h-20" />
            </div>
            <h3 className="font-semibold text-lg tracking-wide text-gray-800 mb-2">
              {feature.title}
            </h3>
            <p className="text-sm text-gray-600 text-center">
              {feature.description}
            </p>
          </motion.div>
        ))}
      </div>
    </section>
  );
};

export default Features;

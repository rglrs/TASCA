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
    description:
      "Organize your study time more efficiently with the Pomodoro technique",
  },
  {
    icon: musicIcon,
    title: "Music Relaxation",
    description: "Improve concentration with relaxing music",
  },
  {
    icon: notesIcon,
    title: "Todolist",
    description: "Manage your tasks to be more structured and organized",
  },
  {
    icon: calendarIcon,
    title: "Calendar",
    description: "No need to worry about missing assignment deadlines",
  },
];

const Features = () => {
  return (
    <section className="flex flex-col items-center px-4 md:px-16 lg:px-32 py-16 bg-[#FFFFFF] font-poppins max-w-screen-sm md:max-w-screen-md lg:max-w-screen-lg xl:max-w-screen-xl mx-auto">
      {/* Judul di Tengah */}
      <motion.h1
        className="text-3xl sm:text-4xl font-bold font-popins text-center text-[#333] mb-24 mt-12"
        initial={{ opacity: 0, y: -50 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 1 }}
      >
        What does
        <span className="inline-flex justify-center sm:justify-start mt-2 sm:mt-0 sm:ml-4">
          <span className="text-[#007BFF]">T</span>
          <span className="text-[#007BFF]">A</span>
          <span className="text-[#28A745]">S</span>
          <span className="text-[#FD7E14]">C</span>
          <span className="text-[#FD7E14]">A</span>
        </span>
        <span className="text-[#333] ml-2">have?</span>
      </motion.h1>

      {/* Konten Fitur */}
      <div className="flex flex-col md:flex-row items-center justify-between w-full">
        {/* Kanan - Mockup Image (Dibuat Order 1 di Mobile) */}
        <motion.img
          src={mockupImage}
          alt="Mockup"
          className="w-[180px] md:w-[250px] lg:w-[300px] xl:max-w-[280px] h-auto"
          whileHover={{ scale: 1.1 }}
          transition={{ duration: 0.3 }}
        />

        {/* Kiri - Fitur Cards (Dibuat Order 2 di Mobile) */}
        <div className="w-full md:w-1/2 space-y-4 order-2 md:order-none mt-14 md:mt-0 flex flex-col items-center px-4">
          {features.map((feature, index) => (
            <motion.div
              key={index}
              className="flex items-center bg-white p-3 md:p-5 lg:p-6 rounded-lg shadow-md transition-all duration-500 hover:bg-[#e0e7ff] w-full md:w-full lg:w-full max-w-[1000px]"
              whileHover={{ scale: 1.05 }}
            >
              <img
                src={feature.icon}
                alt="icon"
                className="w-8 h-8 md:w-10 md:h-10 mr-3"
              />
              <div>
                <h3 className="font-semibold text-sm md:text-base lg:text-lg">
                  {feature.title}
                </h3>
                <p className="text-xs md:text-sm text-gray-600 min-h-[40px]">
                  {feature.description}
                </p>
              </div>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
};

export default Features;
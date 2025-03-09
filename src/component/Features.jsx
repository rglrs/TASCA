import React from "react";
import clockIcon from "../assets/image/clock.svg";
import musicIcon from "../assets/image/music.svg";
import notesIcon from "../assets/image/notes.svg";
import calendarIcon from "../assets/image/calendar.svg";
import phoneImage from "../assets/image/phone.svg";

const features = [
  {
    icon: clockIcon,
    title: "Pomodoro",
    description: "Atur waktu belajarmu lebih efisien dengan teknik Pomodoro",
  },
  {
    icon: musicIcon,
    title: "Music Relaxation",
    description: "Tingkatkan konsentrasi dengan musik yang menenangkan",
  },
  {
    icon: notesIcon,
    title: "Todolist",
    description: "Kelola tugas-tugasmu jadi lebih terstruktur dan terorganisir",
  },
  {
    icon: calendarIcon,
    title: "Calendar",
    description: "Tidak perlu khawatir terlewat deadline tugas",
  },
];

const Features = () => {
    return (
      <section className="flex flex-col lg:flex-row items-start justify-between px-6 md:px-12 lg:px-36 py-8 md:py-12 bg-[#f4f3ff] font-poppins">
        {/* Fitur-Fitur */}
        <div className="w-full lg:w-2/3 flex flex-wrap gap-4">
          {features.map((feature, index) => (
            <div
              key={index}
              className="flex items-center bg-white p-4 md:p-6 rounded-[20px] shadow-md w-full transition-transform transform hover:scale-105"
            >
              <img
                src={feature.icon}
                alt="icon"
                className="w-12 h-12 md:w-14 md:h-14 mr-4"
              />
              <div>
                <h3 className="font-semibold text-base md:text-lg">{feature.title}</h3>
                <p className="text-xs md:text-sm text-gray-600">{feature.description}</p>
              </div>
            </div>
          ))}
        </div>

        {/* Gambar Phone */}
        <div className="w-full lg:w-1/3 flex justify-center lg:justify-end relative mt-6 lg:mt-0">
          {phoneImage ? (
            <img
              src={phoneImage}
              alt="Phone"
              className="w-auto max-w-[150px] md:max-w-[240px] drop-shadow-2xl"
            />
          ) : (
            <p className="text-red-500">Image not found</p>
          )}
          {/* Efek Bayangan */}
          <div className="absolute bottom-[-10px] w-[50%] md:w-[60%] h-4 bg-gray-500 opacity-20 rounded-full blur-lg"></div>
        </div>
      </section>
    );
  };

export default Features;
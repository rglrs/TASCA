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
    <section className="flex flex-col lg:flex-row items-start justify-between px-6 py-12 bg-[#f4f3ff] font-poppins">
      {/* Fitur-Fitur */}
      <div className="w-full lg:w-2/3 flex flex-wrap gap-4">
        {features.map((feature, index) => (
          <div
            key={index}
            className="flex items-center bg-white p-6 rounded-[20px] shadow-md w-full lg:w-[48%] transition-transform transform hover:scale-105"
          >
            <img
              src={feature.icon}
              alt="icon"
              className="w-14 h-14 mr-4"
            />
            <div>
              <h3 className="font-semibold text-lg">{feature.title}</h3>
              <p className="text-sm text-gray-600">{feature.description}</p>
            </div>
          </div>
        ))}
      </div>

      {/* Gambar Phone */}
      <div className="w-full lg:w-1/3 flex justify-center lg:justify-end relative lg:mt-0 mt-6">
        {phoneImage ? (
          <img
            src={phoneImage}
            alt="Phone"
            className="w-auto max-w-[200px] drop-shadow-2xl"
          />
        ) : (
          <p className="text-red-500">Image not found</p>
        )}
        {/* Efek Bayangan */}
        <div className="absolute bottom-[-10px] w-[60%] h-4 bg-gray-500 opacity-20 rounded-full blur-lg"></div>
      </div>
    </section>
  );
};

export default Features;
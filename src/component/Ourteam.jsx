import React from "react";
import { motion } from "framer-motion";
import ragil from "../assets/image/ragil.png";
import fani from "../assets/image/fani.png";
import hana from "../assets/image/hana.png";
import yafi from "../assets/image/yafi.png";
import vonda from "../assets/image/vonda.png";
import fahril from "../assets/image/fahril.png";
import rafif from "../assets/image/rafif.png";

const teamMembers = [
  { img: ragil, name: "Ragil Ridho Saputra", role: "Product Owner & Fullstack" },
  { img: fani, name: "Marieta Nona Alfani", role: "UI/UX Designer & Frontend Developer" },
  { img: hana, name: "Roihanah Inayati Bashiroh", role: "Frontend Developer" },
  { img: yafi, name: "Muhammad Yafi Rifdah", role: "Assistant Scrum Master & Fullstack" },
  { img: vonda, name: "Bayu Ariyo Vonda Wicaksono", role: "UI/UX Designer" },
  { img: fahril, name: "Mochammad Fahril Rizal", role: "Backend & Mobile Developer" },
  { img: rafif, name: "Muhammad Rasyid Rafif", role: "UI/UX Designer" },
];

const OurTeam = () => {
  return (
    <div className="py-10 text-center">
      <h2 className="text-3xl font-bold text-black mb-10">Our Teams</h2>

      {/* Baris pertama (4 gambar) */}
      <div className="grid grid-cols-4 gap-x-6 gap-y-10 px-10 md:px-10 max-w-5xl mx-auto">
        {teamMembers.slice(0, 4).map((member, index) => (
          <motion.div
            key={index}
            className="flex flex-col items-center"
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: index * 0.1 }}
          >
            <motion.div
              className="w-40 h-40 rounded-lg overflow-hidden"
              whileHover={{ scale: 1.1 }}
              transition={{ duration: 0.3 }}
            >
              <img src={member.img} alt={member.name} className="w-full h-full object-contain" />
            </motion.div>
            <h3 className="mt-3 text-sm font-semibold text-gray-800">{member.name}</h3>
            <p className="text-xs text-gray-600">{member.role}</p>
          </motion.div>
        ))}
      </div>

      {/* Baris kedua (3 gambar) */}
      <div className="grid grid-cols-3 gap-x-6 gap-y-10 px-10 md:px-10 mt-8 max-w-4xl mx-auto">
        {teamMembers.slice(4, 7).map((member, index) => (
          <motion.div
            key={index}
            className="flex flex-col items-center"
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: (index + 4) * 0.1 }}
          >
            <motion.div
              className="w-40 h-40 rounded-lg overflow-hidden"
              whileHover={{ scale: 1.1 }}
              transition={{ duration: 0.3 }}
            >
              <img src={member.img} alt={member.name} className="w-full h-full object-contain" />
            </motion.div>
            <h3 className="mt-3 text-sm font-semibold text-gray-800">{member.name}</h3>
            <p className="text-xs text-gray-600">{member.role}</p>
          </motion.div>
        ))}
      </div>
    </div>
  );
};

export default OurTeam;

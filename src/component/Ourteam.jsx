import React from "react";
import { motion } from "framer-motion";
import { useInView } from "react-intersection-observer";
import ragil from "../assets/image/ragil.png";
import fani from "../assets/image/fani.png";
import hana from "../assets/image/hana.png";
import yafi from "../assets/image/yafi.png";
import vonda from "../assets/image/vonda.png";
import fahril from "../assets/image/fahril.png";
import rafif from "../assets/image/rafif.png";
import bgOurteam from "../assets/image/bg_ourteam.svg";

const teamMembers = [
  {
    img: ragil,
    name: "Ragil Ridho Saputra",
    role: "Product Owner & Mobile Developer",
  },
  {
    img: fani,
    name: "Marieta Nona Alfani",
    role: "UI/UX Designer & Frontend Developer",
  },
  { img: hana, name: "Roihanah Inayati Bashiroh", role: "Frontend Developer" },
  {
    img: yafi,
    name: "Muhammad Yafi Rifdah",
    role: "Assistant Scrum Master & Frontend Developer, Mobile Developer",
  },
  { img: vonda, name: "Bayu Ariyo Vonda Wicaksono", role: "UI/UX Designer" },
  {
    img: fahril,
    name: "Mochammad Fahril Rizal",
    role: "Backend & Mobile Developer",
  },
  {
    img: rafif,
    name: "Muhammad Rasyid Rafif",
    role: "UI/UX Designer & Mobile Developer",
  },
];

const OurTeam = () => {
  return (
    <div
  className="pt-36 pb-36 py-10 text-center px-4 sm:px-6 lg:px-8 min-h-screen h-full bg-cover bg-top bg-no-repeat"
  style={{
    backgroundImage: `url(${bgOurteam})`,
  }}
>


      <h2 className="text-3xl font-bold text-white mb-10">Our Team</h2>

      <div className="max-w-5xl mx-auto space-y-8">
        {/* Baris pertama (4 gambar) */}
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-6">
          {teamMembers.slice(0, 4).map((member, index) => {
            const { ref, inView } = useInView({
              triggerOnce: false,
              threshold: 0.2,
            });
            return (
              <motion.div
                key={index}
                ref={ref}
                className="flex flex-col items-center"
                initial={{ opacity: 0, y: 30 }}
                animate={inView ? { opacity: 1, y: 0 } : { opacity: 0, y: 30 }}
                transition={{ duration: 0.5, delay: index * 0.1 }}
              >
                <motion.div
                  className="w-32 h-32 sm:w-40 sm:h-40"
                  whileHover={{ scale: 1.1 }}
                  transition={{ duration: 0.3 }}
                >
                  <img
                    src={member.img}
                    alt={member.name}
                    className="w-full h-full object-contain"
                  />
                </motion.div>
                <h3 className="mt-3 text-sm md:text-base font-semibold text-white">
                  {member.name}
                </h3>
                <p className="text-xs md:text-sm text-white text-center max-w-[200px]">
                  {member.role}
                </p>
              </motion.div>
            );
          })}
        </div>

        {/* Baris kedua (3 gambar) */}
        <div className="grid grid-cols-2 sm:grid-cols-3 gap-6 max-w-4xl mx-auto">
          {teamMembers.slice(4, 7).map((member, index) => {
            const { ref, inView } = useInView({
              triggerOnce: false,
              threshold: 0.2,
            });
            return (
              <motion.div
                key={index}
                ref={ref}
                className={`flex flex-col items-center ${
                  index === 2 ? "col-span-2 sm:col-span-1 mx-auto" : ""
                }`}
                initial={{ opacity: 0, y: 30 }}
                animate={inView ? { opacity: 1, y: 0 } : { opacity: 0, y: 30 }}
                transition={{ duration: 0.5, delay: (index + 4) * 0.1 }}
              >
                <motion.div
                  className="w-32 h-32 sm:w-40 sm:h-40"
                  whileHover={{ scale: 1.1 }}
                  transition={{ duration: 0.3 }}
                >
                  <img
                    src={member.img}
                    alt={member.name}
                    className="w-full h-full object-contain"
                  />
                </motion.div>
                <h3 className="mt-3 text-sm md:text-base font-semibold text-white">
                  {member.name}
                </h3>
                <p className="text-xs md:text-sm text-white text-center max-w-[200px]">
                  {member.role}
                </p>
              </motion.div>
            );
          })}
        </div>
      </div>
    </div>
  );
};

export default OurTeam;

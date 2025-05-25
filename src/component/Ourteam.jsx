import React from "react";
import { motion } from "framer-motion";
import { useInView } from "react-intersection-observer";

const bgImage =
  "https://res.cloudinary.com/dqci5udgl/image/upload/v1748190761/OT_bg_2_dzlc9a.png";

const teamMembers = [
  {
    img: "https://res.cloudinary.com/dqrazyfpm/image/upload/v1744365474/ragil_x9vaqd.png",
    name: "Ragil Ridho Saputra",
    role: "Product Owner & Mobile Developer",
  },
  {
    img: "https://res.cloudinary.com/dqrazyfpm/image/upload/v1744365441/fani_mkkqik.png",
    name: "Marieta Nona Alfani",
    role: "UI/UX Designer & Frontend Developer",
  },
  {
    img: "https://res.cloudinary.com/dqrazyfpm/image/upload/v1744365448/hana_zabczh.png",
    name: "Roihanah Inayati Bashiroh",
    role: "Frontend Developer",
  },
  {
    img: "https://res.cloudinary.com/dqrazyfpm/image/upload/v1744365463/yafi_ewevim.png",
    name: "Muhammad Yafi Rifdah",
    role: "Assistant Scrum Master, Frontend Developer & Mobile Developer",
  },
  {
    img: "https://res.cloudinary.com/dqrazyfpm/image/upload/v1744365471/vonda_l8dmn3.png",
    name: "Bayu Ariyo Vonda Wicaksono",
    role: "UI/UX Designer",
  },
  {
    img: "https://res.cloudinary.com/dqrazyfpm/image/upload/v1744365473/fahril_bh7yd1.png",
    name: "Mochammad Fahril Rizal",
    role: "Backend Developer & Mobile Developer",
  },
  {
    img: "https://res.cloudinary.com/dqrazyfpm/image/upload/v1744365481/rafif_vz6l7t.png",
    name: "Muhammad Rasyid Rafif",
    role: "Mobile Developer",
  },
];

const OurTeam = () => {
  return (
    <div
      className="pt-36 pb-10 py-36 text-center px-4 sm:px-6 lg:px-8 min-h-screen h-full bg-no-repeat bg-top"
      style={{
        backgroundImage: `url(${bgImage})`,
        backgroundSize: "contain",
        backgroundRepeat: "no-repeat",
        backgroundPosition: "top center",
      }}
    >
      <h2 className="text-3xl font-bold text-black mb-10">Our Team</h2>

      <div className="max-w-5xl mx-auto space-y-8 px-4 sm:px-0">
        {/* Baris pertama */}
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
                  className="w-40 h-40 sm:w-48 sm:h-48 flex justify-center items-center"
                  whileHover={{ scale: 1.1 }}
                  transition={{ duration: 0.3 }}
                >
                  <img
                    src={member.img}
                    alt={member.name}
                    className="w-full h-full object-contain"
                  />
                </motion.div>
                <h3 className="mt-3 text-sm md:text-base font-semibold text-black">
                  {member.name}
                </h3>
                <p className="text-xs md:text-sm text-black text-center max-w-[200px]">
                  {member.role}
                </p>
              </motion.div>
            );
          })}
        </div>

        {/* Baris kedua */}
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
                  className="w-40 h-40 sm:w-48 sm:h-48 flex justify-center items-center"
                  whileHover={{ scale: 1.1 }}
                  transition={{ duration: 0.3 }}
                >
                  <img
                    src={member.img}
                    alt={member.name}
                    className="w-full h-full object-contain"
                  />
                </motion.div>
                <h3 className="mt-3 text-sm md:text-base font-semibold text-black">
                  {member.name}
                </h3>
                <p className="text-xs md:text-sm text-black text-center max-w-[200px]">
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

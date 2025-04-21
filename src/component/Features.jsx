import React, { useRef, useEffect, useState } from "react";
import { motion, useInView, AnimatePresence } from "framer-motion";

const features = [
  {
    icon: 'https://res.cloudinary.com/dqrazyfpm/image/upload/v1744365468/clock_repk51.svg',
    title: "Pomodoro",
    description:
      "Organize your study time more efficiently with the Pomodoro technique",
  },
  {
    icon: 'https://res.cloudinary.com/dqrazyfpm/image/upload/v1744365443/music_nq0dkx.svg',
    title: "Music Relaxation",
    description: "Improve concentration with relaxing music",
  },
  {
    icon: 'https://res.cloudinary.com/dqrazyfpm/image/upload/v1744365442/notes_oblq9j.svg',
    title: "Todolist",
    description: "Manage your tasks to be more structured and organized",
  },
  {
    icon: 'https://res.cloudinary.com/dqrazyfpm/image/upload/v1744365469/calendar_b14spl.svg',
    title: "Calendar",
    description: "No need to worry about missing assignment deadlines",
  },
];

const FeatureCard = ({ feature, index, isVisible }) => {
  return (
    <AnimatePresence>
      {isVisible && (
        <motion.div
          key={index}
          className="flex items-center bg-white p-3 md:p-5 lg:p-6 rounded-lg shadow-md transition-all duration-500 hover:bg-[#e0e7ff] w-full md:w-full lg:w-full max-w-[1000px]"
          initial={{ opacity: 0, y: 50 }}
          animate={{ opacity: 1, y: 0 }}
          exit={{ opacity: 0, y: 50 }}
          transition={{ duration: 0.5, delay: index * 0.2 }}
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
      )}
    </AnimatePresence>
  );
};

const Features = () => {
  const sectionRef = useRef(null);
  const isInView = useInView(sectionRef, { 
    amount: 0.3,
    margin: "100px 0px -100px 0px"
  });
  const [hasAnimated, setHasAnimated] = useState(false);

  useEffect(() => {
    if (isInView && !hasAnimated) {
      setHasAnimated(true);
    } else if (!isInView && hasAnimated) {
      setHasAnimated(false);
    }
  }, [isInView, hasAnimated]);

  return (
    <motion.section 
      ref={sectionRef}
      className="flex flex-col items-center px-4 md:px-16 lg:px-32 py-16 bg-[#FFFFFF] font-poppins max-w-screen-sm md:max-w-screen-md lg:max-w-screen-lg xl:max-w-screen-xl mx-auto"
      initial={{ opacity: 0 }}
      animate={{ opacity: isInView ? 1 : 0 }}
      exit={{ opacity: 0 }}
      transition={{ duration: 0.8 }}
    >
      {/* Title */}
      <h1 className="text-3xl sm:text-4xl font-bold font-popins text-center text-[#333] mb-18">
        What does{" "}
        <span className="inline-flex items-center">
          <span className="text-[#007BFF]">T</span>
          <span className="text-[#007BFF]">A</span>
          <span className="text-[#28A745]">S</span>
          <span className="text-[#FD7E14]">C</span>
          <span className="text-[#FD7E14]">A</span>
          <span className="text-[#333] ml-2">have?</span>
        </span>
      </h1>

      {/* Konten Fitur */}
      <div className="flex flex-col md:flex-row items-center justify-between w-full">
        {/* Kanan - Mockup Image */}
        <motion.img
          src="https://res.cloudinary.com/dqrazyfpm/image/upload/v1744365480/tes_xjz7ih.svg"
          alt="Mockup"
          className="w-[180px] md:w-[250px] lg:w-[300px] xl:max-w-[280px] h-auto order-1 md:order-1"
          initial={{ opacity: 0, scale: 0.8 }}
          animate={{ opacity: isInView ? 1 : 0, scale: isInView ? 1 : 0.8 }}
          exit={{ opacity: 0, scale: 0.8 }}
          transition={{ duration: 0.7, delay: 0.3 }}
        />

        {/* Kiri - Fitur Cards */}
        <div className="w-full md:w-1/2 space-y-4 order-2 md:order-2 mt-14 md:mt-0 flex flex-col items-center px-4">
          {features.map((feature, index) => (
            <FeatureCard 
              key={index} 
              feature={feature} 
              index={index} 
              isVisible={isInView}
            />
          ))}
        </div>
      </div>
    </motion.section>
  );
};

export default Features;
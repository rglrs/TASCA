import { motion, useInView } from "framer-motion";
import { useRef } from "react";
import whyImage from "../assets/image/why2.svg";

export default function About() {
  const ref = useRef(null);
  const isInView = useInView(ref, { triggerOnce: false });

  return (
    <section
      ref={ref}
      className="bg-[#BDCBFF] text-white px-4 sm:px-8 md:px-16 lg:px-32 min-h-[80vh] flex flex-col items-center shadow-md py-10"
    >
      {/* Konten About */}
      <div className="flex flex-col md:flex-row-reverse items-center justify-between w-full">
        {/* Gambar */}
        <motion.img
          src={whyImage}
          alt="Why TASCA"
          className="w-64 sm:w-80 md:w-[30rem] lg:w-[30rem] mb-10 md:mb-0 md:mr-10"
          initial={{ opacity: 0, x: 50 }}
          animate={isInView ? { opacity: 1, x: 0 } : {}}
          transition={{ duration: 1 }}
        />

        {/* Teks */}
        <div className="max-w-md space-y-6 text-center md:text-left">
          <motion.h1
            className="text-3xl sm:text-4xl font-bold font-popins text-center md:text-left text-[#ffffff] mb-5"
            initial={{ opacity: 0, y: -50 }}
            animate={isInView ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 1 }}
          >
            What is
            <span className="inline-flex sm:inline-block mt-2 sm:mt-0 sm:ml-4">
              <span className="text-[#007BFF]">T</span>
              <span className="text-[#007BFF]">A</span>
              <span className="text-[#28A745]">S</span>
              <span className="text-[#FD7E14]">C</span>
              <span className="text-[#FD7E14]">A</span>
            </span>
            <span className="text-[#ffffff] ml-2">???</span>
          </motion.h1>

          <motion.p
            className="text-base sm:text-lg text-white text-center md:text-left"
            initial={{ opacity: 0, y: 50 }}
            animate={isInView ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 1, delay: 0.5 }}
          >
            Tasca is the smart solution to improve focus and productivity and
            learning. With Pomodoro features with Ambient Sound, Task
            Management, and integrated with calendar, Tasca is ready to be your
            loyal productivity buddy.
          </motion.p>
        </div>
      </div>
    </section>
  );
}

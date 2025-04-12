import React, { useRef } from "react";
import { motion, useInView } from "framer-motion";
import TascaLogo from "./TascaLogo";

const About = () => {
  const ref = useRef(null);
  const isInView = useInView(ref, { once: false, amount: 0.3 });

  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.2,
        delayChildren: 0.3,
      },
    },
  };

  const itemVariants = {
    hidden: { y: 20, opacity: 0 },
    visible: {
      y: 0,
      opacity: 1,
      transition: { duration: 0.8, ease: "easeOut" },
    },
  };

  const features = [
    {
      title: "Task Management",
      description:
        "Organize your assignments, projects, and daily to-dos with our intuitive task management system.",
      icon: (
        <svg
          xmlns="http://www.w3.org/2000/svg"
          className="h-12 w-12 text-[#007BFF]"
          fill="none"
          viewBox="0 0 24 24"
          stroke="currentColor"
        >
          <path
            strokeLinecap="round"
            strokeLinejoin="round"
            strokeWidth={2}
            d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"
          />
        </svg>
      ),
    },
    {
      title: "Pomodoro Technique",
      description:
        "Enhance focus and productivity with built-in Pomodoro timer for structured work sessions and breaks.",
      icon: (
        <svg
          xmlns="http://www.w3.org/2000/svg"
          className="h-12 w-12 text-[#28A745]"
          fill="none"
          viewBox="0 0 24 24"
          stroke="currentColor"
        >
          <path
            strokeLinecap="round"
            strokeLinejoin="round"
            strokeWidth={2}
            d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"
          />
        </svg>
      ),
    },
    {
      title: "Study Planner",
      description:
        "Plan your study sessions, track progress, and visualize your academic journey effectively.",
      icon: (
        <svg
          xmlns="http://www.w3.org/2000/svg"
          className="h-12 w-12 text-[#FD7E14]"
          fill="none"
          viewBox="0 0 24 24"
          stroke="currentColor"
        >
          <path
            strokeLinecap="round"
            strokeLinejoin="round"
            strokeWidth={2}
            d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253"
          />
        </svg>
      ),
    },
  ];

  return (
    <section
      id="about"
      ref={ref}
      className="bg-indigo-200 py-20 md:py-32 px-6 md:px-16 lg:px-32 relative overflow-hidden"
    >
      {/* Background decorative elements */}
      <div className="absolute top-0 left-0 w-64 h-64 bg-[#007BFF]/10 rounded-full -translate-x-1/2 -translate-y-1/2"></div>
      <div className="absolute bottom-0 right-0 w-80 h-80 bg-[#FD7E14]/10 rounded-full translate-x-1/3 translate-y-1/3"></div>

      <div className="container mx-auto relative z-10">
        <motion.div
          className="text-center max-w-3xl mx-auto mb-16"
          initial={{ opacity: 0, y: 20 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.8 }}
        >
          <h2 className="text-3xl md:text-4xl font-bold mb-5 flex flex-col sm:flex-row items-center justify-center px-4 sm:px-0">
            <span className="mr-0 sm:mr-3 mb-2 sm:mb-0">Let's get to know</span>
            <TascaLogo size="lg" />
          </h2>
          <p className="text-lg text-gray-700 leading-relaxed px-4 sm:px-8 md:px-12">
            TASCA is a task and study management app designed to help you manage
            your time and increase your productivity with its
            <span className="font-semibold text-[#007BFF] ml-1">Pomodoro</span>.
          </p>
        </motion.div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-12 items-center">
          {/* Left side - Features */}
          <motion.div
            className="space-y-8 px-4 md:pl-20"
            variants={containerVariants}
            initial="hidden"
            animate={isInView ? "visible" : "hidden"}
          >
            <motion.h3
              className="text-2xl md:text-3xl font-bold text-gray-800 text-center md:text-left"
              variants={itemVariants}
            >
              Why Choose <span className="text-[#007BFF]">TASCA</span>?
            </motion.h3>

            <div className="flex flex-col gap-4 md:gap-8">
              {features.map((feature, index) => (
                <motion.div
                  key={index}
                  className="feature-card p-6 flex flex-col md:flex-row items-start gap-4 bg-white/80 rounded-xl hover:shadow-lg transition-shadow"
                  variants={itemVariants}
                  whileHover={{ y: -5 }}
                >
                  <div className="flex-shrink-0">{feature.icon}</div>
                  <div>
                    <h4 className="text-xl font-semibold mb-2 text-center md:text-left">
                      {feature.title}
                    </h4>
                    <p className="text-gray-600 text-center md:text-left">
                      {feature.description}
                    </p>
                  </div>
                </motion.div>
              ))}
            </div>
          </motion.div>

          {/* Right side - Dashboard Preview */}
          <motion.div
            className="relative px-4"
            initial={{ opacity: 0, x: 50 }}
            animate={isInView ? { opacity: 1, x: 0 } : {}}
            transition={{ duration: 0.8, delay: 0.2 }}
          >
            <div className="relative">
              <motion.div
                className="bg-white rounded-2xl shadow-xl p-6 md:p-8 border-2 border-white max-w-md mx-auto aspect-square"
                animate={{ y: [0, -15, 0] }}
                transition={{
                  repeat: Infinity,
                  duration: 6,
                  ease: "easeInOut",
                }}
              >
                <div className="flex justify-between items-center mb-6">
                  <h3 className="font-bold text-2xl text-gray-800 flex items-center">
                    <TascaLogo size="md" />
                    <span className="ml-2">Dashboard</span>
                  </h3>
                  <div className="w-10 h-10 bg-[#007BFF]/10 rounded-full flex items-center justify-center">
                    <span className="text-[#007BFF] font-semibold">85%</span>
                  </div>
                </div>

                <div className="space-y-4">
                  <div className="bg-[#F7F1FE] p-4 rounded-lg">
                    <h4 className="font-semibold mb-2 flex items-center">
                      <span className="w-3 h-3 bg-[#28A745] rounded-full mr-2"></span>
                      Semester Project
                    </h4>
                    <div className="w-full bg-gray-200 rounded-full h-2.5">
                      <div
                        className="bg-[#28A745] h-2.5 rounded-full"
                        style={{ width: "70%" }}
                      ></div>
                    </div>
                    <div className="text-sm text-gray-500 mt-1">
                      Due in 5 days
                    </div>
                  </div>

                  <div className="bg-[#F7F1FE] p-4 rounded-lg">
                    <h4 className="font-semibold mb-2 flex items-center">
                      <span className="w-3 h-3 bg-[#FD7E14] rounded-full mr-2"></span>
                      Study for Finals
                    </h4>
                    <div className="w-full bg-gray-200 rounded-full h-2.5">
                      <div
                        className="bg-[#FD7E14] h-2.5 rounded-full"
                        style={{ width: "45%" }}
                      ></div>
                    </div>
                    <div className="text-sm text-gray-500 mt-1">
                      4 pomodoros today
                    </div>
                  </div>

                  <div className="bg-[#F7F1FE] p-4 rounded-lg">
                    <h4 className="font-semibold mb-2 flex items-center">
                      <span className="w-3 h-3 bg-[#007BFF] rounded-full mr-2"></span>
                      Reading Assignment
                    </h4>
                    <div className="w-full bg-gray-200 rounded-full h-2.5">
                      <div
                        className="bg-[#007BFF] h-2.5 rounded-full"
                        style={{ width: "90%" }}
                      ></div>
                    </div>
                    <div className="text-sm text-gray-500 mt-1">
                      Almost complete!
                    </div>
                  </div>
                </div>

                <div className="mt-6 p-4 bg-[#007BFF]/10 rounded-lg flex items-center justify-between">
                  <div>
                    <div className="text-sm text-gray-600">Current Focus</div>
                    <div className="font-bold text-gray-800">Study Session</div>
                  </div>
                  <div className="text-3xl font-bold text-[#007BFF]">25:00</div>
                </div>
              </motion.div>

              {/* Decorative dots */}
              <div className="absolute -bottom-4 -right-4 grid grid-cols-3 gap-2">
                {[...Array(9)].map((_, i) => (
                  <div
                    key={i}
                    className="w-2 h-2 bg-[#007BFF]/40 rounded-full"
                  ></div>
                ))}
              </div>
            </div>
          </motion.div>
        </div>

        <motion.div
          className="text-center mt-16 px-4"
          initial={{ opacity: 0, y: 20 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.8, delay: 0.5 }}
        >
          <p className="text-lg text-gray-700 max-w-2xl mx-auto">
            TASCA is suitable for college students, students, and professionals
            who want to better organize their time and achieve their goals in a
            more efficient and structured manner.
          </p>
        </motion.div>
      </div>
    </section>
  );
};

export default About;
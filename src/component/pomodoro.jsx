import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { Play, Pause, ChevronUp, ChevronDown, ChevronLeft } from "lucide-react";
import { motion, AnimatePresence } from "framer-motion";
import Ambience from "../component/Ambience.jsx";

const Pomodoro = () => {
  const defaultFocusMinutes = 25;
  const defaultRelaxMinutes = 5;
  const longFocusMinutes = 50;
  const longRelaxMinutes = 10;

  const [focusTime, setFocusTime] = useState(defaultFocusMinutes);
  const [relaxTime, setRelaxTime] = useState(defaultRelaxMinutes);
  const [isFocusMode, setIsFocusMode] = useState(true);
  const [time, setTime] = useState(defaultFocusMinutes * 60);
  const [isRunning, setIsRunning] = useState(false);
  const [isDropdownOpen, setIsDropdownOpen] = useState(false);
  const navigate = useNavigate();

  useEffect(() => {
    let timer;
    if (isRunning && time > 0) {
      timer = setInterval(() => {
        setTime((prevTime) => prevTime - 1);
      }, 1000);
    } else if (time === 0) {
      // Automatically switch modes when timer reaches zero
      handleSkip();
      setIsRunning(false);
    }
    return () => clearInterval(timer);
  }, [isRunning, time]);

  const formatTime = (seconds) => {
    const minutes = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${minutes.toString().padStart(2, "0")}:${secs
      .toString()
      .padStart(2, "0")}`;
  };

  const resetTimer = () => {
    setIsRunning(false);
    setTime(isFocusMode ? focusTime * 60 : relaxTime * 60);
  };

  const handleSkip = () => {
    setIsRunning(false);

    if (isFocusMode) {
      setIsFocusMode(false);
      setTime(relaxTime * 60);
    } else {
      setIsFocusMode(true);
      setTime(focusTime * 60);
    }
  };

  const setCustomTime = (minutes) => {
    setIsRunning(false);

    if (minutes === 25) {
      setFocusTime(defaultFocusMinutes);
      setRelaxTime(defaultRelaxMinutes);
    } else if (minutes === 50) {
      setFocusTime(longFocusMinutes);
      setRelaxTime(longRelaxMinutes);
    }

    setIsFocusMode(true);
    setTime(minutes * 60);
    setIsDropdownOpen(false);
  };

  const handleBack = () => {
    navigate("/");
  };

  const dropdownVariants = {
    hidden: {
      opacity: 0,
      y: -10,
      scale: 0.95,
    },
    visible: {
      opacity: 1,
      y: 0,
      scale: 1,
      transition: {
        duration: 0.3,
        ease: "easeOut",
      },
    },
    exit: {
      opacity: 0,
      y: -10,
      scale: 0.95,
      transition: {
        duration: 0.2,
        ease: "easeIn",
      },
    },
  };

  return (
    <div className="relative flex flex-col items-center justify-center min-h-screen bg-white text-black pb-38 md:pb-66 overflow-x-hidden">
      {/* Navbar */}
      <div className="sticky top-0 z-10 w-full flex justify-between items-center p-4 sm:p-4 bg-white shadow-sm">
        <div className="flex items-center">
          <button
            onClick={handleBack}
            className="mr-1 sm:mr-3 text-gray-600 hover:text-gray-800"
          >
            <ChevronLeft size={20} className="sm:w-6 sm:h-6" />
          </button>
          <div
            onClick={handleBack}
            className="flex items-center bg-white rounded-xl px-2 sm:px-4 py-1 sm:py-2 shadow-md hover:shadow-lg transition-shadow duration-300 cursor-pointer"
          >
            <img
              src="https://res.cloudinary.com/dqrazyfpm/image/upload/v1744365464/logo_vzaawb.svg"
              alt="Logo"
              className="h-5 sm:h-8"
            />
            <h1 className="text-base sm:text-2xl font-bold font-poppins ml-1 sm:ml-2">
              <span className="text-[#007BFF]">T</span>
              <span className="text-[#007BFF]">a</span>
              <span className="text-[#28A745]">s</span>
              <span className="text-[#FD7E14]">c</span>
              <span className="text-[#FD7E14]">a</span>
            </h1>
          </div>
        </div>
        <div className="relative">
          <button
            onClick={() => setIsDropdownOpen(!isDropdownOpen)}
            className="flex items-center bg-blue-500 text-white px-2 sm:px-4 py-1 sm:py-2 text-xs sm:text-base rounded-lg shadow-md hover:bg-blue-600 transition-colors whitespace-nowrap"
          >
            Focus Timer{" "}
            {isDropdownOpen ? (
              <ChevronUp className="ml-1 sm:ml-2" size={12} />
            ) : (
              <ChevronDown className="ml-1 sm:ml-2" size={12} />
            )}
          </button>
          <AnimatePresence>
            {isDropdownOpen && (
              <motion.div
                className="absolute right-0 mt-2 w-40 sm:w-64 bg-blue-500 text-white rounded-lg shadow-lg z-10 overflow-hidden"
                variants={dropdownVariants}
                initial="hidden"
                animate="visible"
                exit="exit"
              >
                <button
                  onClick={() => setCustomTime(25)}
                  className="block w-full text-left px-2 sm:px-4 py-2 text-xs sm:text-base hover:bg-blue-600 transition-colors duration-200"
                >
                  25min Focus, 5min relax
                </button>
                <button
                  onClick={() => setCustomTime(50)}
                  className="block w-full text-left px-2 sm:px-4 py-2 text-xs sm:text-base hover:bg-blue-600 transition-colors duration-200"
                >
                  50min Focus, 10min relax
                </button>
              </motion.div>
            )}
          </AnimatePresence>
        </div>
      </div>

      {/* Kontainer Timer */}
      <div className="flex flex-col md:flex-row items-center justify-center gap-4 md:gap-20 mt-8 md:mt-14 w-full px-4">
        {/* Timer Section */}
        <div
          className="relative w-56 h-56 sm:w-64 sm:h-64 md:w-80 md:h-80 flex flex-col justify-center items-center 
rounded-full border-4 border-gray-300 
bg-[radial-gradient(circle,_rgba(0,123,255,0.5)_0%,_rgba(255,255,255,1)_70%)]
shadow-lg p-4 md:p-6 mt-4 md:mt-0"
        >
          {isRunning && (
            <div className="absolute inset-0 rounded-full border-8 border-transparent animate-outline"></div>
          )}
          <div className="flex flex-col items-center mb-2 md:mb-4">
            <p className="text-sm md:text-md font-semibold">Stay Focused</p>
            <div className="flex gap-1 mt-1">
              <img
                src="https://res.cloudinary.com/dqrazyfpm/image/upload/v1744365463/tomat_bzl4aw.svg"
                alt="Tomato"
                className="w-4 h-4 md:w-5 md:h-5"
              />
              <img
                src="https://res.cloudinary.com/dqrazyfpm/image/upload/v1744365463/tomat_bzl4aw.svg"
                alt="Tomato"
                className="w-4 h-4 md:w-5 md:h-5"
              />
              <img
                src="https://res.cloudinary.com/dqrazyfpm/image/upload/v1744365463/tomat_bzl4aw.svg"
                alt="Tomato"
                className="w-4 h-4 md:w-5 md:h-5"
              />
            </div>
          </div>
          <div className="text-4xl sm:text-5xl md:text-6xl font-poppins font-semibold mb-2 md:mb-4">
            {formatTime(time)}
          </div>
          <Ambience isRunning={isRunning} />
        </div>

        {/* Tombol & Judul */}
        <div className="flex flex-col items-center gap-3 md:gap-4 px-4 md:px-0 md:ml-10 lg:ml-32">
          <h2 className="text-2xl md:text-3xl font-bold text-center">
            Pomodoro
          </h2>
          <div className="flex justify-center items-center gap-3 md:gap-6 mt-1 md:mt-2 w-full max-w-[300px] md:max-w-[350px]">
            <button
              onClick={handleSkip}
              className="flex items-center justify-center w-12 h-12 sm:w-14 sm:h-14 md:w-16 md:h-16 bg-white rounded-full shadow-md hover:bg-gray-100 text-black text-xs sm:text-sm font-bold"
            >
              Skip
            </button>
            <button
              onClick={() => setIsRunning(!isRunning)}
              className="flex items-center justify-center w-14 h-14 sm:w-16 sm:h-16 md:w-20 md:h-20 bg-[#EF894F] outline-[#EF894F] outline-offset-2 outline-2 rounded-full shadow-lg hover:bg-orange-500 text-white relative"
            >
              {isRunning ? (
                <Pause
                  size={24}
                  className="text-white"
                  stroke="none"
                  fill="white"
                />
              ) : (
                <Play
                  size={24}
                  className="text-white"
                  stroke="none"
                  fill="white"
                />
              )}
            </button>
            <button
              onClick={resetTimer}
              className="flex items-center justify-center w-12 h-12 sm:w-14 sm:h-14 md:w-16 md:h-16 bg-white rounded-full shadow-md hover:bg-gray-100 text-black text-xs sm:text-sm font-bold"
            >
              End
            </button>
          </div>
          <p className="mt-2 md:mt-4 px-3 md:px-4 py-2 bg-white shadow-md rounded-lg text-center text-gray-700 text-sm md:text-base font-medium w-full max-w-[300px] md:max-w-[350px]">
            {isFocusMode
              ? `Start now, don't wait for later! These ${focusTime} minutes are yours!`
              : `Time to recharge! Enjoy your ${relaxTime} minute break.`}
          </p>
        </div>
      </div>

      {/* bg bawah */}
      <motion.div
        className="absolute bottom-0 w-full h-24 sm:h-32 md:h-40 lg:h-70 bg-no-repeat bg-cover"
        style={{
          backgroundImage: `url(https://res.cloudinary.com/dqrazyfpm/image/upload/v1744365475/bg_pomodoro_t87usq.png)`,
        }}
        animate={{ opacity: [0, 1], y: [20, 0] }}
        transition={{ duration: 1.5, ease: "easeOut" }}
      ></motion.div>
    </div>
  );
};

export default Pomodoro;

import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { Play, Pause, ChevronUp, ChevronDown, ChevronLeft } from "lucide-react";
import { motion, AnimatePresence } from "framer-motion";
import TomatoIcon from "https://res.cloudinary.com/dqrazyfpm/image/upload/v1744365463/tomat_bzl4aw.svg";
import logo from "https://res.cloudinary.com/dqrazyfpm/image/upload/v1744365464/logo_vzaawb.svg";
import Ambience from "../component/Ambience.jsx";
import BgPomodoro from "https://res.cloudinary.com/dqrazyfpm/image/upload/v1744365475/bg_pomodoro_t87usq.png";

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

    // Toggle between focus and relax mode
    if (isFocusMode) {
      // Switch to relax mode
      setIsFocusMode(false);
      setTime(relaxTime * 60);
    } else {
      // Switch to focus mode
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

    // Reset to focus mode when changing timer settings
    setIsFocusMode(true);
    setTime(minutes * 60);
    setIsDropdownOpen(false);
  };

  const handleBack = () => {
    navigate("/");
  };

  // Animation variants for dropdown
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
    <div className="relative flex flex-col items-center justify-center min-h-screen bg-white text-black pb-40">
      {/* Navbar */}
      <div className="absolute top-0 left-0 right-0 flex justify-between items-center p-4">
        <div className="flex items-center">
          <button
            onClick={handleBack}
            className="mr-3 text-gray-600 hover:text-gray-800"
          >
            <ChevronLeft size={28} />
          </button>
          <div
            onClick={handleBack}
            className="flex items-center bg-white rounded-xl px-4 py-2 shadow-md hover:shadow-lg transition-shadow duration-300 cursor-pointer"
          >
            <img src={logo} alt="Logo" className="h-8" />
            <h1 className="text-2xl font-bold font-poppins ml-2">
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
            className="flex items-center bg-blue-500 text-white px-4 py-2 rounded-lg shadow-md hover:bg-blue-600 transition-colors"
          >
            Focus Timer{" "}
            {isDropdownOpen ? (
              <ChevronUp className="ml-2" size={16} />
            ) : (
              <ChevronDown className="ml-2" size={16} />
            )}
          </button>
          <AnimatePresence>
            {isDropdownOpen && (
              <motion.div
                className="absolute right-0 mt-2 w-64 bg-blue-500 text-white rounded-lg shadow-lg z-10 overflow-hidden"
                variants={dropdownVariants}
                initial="hidden"
                animate="visible"
                exit="exit"
              >
                <button
                  onClick={() => setCustomTime(25)}
                  className="block w-full text-left px-4 py-2 hover:bg-blue-600 transition-colors duration-200"
                >
                  25min Focus, 5min relax
                </button>
                <button
                  onClick={() => setCustomTime(50)}
                  className="block w-full text-left px-4 py-2 hover:bg-blue-600 transition-colors duration-200"
                >
                  50min Focus, 10min relax
                </button>
              </motion.div>
            )}
          </AnimatePresence>
        </div>
      </div>

      {/* Kontainer Timer */}
      <div className="flex flex-col md:flex-row items-center justify-center gap-20 mt-7">
        {/* Timer Section */}
        <div
          className="relative w-64 h-64 md:w-80 md:h-80 flex flex-col justify-center items-center 
  rounded-full border-4 border-gray-300 
  bg-[radial-gradient(circle,_rgba(0,123,255,0.5)_0%,_rgba(255,255,255,1)_70%)]
  shadow-lg p-6 mt-28 md:mt-0"
        >
          {isRunning && (
            <div className="absolute inset-0 rounded-full border-8 border-transparent animate-outline"></div>
          )}
          <div className="flex flex-col items-center mb-4">
            <p className="text-md font-semibold">Stay Focused</p>
            <div className="flex gap-1 mt-1">
              <img src={TomatoIcon} alt="Tomato" className="w-5 h-5" />
              <img src={TomatoIcon} alt="Tomato" className="w-5 h-5" />
              <img src={TomatoIcon} alt="Tomato" className="w-5 h-5" />
            </div>
          </div>
          <div className="text-6xl font-poppins font-semibold mb-4">
            {formatTime(time)}
          </div>
          <Ambience isRunning={isRunning} />
        </div>

        {/* Tombol & Judul */}
        <div className="flex flex-col items-center gap-4 px-6 md:px-0 md:ml-32">
          <h2 className="text-3xl font-bold text-center">Pomodoro</h2>
          <div className="flex justify-center items-center gap-4 md:gap-6 mt-2 w-full max-w-[350px]">
            <button
              onClick={handleSkip}
              className="flex items-center justify-center w-14 h-14 md:w-16 md:h-16 bg-white rounded-full shadow-md hover:bg-gray-100 text-black text-sm font-bold"
            >
              Skip
            </button>
            <button
              onClick={() => setIsRunning(!isRunning)}
              className="flex items-center justify-center w-16 h-16 md:w-20 md:h-20 bg-[#EF894F] outline-[#EF894F] outline-offset-2 outline-2 rounded-full shadow-lg hover:bg-orange-500 text-white relative"
            >
              {isRunning ? (
                <Pause
                  size={28}
                  className="text-white"
                  stroke="none"
                  fill="white"
                />
              ) : (
                <Play
                  size={28}
                  className="text-white"
                  stroke="none"
                  fill="white"
                />
              )}
            </button>
            <button
              onClick={resetTimer}
              className="flex items-center justify-center w-14 h-14 md:w-16 md:h-16 bg-white rounded-full shadow-md hover:bg-gray-100 text-black text-sm font-bold"
            >
              End
            </button>
          </div>
          <p className="mt-4 px-4 py-2 bg-white shadow-md rounded-lg text-center text-gray-700 font-medium w-full max-w-[350px]">
            {isFocusMode
              ? `Start now, don't wait for later! These ${focusTime} minutes are yours!`
              : `Time to recharge! Enjoy your ${relaxTime} minute break.`}
          </p>
        </div>
      </div>

      {/* bg bawah */}
      <motion.div
        className="absolute bottom-[-20px] md:bottom-[-50px] w-full h-40 md:h-70 bg-no-repeat bg-cover"
        style={{ backgroundImage: `url(${BgPomodoro})` }}
        animate={{ opacity: [0, 1], y: [50, 0] }}
        transition={{ duration: 1.5, ease: "easeOut" }}
      ></motion.div>
    </div>
  );
};

export default Pomodoro;

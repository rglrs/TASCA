import { useState, useEffect, useCallback, memo } from "react";
import { useNavigate } from "react-router-dom";
import { Play, Pause, ChevronUp, ChevronDown, ChevronLeft } from "lucide-react";
import Ambience from "../component/Ambience.jsx";

const TimerDropdown = memo(({ isOpen, onSelect }) => {
  if (!isOpen) return null;
  
  return (
    <div 
      className="absolute right-0 mt-2 w-40 sm:w-64 bg-blue-500 text-white rounded-lg shadow-lg z-10 overflow-hidden"
      style={{
        animation: "fadeIn 0.2s ease-out forwards"
      }}
    >
      <button
        onClick={() => onSelect(25, 5)}
        className="block w-full text-left px-2 sm:px-4 py-2 text-xs sm:text-base hover:bg-blue-600 transition-colors duration-200"
      >
        25min Focus, 5min relax
      </button>
      <button
        onClick={() => onSelect(50, 10)}
        className="block w-full text-left px-2 sm:px-4 py-2 text-xs sm:text-base hover:bg-blue-600 transition-colors duration-200"
      >
        50min Focus, 10min relax
      </button>
    </div>
  );
});

// Memoize the timer display to prevent unnecessary re-renders
const TimerDisplay = memo(({ time }) => {
  const formatTime = (seconds) => {
    const minutes = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${minutes.toString().padStart(2, "0")}:${secs
      .toString()
      .padStart(2, "0")}`;
  };
  
  return (
    <div className="text-4xl sm:text-5xl md:text-6xl font-poppins font-semibold mb-2 md:mb-4">
      {formatTime(time)}
    </div>
  );
});

// Add a simple CSS animation instead of using framer-motion
const cssAnimation = `
  @keyframes fadeIn {
    from { opacity: 0; transform: translateY(-10px) scale(0.95); }
    to { opacity: 1; transform: translateY(0) scale(1); }
  }
  
  @keyframes outline {
    0% { box-shadow: 0 0 0 0 rgba(239, 137, 79, 0.7); }
    70% { box-shadow: 0 0 0 10px rgba(239, 137, 79, 0); }
    100% { box-shadow: 0 0 0 0 rgba(239, 137, 79, 0); }
  }
`;

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

  // Use requestAnimationFrame for smoother timer
  useEffect(() => {
    let rafId;
    let lastTime = null;
    
    const updateTimer = (timestamp) => {
      if (!isRunning || time <= 0) return;
      
      if (!lastTime) {
        lastTime = timestamp;
      }
      
      // Update every second, not on every frame
      const elapsed = timestamp - lastTime;
      if (elapsed >= 1000) {
        setTime(prevTime => {
          const newTime = prevTime - 1;
          if (newTime <= 0) {
            handleSkip();
            setIsRunning(false);
            return 0;
          }
          return newTime;
        });
        lastTime = timestamp;
      }
      
      rafId = requestAnimationFrame(updateTimer);
    };
    
    if (isRunning && time > 0) {
      rafId = requestAnimationFrame(updateTimer);
    }
    
    return () => {
      if (rafId) {
        cancelAnimationFrame(rafId);
      }
    };
  }, [isRunning, time]);

  // Memoize handlers to prevent recreation on every render
  const resetTimer = useCallback(() => {
    setIsRunning(false);
    setTime(isFocusMode ? focusTime * 60 : relaxTime * 60);
  }, [isFocusMode, focusTime, relaxTime]);

  const handleSkip = useCallback(() => {
    setIsRunning(false);
    
    if (isFocusMode) {
      setIsFocusMode(false);
      setTime(relaxTime * 60);
    } else {
      setIsFocusMode(true);
      setTime(focusTime * 60);
    }
  }, [isFocusMode, focusTime, relaxTime]);

  const setCustomTime = useCallback((focusMin, relaxMin) => {
    setIsRunning(false);
    setFocusTime(focusMin);
    setRelaxTime(relaxMin);
    setIsFocusMode(true);
    setTime(focusMin * 60);
    setIsDropdownOpen(false);
  }, []);

  const handleBack = useCallback(() => {
    navigate("/");
  }, [navigate]);

  const toggleRunning = useCallback(() => {
    setIsRunning(prev => !prev);
  }, []);

  const toggleDropdown = useCallback(() => {
    setIsDropdownOpen(prev => !prev);
  }, []);

  // Preload background image
  useEffect(() => {
    const img = new Image();
    img.src = "https://res.cloudinary.com/dqrazyfpm/image/upload/v1744365475/bg_pomodoro_t87usq.png";
  }, []);

  // Close dropdown when clicking outside
  useEffect(() => {
    const handleClickOutside = () => {
      if (isDropdownOpen) {
        setIsDropdownOpen(false);
      }
    };
    
    document.addEventListener('click', handleClickOutside);
    return () => {
      document.removeEventListener('click', handleClickOutside);
    };
  }, [isDropdownOpen]);

  return (
    <>
      {/* Add simple CSS animations */}
      <style>{cssAnimation}</style>
      
      <div className="relative flex flex-col items-center min-h-screen bg-white text-black overflow-hidden">
        {/* Navbar */}
        <div className="fixed top-0 left-0 right-0 z-10 w-full flex justify-between items-center p-4 sm:p-4 bg-white shadow-sm">
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
                loading="lazy"
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
          <div className="relative" onClick={(e) => e.stopPropagation()}>
            <button
              onClick={toggleDropdown}
              className="flex items-center bg-blue-500 text-white px-2 sm:px-4 py-1 sm:py-2 text-xs sm:text-base rounded-lg shadow-md hover:bg-blue-600 transition-colors whitespace-nowrap"
            >
              Focus Timer{" "}
              {isDropdownOpen ? (
                <ChevronUp className="ml-1 sm:ml-2" size={12} />
              ) : (
                <ChevronDown className="ml-1 sm:ml-2" size={12} />
              )}
            </button>
            <TimerDropdown 
              isOpen={isDropdownOpen} 
              onSelect={setCustomTime}
            />
          </div>
        </div>

        {/* Main content area with proper spacing */}
        <div className="w-full flex flex-col items-center pt-34 sm:pt-38">
          {/* Timer Container - moved higher up */}
          <div className="flex flex-col md:flex-row items-center justify-center gap-4 md:gap-24 w-full px-4 mt-0">
            {/* Timer Section */}
            <div
              className={`relative w-56 h-56 sm:w-64 sm:h-64 md:w-80 md:h-80 flex flex-col justify-center items-center 
                        rounded-full border-4 border-gray-300 
                        bg-[radial-gradient(circle,_rgba(0,123,255,0.5)_0%,_rgba(255,255,255,1)_70%)]
                        shadow-lg p-4 md:p-6 ${isRunning ? 'animate-outline' : ''}`}
            >
              <div className="flex flex-col items-center mb-2 md:mb-4">
                <p className="text-sm md:text-md font-semibold">Stay Focused</p>
                <div className="flex gap-1 mt-1">
                  <img
                    src="https://res.cloudinary.com/dqrazyfpm/image/upload/v1744365463/tomat_bzl4aw.svg"
                    alt="Tomato"
                    className="w-4 h-4 md:w-5 md:h-5"
                    loading="lazy"
                  />
                  <img
                    src="https://res.cloudinary.com/dqrazyfpm/image/upload/v1744365463/tomat_bzl4aw.svg"
                    alt="Tomato"
                    className="w-4 h-4 md:w-5 md:h-5"
                    loading="lazy"
                  />
                  <img
                    src="https://res.cloudinary.com/dqrazyfpm/image/upload/v1744365463/tomat_bzl4aw.svg"
                    alt="Tomato"
                    className="w-4 h-4 md:w-5 md:h-5"
                    loading="lazy"
                  />
                </div>
              </div>
              <TimerDisplay time={time} />
              <Ambience isRunning={isRunning} />
            </div>

            {/* Buttons & Title */}
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
                  onClick={toggleRunning}
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
        </div>

        {/* Background at bottom - using simple CSS instead of motion animation*/}
        <div
          className="absolute bottom-0 w-full h-16 sm:h-24 md:h-28 lg:h-50 bg-no-repeat bg-cover"
          style={{
            backgroundImage: `url(https://res.cloudinary.com/dqrazyfpm/image/upload/v1744365475/bg_pomodoro_t87usq.png)`,
            animation: "fadeIn 1.5s ease-out"
          }}
        />
      </div>
    </>
  );
};

export default Pomodoro;
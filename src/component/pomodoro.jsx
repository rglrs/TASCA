import { useState, useEffect } from "react";
import { Play, Pause } from "lucide-react";
import { motion } from "framer-motion";
import TomatoIcon from "../assets/image/tomat.svg";
import SongIcon from "../assets/image/song.svg";
import Navbar2 from "../component/Navbar2";
import BgOurteam from "../assets/image/bg_pomodoro.png"; // Pastikan diimpor dengan benar

const Pomodoro = () => {
  const defaultTime = 25 * 60;
  const [time, setTime] = useState(defaultTime);
  const [isRunning, setIsRunning] = useState(false);

  useEffect(() => {
    let timer;
    if (isRunning && time > 0) {
      timer = setInterval(() => {
        setTime((prevTime) => prevTime - 1);
      }, 1000);
    } else if (time === 0) {
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
    setTime(defaultTime);
  };

  const chooseMusic = () => {
    alert("Fitur pemilihan lagu akan ditambahkan di sini!");
  };

  return (
    <div className="relative flex flex-col items-center justify-center min-h-screen bg-white text-black pb-40">
      {/* Navbar */}
      <Navbar2 />

      {/* Kontainer Timer */}
      <div className="flex flex-col md:flex-row items-center justify-center gap-20 mt-7">
        {/* Timer Section */}
        <div className="relative w-80 h-80 flex flex-col justify-center items-center rounded-full bg-gradient-to-br from-blue-200 to-blue-50 shadow-lg p-10">
          <div className="absolute inset-0 rounded-full border-8 border-white opacity-40"></div>
          <div className="absolute inset-0 rounded-full border-4 border-white opacity-10"></div>

          <p className="text-md font-semibold">Stay Focused</p>
          <div className="flex gap-1 mt-1">
            {[...Array(3)].map((_, index) => (
              <img key={index} src={TomatoIcon} alt="Tomato" className="w-5 h-5" />
            ))}
          </div>
          <div className="text-6xl font-poppins font-semibold my-4">
            {formatTime(time)}
          </div>
          <button
            onClick={chooseMusic}
            className="flex items-center gap-2 font-semibold text-black hover:text-gray-700"
          >
            <img src={SongIcon} alt="Song" className="w-5 h-5" />
            <span>Forest Sound</span>
          </button>
        </div>

        {/* Tombol & Judul */}
        <div className="flex flex-col items-center gap-4">
          <h2 className="text-3xl font-bold">Pomodoro</h2>
          <div className="flex justify-center items-center gap-6 mt-2">
            <button className="flex items-center justify-center w-16 h-16 bg-white rounded-full shadow-md hover:bg-gray-100 text-black text-sm font-bold">
              Skip
            </button>
            <button
              onClick={() => setIsRunning(!isRunning)}
              className="flex items-center justify-center w-20 h-20 bg-[#EF894F] outline-[#EF894F] outline-offset-2 outline-2 rounded-full shadow-lg hover:bg-orange-500 text-white relative"
            >
              {isRunning ? (
                <Pause size={32} className="text-white" stroke="none" fill="white" />
              ) : (
                <Play size={32} className="text-white" stroke="none" fill="white" />
              )}
            </button>
            <button
              onClick={resetTimer}
              className="flex items-center justify-center w-16 h-16 bg-white rounded-full shadow-md hover:bg-gray-100 text-black text-sm font-bold"
            >
              End
            </button>
          </div>

          {/* Motivational Text */}
          <p className="mt-4 px-4 py-2 bg-white shadow-md rounded-lg text-center text-gray-700 font-medium">
            Mulai sekarang, jangan tunggu nanti! 25 menit ini milikmu!
          </p>
        </div>
      </div>

      {/* Footer dengan animasi */}
      <motion.div
        className="absolute bottom-0 w-[100%] h-70 bg-no-repeat bg-cover"
        style={{ backgroundImage: `url(${BgOurteam})` }}
        animate={{ opacity: [0, 1], y: [50, 0] }}
        transition={{ duration: 2.0, ease: "easeOut" }}
      ></motion.div>
    </div>
  );
};

export default Pomodoro;
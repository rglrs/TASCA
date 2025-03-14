import { useState, useEffect } from "react";
import { Play, Pause } from "lucide-react";
import TomatoIcon from "../assets/image/tomat.svg";
import SongIcon from "../assets/image/song.svg";

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
        return `${minutes.toString().padStart(2, "0")}:${secs.toString().padStart(2, "0")}`;
    };

    const resetTimer = () => {
        setIsRunning(false);
        setTime(defaultTime);
    };

    const chooseMusic = () => {
        alert("Fitur pemilihan lagu akan ditambahkan di sini!");
    };

    return (
        <div className="flex justify-center items-center h-screen bg-gradient-to-b from-purple-200 to-white text-black">
            <div className="flex flex-col items-center">
                <h2 className="text-2xl font-bold mb-4">Pomodoro</h2>
                <div className="relative w-80 h-80 flex flex-col justify-center items-center rounded-full border-4 border-gray-300 bg-white shadow-lg p-6">
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
                    <div className="text-6xl font-poppins font-semibold mb-4">{formatTime(time)}</div>
                    <button onClick={chooseMusic} className="flex items-center gap-2 font-semibold text-black hover:text-gray-700">
                        <img src={SongIcon} alt="Song" className="w-5 h-5" />
                        <span>Forest Sound</span>
                    </button>
                </div>
                <div className="flex justify-center items-center gap-6 mt-6">
                    <button className="flex items-center justify-center w-16 h-16 bg-white rounded-full shadow-md hover:bg-gray-100 text-black text-sm font-bold">
                        Skip
                    </button>
                    <button
                        onClick={() => setIsRunning(!isRunning)}
                        className="flex items-center justify-center w-20 h-20 bg-[#EF894F] outline outline-[#EF894F] outline-offset-2 outline-2 rounded-full shadow-lg hover:bg-orange-500 text-white relative"
                    >
                        {isRunning ? (
                            <Pause size={32} className="text-white" stroke="none" fill="white" />
                        ) : (
                            <Play size={32} className="text-white" stroke="none" fill="white" />
                        )}
                    </button>
                    <button onClick={resetTimer} className="flex items-center justify-center w-16 h-16 bg-white rounded-full shadow-md hover:bg-gray-100 text-black text-sm font-bold">
                        End
                    </button>
                </div>
            </div>
        </div>
    );
};

export default Pomodoro;
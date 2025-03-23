import { useState, useEffect, useRef } from "react";
import { X } from "lucide-react";
import SongIcon from "../assets/image/non_song.svg";
import ActiveSongIcon from "../assets/image/song.svg";
import birdAudio from "../assets/audio/bird_ambience.mp3";
import fireAudio from "../assets/audio/fire_ambience.mp3";
import forestAudio from "../assets/audio/forest_ambience.mp3";
import nightAudio from "../assets/audio/night_ambience.mp3";
import rainAudio from "../assets/audio/rain_ambience.mp3";
import waveAudio from "../assets/audio/wave_ambience.mp3";
import windAudio from "../assets/audio/wind_ambience.mp3";
import nonmusicIcon from "../assets/image/non_music.svg";
import birdIcon from "../assets/image/bird.svg";
import fireIcon from "../assets/image/fire.svg";
import forestIcon from "../assets/image/forest.svg";
import nightIcon from "../assets/image/night.svg";
import rainIcon from "../assets/image/rain.svg";
import waveIcon from "../assets/image/wave.svg";
import windIcon from "../assets/image/wind.svg";

const Ambience = ({ isRunning }) => {
  const [isAmbienceMenuOpen, setIsAmbienceMenuOpen] = useState(false);
  const [selectedAmbience, setSelectedAmbience] = useState(null);
  const audioRef = useRef(new Audio());
  const buttonRef = useRef(null);

  const ambienceSounds = [
    { name: "None", audio: null, icon: nonmusicIcon },
    { name: "Forest", audio: forestAudio, icon: forestIcon },
    { name: "Rain", audio: rainAudio, icon: rainIcon },
    { name: "Wave", audio: waveAudio, icon: waveIcon },
    { name: "Fire", audio: fireAudio, icon: fireIcon },
    { name: "Bird", audio: birdAudio, icon: birdIcon },
    { name: "Wind", audio: windAudio, icon: windIcon },
    { name: "Night", audio: nightAudio, icon: nightIcon },
  ];

  // Determine if sound is currently playing
  const isSoundPlaying = isRunning && selectedAmbience;

  // Find the current ambience audio source
  const currentAmbienceAudio = selectedAmbience 
    ? ambienceSounds.find(sound => sound.name === selectedAmbience)?.audio 
    : null;

  // Handle audio playback based on timer state and selected ambience
  useEffect(() => {
    if (currentAmbienceAudio) {
      audioRef.current.src = currentAmbienceAudio;
      audioRef.current.loop = true;
      
      if (isRunning) {
        audioRef.current.play().catch(e => console.error("Audio play error:", e));
      } else {
        audioRef.current.pause();
      }
    } else {
      audioRef.current.pause();
    }

    return () => {
      audioRef.current.pause();
    };
  }, [currentAmbienceAudio, isRunning]);

  // Close menu when clicking outside
  useEffect(() => {
    const handleClickOutside = (event) => {
      if (buttonRef.current && !buttonRef.current.contains(event.target)) {
        if (isAmbienceMenuOpen) setIsAmbienceMenuOpen(false);
      }
    };

    document.addEventListener("mousedown", handleClickOutside);
    return () => {
      document.removeEventListener("mousedown", handleClickOutside);
    };
  }, [isAmbienceMenuOpen]);

  const toggleAmbienceMenu = () => {
    setIsAmbienceMenuOpen(!isAmbienceMenuOpen);
  };

  const selectAmbience = (ambienceName) => {
    setSelectedAmbience(ambienceName === "None" ? null : ambienceName);
    setIsAmbienceMenuOpen(false);
  };

  return (
    <div className="relative" ref={buttonRef}>
      <button
        onClick={toggleAmbienceMenu}
        className="flex items-center gap-2 font-semibold text-black hover:text-gray-700"
      >
        <img 
          src={isSoundPlaying ? ActiveSongIcon : SongIcon} 
          alt="Sound" 
          className="w-5 h-5" 
        />
        {selectedAmbience && <span>{selectedAmbience} Sound</span>}
      </button>

      {/* Ambience Selection Menu - Smaller size */}
      {isAmbienceMenuOpen && (
        <div className="absolute top-full left-1/2 transform -translate-x-1/2 mt-2 z-20 bg-white rounded-2xl shadow-xl p-3 w-64">
          <div className="flex justify-between items-center mb-2">
            <h3 className="font-semibold text-sm">Ambient Sound</h3>
            <button 
              onClick={() => setIsAmbienceMenuOpen(false)}
              className="text-black hover:text-gray-700"
            >
              <X size={16} />
            </button>
          </div>

          <div className="grid grid-cols-4 gap-2">
            {ambienceSounds.map((sound) => (
              <button
                key={sound.name}
                onClick={() => selectAmbience(sound.name)}
                className={`flex flex-col items-center justify-center p-1 rounded-lg transition-all duration-200 
                  ${(selectedAmbience === sound.name) || 
                    (sound.name === "None" && selectedAmbience === null)
                      ? "text-blue-500"
                      : "text-black"
                  } hover:shadow-md`}
              >
                <img 
                  src={sound.icon} 
                  alt={sound.name} 
                  className="w-6 h-6 mb-1" 
                />
                <span className="text-xs font-medium">{sound.name}</span>
              </button>
            ))}
          </div>
        </div>
      )}
    </div>
  );
};

export default Ambience;
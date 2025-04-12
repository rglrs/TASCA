import { useState, useEffect, useRef } from "react";
import { X } from "lucide-react";
import birdAudio from "../assets/audio/bird_ambience.mp3";
import fireAudio from "../assets/audio/fire_ambience.mp3";
import forestAudio from "../assets/audio/forest_ambience.mp3";
import nightAudio from "../assets/audio/night_ambience.mp3";
import rainAudio from "../assets/audio/rain_ambience.mp3";
import waveAudio from "../assets/audio/wave_ambience.mp3";
import windAudio from "../assets/audio/wind_ambience.mp3";

const Ambience = ({ isRunning }) => {
  const [isAmbienceMenuOpen, setIsAmbienceMenuOpen] = useState(false);
  const [selectedAmbience, setSelectedAmbience] = useState(null);
  const audioRef = useRef(new Audio());
  const buttonRef = useRef(null);

  const ambienceSounds = [
    { name: "None", audio: null, icon: 'https://res.cloudinary.com/dqrazyfpm/image/upload/v1744365420/non_music_unn7cx.svg' },
    { name: "Forest", audio: forestAudio, icon: 'https://res.cloudinary.com/dqrazyfpm/image/upload/v1744365421/forest_mnnfvg.svg' },
    { name: "Rain", audio: rainAudio, icon: 'https://res.cloudinary.com/dqrazyfpm/image/upload/v1744365473/rain_idbsuh.svg' },
    { name: "Wave", audio: waveAudio, icon: 'https://res.cloudinary.com/dqrazyfpm/image/upload/v1744365452/wave_wj9nl0.svg' },
    { name: "Fire", audio: fireAudio, icon: 'https://res.cloudinary.com/dqrazyfpm/image/upload/v1744365424/fire_n8jw4v.svg' },
    { name: "Bird", audio: birdAudio, icon: 'https://res.cloudinary.com/dqrazyfpm/image/upload/v1744365443/bird_z4bd0o.svg' },
    { name: "Wind", audio: windAudio, icon: 'https://res.cloudinary.com/dqrazyfpm/image/upload/v1744365454/wind_elkxgk.svg' },
    { name: "Night", audio: nightAudio, icon: 'https://res.cloudinary.com/dqrazyfpm/image/upload/v1744365460/night_bmtt1x.svg' },
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

  // Determine the icon to display based on selected ambience
  const currentIcon = selectedAmbience 
    ? ambienceSounds.find(sound => sound.name === selectedAmbience)?.icon 
    : 'https://res.cloudinary.com/dqrazyfpm/image/upload/v1744365446/non_song_iqvdxh.svg';

  return (
    <div className="relative" ref={buttonRef}>
      <button
        onClick={toggleAmbienceMenu}
        className="flex items-center gap-2 font-semibold text-black hover:text-gray-700"
      >
        <img 
          src={isSoundPlaying ? 'https://res.cloudinary.com/dqrazyfpm/image/upload/v1744365472/song_nbcrx3.svg' : currentIcon} 
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
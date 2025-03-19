import React from "react";
import HeroSection from "./HeroSection";
import PomodoroSection from "./PomodoroSection";

const LandingPage = () => {
  return (
    <div className="min-h-screen bg-gray-100 flex flex-col items-center text-center p-6 scroll-smooth">
      <HeroSection />
      <div className="mt-32"></div> {/* Tambahkan jarak antara HeroSection dan PomodoroSection */}
      <PomodoroSection />
    </div>
  );
};

export default LandingPage;

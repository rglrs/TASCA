import { useEffect, useState } from "react";
import Navbar from "../component/Navbar";
import Footer from "../component/Footer";
import Features from "../component/Features";
import LandingPage from "../component/LandingPage";
import About from "../component/about";
import OurTeam from "../component/Ourteam";
import Testimoni from "../component/Testimoni";

export default function Dashboard() {
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const timer = setTimeout(() => {
      setLoading(false);
    }, 500);

    return () => clearTimeout(timer);
  }, []);

  const Loading = () => (
    <div className="flex items-center justify-center min-h-screen bg-[#FFFFFF] transition-opacity duration-[2000ms]">
      <div className="flex space-x-2">
        <div className="dot"></div>
        <div className="dot"></div>
        <div className="dot"></div>
      </div>
      <style>
        {`
          .dot {
              width: 15px;
              height: 15px;
              border-radius: 50%;
              background-color: #3498db;
              animation: bounce 3s infinite alternate ease-in-out;
          }

          .dot:nth-child(2) {
              animation-delay: 0.5s;
          }

          .dot:nth-child(3) {
              animation-delay: 1s;
          }

          @keyframes bounce {
              0% {
                  transform: translateY(0);
              }
              50% {
                  transform: translateY(-20px);
              }
              100% {
                  transform: translateY(0);
              }
          }
        `}
      </style>
    </div>
  );

  if (loading) {
    return <Loading />;
  }

  return (
      <div className="min-h-screen bg-[#FFFFFF] transition-opacity duration-[2000ms] overflow-x-hidden">
    
      <Navbar />
      <div id="home" className="mt-[-88px]">
        <LandingPage />
      </div>
      <About /> 
      <div id="features" className="w-full">
        <Features />
      </div>
      <div id="ourteam" className="w-full min-h-screen">
        <OurTeam />
      </div>
      <div id="testimoni" className="w-full min-h-screen">
        <Testimoni />
      </div>
      <Footer />
    </div>
  );
}
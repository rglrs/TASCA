import { useState } from "react";
import { useInView } from "react-intersection-observer";
import { motion, AnimatePresence } from "framer-motion";
import logo from "../assets/image/logo.svg";
import { useNavigate } from "react-router-dom";

export default function Navbar() {
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);
  const navigate = useNavigate();
  const { ref, inView } = useInView({
    triggerOnce: false,
    threshold: 0.1,
  });

  const scrollToSection = (id) => {
    const offsets = {
      home: 120,
      about: 20,
      features: 59,
      ourteams: 180,
      download: 100,
    };

    const section = document.getElementById(id);
    if (section) {
      const offset = offsets[id] || 120;
      const sectionPosition =
        section.getBoundingClientRect().top + window.scrollY - offset;
      window.scrollTo({ top: sectionPosition, behavior: "smooth" });
    }
  };

  const handleDemoAppsClick = () => {
    navigate("/pomodoro"); // Navigate to the pomodoro page
  };

  return (
    <nav
      ref={ref}
      className={`fixed top-2 left-1/2 transform -translate-x-1/2 bg-white shadow-lg shadow-gray-400/50 rounded-[20px] px-6 py-4 flex items-center justify-between w-[95%] max-w-6xl z-50
    transition-all duration-[1200ms] ease-[cubic-bezier(0.25, 1, 0.5, 1)]
    ${inView ? "translate-y-0 opacity-100" : "-translate-y-5 opacity-0"}`}
    >
      {/* Logo */}
      <div className="flex items-center space-x-2">
        <img src={logo} alt="Logo" className="h-13" />
        <h1 className="text-2xl font-bold font-poppins">
          <span className="text-[#007BFF]">T</span>
          <span className="text-[#007BFF]">a</span>
          <span className="text-[#28A745]">s</span>
          <span className="text-[#FD7E14]">c</span>
          <span className="text-[#FD7E14]">a</span>
        </h1>
      </div>

      {/* Menu Navbar */}
      <div className="hidden md:flex flex-1 justify-center">
        <div className="flex space-x-8 font-poppins font-semibold">
          {["Home", "About", "Features", "Our Teams"].map((item, index) => (
            <button
              key={index}
              onClick={() =>
                scrollToSection(item.toLowerCase().replace(/\s/g, ""))
              }
              className="text-blue-600 relative group transition-transform duration-500 hover:scale-110"
            >
              {item}
              <span className="absolute -bottom-1 left-0 w-0 h-[2px] bg-blue-600 transition-all duration-500 group-hover:w-full"></span>
            </button>
          ))}
        </div>
      </div>

      {/* Button - Desktop */}
      <button
        onClick={handleDemoAppsClick}
        className="hidden md:block bg-blue-600 text-white px-3 py-1.5 rounded-xl transition-all duration-500 transform hover:scale-110 active:scale-95 hover:bg-blue-700 shadow-md hover:shadow-2xl"
      >
        Demo Apps
      </button>

      {/* Mobile Menu Controls */}
      <div className="flex md:hidden items-center space-x-2">
        {/* Demo Apps Button - Mobile */}
        <button
          onClick={handleDemoAppsClick}
          className="bg-blue-600 text-white px-2 py-1 text-sm rounded-xl transition-all duration-500 transform hover:scale-110 active:scale-95 hover:bg-blue-700 shadow-md"
        >
          Demo Apps
        </button>
        
        {/* Hamburger Menu */}
        <button
          onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
          className="p-2 w-10 h-10 flex items-center justify-center text-sm text-gray-500 rounded-lg hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-gray-200"
        >
          <span className="sr-only">Open main menu</span>
          <svg
            className="w-5 h-5"
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 17 14"
          >
            <path
              stroke="currentColor"
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth="2"
              d="M1 1h15M1 7h15M1 13h15"
            />
          </svg>
        </button>
      </div>

      {/* Dropdown Mobile */}
      <AnimatePresence>
        {isMobileMenuOpen && (
          <motion.div
            initial={{ opacity: 0, y: -10 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{
              opacity: 0,
              y: -10,
              transition: { duration: 0.3, ease: "easeInOut" },
            }}
            transition={{ duration: 0.3, ease: "easeInOut" }}
            className="absolute top-16 right-0 w-[80%] bg-white border border-gray-100 rounded-lg shadow-lg z-40 overflow-hidden"
          >
            <ul className="flex flex-col p-4 space-y-2">
              {["Home", "About", "Features", "Our Teams"].map((item, index) => (
                <li key={index}>
                  <button
                    onClick={() => {
                      scrollToSection(item.toLowerCase().replace(/\s/g, ""));
                      setIsMobileMenuOpen(false);
                    }}
                    className="block py-2 px-3 text-blue-600 hover:bg-gray-100 rounded w-full text-left transition-all duration-300"
                  >
                    {item}
                  </button>
                </li>
              ))}
            </ul>
          </motion.div>
        )}
      </AnimatePresence>
    </nav>
  );
}
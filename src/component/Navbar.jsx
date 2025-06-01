import { useState, useEffect } from "react";
import { useInView } from "react-intersection-observer";
import { motion, AnimatePresence } from "framer-motion";
import { useNavigate } from "react-router-dom";

const MENU_ITEMS = [
  { label: "Home", id: "home" },
  { label: "About", id: "about" },
  { label: "Features", id: "features" },
  { label: "Our Teams", id: "ourteam" },
  { label: "Testimoni", id: "testimoni" },
];

const OFFSET_VALUES = {
  home: 120,
  about: 20,
  features: 59,
  ourteam: 180,
  testimoni: 150,
  download: 100,
};

export default function Navbar() {
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);
  const [activeSection, setActiveSection] = useState("home");
  const navigate = useNavigate();
  const { ref, inView } = useInView({
    triggerOnce: false,
    threshold: 0.1,
  });

  useEffect(() => {
    const handleScroll = () => {
      const scrollPosition = window.scrollY + 200;

      for (const { id } of MENU_ITEMS) {
        const element = document.getElementById(id);
        if (element) {
          const offsetTop = element.offsetTop;
          const offsetHeight = element.offsetHeight;
          if (
            scrollPosition >= offsetTop &&
            scrollPosition < offsetTop + offsetHeight
          ) {
            setActiveSection(id);
            break;
          }
        }
      }
    };

    window.addEventListener("scroll", handleScroll);
    return () => window.removeEventListener("scroll", handleScroll);
  }, []);

  const scrollToSection = (id) => {
    const section = document.getElementById(id);
    if (section) {
      const offset = OFFSET_VALUES[id] || 120;
      const sectionPosition =
        section.getBoundingClientRect().top + window.scrollY - offset;

      window.scrollTo({ top: sectionPosition, behavior: "smooth" });
      setActiveSection(id);
    }
  };

  const handleDemoAppsClick = () => navigate("/pomodoro");

  const renderMenuItems = (isMobile = false) =>
    MENU_ITEMS.map(({ label, id }) => (
      <button
        key={id}
        onClick={() => {
          scrollToSection(id);
          if (isMobile) setIsMobileMenuOpen(false);
        }}
        className={`${
          isMobile
            ? `block py-2 px-3 w-full text-left rounded hover:bg-gray-100 transition-all duration-300 ${
                activeSection === id ? "text-blue-600 font-bold" : "text-gray-600"
              }`
            : `text-blue-600 relative group transition-transform duration-500 hover:scale-110`
        }`}
      >
        {label}
        {!isMobile && (
          <span
            className={`absolute -bottom-1 left-0 h-[2px] bg-blue-600 transition-all duration-500 ${
              activeSection === id ? "w-full" : "w-0 group-hover:w-full"
            }`}
          ></span>
        )}
      </button>
    ));

  return (
    <nav
      ref={ref}
      className={`fixed top-2 left-1/2 transform -translate-x-1/2 bg-white shadow-lg shadow-gray-400/50 rounded-[20px] px-6 py-4 flex items-center justify-between w-[95%] max-w-6xl z-50
        transition-all duration-[1200ms] ease-[cubic-bezier(0.25, 1, 0.5, 1)]
        ${inView ? "translate-y-0 opacity-100" : "-translate-y-5 opacity-0"}`}
    >
      {/* Logo */}
      <div className="flex items-center space-x-2">
        <img
          src="https://res.cloudinary.com/dqrazyfpm/image/upload/v1744365464/logo_vzaawb.svg"
          alt="Logo"
          className="h-10 md:h-13"
        />
        <h1 className="text-xl md:text-2xl font-bold font-poppins">
          <span className="text-[#007BFF]">T</span>
          <span className="text-[#007BFF]">a</span>
          <span className="text-[#28A745]">s</span>
          <span className="text-[#FD7E14]">c</span>
          <span className="text-[#FD7E14]">a</span>
        </h1>
      </div>

      {/* Menu Desktop */}
      <div className="hidden md:flex flex-1 justify-center space-x-8 font-poppins font-semibold">
        {renderMenuItems()}
      </div>

      {/* Demo Button - Desktop */}
      <button
        onClick={handleDemoAppsClick}
        className="hidden md:block bg-blue-600 text-white px-4 py-2 rounded-xl hover:bg-blue-700"
      >
        Demo Apps
      </button>

      {/* Mobile Controls */}
      <div className="flex md:hidden items-center space-x-2">
        <button
          onClick={handleDemoAppsClick}
          className="bg-blue-600 text-white px-3 py-1.5 text-sm rounded-xl hover:bg-blue-700"
        >
          Demo Apps
        </button>
        <button
          onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
          className="p-2 w-10 h-10 flex items-center justify-center text-sm text-gray-500 rounded-lg hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-gray-200"
        >
          <span className="sr-only">Open main menu</span>
          <svg className="w-5 h-5" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 17 14">
            <path stroke="currentColor" strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M1 1h15M1 7h15M1 13h15" />
          </svg>
        </button>
      </div>

      {/* Mobile Dropdown */}
      <AnimatePresence>
        {isMobileMenuOpen && (
          <motion.div
            initial={{ opacity: 0, y: -10 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -10, transition: { duration: 0.3, ease: "easeInOut" } }}
            transition={{ duration: 0.3, ease: "easeInOut" }}
            className="absolute top-16 right-0 w-[80%] bg-white border border-gray-100 rounded-lg shadow-lg z-40 overflow-hidden"
          >
            <ul className="flex flex-col p-4 space-y-2">
              {renderMenuItems(true)}
            </ul>
          </motion.div>
        )}
      </AnimatePresence>
    </nav>
  );
}

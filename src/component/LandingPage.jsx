import { motion } from 'framer-motion';
import mockupImage from '../assets/image/mockup.svg';
import googlePlayImage from '../assets/image/gp.png';

export default function LandingPage() {
    return (
        <section className="flex flex-col md:flex-row items-center justify-between min-h-[80vh] bg-[#F7F1FE] text-black px-4 sm:px-8 md:px-16 lg:px-32 mt-14">
            <div className="flex flex-col max-w-md mt-24 space-y-8 self-start ml-[-5px] sm:ml-[-25px]">
                <motion.h1
                    className="text-3xl sm:text-6xl md:text-7xl font-bold flex space-x-1"
                    initial={{ opacity: 0, y: -50 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ duration: 1 }}
                >
                    <span className="text-[#007BFF]">T</span>
                    <span className="text-[#007BFF]">a</span>
                    <span className="text-[#28A745]">s</span>
                    <span className="text-[#FD7E14]">c</span>
                    <span className="text-[#FD7E14]">a</span>
                </motion.h1>
                <motion.p
                    className="text-base sm:text-lg md:text-xl"
                    initial={{ opacity: 0, y: 50 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ duration: 1, delay: 0.5 }}
                >
                    Tingkatkan produktivitasmu dengan fitur manajemen tugas dan teknik Pomodoro. Cocok untuk pelajar, mahasiswa, dan profesional.
                </motion.p>
                <motion.div
                    className="flex items-left space-x-4 -ml-1 sm:-ml-3"
                    initial={{ opacity: 0 }}
                    animate={{ opacity: 1 }}
                    transition={{ duration: 1, delay: 1 }}
                >
                    <a href="https://play.google.com/store" target="_blank" rel="noopener noreferrer">
                        <img src={googlePlayImage} alt="Download on Google Play" className="w-40 sm:w-53 h-auto -mt-20 mb-4" />
                    </a>
                </motion.div>
            </div>
            <motion.img
                src={mockupImage}
                alt="TASCA Mockup"
                className="w-80 sm:w-96 md:w-[45rem] lg:w-[50rem] mt-12 md:mt-10 translate-x-34 sm:translate-x-54 -translate-y-10 sm:-translate-y-20"
                initial={{ opacity: 0, x: 50 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ duration: 1, delay: 1 }}
            />
        </section>
    );
}
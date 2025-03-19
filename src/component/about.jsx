import { motion, useInView } from 'framer-motion';
import { useRef } from 'react';
import whyImage from '../assets/image/why.svg';

export default function About() {
    const ref = useRef(null);
    const isInView = useInView(ref, { triggerOnce: false });

    return (
        <section ref={ref} className="bg-[#F7F1FE] text-black px-4 sm:px-8 md:px-16 lg:px-32 mt-16 min-h-[80vh] flex flex-col items-center">
            
            <motion.h1
                className="text-3xl sm:text-4xl font-bold font-popins text-center text-[#333] mb-5"
                initial={{ opacity: 0, y: -50 }}
                animate={isInView ? { opacity: 1, y: 0 } : {}}
                transition={{ duration: 1 }}
            >
                Yuk Kenalan Sama
                <span className="block sm:inline-block mt-2 -mb-10 sm:mt-0 sm:ml-4">
                    <span className="text-[#007BFF] mr-2">T</span>
                    <span className="text-[#007BFF] mr-2">A</span>
                    <span className="text-[#28A745] mr-2">S</span>
                    <span className="text-[#FD7E14] mr-2">C</span>
                    <span className="text-[#FD7E14]">A</span>
                </span>
            </motion.h1>

            {/* Konten About */}
            <div className="flex flex-col md:flex-row items-center justify-between w-full">
                {/* Gambar */}
                <motion.img
                    src={whyImage}
                    alt="Why TASCA"
                    className="w-64 sm:w-80 md:w-[30rem] lg:w-[30rem] mb-10 md:mb-0 md:ml-16 lg:ml-5"
                    initial={{ opacity: 0, x: -50 }}
                    animate={isInView ? { opacity: 1, x: 0 } : {}}
                    transition={{ duration: 1 }}
                />

                {/* Teks */}
                <div className="max-w-md space-y-6 text-center md:text-left">
                    <motion.h2
                        className="text-2xl sm:text-3xl font-bold text-[#007BFF]"
                        initial={{ opacity: 0, y: -50 }}
                        animate={isInView ? { opacity: 1, y: 0 } : {}}
                        transition={{ duration: 1, delay: 0.2 }}
                    >
                        Kenapa Memilih TASCA?
                    </motion.h2>
                    <motion.p
                        className="text-base sm:text-lg text-gray-700"
                        initial={{ opacity: 0, y: 50 }}
                        animate={isInView ? { opacity: 1, y: 0 } : {}}
                        transition={{ duration: 1, delay: 0.5 }}
                    >
                        <strong>
                            <span className="text-[#007BFF]">T</span>
                            <span className="text-[#007BFF]">A</span>
                            <span className="text-[#28A745]">S</span>
                            <span className="text-[#FD7E14]">C</span>
                            <span className="text-[#FD7E14]">A</span>
                        </strong> adalah aplikasi manajemen tugas dan belajar berbasis 
                        <span className=" font-semibold text-[#007BFF]"> Pomodoro</span>. Dirancang untuk membantumu tetap fokus, 
                        menyelesaikan tugas dengan lebih efisien, dan meningkatkan produktivitas.
                    </motion.p>
                    <motion.p
                        className="text-base sm:text-lg text-gray-700"
                        initial={{ opacity: 0, y: 50 }}
                        animate={isInView ? { opacity: 1, y: 0 } : {}}
                        transition={{ duration: 1, delay: 0.8 }}
                    >
                        Cocok untuk pelajar, mahasiswa, dan profesional yang ingin mengatur waktu dengan lebih baik dan mencapai tujuan mereka.
                    </motion.p>
                </div>
            </div>
        </section>
    );
}

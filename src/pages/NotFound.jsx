import { Link } from 'react-router-dom';
import { motion, AnimatePresence } from 'framer-motion';
import { DotLottieReact } from '@lottiefiles/dotlottie-react';

export default function NotFound() {
  return (
    <div className="flex flex-col items-center justify-center min-h-screen bg-gradient-to-br from-indigo-100 to-gray-200 p-4">
      <AnimatePresence mode="sync">
        <motion.div
          key="not-found"
          initial={{ opacity: 0, scale: 0.9 }}
          animate={{ opacity: 1, scale: 1 }}
          exit={{ opacity: 0, scale: 0.8 }}
          transition={{ duration: 0.3 }}
          className="text-center"
        >
          <motion.h1
            initial={{ opacity: 0, y: -20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.3, delay: 0.1 }}
            className="text-6xl md:text-7xl font-extrabold text-indigo-600 mb-4 animate-pulse"
          >
            
          </motion.h1>
          <motion.p
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.3, delay: 0.2 }}
            className="text-xl md:text-2xl font-semibold text-gray-700 mb-6"
          >
            Oops! Halaman Tidak Ditemukan
          </motion.p>
          <DotLottieReact
            src="https://lottie.host/81af32d3-0ef3-44a6-b208-1d79786bd6b1/DayuRINdYq.lottie"
            loop
            autoplay
            style={{ width: '300px', height: '300px', margin: 'auto' }}
            onLoad={() => console.log("Lottie loaded")}
          />
          <motion.p
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.3, delay: 0.3 }}
            className="text-gray-500 mb-8 text-center max-w-md px-4 md:px-0"
          >
            Sepertinya halaman yang Anda cari tidak ada atau telah dipindahkan.
            Silakan kembali ke halaman utama untuk melanjutkan.
          </motion.p>
          <Link to="/">
            <motion.button
              initial={{ opacity: 0, scale: 0.8 }}
              animate={{ opacity: 1, scale: 1 }}
              transition={{ duration: 0.3, delay: 0.4 }}
              className="bg-indigo-600 text-white px-4 md:px-6 py-2 md:py-3 rounded-xl font-semibold hover:bg-blue-800 transition-transform duration-300 hover:scale-110"
            >
              Kembali ke Beranda
            </motion.button>
          </Link>
        </motion.div>
      </AnimatePresence>
    </div>
  );
}

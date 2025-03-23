import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { motion } from "framer-motion";
import { FiLock, FiEye, FiEyeOff } from "react-icons/fi";
import Lottie from "lottie-react";
import forgotImage from "../assets/image/forgot.svg";
import successAnimation from "../assets/animation/success.json";

export default function ResetPassword() {
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [isMatch, setIsMatch] = useState(true);
  const [isValid, setIsValid] = useState(true);
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [showModal, setShowModal] = useState(false);
  const navigate = useNavigate();

  const validatePassword = (password) => {
    return password.length >= 8 && /[A-Z]/.test(password) && /[0-9]/.test(password);
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    if (password === confirmPassword && validatePassword(password)) {
      setIsSubmitting(true);
  
      setTimeout(() => {
        setShowModal(true);
        setIsSubmitting(false);
      }, 1500);
    } else {
      setIsMatch(password === confirmPassword);
      setIsValid(validatePassword(password));
    }
  };

  const handleCloseModal = () => {
    setShowModal(false);
    setTimeout(() => {
      window.location.href = "yourapp://home";
    }, 1000);
  };

  return (
    <div className="flex items-center justify-center min-h-screen bg-gray-100 p-4 relative">
      {/* Overlay & Blur Effect */}
      {showModal && <div className="absolute inset-0 bg-gray-200 bg-opacity-30 backdrop-blur-md"></div>}

      <motion.div 
        initial={{ opacity: 0, y: 50 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5 }}
        className={`w-full max-w-4xl bg-white shadow-lg rounded-2xl overflow-hidden flex flex-col md:flex-row transition ${
          showModal ? "blur-sm" : ""
        }`}
      >
        {/* Image */}
        <div className="w-full md:w-1/2 flex items-center justify-center bg-blue-50 p-6">
          <img src={forgotImage} alt="Forgot Password" className="max-w-40 md:max-w-full h-auto" />
        </div>
        
        {/* Form */}
        <div className="w-full md:w-1/2 p-6 md:p-8">
          <h2 className="text-2xl font-semibold text-gray-800 text-center mb-4">
            Buat Kata Sandi Baru
          </h2>
          <p className="text-gray-600 text-sm text-center mb-6">
            Masukkan kata sandi baru Anda.
          </p>
          <form onSubmit={handleSubmit}>
            <label htmlFor="password" className="block text-gray-700 text-sm font-medium mb-2">
              Kata Sandi Baru
            </label>
            <div className="relative">
              <FiLock className="absolute left-3 top-3 text-gray-500" />
              <input 
                id="password" 
                type={showPassword ? "text" : "password"} 
                value={password} 
                onChange={(e) => setPassword(e.target.value)}
                className={`w-full p-2 pl-10 pr-10 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 ${!isValid ? "border-red-500" : "border-gray-300"}`}
                placeholder="Masukkan kata sandi baru"
              />
              <button
                type="button"
                className="absolute right-3 top-2 text-gray-500"
                onClick={() => setShowPassword(!showPassword)}
              >
                {showPassword ? <FiEyeOff /> : <FiEye />}
              </button>
            </div>
            {!isValid && <p className="text-red-500 text-xs mt-1">Kata sandi minimal 8 karakter, harus mengandung huruf besar dan angka</p>}
            
            <label htmlFor="confirmPassword" className="block text-gray-700 text-sm font-medium mt-4 mb-2">
              Konfirmasi Kata Sandi
            </label>
            <div className="relative">
              <FiLock className="absolute left-3 top-3 text-gray-500" />
              <input 
                id="confirmPassword" 
                type={showConfirmPassword ? "text" : "password"} 
                value={confirmPassword} 
                onChange={(e) => setConfirmPassword(e.target.value)}
                className={`w-full p-2 pl-10 pr-10 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 ${!isMatch ? "border-red-500" : "border-gray-300"}`}
                placeholder="Konfirmasi kata sandi"
              />
              <button
                type="button"
                className="absolute right-3 top-2 text-gray-500"
                onClick={() => setShowConfirmPassword(!showConfirmPassword)}
              >
                {showConfirmPassword ? <FiEyeOff /> : <FiEye />}
              </button>
            </div>
            {!isMatch && <p className="text-red-500 text-xs mt-1">Kata sandi tidak cocok</p>}
            <button 
              type="submit" 
              className={`w-full mt-4 bg-blue-500 hover:bg-blue-600 text-white font-semibold py-2 px-4 rounded-lg transition duration-300 ${isSubmitting ? "opacity-50 cursor-not-allowed" : ""}`}
              disabled={isSubmitting}
            >
              {isSubmitting ? "Menyimpan..." : "Simpan Kata Sandi"}
            </button>
          </form>
        </div>
      </motion.div>

      {/* Modal Pop-up */}
      {showModal && (
        <div className="fixed inset-0 flex items-center justify-center bg-black/40 backdrop-blur-sm">
          <motion.div 
            initial={{ scale: 0.8, opacity: 0, y: -20 }}
            animate={{ scale: 1, opacity: 1, y: 0 }}
            transition={{ duration: 0.4, ease: "easeOut" }}
            className="relative bg-white shadow-xl p-6 rounded-2xl w-96 text-center"
          >
            {/* Kontainer Animasi (Diperbesar & Looping) */}
            <div className="flex justify-center p-4">
              <Lottie animationData={successAnimation} loop={true} className="w-52 h-52" />
            </div>

            {/* Judul & Pesan */}
            <h3 className="text-xl font-semibold text-gray-800">Berhasil!</h3>
            <p className="text-gray-700 text-sm mt-2 leading-relaxed">
              Kata sandi Anda telah diperbarui. Silakan login kembali ke aplikasi.
            </p>

            {/* Tombol Kembali */}
            <button
              onClick={handleCloseModal}
              className="mt-5 w-full bg-blue-500 hover:bg-blue-600 text-white font-semibold py-2 px-4 rounded-lg transition duration-300"
            >
              Kembali ke Aplikasi
            </button>
          </motion.div>
        </div>
      )}
    </div>
  );
}

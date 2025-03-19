import React from 'react';
import { motion } from 'framer-motion';

const TascaLogo = ({ size = 'md' }) => {
  const sizeClasses = {
    sm: 'text-xl',
    md: 'text-2xl',
    lg: 'text-3xl'
  };

  const letterVariants = {
    hover: {
      y: -5,
      scale: 1.2,
      transition: {
        type: "spring",
        stiffness: 300,
        damping: 10
      }
    }
  };

  return (
    <span className={`font-bold ${sizeClasses[size]} inline-flex gap-[2px]`}>
      <motion.span 
        className="text-[#007BFF] cursor-pointer"
        variants={letterVariants}
        whileHover="hover"
      >
        T
      </motion.span>
      <motion.span 
        className="text-[#007BFF] cursor-pointer"
        variants={letterVariants}
        whileHover="hover"
      >
        A
      </motion.span>
      <motion.span 
        className="text-[#28A745] cursor-pointer"
        variants={letterVariants}
        whileHover="hover"
      >
        S
      </motion.span>
      <motion.span 
        className="text-[#FD7E14] cursor-pointer"
        variants={letterVariants}
        whileHover="hover"
      >
        C
      </motion.span>
      <motion.span 
        className="text-[#FD7E14] cursor-pointer"
        variants={letterVariants}
        whileHover="hover"
      >
        A
      </motion.span>
    </span>
  );
};

export default TascaLogo;
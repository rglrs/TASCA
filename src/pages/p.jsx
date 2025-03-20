import React, { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { Settings, PenTool as Tool, Clock, AlertCircle } from 'lucide-react';

const Maintenance = () => {
  const [timeLeft, setTimeLeft] = useState({
    days: 0,
    hours: 0,
    minutes: 0,
    seconds: 0
  });
  const [progress, setProgress] = useState(0);

  useEffect(() => {
    // Define fixed start and end dates that will be the same for all users
    // Change these dates to your desired maintenance window
    const startDate = new Date('2025-03-16T00:00:00Z'); // Fixed start date (4 days ago from Mar 20, 2025)
    const targetDate = new Date('2025-03-24T00:00:00Z'); // Fixed end date (4 days from now)
    
    const totalDuration = targetDate.getTime() - startDate.getTime();

    const timer = setInterval(() => {
      const now = new Date();
      const elapsedTime = now.getTime() - startDate.getTime();
      const difference = targetDate.getTime() - now.getTime();

      if (difference <= 0) {
        clearInterval(timer);
        setTimeLeft({ days: 0, hours: 0, minutes: 0, seconds: 0 });
        setProgress(100);
        return;
      }

      const days = Math.floor(difference / (1000 * 60 * 60 * 24));
      const hours = Math.floor((difference % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
      const minutes = Math.floor((difference % (1000 * 60 * 60)) / (1000 * 60));
      const seconds = Math.floor((difference % (1000 * 60)) / 1000);

      setTimeLeft({ days, hours, minutes, seconds });
      setProgress((elapsedTime / totalDuration) * 100);
    }, 1000);

    return () => clearInterval(timer);
  }, []);

  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.3,
      },
    },
  };

  const itemVariants = {
    hidden: { y: 20, opacity: 0 },
    visible: {
      y: 0,
      opacity: 1,
      transition: {
        duration: 0.8,
        ease: "easeOut",
      },
    },
  };

  const floatingAnimation = {
    y: [-10, 10],
    transition: {
      duration: 2,
      repeat: Infinity,
      repeatType: "reverse",
      ease: "easeInOut",
    },
  };

  const spinAnimation = {
    rotate: 360,
    transition: {
      duration: 8,
      repeat: Infinity,
      ease: "linear",
    },
  };

  return (
    <div className="min-h-screen bg-white flex items-center justify-center p-4 overflow-hidden">
      <motion.div
        variants={containerVariants}
        initial="hidden"
        animate="visible"
        className="max-w-4xl w-full px-4 sm:px-6 lg:px-8"
      >
        <motion.div 
          className="bg-white rounded-3xl p-6 sm:p-8 lg:p-12 shadow-2xl border border-gray-100"
          variants={itemVariants}
        >
          <div className="flex flex-col items-center text-center space-y-6 sm:space-y-8">
            <motion.div 
              className="relative"
              animate={floatingAnimation}
            >
              <motion.div
                className="absolute -left-8 sm:-left-12 -top-8 sm:-top-12 text-blue-500"
                animate={spinAnimation}
              >
                <Settings size={32} />
              </motion.div>
              <motion.div
                className="absolute -right-8 sm:-right-12 -top-8 sm:-top-12 text-indigo-500"
                animate={spinAnimation}
              >
                <Tool size={32} />
              </motion.div>
              <AlertCircle size={64} className="text-blue-600" />
            </motion.div>

            <motion.h1 
              variants={itemVariants}
              className="text-3xl sm:text-4xl lg:text-5xl font-bold text-gray-900"
            >
              We're Under Maintenance
            </motion.h1>

            <motion.p 
              variants={itemVariants}
              className="text-base sm:text-lg text-gray-600 max-w-2xl"
            >
              We're currently upgrading our systems to bring you an even better experience. 
              Our team is working hard to get everything back up and running as quickly as possible.
            </motion.p>

            <motion.div 
              variants={itemVariants}
              className="w-full max-w-2xl space-y-4"
            >
              <div className="flex items-center justify-between text-gray-700">
                <div className="flex items-center space-x-2">
                  <Clock size={24} className="text-blue-500" />
                  <span className="text-lg">Progress</span>
                </div>
                <span className="text-lg font-semibold">{Math.round(progress)}%</span>
              </div>
              
              <div className="w-full h-4 bg-gray-100 rounded-full overflow-hidden">
                <motion.div
                  className="h-full bg-gradient-to-r from-blue-500 to-indigo-500"
                  initial={{ width: "0%" }}
                  animate={{ width: `${progress}%` }}
                  transition={{ duration: 0.5 }}
                />
              </div>

              <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 sm:gap-4">
                {[
                  { label: 'Days', value: timeLeft.days },
                  { label: 'Hours', value: timeLeft.hours },
                  { label: 'Minutes', value: timeLeft.minutes },
                  { label: 'Seconds', value: timeLeft.seconds }
                ].map((item, index) => (
                  <motion.div
                    key={index}
                    className="bg-gray-50 rounded-xl p-3 sm:p-4 border border-gray-100"
                    whileHover={{ scale: 1.05 }}
                  >
                    <div className="text-xl sm:text-2xl font-bold text-gray-900">{String(item.value).padStart(2, '0')}</div>
                    <div className="text-xs sm:text-sm text-gray-500">{item.label}</div>
                  </motion.div>
                ))}
              </div>
            </motion.div>

            <motion.div 
              variants={itemVariants}
              className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 sm:gap-6 w-full mt-8"
            >
              {[
                {
                  title: "System Upgrade",
                  description: "Implementing new features and improvements",
                  icon: <Settings className="text-blue-500" size={24} />,
                },
                {
                  title: "Security Updates",
                  description: "Enhancing system security protocols",
                  icon: <AlertCircle className="text-indigo-500" size={24} />,
                },
                {
                  title: "Performance Boost",
                  description: "Optimizing for better performance",
                  icon: <Tool className="text-blue-600" size={24} />,
                },
              ].map((item, index) => (
                <motion.div
                  key={index}
                  className="bg-gray-50 rounded-xl p-4 sm:p-6 border border-gray-100 hover:bg-gray-100 transition-colors"
                  whileHover={{ scale: 1.02 }}
                  transition={{ type: "spring", stiffness: 300 }}
                >
                  <div className="flex flex-col items-center text-center space-y-3">
                    {item.icon}
                    <h3 className="text-lg sm:text-xl font-semibold text-gray-900">{item.title}</h3>
                    <p className="text-sm sm:text-base text-gray-600">{item.description}</p>
                  </div>
                </motion.div>
              ))}
            </motion.div>
          </div>
        </motion.div>
      </motion.div>
    </div>
  );
};

export default Maintenance;
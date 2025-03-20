import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Settings, Wrench, Clock, AlertCircle, Server, Cpu, Shield, Zap } from 'lucide-react';

const Maintenance = () => {
  const [timeLeft, setTimeLeft] = useState({
    days: 0,
    hours: 0,
    minutes: 0,
    seconds: 0
  });
  const [progress, setProgress] = useState(0);
  const [currentFeature, setCurrentFeature] = useState(0);

  useEffect(() => {
    // Fixed start date: 20th of current month
    const startDate = new Date();
    startDate.setDate(20);
    startDate.setHours(0, 0, 0, 0);
    
    // Fixed end date: 25th of current month at 20:00
    const targetDate = new Date();
    targetDate.setDate(25);
    targetDate.setHours(20, 0, 0, 0);
    
    const totalDuration = targetDate.getTime() - startDate.getTime();

    const updateCountdown = () => {
      const now = new Date();
      const difference = targetDate.getTime() - now.getTime();
      const elapsedTime = now.getTime() - startDate.getTime();

      if (difference <= 0) {
        setTimeLeft({ days: 0, hours: 0, minutes: 0, seconds: 0 });
        setProgress(100);
        return;
      }

      const days = Math.floor(difference / (1000 * 60 * 60 * 24));
      const hours = Math.floor((difference % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
      const minutes = Math.floor((difference % (1000 * 60 * 60)) / (1000 * 60));
      const seconds = Math.floor((difference % (1000 * 60)) / 1000);

      setTimeLeft({ days, hours, minutes, seconds });
      
      // Calculate progress percentage based on elapsed time
      const currentProgress = Math.min(Math.max((elapsedTime / totalDuration) * 100, 0), 100);
      setProgress(currentProgress);
    };

    updateCountdown();
    const timer = setInterval(updateCountdown, 1000);

    const featureInterval = setInterval(() => {
      setCurrentFeature(prev => (prev + 1) % features.length);
    }, 3000);

    return () => {
      clearInterval(timer);
      clearInterval(featureInterval);
    };
  }, []);

  const features = [
    {
      icon: <Server className="w-6 h-6" />,
      title: "Server Upgrades",
      description: "Implementing cutting-edge server architecture"
    },
    {
      icon: <Shield className="w-6 h-6" />,
      title: "Security Enhancement",
      description: "Strengthening our security protocols"
    },
    {
      icon: <Cpu className="w-6 h-6" />,
      title: "System Optimization",
      description: "Boosting overall system performance"
    },
    {
      icon: <Zap className="w-6 h-6" />,
      title: "Speed Improvements",
      description: "Enhancing application response time"
    }
  ];

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 via-white to-indigo-50 flex items-center justify-center p-2 sm:p-4">
      <div className="max-w-5xl w-full mx-auto px-2 sm:px-4 py-4 sm:py-8 relative">
        {/* Decorative Elements - Responsive sizes */}
        <div className="absolute top-0 left-0 w-32 sm:w-48 md:w-64 h-32 sm:h-48 md:h-64 bg-blue-100 rounded-full filter blur-3xl opacity-30 animate-pulse" />
        <div className="absolute bottom-0 right-0 w-32 sm:w-48 md:w-64 h-32 sm:h-48 md:h-64 bg-indigo-100 rounded-full filter blur-3xl opacity-30 animate-pulse delay-700" />
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-48 sm:w-64 md:w-96 h-48 sm:h-64 md:h-96 bg-purple-100 rounded-full filter blur-3xl opacity-20 animate-pulse delay-500" />

        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8 }}
          className="relative bg-white/80 backdrop-blur-lg rounded-2xl sm:rounded-3xl p-4 sm:p-6 md:p-8 shadow-2xl border border-white/20"
        >
          <div className="flex flex-col items-center text-center space-y-6 sm:space-y-8">
            {/* Header Section - Responsive icon sizes */}
            <motion.div 
              className="relative"
              animate={{ rotate: [0, 5, -5, 0] }}
              transition={{ duration: 6, repeat: Infinity }}
            >
              <div className="relative">
                <motion.div
                  animate={{ rotate: 360 }}
                  transition={{ duration: 8, repeat: Infinity, ease: "linear" }}
                  className="absolute -left-4 sm:-left-6 -top-4 sm:-top-6"
                >
                  <Settings className="w-6 h-6 sm:w-8 sm:h-8 text-blue-500" />
                </motion.div>
                <motion.div
                  animate={{ rotate: -360 }}
                  transition={{ duration: 8, repeat: Infinity, ease: "linear" }}
                  className="absolute -right-4 sm:-right-6 -top-4 sm:-top-6"
                >
                  <Wrench className="w-6 h-6 sm:w-8 sm:h-8 text-indigo-500" />
                </motion.div>
                <div className="bg-gradient-to-r from-blue-500 via-purple-500 to-indigo-500 p-3 sm:p-4 rounded-full shadow-xl">
                  <AlertCircle className="w-12 h-12 sm:w-16 sm:h-16 text-white" />
                </div>
              </div>
            </motion.div>

            <div className="space-y-3 sm:space-y-4">
              <motion.h1 
                className="text-3xl sm:text-4xl md:text-5xl font-bold bg-gradient-to-r from-blue-600 via-purple-600 to-indigo-600 text-transparent bg-clip-text"
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                transition={{ delay: 0.2 }}
              >
                System Maintenance
              </motion.h1>
              <motion.p 
                className="text-base sm:text-lg text-gray-600 max-w-2xl mx-auto px-2"
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                transition={{ delay: 0.4 }}
              >
                We're upgrading our infrastructure to provide you with an enhanced experience.
                Our team is working diligently to complete the maintenance as quickly as possible.
              </motion.p>
            </div>

            {/* Progress Section */}
            <motion.div 
              className="w-full max-w-2xl space-y-4 sm:space-y-6 px-2"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              transition={{ delay: 0.6 }}
            >
              <div className="flex items-center justify-between text-gray-700">
                <div className="flex items-center space-x-2">
                  <Clock className="w-5 h-5 sm:w-6 sm:h-6 text-blue-500" />
                  <span className="text-base sm:text-lg font-medium">Maintenance Progress</span>
                </div>
                <span className="text-xl sm:text-2xl font-bold bg-gradient-to-r from-blue-600 to-indigo-600 text-transparent bg-clip-text">
                  {Math.round(progress)}%
                </span>
              </div>
              
              <div className="h-3 sm:h-4 bg-gray-100 rounded-full overflow-hidden shadow-inner">
                <motion.div
                  className="h-full bg-gradient-to-r from-blue-500 via-purple-500 to-indigo-500"
                  initial={{ width: "0%" }}
                  animate={{ width: `${progress}%` }}
                  transition={{ duration: 0.8 }}
                />
              </div>

              {/* Countdown Timer - Responsive grid */}
              <div className="grid grid-cols-2 sm:grid-cols-4 gap-2 sm:gap-4">
                {[
                  { label: 'Days', value: timeLeft.days },
                  { label: 'Hours', value: timeLeft.hours },
                  { label: 'Minutes', value: timeLeft.minutes },
                  { label: 'Seconds', value: timeLeft.seconds }
                ].map((item, index) => (
                  <motion.div
                    key={index}
                    className="bg-white rounded-lg sm:rounded-xl p-3 sm:p-4 shadow-lg border border-gray-100 relative overflow-hidden group"
                    whileHover={{ scale: 1.05, backgroundColor: "#F8FAFC" }}
                    transition={{ type: "spring", stiffness: 400 }}
                  >
                    <motion.div 
                      className="absolute inset-0 bg-gradient-to-r from-blue-50 to-indigo-50 opacity-0 group-hover:opacity-100 transition-opacity"
                      initial={false}
                    />
                    <motion.div 
                      className="relative z-10"
                      animate={{ scale: [1, 1.1, 1] }}
                      transition={{ duration: 1, repeat: Infinity, repeatDelay: 1 }}
                    >
                      <div className="text-2xl sm:text-3xl font-bold bg-gradient-to-r from-blue-600 to-indigo-600 text-transparent bg-clip-text">
                        {String(item.value).padStart(2, '0')}
                      </div>
                      <div className="text-xs sm:text-sm text-gray-500 font-medium">{item.label}</div>
                    </motion.div>
                  </motion.div>
                ))}
              </div>
            </motion.div>

            {/* Features Showcase - Responsive layout */}
            <div className="w-full max-w-3xl px-2">
              <AnimatePresence mode="wait">
                <motion.div
                  key={currentFeature}
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, y: -20 }}
                  transition={{ duration: 0.5 }}
                  className="bg-gradient-to-r from-blue-50 to-indigo-50 rounded-xl sm:rounded-2xl p-4 sm:p-6 shadow-inner relative overflow-hidden group"
                >
                  <motion.div 
                    className="absolute inset-0 bg-gradient-to-r from-blue-100/50 to-indigo-100/50 opacity-0 group-hover:opacity-100 transition-opacity"
                    initial={false}
                  />
                  <div className="flex flex-col sm:flex-row items-center sm:justify-center space-y-3 sm:space-y-0 sm:space-x-4 relative z-10">
                    <div className="bg-white p-3 rounded-full shadow-md">
                      {features[currentFeature].icon}
                    </div>
                    <div className="text-center sm:text-left">
                      <h3 className="text-lg sm:text-xl font-semibold text-gray-800">
                        {features[currentFeature].title}
                      </h3>
                      <p className="text-sm sm:text-base text-gray-600">
                        {features[currentFeature].description}
                      </p>
                    </div>
                  </div>
                </motion.div>
              </AnimatePresence>
            </div>

            {/* Status Updates - Responsive text */}
            <motion.div 
              className="text-xs sm:text-sm text-gray-500 flex items-center space-x-2 bg-white/50 px-3 sm:px-4 py-2 rounded-full shadow-inner"
              animate={{ opacity: [0.5, 1, 0.5] }}
              transition={{ duration: 2, repeat: Infinity }}
            >
              <div className="w-1.5 h-1.5 sm:w-2 sm:h-2 bg-green-500 rounded-full animate-pulse" />
              <span>All systems are being monitored during the maintenance</span>
            </motion.div>
          </div>
        </motion.div>
      </div>
    </div>
  );
};

export default Maintenance;
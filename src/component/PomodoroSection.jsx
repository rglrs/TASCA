import React from 'react';
import { Clock, Check, Zap, BarChart, Loader2 } from 'lucide-react';
import Badge from '../component/ui/Badge';
import { cn } from '../lib/utils';
import Progress from '../component/ui/Progress';

const PomodoroSection = () => {
return (
    <section className="py-20 bg-white overflow-hidden">
    <div className="container px-4 mx-auto max-w-7xl">
        <div className="flex flex-col lg:flex-row items-center gap-12 lg:gap-24">
        
        {/* Left side: Timer illustration */}
        <div className="w-full lg:w-1/2 order-2 lg:order-1">
            <div className="relative mx-auto max-w-md">
            
            {/* Main timer circle */}
            <div className="aspect-square relative rounded-full border-[16px] border-red-100 dark:border-red-900/30 p-4 animate-scale-in">
                <div className="absolute inset-0 rounded-full border-t-[16px] border-l-[8px] border-red-500 animate-spin" style={{animationDuration: '30s'}}></div>
                
                <div className="flex flex-col items-center justify-center h-full">
                <div className="text-5xl font-display font-bold text-red-500">24:38</div>
                <div className="text-gray-500 dark:text-gray-400 mt-2">Focus Time</div>
                
                <div className="flex gap-4 mt-6">
                    <div className="w-12 h-12 rounded-full bg-red-500 text-white flex items-center justify-center shadow-md">
                    <Loader2 className="h-6 w-6 animate-spin" />
                    </div>
                    <div className="w-12 h-12 rounded-full bg-white text-gray-600 dark:bg-gray-800 dark:text-gray-300 flex items-center justify-center border border-gray-200 dark:border-gray-700">
                    <Zap className="h-6 w-6" />
                    </div>
                </div>
                </div>
            </div>
            </div>
        </div>
        
        {/* Right side: Content */}
        <div className="w-full lg:w-1/2 text-center lg:text-left order-1 lg:order-2">
            <Badge variant="outline" className="px-4 py-2 mb-6 border-red-200 text-red-700 bg-red-50 rounded-full dark:border-red-800 dark:bg-red-900/30 dark:text-red-400 transition-transform duration-300 hover:scale-105">
            Pomodoro Technique
            </Badge>
            
            <h2 className="text-3xl md:text-4xl font-display font-bold mb-6">
            Boost Your Productivity and Learning Efficiency
            </h2>
            
            <p className="text-lg text-gray-600 mb-8 dark:text-gray-300">
            Our integrated Pomodoro timer helps you maintain focus, prevent burnout, and track your productive time while you learn and complete tasks.
            </p>
            
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
            {[{
                icon: <Clock className="h-8 w-8 p-1.5 bg-red-100 text-red-600 rounded-lg dark:bg-red-900/30 dark:text-red-400" />, 
                title: "Time Management",
                description: "Alternate between focused work periods and short breaks to maximize productivity."
                },
                {
                icon: <Check className="h-8 w-8 p-1.5 bg-green-100 text-green-600 rounded-lg dark:bg-green-900/30 dark:text-green-400" />,
                title: "Task Integration",
                description: "Link your Pomodoro sessions directly to tasks in your project management system."
                },
                {
                icon: <Zap className="h-8 w-8 p-1.5 bg-yellow-100 text-yellow-600 rounded-lg dark:bg-yellow-900/30 dark:text-yellow-400" />,
                title: "Focus Mode",
                description: "Block distractions and stay in the zone with our dedicated focus mode."
                },
                {
                icon: <BarChart className="h-8 w-8 p-1.5 bg-blue-100 text-blue-600 rounded-lg dark:bg-blue-900/30 dark:text-blue-400" />,
                title: "Productivity Analytics",
                description: "Track your focus sessions and see data-driven insights on your work patterns."
                }
            ].map((item, i) => (
                <div key={i} className="flex gap-4 animate-slide-up transition-transform duration-300 hover:scale-105" style={{animationDelay: `${i * 100}ms`}}>
                <div className="flex-shrink-0 mt-1">{item.icon}</div>
                <div>
                    <h3 className="font-display font-semibold mb-1">{item.title}</h3>
                    <p className="text-sm text-gray-600 dark:text-gray-400">{item.description}</p>
                </div>
                </div>
            ))}
            </div>
        </div>
        </div>
    </div>
    </section>
);
};

export default PomodoroSection;
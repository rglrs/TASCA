import React from "react";
import { Button } from "@/components/ui/button";
import { ArrowRight, Clock, BookOpen, ListTodo } from "lucide-react";

const CTA = () => {
  return (
    <section className="py-20 relative overflow-hidden">
      {/* Background gradient */}
      <div className="absolute inset-0 bg-gradient-to-br from-blue-50 to-red-50 -z-10 dark:from-blue-950/30 dark:to-red-950/30" />
      
      {/* Abstract shapes */}
      <div className="absolute top-0 left-1/4 w-96 h-96 bg-blue-100/50 rounded-full blur-3xl -z-10 dark:bg-blue-900/10" />
      <div className="absolute bottom-0 right-1/4 w-64 h-64 bg-red-100/50 rounded-full blur-3xl -z-10 dark:bg-red-900/10" />
      
      <div className="container px-4 mx-auto max-w-5xl">
        <div className="text-center">
          <h2 className="text-3xl md:text-4xl lg:text-5xl font-display font-bold mb-6 animate-fade-in">
            Ready to Transform Your Learning and Productivity?
          </h2>
          
          <p className="text-lg md:text-xl text-gray-600 mb-10 max-w-3xl mx-auto dark:text-gray-300 animate-fade-in" style={{ animationDelay: "100ms" }}>
            Join thousands of students and professionals who have already discovered the power of combined learning, 
            task management, and the Pomodoro technique.
          </p>
          
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-12 max-w-4xl mx-auto">
            {[
              {
                icon: <BookOpen className="h-10 w-10 p-2 text-primary" />,
                title: "Personalized Learning",
                description: "Courses and content tailored to your unique needs and goals."
              },
              {
                icon: <ListTodo className="h-10 w-10 p-2 text-purple-600" />,
                title: "Task Organization",
                description: "Manage all your assignments, projects, and personal tasks in one place."
              },
              {
                icon: <Clock className="h-10 w-10 p-2 text-red-600" />,
                title: "Pomodoro Focus",
                description: "Optimize your work sessions with our integrated Pomodoro timer."
              }
            ].map((item, i) => (
              <div key={i} className="flex flex-col items-center p-6 rounded-xl bg-white/80 shadow-soft border border-gray-100 dark:bg-gray-800/50 dark:border-gray-700 animate-scale-in" style={{animationDelay: `${i * 100}ms`}}>
                <div className="mb-3 rounded-full bg-gray-50 p-3 dark:bg-gray-700/50">{item.icon}</div>
                <h3 className="text-lg font-display font-semibold mb-2">{item.title}</h3>
                <p className="text-sm text-gray-600 text-center dark:text-gray-400">{item.description}</p>
              </div>
            ))}
          </div>
          
          <div className="flex flex-col sm:flex-row gap-4 justify-center animate-fade-in" style={{ animationDelay: "200ms" }}>
            <Button size="lg" className="group text-lg">
              Get Started Free
              <ArrowRight className="ml-2 h-5 w-5 transition-transform group-hover:translate-x-1" />
            </Button>
            <Button size="lg" variant="outline" className="text-lg">
              Watch Demo
            </Button>
          </div>
        </div>
      </div>
    </section>
  );
};

export default CTA;
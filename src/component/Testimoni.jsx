import React, { useEffect, useRef } from "react";
import { motion, useAnimation } from "framer-motion";

const Testimoni = () => {
  const testimonials = [
    {
      id: 1,
      name: "Teman Tasca",
      avatar: "https://randomuser.me/api/portraits/women/44.jpg",
      text: "Saya butuh alat yang bisa membantu saya mengatur waktu dan tugas dengan efisien. Dengan fitur lengkap seperti timer belajar, suara ambient yang meningkatkan fokus saya bisa mengatur semuanya dalam satu tempat.",
    },
    {
      id: 2,
      name: "Teman Tasca",
      avatar: "https://randomuser.me/api/portraits/women/65.jpg",
      text: "Sejak menggunakan TASCA, saya merasakan perubahan besar dalam cara saya belajar. Fitur Pomodoro membantu saya tetap fokus tanpa merasa kelelahan, sementara ambient sound membuat suasana belajar jadi lebih nyaman.",
    },
    {
      id: 3,
      name: "Teman Tasca",
      avatar: "https://randomuser.me/api/portraits/men/33.jpg",
      text: "Saya selalu kesulitan mengatur waktu belajar, tetapi setelah mencoba TASCA, semuanya jadi lebih terstruktur. Fitur manajemen tugas sangat membantu saya apa yang harus, dan saya tidak pernah lagi melewatkan deadline.",
    },
    {
      id: 4,
      name: "Teman Tasca",
      avatar: "https://randomuser.me/api/portraits/men/45.jpg",
      text: "Dulu saya sering terdistraksi saat belajar, tapi TASCA membantu saya tetap berada di jalur yang benar. Fitur pengatur waktu Pomodoro-nya membuat saya lebih disiplin, tenang dalam membagi sesi belajar dan istirahat.",
    },
  ];

  const controls = useAnimation();
  const containerRef = useRef(null);

  useEffect(() => {
    let animationActive = true;

    const animate = async () => {
      const containerWidth = containerRef.current?.scrollWidth / 3;
      if (!containerWidth) return;

      while (animationActive) {
        try {
          await controls.start({
            x: -containerWidth,
            transition: {
              duration: 20,
              ease: "linear",
            },
          });

          if (!animationActive) break;

          await controls.start({
            x: 0,
            transition: { duration: 0 },
          });
        } catch (error) {
          break;
        }
      }
    };

    if (containerRef.current) {
      animate();
    }

    return () => {
      animationActive = false;
      controls.stop();
    };
  }, [controls]);

  return (
    <section
      className="py-50 px-6 md:px-20 font-sans bg-cover bg-top bg-no-repeat min-h-screen"
      style={{
        backgroundImage: `url(https://res.cloudinary.com/dqrazyfpm/image/upload/v1744365458/bg_ourteam_rbrfz0.svg)`,
      }}
    >
      <div className="text-center mb-25">
        <h2 className="text-4xl font-bold text-white">
          <span className="inline-flex items-center">
            <span className="text-[#007BFF]">T</span>
            <span className="text-[#007BFF]">A</span>
            <span className="text-[#28A745]">S</span>
            <span className="text-[#FD7E14]">C</span>
            <span className="text-[#FD7E14]">A</span>
            <span className="text-[#fcfafa] ml-2">Energizer!</span>
          </span>
        </h2>
        <p className="mt-4 text-lg text-white">
          Thank you for believing in Tasca. Your support is the reason why{" "}
          <br />
          we continue to grow and make your learning experience more exciting.
        </p>
      </div>

      <div className="overflow-hidden">
        <motion.div
          className="flex flex-nowrap"
          animate={controls}
          ref={containerRef}
          style={{ width: "max-content" }}
        >
          {[...Array(3)]
            .flatMap(() => testimonials)
            .map((item, idx) => (
              <div
                key={idx}
                className="min-w-[280px] max-w-[280px] min-h-[260px] bg-white/20 backdrop-blur-md rounded-xl shadow-md p-6 border border-white/30 mr-8"
              >
                <div className="flex items-center mb-4">
                  <img
                    src={item.avatar}
                    alt="Avatar"
                    className="w-16 h-16 rounded-full mr-4"
                  />
                  <h3 className="font-semibold text-md text-black">
                    {item.name}
                  </h3>
                </div>
                <p className="text-black/90 text-sm leading-relaxed">
                  {item.text}
                </p>
              </div>
            ))}
        </motion.div>
      </div>
    </section>
  );
};

export default Testimoni;

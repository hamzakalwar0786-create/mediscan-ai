import { useEffect } from "react";
import { ShieldAlert } from "lucide-react";

interface SplashViewProps {
  onFinish: () => void;
}

export default function SplashView({ onFinish }: SplashViewProps) {
  useEffect(() => {
    const timer = setTimeout(() => {
      onFinish();
    }, 3200);
    return () => clearTimeout(timer);
  }, [onFinish]);

  return (
    <main className="relative min-h-screen w-full flex flex-col items-center justify-center bg-white overflow-hidden transition-all duration-700 select-none">
      {/* Soft Clinical Atmospheric Lights */}
      <div className="absolute top-0 left-0 w-full h-full opacity-30 pointer-events-none">
        <div className="absolute top-[-10%] left-[-15%] w-[50%] h-[50%] bg-[#0052cc] rounded-full blur-[140px] opacity-20"></div>
        <div className="absolute bottom-[-10%] right-[-15%] w-[50%] h-[50%] bg-[#4ae176] rounded-full blur-[140px] opacity-20"></div>
      </div>

      {/* Main Content Card Container */}
      <div className="flex flex-col items-center justify-center z-10 scale-95 md:scale-100 transition-all">
        {/* Pulsing Clinical Logo Badge with scanner glow */}
        <div className="relative mb-8 p-6 rounded-2xl bg-white shadow-xl ring-1 ring-neutral-100 border border-neutral-100 transition-transform duration-1000 ease-out animate-pulse">
          {/* Main Logo Container */}
          <div className="w-32 h-32 md:w-36 md:h-36 bg-[#0052cc] rounded-3xl flex items-center justify-center shadow-lg relative overflow-hidden">
            {/* The standard blue medical box plus heartbeat green line checkmark */}
            <div className="relative flex items-center justify-center w-full h-full">
              {/* White cross symbol */}
              <div className="absolute w-5 h-20 bg-white rounded-full"></div>
              <div className="absolute w-20 h-5 bg-white rounded-full"></div>
              {/* Heartbeat green pulse checkline overlay */}
              <svg 
                className="absolute w-20 h-16 text-[#22c55e] stroke-[6] fill-none drop-shadow-[0_2px_4px_rgba(0,0,0,0.25)]" 
                viewBox="0 0 100 100"
              >
                <path d="M10 50 L35 50 L45 25 L55 75 L65 50 L90 50" strokeLinecap="round" strokeLinejoin="round" />
              </svg>
            </div>
            
            {/* Moving Laser Scanner line on logo */}
            <div className="absolute w-full h-1 bg-cyan-300 opacity-60 shadow-[0_0_10px_#22d3ee] top-0 left-0 animate-bounce duration-1000" style={{ animationDuration: '2.5s' }}></div>
          </div>
        </div>

        {/* Display Typography pairing */}
        <div className="text-center font-sans tracking-tight">
          <h1 className="text-4xl md:text-5xl font-extrabold text-[#003d9b] select-text">
            MediScan AI
          </h1>
          
          {/* Animated bouncy progress bullet indicators */}
          <div className="mt-6 flex justify-center gap-2 h-1.5">
            <span className="w-2.5 h-2.5 bg-[#0052cc] rounded-full animate-bounce" style={{ animationDelay: '0s' }}></span>
            <span className="w-2.5 h-2.5 bg-[#0052cc]/75 rounded-full animate-bounce" style={{ animationDelay: '0.2s' }}></span>
            <span className="w-2.5 h-2.5 bg-[#0052cc]/40 rounded-full animate-bounce" style={{ animationDelay: '0.4s' }}></span>
          </div>
        </div>
      </div>

      {/* HIPAA Statement - Fixed Secure Footer */}
      <footer className="absolute bottom-12 left-0 w-full text-center px-6">
        <p className="text-xs font-semibold uppercase text-neutral-400 tracking-[0.2em] mb-2">
          AI-POWERED HEALTHCARE
        </p>
        <div className="inline-flex items-center justify-center gap-2 text-neutral-500 bg-neutral-50 px-4 py-1.5 rounded-full border border-neutral-100 shadow-sm max-w-xs mx-auto">
          <ShieldAlert className="w-4 h-4 text-[#22c55e] shrink-0" />
          <span className="text-xs font-medium tracking-wide">Secure Clinical Data Processing</span>
        </div>
      </footer>
    </main>
  );
}

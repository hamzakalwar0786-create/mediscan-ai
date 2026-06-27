import { useState } from "react";
import { ArrowRight, Heart, Shield, CheckCircle, Brain, Mail, Send, Activity } from "lucide-react";

interface OnboardingViewProps {
  onFinish: () => void;
}

export default function OnboardingView({ onFinish }: OnboardingViewProps) {
  const [currentSlide, setCurrentSlide] = useState(0);
  const totalSlides = 3;

  const handleNext = () => {
    if (currentSlide < totalSlides - 1) {
      setCurrentSlide(currentSlide + 1);
    } else {
      onFinish();
    }
  };

  return (
    <main className="min-h-screen bg-[#f7f9fb] text-slate-800 flex flex-col justify-between select-none relative pb-10">
      {/* Top Header Section */}
      <header className="flex justify-between items-center h-20 px-6 max-w-lg mx-auto w-full">
        <div className="flex items-center gap-2">
          {/* Diagnostic dynamic medical pulse container */}
          <div className="w-8 h-8 rounded-lg bg-[#0052cc] flex items-center justify-center shrink-0 shadow-md shadow-[#0052cc]/20">
            <span className="text-white font-bold text-base leading-none">M</span>
          </div>
          <span className="font-extrabold text-lg text-[#003d9b] tracking-tight">MediScan AI</span>
        </div>
        {currentSlide < totalSlides - 1 && (
          <button 
            onClick={() => setCurrentSlide(totalSlides - 1)}
            className="text-sm font-semibold text-neutral-400 hover:text-[#0052cc] transition-colors"
          >
            Skip
          </button>
        )}
      </header>

      {/* Main Slide Carousel Container */}
      <div className="flex-1 flex flex-col items-center justify-center max-w-sm mx-auto px-6 w-full">
        {currentSlide === 0 && (
          <div className="flex flex-col items-center animate-fadeIn w-full">
            {/* Slide 0 Diagnostic report scanning preview */}
            <div className="relative w-full max-w-[290px] aspect-[4/5] bg-white rounded-[2rem] p-4 shadow-xl border border-neutral-100 overflow-hidden mb-8">
              <div className="absolute inset-0 bg-gradient-to-br from-[#0052cc]/5 to-transparent"></div>
              
              <div className="relative h-full w-full bg-neutral-50 rounded-2xl border border-dashed border-neutral-200 flex flex-col justify-center items-center overflow-hidden p-4">
                {/* Horizontal scanner light */}
                <div className="absolute w-full h-[3px] bg-gradient-to-r from-transparent via-[#0052cc] to-transparent shadow-[0_0_15px_#0052cc] top-0 left-0 animate-[scan_2s_infinite_ease-in-out]"></div>
                
                {/* Embedded medical summary sheet representing CBC */}
                <div className="w-full text-[10px] text-neutral-400 space-y-2 p-2">
                  <p className="font-bold border-b pb-1 text-[#0052cc]">LABORATORY REPORT - CBC</p>
                  <div className="flex justify-between"><span>HEMOGLOBIN</span><span className="font-semibold text-neutral-600">14.2 g/dL</span></div>
                  <div className="flex justify-between"><span>WBC COUNT</span><span className="font-semibold text-neutral-600">7.2 x10³/µL</span></div>
                  <div className="flex justify-between"><span>PLATELETS</span><span className="font-semibold text-neutral-600">210 x10³/µL</span></div>
                  <div className="flex justify-between"><span>MCV</span><span className="font-semibold text-neutral-600">88 fL</span></div>
                  <div className="h-1.5 bg-neutral-200 rounded-full w-3/4"></div>
                </div>

                {/* Secure overlay floating box */}
                <div className="absolute bottom-3 left-3 right-3 h-12 bg-white/95 backdrop-blur-md rounded-xl flex items-center px-3 gap-3 border border-neutral-100 shadow-lg">
                  <div className="w-8 h-8 rounded-full bg-[#0052cc] flex items-center justify-center">
                    <Activity className="w-4 h-4 text-white" />
                  </div>
                  <div className="flex-1">
                    <p className="text-[10px] font-bold text-neutral-800">OCR ANALYSIS</p>
                    <div className="h-1.5 w-2/3 bg-neutral-200 rounded-full overflow-hidden">
                      <div className="h-full bg-[#22c55e] w-4/5 animate-pulse"></div>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            {/* Display texts */}
            <div className="text-center space-y-3">
              <h2 className="text-2xl font-bold text-[#003d9b] tracking-tight">Scan Your Reports</h2>
              <p className="text-sm leading-relaxed text-neutral-500">
                Effortlessly convert your paper medical records into digital, searchable data using our advanced OCR technology.
              </p>
            </div>
          </div>
        )}

        {currentSlide === 1 && (
          <div className="flex flex-col items-center animate-fadeIn w-full">
            {/* Slide 1 Hemoglobin analysis listing with abnormal marker */}
            <div className="relative w-full max-w-[290px] aspect-[4/5] bg-white rounded-[2rem] p-4 shadow-xl border border-neutral-100 flex flex-col gap-3 justify-center mb-8">
              {/* Normal Parameter row */}
              <div className="bg-white rounded-xl p-3 border-l-4 border-[#22c55e] shadow-sm space-y-1">
                <div className="flex justify-between items-center">
                  <span className="text-[10px] font-bold tracking-wider text-neutral-400">HEMOGLOBIN</span>
                  <span className="text-xs font-bold text-neutral-800">14.2 g/dL</span>
                </div>
                <div className="h-1.5 w-full bg-neutral-100 rounded-full overflow-hidden">
                  <div className="h-full bg-[#22c55e] w-3/4"></div>
                </div>
              </div>

              {/* Abnormal Parameter row with alert icon */}
              <div className="bg-white rounded-xl p-3 border-l-4 border-[#ef4444] shadow-sm space-y-1 relative">
                <div className="flex justify-between items-center">
                  <span className="text-[10px] font-bold tracking-wider text-neutral-400">VITAMIN D</span>
                  <span className="text-xs font-bold text-[#ef4444]">12.5 ng/mL</span>
                </div>
                <div className="h-1.5 w-full bg-neutral-100 rounded-full overflow-hidden">
                  <div className="h-full bg-[#ef4444] w-1/4"></div>
                </div>
                {/* Floating flag */}
                <div className="absolute -top-1.5 -right-1.5 bg-[#ef4444] text-white w-5 h-5 rounded-full flex items-center justify-center text-[10px] font-bold shadow-md">
                  !
                </div>
              </div>

              {/* AI Diagnosis analysis loader banner */}
              <div className="bg-[#0052cc]/5 rounded-xl border border-[#0052cc]/10 p-3.5 flex flex-col items-center justify-center text-center">
                <div className="w-10 h-10 bg-white rounded-full shadow-sm flex items-center justify-center mb-2 animate-bounce">
                  <Brain className="w-5 h-5 text-[#0052cc]" />
                </div>
                <p className="text-[10px] font-bold text-[#0052cc] tracking-wide uppercase">AI HEALTH CLASSIFE</p>
                <p className="text-[11px] text-neutral-500 mt-0.5">Diagnosing biological markers...</p>
              </div>
            </div>

            {/* Display texts */}
            <div className="text-center space-y-3">
              <h2 className="text-2xl font-bold text-[#003d9b] tracking-tight">AI Diagnosis</h2>
              <p className="text-sm leading-relaxed text-neutral-500">
                Our clinical AI analyzes your data to highlight critical insights and potential health indicators in seconds.
              </p>
            </div>
          </div>
        )}

        {currentSlide === 2 && (
          <div className="flex flex-col items-center animate-fadeIn w-full">
            {/* Slide 2 Chat bubble preview */}
            <div className="relative w-full max-w-[290px] aspect-[4/5] bg-white rounded-[2rem] p-4 shadow-xl border border-neutral-100 flex flex-col mb-8 overflow-hidden">
              <div className="flex-1 space-y-3 overflow-y-auto block select-none">
                {/* Patient Query bubble */}
                <div className="flex justify-start">
                  <div className="bg-neutral-50 border border-neutral-100 p-3 rounded-2xl rounded-tl-none shadow-sm max-w-[85%] text-left">
                    <p className="text-xs text-neutral-600 line-clamp-2">My Vitamin D level is low. What should I do next?</p>
                  </div>
                </div>

                {/* AI doctor high-trust clinic response */}
                <div className="flex justify-end">
                  <div className="bg-[#0052cc] p-3 rounded-xl rounded-tr-none shadow-md max-w-[90%] text-left text-white">
                    <div className="flex items-center gap-1 mb-1">
                      <CheckCircle className="w-3.5 h-3.5 text-[#4ae176]" />
                      <span className="text-[8px] font-bold uppercase tracking-widest text-[#6bff8f]">VERIFIED CLINICIAN</span>
                    </div>
                    <p className="text-xs leading-relaxed text-white">
                      Based on your report, I recommend increasing dairy foods and consulting your GP about weekly Vitamin D3 supplements.
                    </p>
                  </div>
                </div>
              </div>

              {/* Chat Input Placeholder */}
              <div className="mt-2 bg-neutral-50 p-2 rounded-full flex items-center justify-between border border-neutral-100 shadow-inner">
                <span className="text-xs text-neutral-400 ml-2">Type your question...</span>
                <div className="w-7 h-7 rounded-full bg-[#0052cc] flex items-center justify-center text-white">
                  <Send className="w-3 h-3 text-white" />
                </div>
              </div>
            </div>

            {/* Display texts */}
            <div className="text-center space-y-3">
              <h2 className="text-2xl font-bold text-[#003d9b] tracking-tight">Consult AI Doctor</h2>
              <p className="text-sm leading-relaxed text-neutral-500">
                Ask questions about your reports and get instant, easy-to-understand explanations from our friendly health assistant.
              </p>
            </div>
          </div>
        )}
      </div>

      {/* Footer controls section with Pagination & Button */}
      <footer className="w-full max-w-sm mx-auto px-6 flex flex-col items-center gap-6 mt-4">
        {/* Progress pagination dots */}
        <div className="flex gap-2">
          {Array.from({ length: totalSlides }).map((_, idx) => (
            <div
              key={idx}
              className={`h-2 rounded-full transition-all duration-300 ${
                idx === currentSlide ? "w-8 bg-[#0052cc]" : "w-2 bg-neutral-200"
              }`}
            />
          ))}
        </div>

        {/* Action Button */}
        <button
          onClick={handleNext}
          className="w-full h-12 bg-[#0052cc] hover:bg-[#003d9b] text-white rounded-xl font-bold text-sm shadow-lg shadow-[#0052cc]/20 transition-transform active:scale-[0.98] flex items-center justify-center gap-2"
        >
          <span>{currentSlide === totalSlides - 1 ? "Get Started" : "Continue"}</span>
          {currentSlide < totalSlides - 1 && <ArrowRight className="w-4 h-4 text-white" />}
        </button>
      </footer>

      {/* Embedded scanning CSS keyframe */}
      <style>{`
        @keyframes scan {
          0% { top: 0; opacity: 0; }
          10% { opacity: 1; }
          90% { opacity: 1; }
          100% { top: 100%; opacity: 0; }
        }
        .animate-fadeIn {
          animation: fIn 0.4s ease-out;
        }
        @keyframes fIn {
          from { opacity: 0; transform: translateY(8px); }
          to { opacity: 1; transform: translateY(0); }
        }
      `}</style>
    </main>
  );
}

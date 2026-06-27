import { useState } from "react";
import { Search, Flame, ShieldAlert, Sparkles, FileText, Activity } from "lucide-react";

interface CategoriesViewProps {
  onScanClick: () => void;
}

const CATEGORIES = [
  {
    title: "Blood Tests",
    desc: "CBC, Sugar, Thyroid. Check infection, biological markers, and anemia levels.",
    icon: "bloodtype",
    color: "bg-[#0052cc]/10 text-[#0052cc]"
  },
  {
    title: "Urine Tests",
    desc: "Screening for metabolic disorders, kidney function, and urinary tract infections.",
    icon: "science",
    color: "bg-[#22c55e]/15 text-[#15803d]"
  },
  {
    title: "Imaging",
    desc: "X-Ray, MRI, and CT Scans for internal visual clinical diagnosis and body charting.",
    icon: "radiology",
    color: "bg-orange-50 text-orange-600"
  },
  {
    title: "Cardiac Tests",
    desc: "Electrocardiograms (ECG) and functional Stress Tests to monitor arterial rhythm.",
    icon: "ecg_heart",
    color: "bg-red-50 text-[#ef4444]"
  },
  {
    title: "Hormone Tests",
    desc: "Analyzing endorcrine health, insulin paths, thyroid balances, and metabolism.",
    icon: "vital_signs",
    color: "bg-purple-50 text-purple-600"
  },
  {
    title: "COVID-19",
    desc: "Rapid antigen checks and PCR tests for instant diagnostic viral screening.",
    icon: "coronavirus",
    color: "bg-teal-50 text-teal-600"
  }
];

export default function CategoriesView({ onScanClick }: CategoriesViewProps) {
  const [query, setQuery] = useState("");

  const filtered = CATEGORIES.filter(cat => 
    cat.title.toLowerCase().includes(query.toLowerCase()) || 
    cat.desc.toLowerCase().includes(query.toLowerCase())
  );

  return (
    <div className="w-full max-w-5xl mx-auto space-y-6 animate-fadeIn pb-12">
      {/* Title section */}
      <div>
        <h2 className="text-xl md:text-2xl font-extrabold text-[#003d9b] tracking-tight">
          Diagnostic Categories
        </h2>
        <p className="text-xs font-semibold text-neutral-400 mt-1 uppercase tracking-wider">
          Search and select a test category for AI-assisted analysis
        </p>
      </div>

      {/* Styled search panel */}
      <div className="relative">
        <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 w-5 h-5 text-neutral-400" />
        <input 
          type="text"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder="Search blood, cardiac, or MRI tests..."
          className="w-full h-12 pl-11 pr-4 bg-white border border-neutral-100 rounded-xl outline-none focus:ring-2 focus:ring-[#0052cc] text-sm text-neutral-800 transition-all font-medium shadow-sm"
        />
      </div>

      {/* Category Grid bento block layout */}
      <section className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {CATEGORIES.map((cat, idx) => {
          const isMatched = filtered.some(f => f.title === cat.title);
          return (
            <div 
              key={idx}
              className={`p-5 rounded-2xl border bg-white transition-all duration-300 shadow-sm flex flex-col justify-between gap-4 ${
                isMatched 
                  ? "opacity-100 scale-100 border-neutral-100 hover:border-neutral-250 cursor-pointer" 
                  : "opacity-40 scale-[0.98] border-neutral-100 pointer-events-none"
              }`}
            >
              <div className="flex gap-4">
                <div className={`w-12 h-12 rounded-xl flex items-center justify-center shrink-0 ${cat.color}`}>
                  <span className="material-symbols-outlined !text-2xl">{cat.icon}</span>
                </div>
                <div className="text-left">
                  <h3 className="text-sm font-extrabold text-neutral-900">{cat.title}</h3>
                  <p className="text-xs text-neutral-500 mt-1 leading-relaxed">{cat.desc}</p>
                </div>
              </div>
            </div>
          );
        })}
      </section>

      {/* Quick Prominent Scan Promo card */}
      <section className="bg-[#0052cc] text-white p-6 rounded-3xl relative overflow-hidden">
        <div className="absolute right-[-20px] top-[-25px] opacity-10">
          <Sparkles className="w-36 h-36 text-white" />
        </div>

        <div className="flex items-center gap-2 mb-3">
          <Sparkles className="w-4 h-4 text-[#6bff8f]" />
          <span className="text-[10px] font-bold uppercase tracking-wider text-[#6bff8f]">AI Powered Scan</span>
        </div>

        <h3 className="text-xl md:text-2xl font-bold leading-tight max-w-sm mb-2">
          Instant Result Decoding
        </h3>
        
        <p className="text-xs leading-relaxed text-white/95 max-w-sm mb-6">
          Upload any medical report to get a simplified clinical summary in seconds.
        </p>

        <button 
          onClick={onScanClick}
          className="bg-white text-[#0052cc] hover:bg-[#eceef0] h-11 px-6 rounded-full font-bold text-xs shadow-md transition-transform active:scale-95 flex items-center gap-1.5"
        >
          <span>Start Scan Now</span>
        </button>
      </section>
    </div>
  );
}

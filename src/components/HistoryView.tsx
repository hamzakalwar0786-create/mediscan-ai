import { useState } from "react";
import { Search, SlidersHorizontal, FileText, Calendar, ChevronRight, CheckCircle2, AlertOctagon, TrendingUp } from "lucide-react";
import { MedicalReport } from "../types";

interface HistoryViewProps {
  reports: MedicalReport[];
  onSelectReport: (report: MedicalReport) => void;
}

export default function HistoryView({ reports, onSelectReport }: HistoryViewProps) {
  const [query, setQuery] = useState("");

  const filtered = reports.filter(rep => 
    rep.title.toLowerCase().includes(query.toLowerCase()) || 
    rep.location.toLowerCase().includes(query.toLowerCase())
  );

  return (
    <div className="w-full max-w-5xl mx-auto space-y-6 animate-fadeIn pb-12">
      {/* Title Header */}
      <div>
        <h2 className="text-xl md:text-2xl font-extrabold text-[#003d9b] tracking-tight">Report History</h2>
        <p className="text-xs font-semibold text-neutral-400 mt-1 uppercase tracking-wider">Review and track your past medical diagnostic data</p>
      </div>

      {/* Search and filter bar log */}
      <div className="flex gap-3 select-none">
        <div className="relative flex-grow">
          <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-neutral-400" />
          <input 
            type="text"
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder="Search reports..."
            className="w-full h-11 pl-10 pr-4 bg-white border border-neutral-100 rounded-xl outline-none focus:ring-2 focus:ring-[#0052cc] text-sm text-neutral-800 transition-all font-medium shadow-sm"
          />
        </div>
        <button 
          onClick={() => alert("Sorting parameters activated.")}
          className="w-11 h-11 bg-white border border-neutral-100 rounded-xl flex items-center justify-center hover:bg-neutral-50 transition-colors shadow-sm"
        >
          <SlidersHorizontal className="w-4 h-4 text-[#0052cc]" />
        </button>
      </div>

      {/* History panel listings */}
      <div className="space-y-4">
        {filtered.map((report) => {
          const isAbnormal = report.status === "Abnormal";
          return (
            <div 
              key={report.id}
              onClick={() => onSelectReport(report)}
              className={`report-card bg-white p-4 rounded-xl shadow-sm border border-neutral-100 flex flex-col gap-2 hover:shadow-md cursor-pointer transition-all active:scale-[0.99] group ${
                isAbnormal ? "border-l-4 border-l-[#ef4444]" : ""
              }`}
            >
              <div className="flex justify-between items-start">
                <div className="text-left">
                  <p className="text-[10px] font-bold text-neutral-400 uppercase tracking-widest">{report.date}</p>
                  <h3 className="text-base font-extrabold text-neutral-900 mt-1 group-hover:text-[#0052cc] transition-colors">{report.title}</h3>
                </div>

                <span className={`px-2.5 py-1 rounded-full text-[10px] font-extrabold uppercase tracking-wide flex items-center gap-1 shrink-0 ${
                  isAbnormal 
                    ? "bg-red-50 text-[#ef4444]" 
                    : "bg-[#22c55e]/15 text-[#15803d]"
                }`}>
                  {isAbnormal ? (
                    <>
                      <AlertOctagon className="w-3.5 h-3.5 text-[#ef4444]" />
                      <span>Deficiencies Found</span>
                    </>
                  ) : (
                    <>
                      <CheckCircle2 className="w-3.5 h-3.5 text-[#22c55e]" />
                      <span>Stable Normal</span>
                    </>
                  )}
                </span>
              </div>

              <div className="flex items-center gap-2 text-neutral-400 mt-1 select-none">
                <span className="material-symbols-outlined !text-lg">biotech</span>
                <p className="text-xs font-semibold">{report.location}</p>
              </div>

              <div className="pt-3 mt-1 border-t border-neutral-100 flex justify-end">
                <button className="text-xs font-bold text-[#0052cc] flex items-center gap-0.5">
                  <span>View Details</span>
                  <ChevronRight className="w-4 h-4 shrink-0 transition-transform group-hover:translate-x-0.5" />
                </button>
              </div>
            </div>
          );
        })}

        {filtered.length === 0 && (
          <div className="p-8 text-center text-neutral-400 font-semibold text-xs border border-dashed rounded-xl">
            No diagnostic sessions matched your search.
          </div>
        )}
      </div>

      {/* Summary health trend section widget */}
      <section className="p-5 bg-gradient-to-r from-[#0052cc] to-[#003d9b] text-white rounded-2xl relative overflow-hidden">
        {/* Decorative ambient bubble */}
        <div className="absolute right-[-15px] bottom-[-20px] bg-white/5 w-28 h-28 rounded-full blur-2xl"></div>

        <div className="relative z-10 space-y-3">
          <div className="flex items-center gap-2">
            <TrendingUp className="w-5 h-5 text-[#4ae176]" />
            <h4 className="text-sm font-extrabold uppercase tracking-wider text-[#6bff8f]">Aggregate Health Progression</h4>
          </div>
          
          <p className="text-xs leading-relaxed text-white/95 max-w-lg">
            Based on your last parsed lipid profiles and CBC reports, your cholesterol levels indicate a 12% improvement toward the stable normal medical reference limits.
          </p>

          <div className="h-1.5 bg-white/20 rounded-full w-full overflow-hidden">
            <div className="h-full bg-[#6bff8f] w-4/5 rounded-full"></div>
          </div>
        </div>
      </section>

    </div>
  );
}

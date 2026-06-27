import { MedicalReport } from "../types";
import { Download, Bot, CheckCircle, HelpCircle, ArrowLeft, Heart, Sparkles, Plus, AlertCircle, ShoppingCart } from "lucide-react";

interface AnalysisViewProps {
  report: MedicalReport;
  onBack: () => void;
  onConsult: () => void;
}

export default function AnalysisView({ report, onBack, onConsult }: AnalysisViewProps) {
  // Safe helper to identify if parameter results can be plotted (convert as number string)
  const isAbnormalReport = report.status === "Abnormal";

  return (
    <div className="w-full max-w-5xl mx-auto space-y-6 animate-fadeIn pb-16">
      
      {/* Back button and profile header */}
      <button 
        onClick={onBack}
        className="inline-flex items-center gap-2 text-sm font-bold text-[#0052cc] hover:underline"
      >
        <ArrowLeft className="w-4 h-4" />
        <span>Back to Dashboard</span>
      </button>

      {/* Header Bio Info */}
      <section className="bg-white p-6 rounded-2xl border border-neutral-100 shadow-sm flex flex-col md:flex-row md:items-end justify-between gap-4">
        <div>
          <h2 className="text-2xl md:text-3xl font-extrabold text-[#003d9b] tracking-tight">John Doe</h2>
          <p className="text-xs font-semibold text-neutral-400 mt-1 flex items-center gap-1.5 uppercase tracking-wider">
            {report.date} • {report.title}
          </p>
        </div>
        
        {/* Actions side-by-side above parameters */}
        <div className="flex flex-wrap gap-2.5">
          <button 
            onClick={() => alert("Simulating high-quality clinic PDF download pipeline...")}
            className="h-11 px-5 rounded-xl border-2 border-[#0052cc] text-[#0052cc] hover:bg-[#0052cc]/5 text-xs font-bold flex items-center gap-2 transition-transform active:scale-95"
          >
            <Download className="w-4 h-4" />
            <span>Download PDF</span>
          </button>
          
          <button 
            onClick={onConsult}
            className="h-11 px-5 rounded-xl bg-[#0052cc] hover:bg-[#003d9b] text-white text-xs font-bold flex items-center gap-2 shadow-md shadow-[#0052cc]/10 transition-transform active:scale-95"
          >
            <Bot className="w-4 h-4 text-white" />
            <span>Consult AI Doctor</span>
          </button>
        </div>
      </section>

      {/* Main Parameters Table grid */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 items-start">
        
        {/* Left column: Parameters listing */}
        <div className="lg:col-span-2 space-y-6">
          <div className="bg-white rounded-2xl shadow-sm border border-neutral-100 overflow-hidden">
            <div className="px-6 py-4 border-b border-neutral-100 bg-neutral-50/50 flex justify-between items-center">
              <h3 className="text-sm font-bold text-[#003d9b] uppercase tracking-wider">Diagnostic Parameters</h3>
              <span className={`text-[10px] font-bold px-2 py-0.5 rounded-full uppercase ${
                isAbnormalReport ? "bg-red-50 text-[#ef4444]" : "bg-[#22c55e]/15 text-[#15803d]"
              }`}>
                {report.status} report
              </span>
            </div>

            <div className="overflow-x-auto">
              <table className="w-full text-left border-collapse">
                <thead>
                  <tr className="bg-neutral-50 text-neutral-400 border-b border-neutral-100">
                    <th className="px-6 py-3 text-xs font-semibold uppercase tracking-wider">Parameter</th>
                    <th className="px-6 py-3 text-xs font-semibold uppercase tracking-wider">Result</th>
                    <th className="px-6 py-3 text-xs font-semibold uppercase tracking-wider text-right md:text-left">Reference Range</th>
                    <th className="px-6 py-4 text-xs font-semibold uppercase tracking-wider text-center shrink-0">Evaluation</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-neutral-100">
                  {report.parameters.map((param, idx) => {
                    const isLowOrHigh = param.status === "LOW" || param.status === "HIGH" || param.status === "ABNORMAL";
                    return (
                      <tr 
                        key={idx} 
                        className={`hover:bg-neutral-50/40 transition-colors ${
                          isLowOrHigh ? "border-l-4 border-l-[#ef4444]" : "border-l-4 border-l-transparent"
                        }`}
                      >
                        <td className="px-6 py-4 font-semibold text-neutral-800 text-sm">{param.name}</td>
                        <td className={`px-6 py-4 text-base font-extrabold ${isLowOrHigh ? "text-[#ef4444]" : "text-[#22c55e]"}`}>
                          {param.result} <span className="text-xs font-medium text-neutral-400">{param.unit}</span>
                        </td>
                        <td className="px-6 py-4 text-xs font-medium text-neutral-500 text-right md:text-left">{param.referenceRange}</td>
                        <td className="px-6 py-4 text-center">
                          <span className={`inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-[10px] font-extrabold uppercase shrink-0 ${
                            isLowOrHigh 
                              ? "bg-red-50 text-[#ef4444]" 
                              : "bg-[#22c55e]/15 text-[#15803d]"
                          }`}>
                            {isLowOrHigh ? (
                              <>
                                <AlertCircle className="w-3 h-3 text-[#ef4444]" />
                                <span>{param.status}</span>
                              </>
                            ) : (
                              <>
                                <CheckCircle className="w-3 h-3 text-[#22c55e]" />
                                <span>NORMAL</span>
                              </>
                            )}
                          </span>
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>
          </div>

          {/* SVG Trends Bar Chart */}
          <div className="bg-white p-6 rounded-2xl border border-neutral-100 shadow-sm relative">
            <div className="flex justify-between items-start mb-6">
              <div>
                <h3 className="text-xs font-bold text-neutral-400 uppercase tracking-wider">Biological Parameters Trend</h3>
                <p className="text-xs text-neutral-500 mt-1">Comparison charts over last 6 months</p>
              </div>
              <span className="text-[10px] font-semibold text-neutral-500 bg-neutral-100 px-2.5 py-1 rounded-full uppercase">
                Last 6 months
              </span>
            </div>

            {/* Custom SVG/HTML Bar Chart for Hemoglobin/General Trend */}
            <div className="h-44 flex items-end justify-between gap-3 pt-6 border-b border-neutral-100 px-2">
              <div className="flex-1 flex flex-col justify-end items-center h-full group">
                <div className="w-full bg-[#0052cc]/10 hover:bg-[#0052cc]/25 transition-colors rounded-t-lg" style={{ height: '75%' }}></div>
                <span className="text-[10px] text-neutral-400 font-bold uppercase tracking-wider mt-2.5">MAY</span>
              </div>
              <div className="flex-1 flex flex-col justify-end items-center h-full group">
                <div className="w-full bg-[#0052cc]/10 hover:bg-[#0052cc]/25 transition-colors rounded-t-lg" style={{ height: '80%' }}></div>
                <span className="text-[10px] text-neutral-400 font-bold uppercase tracking-wider mt-2.5">JUN</span>
              </div>
              <div className="flex-1 flex flex-col justify-end items-center h-full group">
                <div className="w-full bg-[#0052cc]/10 hover:bg-[#0052cc]/25 transition-colors rounded-t-lg" style={{ height: '70%' }}></div>
                <span className="text-[10px] text-neutral-400 font-bold uppercase tracking-wider mt-2.5">JUL</span>
              </div>
              <div className="flex-1 flex flex-col justify-end items-center h-full group">
                <div className="w-full bg-[#0052cc]/10 hover:bg-[#0052cc]/25 transition-colors rounded-t-lg" style={{ height: '65%' }}></div>
                <span className="text-[10px] text-neutral-400 font-bold uppercase tracking-wider mt-2.5">AUG</span>
              </div>
              <div className="flex-1 flex flex-col justify-end items-center h-full group relative">
                {/* Visual red abnormal line threshold overlay */}
                <div className="absolute top-1/3 left-0 right-0 h-0.5 bg-[#ef4444]/40 z-0"></div>
                {/* Selected parameter (red bar highlight representing test outcome) */}
                <div className="w-full bg-[#ef4444] rounded-t-lg relative z-10" style={{ height: '52%' }}>
                  <div className="absolute -top-7 left-1/2 -translate-x-1/2 bg-[#ef4444] text-white text-[9px] font-bold px-2 py-0.5 rounded shadow-sm">
                    {report.parameters[0]?.result || "10.5"}
                  </div>
                </div>
                <span className="text-[10px] text-[#ef4444] font-extrabold uppercase tracking-wider mt-2.5">OCT</span>
              </div>
            </div>
            
            <p className="text-[11px] text-neutral-400 mt-4 text-center leading-normal">
              Red horizontal line represents the standard normal baseline diagnostic limits threshold (deficiencies indicated).
            </p>
          </div>
        </div>

        {/* Right column sidebar: AI Insights and Recommendations */}
        <aside className="space-y-6">
          
          {/* AI Insights panel card */}
          <div className="bg-[#0052cc] text-white rounded-2xl p-6 shadow-xl relative overflow-hidden">
            {/* Ambient background spark banner */}
            <div className="absolute right-[-20px] top-[-25px] opacity-10">
              <Sparkles className="w-36 h-36 text-white" />
            </div>

            <div className="flex items-center gap-2 mb-4">
              <Bot className="w-5 h-5 text-white" />
              <h3 className="text-base font-extrabold tracking-tight">AI Insights Summary</h3>
            </div>

            <p className="text-sm leading-relaxed text-white/90">
              {report.insights || "No insight details generated. Ask the health doctor inside clinic chat."}
            </p>

            {report.trendSummary && (
              <div className="mt-4 p-4 bg-white/10 rounded-xl border border-white/15 backdrop-blur-md">
                <p className="text-xs italic leading-relaxed text-white">
                  "{report.trendSummary}"
                </p>
              </div>
            )}
          </div>

          {/* Actionable Diet Clinical Recommendations list of targets */}
          <div className="bg-white p-6 rounded-2xl border border-neutral-100 shadow-sm space-y-5">
            <div className="flex items-center gap-2 text-[#0052cc]">
              <Sparkles className="w-5 h-5" />
              <h3 className="text-sm font-bold uppercase tracking-wider text-neutral-800">Recommendations</h3>
            </div>

            <ul className="space-y-4">
              {(report.recommendations || []).map((rec, idx) => (
                <li key={idx} className="flex gap-4">
                  <div className="w-9 h-9 rounded-xl bg-[#0052cc]/10 flex items-center justify-center shrink-0">
                    {/* Diagnostic check circles */}
                    <span className="text-xs font-bold text-[#0052cc]">{idx + 1}</span>
                  </div>
                  <div>
                    <p className="text-xs font-extrabold text-neutral-800 leading-tight">{rec.task}</p>
                    <p className="text-[11px] text-neutral-500 mt-0.5 leading-snug">{rec.detail}</p>
                  </div>
                </li>
              ))}
            </ul>

            <button 
              onClick={() => alert("Your recovery checklist and diet plan has been formatted and shared with your dashboard profile.")}
              className="w-full mt-4 py-2.5 rounded-lg border border-neutral-200 text-xs font-semibold text-neutral-500 hover:bg-neutral-50 transition-colors"
            >
              View Detailed Action Plan
            </button>
          </div>

          {/* Human Hematologist support verified action line banner */}
          <div className="rounded-2xl overflow-hidden shadow-md relative h-40 group select-none">
            {/* Placeholder healthcare laboratory illustration image */}
            <div className="absolute inset-0 bg-[#07090e]">
              {/* Fallback pattern representing high tech clinic */}
              <div className="w-full h-full bg-gradient-to-tr from-[#003d9b]/50 to-[#22c55e]/15 flex items-center justify-center">
                <Heart className="w-16 h-16 text-[#0052cc]/20 animate-pulse" />
              </div>
            </div>
            
            <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-black/40 to-transparent flex flex-col justify-end p-4">
              <span className="text-[10px] font-bold text-[#6bff8f] uppercase tracking-widest mb-1">Human Overlook</span>
              <p className="text-white text-xs font-extrabold leading-snug">
                Verify results with a certified hematology practitioner online 24/7.
              </p>
              <button 
                onClick={() => alert("Paging available clinic practitioner representatives...")}
                className="mt-2.5 text-[10px] font-bold uppercase tracking-wider text-[#6bff8f] flex items-center gap-1 group-hover:underline text-left"
              >
                <span>Connect Now</span>
                <span>→</span>
              </button>
            </div>
          </div>

        </aside>

      </div>
    </div>
  );
}

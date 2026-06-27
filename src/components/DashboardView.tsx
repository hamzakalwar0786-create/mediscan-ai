import { MedicalReport } from "../types";
import { CheckCircle, AlertTriangle, Calendar, Lightbulb, Bell, FileText, ChevronRight, Activity, ArrowRight } from "lucide-react";

interface DashboardViewProps {
  onScanClick: () => void;
  reports: MedicalReport[];
  onSelectReport: (report: MedicalReport) => void;
  onNavigateToTab: (tab: string) => void;
}

export default function DashboardView({ onScanClick, reports, onSelectReport, onNavigateToTab }: DashboardViewProps) {
  // Extract latest report for health overview
  const latestReport = reports[0] || null;
  const healthStatus = reports.some(r => r.status === "Abnormal") ? "Abnormal" : "Normal";

  return (
    <div className="w-full max-w-5xl mx-auto space-y-8 animate-fadeIn pb-12">
      {/* Greeting Section */}
      <section className="space-y-1">
        <h2 className="text-2xl md:text-3xl font-extrabold text-[#003d9b] tracking-tight">
          Good morning, John
        </h2>
        <p className="text-sm font-medium text-neutral-500">
          Your health metrics look <span className={`font-semibold ${healthStatus === "Normal" ? "text-[#22c55e]" : "text-[#ef4444]"}`}>{healthStatus.toLowerCase()}</span> today.
        </p>
      </section>

      {/* Prominent Scan Action Button Card */}
      <section>
        <button 
          onClick={onScanClick}
          className="group w-full bg-[#0052cc] hover:bg-[#003d9b] transition-all duration-300 rounded-3xl p-6 text-left flex flex-col items-center justify-center gap-4 text-white shadow-xl shadow-[#0052cc]/10 hover:shadow-[#0052cc]/20 relative overflow-hidden"
        >
          {/* Decorative scanner lines animation background */}
          <div className="absolute inset-0 bg-gradient-to-br from-white/10 to-transparent"></div>
          
          <div className="bg-white/20 p-4 rounded-full animate-pulse">
            <svg className="w-10 h-10 text-white" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
              <path strokeLinecap="round" strokeLinejoin="round" d="M3 9V6a2 2 0 0 1 2-2h3M16 4h3a2 2 0 0 1 2 2v3M21 15v3a2 2 0 0 1-2 2h-3M8 20H5a2 2 0 0 1-2-2v-3" />
              <line x1="6" y1="12" x2="18" y2="12" />
            </svg>
          </div>

          <div className="text-center z-10">
            <span className="text-xl md:text-2xl font-bold block mb-1">Scan New Report</span>
            <span className="text-xs font-bold text-white/80 uppercase tracking-widest leading-none bg-black/10 px-3 py-1 rounded-full">AI-Powered Diagnostics</span>
          </div>
        </button>
      </section>

      {/* Bento Grid Summary Card details */}
      <section className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        
        {/* Health Overview */}
        <div className="bg-white p-5 rounded-2xl border border-neutral-100 shadow-sm flex flex-col justify-between gap-4">
          <div className="flex items-center justify-between">
            <h3 className="text-xs font-bold text-neutral-400 uppercase tracking-wider">Health Overview</h3>
            {healthStatus === "Normal" ? (
              <CheckCircle className="w-5 h-5 text-[#22c55e]" />
            ) : (
              <AlertTriangle className="w-5 h-5 text-[#ef4444]" />
            )}
          </div>
          <div className="py-1">
            <div className="text-3xl font-extrabold text-neutral-900 tracking-tight">
              {healthStatus}
            </div>
            <p className="text-xs text-neutral-500 mt-1">
              Based on {reports.length} diagnostic scan sessions
            </p>
          </div>
          {/* Progress bar indicator */}
          <div className="h-1.5 w-full bg-neutral-100 rounded-full overflow-hidden">
            <div 
              className={`h-full rounded-full transition-all duration-500 ${healthStatus === "Normal" ? "bg-[#22c55e]" : "bg-[#ef4444]"}`}
              style={{ width: healthStatus === "Normal" ? "92%" : "45%" }}
            ></div>
          </div>
        </div>

        {/* Upcomming Appointments */}
        <div className="bg-white p-5 rounded-2xl border border-neutral-100 shadow-sm flex flex-col justify-between gap-4">
          <div className="flex items-center justify-between">
            <h3 className="text-xs font-bold text-neutral-400 uppercase tracking-wider">Next Appointment</h3>
            <Calendar className="w-5 h-5 text-[#0052cc]" />
          </div>
          <div className="py-1 space-y-0.5">
            <p className="text-lg font-bold text-neutral-950">Dr. Sarah Chen</p>
            <p className="text-xs font-medium text-neutral-500">
              Cardiology Review • Tomorrow, 10:30 AM
            </p>
          </div>
          <button 
            onClick={() => onNavigateToTab("chat")}
            className="text-xs font-bold text-[#0052cc] flex items-center gap-1.5 hover:underline"
          >
            <span>Ask health question</span>
            <ArrowRight className="w-3.5 h-3.5" />
          </button>
        </div>

        {/* Daily Clinican Tip */}
        <div className="bg-[#0052cc]/5 p-5 rounded-2xl border border-[#0052cc]/10 shadow-sm flex flex-col justify-between gap-4 md:col-span-2 lg:col-span-1">
          <div className="flex items-center justify-between">
            <h3 className="text-xs font-bold text-[#0052cc] uppercase tracking-wider">Daily Insight</h3>
            <Lightbulb className="w-5 h-5 text-[#0052cc] fill-[#0052cc]/10" />
          </div>
          <div className="py-1">
            <p className="text-sm font-medium text-neutral-600 italic leading-relaxed">
              "Increasing raw iron and Vitamin C intake by 25% today can significantly strengthen the haemoglobin carrying structures scanned in your blood profiles."
            </p>
          </div>
          <div className="text-[10px] text-neutral-400 font-bold uppercase tracking-widest">
            Nutritional AI Companion
          </div>
        </div>

      </section>

      {/* Recent report lists */}
      <section className="space-y-4">
        <div className="flex justify-between items-center">
          <h3 className="text-lg font-extrabold text-[#003d9b] tracking-tight">Recent Scan Reports</h3>
          <button 
            onClick={() => onNavigateToTab("history")}
            className="text-xs font-bold text-[#0052cc] hover:underline"
          >
            See All
          </button>
        </div>

        <div className="space-y-3">
          {reports.map((report) => (
            <div 
              key={report.id}
              onClick={() => onSelectReport(report)}
              className="bg-white p-4 rounded-xl border border-neutral-100 flex items-center justify-between gap-4 hover:shadow-md cursor-pointer transition-all active:scale-[0.99] hover:border-neutral-200 group"
            >
              <div className="flex items-center gap-4">
                {/* Visual Icon category depending on type */}
                <div className={`w-11 h-11 rounded-xl flex items-center justify-center transition-colors ${
                  report.status === "Abnormal" 
                    ? "bg-red-50 text-[#ef4444]" 
                    : "bg-neutral-50 text-[#0052cc]"
                }`}>
                  <FileText className="w-5 h-5" />
                </div>
                <div className="text-left">
                  <h4 className="font-bold text-sm text-neutral-900 group-hover:text-[#0052cc] transition-colors">{report.title}</h4>
                  <p className="text-xs text-neutral-400 mt-0.5">Uploaded: {report.date} • {report.location}</p>
                </div>
              </div>

              {/* Status Badge */}
              <div className="flex items-center gap-3">
                <span className={`px-2.5 py-1 rounded-full text-xs font-bold tracking-wide uppercase ${
                  report.status === "Normal" 
                    ? "bg-[#6bff8f]/20 text-[#007432]" 
                    : "bg-red-50 text-[#ef4444]"
                }`}>
                  {report.status}
                </span>
                <ChevronRight className="w-4 h-4 text-neutral-400 group-hover:translate-x-0.5 transition-transform" />
              </div>
            </div>
          ))}
        </div>
      </section>
    </div>
  );
}

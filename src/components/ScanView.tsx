import React, { useState, useRef } from "react";
import { X, Camera, UploadCloud, FileText, AlertCircle, Zap, ZapOff } from "lucide-react";
import { MedicalReport } from "../types";

interface ScanViewProps {
  onClose: () => void;
  onScanCompleted: (report: MedicalReport) => void;
}

export default function ScanView({ onClose, onScanCompleted }: ScanViewProps) {
  const [dragActive, setDragActive] = useState(false);
  const [processing, setProcessing] = useState(false);
  const [statusMsg, setStatusMsg] = useState("Reading clinical documents...");
  const [errorMsg, setErrorMsg] = useState("");
  const [flash, setFlash] = useState(true);

  const fileInputRef = useRef<HTMLInputElement>(null);
  const cameraInputRef = useRef<HTMLInputElement>(null);

  const toBase64 = (file: File) =>
    new Promise<string>((resolve, reject) => {
      const reader = new FileReader();
      reader.readAsDataURL(file);
      reader.onload = () => resolve(reader.result as string);
      reader.onerror = (err) => reject(err);
    });

  const startAnalysis = async (file: File) => {
    setProcessing(true);
    setErrorMsg("");
    setStatusMsg("Reading clinical documents...");
    try {
      const base64Img = await toBase64(file);
      setStatusMsg("Correlating parameters with Gemini AI...");
      const response = await fetch("/api/analyze-report", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ image: base64Img, fileName: file.name }),
      });
      if (!response.ok) throw new Error("Server error during analysis.");
      const data = await response.json();
      if (data.success && data.report) {
        setStatusMsg("Decoding complete!");
        setTimeout(() => onScanCompleted(data.report), 900);
      } else {
        throw new Error(data.error || "Failed to read report.");
      }
    } catch (e: any) {
      setErrorMsg(e.message || "Analysis failed. Try a clearer image.");
      setProcessing(false);
    }
  };

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files?.[0]) startAnalysis(e.target.files[0]);
  };

  const handleDrag = (e: React.DragEvent) => {
    e.preventDefault();
    e.stopPropagation();
    setDragActive(e.type === "dragenter" || e.type === "dragover");
  };

  const handleDrop = (e: React.DragEvent) => {
    e.preventDefault();
    e.stopPropagation();
    setDragActive(false);
    if (e.dataTransfer.files?.[0]) startAnalysis(e.dataTransfer.files[0]);
  };

  const handleSimulate = async (index: number) => {
    setProcessing(true);
    setErrorMsg("");
    setStatusMsg("Loading demo scan...");
    try {
      const names = ["cbc_blood.png", "lipid_panel.pdf", "vitamin_deficient.jpg"];
      const response = await fetch("/api/analyze-report", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ fileName: names[index] }),
      });
      const data = await response.json();
      if (data.success && data.report) {
        setStatusMsg("Done!");
        setTimeout(() => onScanCompleted(data.report), 800);
      } else {
        throw new Error("Demo scan failed.");
      }
    } catch (e: any) {
      setErrorMsg(e.message);
      setProcessing(false);
    }
  };

  return (
    <div className="fixed inset-0 z-50 bg-[#07090e] text-white flex flex-col overflow-y-auto">

      {/* ── Header ── */}
      <header className="sticky top-0 z-30 flex justify-between items-center h-16 px-5 bg-black/60 backdrop-blur-md border-b border-white/10">
        <button
          onClick={onClose}
          className="w-10 h-10 flex items-center justify-center rounded-full hover:bg-white/10 transition-all"
        >
          <X className="w-5 h-5" />
        </button>
        <div className="text-center">
          <p className="text-sm font-bold tracking-wide">Scan Medical Report</p>
          <p className="text-[9px] text-white/40 font-bold tracking-[2px] uppercase">MediScan AI</p>
        </div>
        <button
          onClick={() => setFlash(!flash)}
          className={`w-10 h-10 flex items-center justify-center rounded-full hover:bg-white/10 transition-all ${flash ? "text-yellow-400" : "text-white/40"}`}
        >
          {flash ? <Zap className="w-4 h-4 fill-yellow-400" /> : <ZapOff className="w-4 h-4" />}
        </button>
      </header>

      <div className="flex flex-col items-center gap-5 px-5 py-6 w-full max-w-sm mx-auto">

        {/* ── PRIMARY ACTIONS — TOP, ALWAYS VISIBLE ── */}
        <div className="w-full grid grid-cols-2 gap-3">

          {/* SCAN with Camera */}
          <button
            onClick={() => cameraInputRef.current?.click()}
            className="flex flex-col items-center justify-center gap-2.5 py-5 px-4 rounded-2xl bg-[#0052cc] hover:bg-[#003d9b] active:scale-95 transition-all shadow-lg shadow-[#0052cc]/30"
          >
            <div className="w-12 h-12 rounded-full bg-white/20 flex items-center justify-center">
              <Camera className="w-6 h-6 text-white" />
            </div>
            <div className="text-center">
              <p className="text-sm font-bold text-white leading-tight">Scan Report</p>
              <p className="text-[10px] text-white/60 mt-0.5">Use Camera</p>
            </div>
          </button>
          <input
            type="file"
            ref={cameraInputRef}
            onChange={handleFileChange}
            accept="image/*"
            capture="environment"
            className="hidden"
          />

          {/* UPLOAD from Gallery */}
          <button
            onClick={() => fileInputRef.current?.click()}
            className="flex flex-col items-center justify-center gap-2.5 py-5 px-4 rounded-2xl bg-[#059669] hover:bg-[#047857] active:scale-95 transition-all shadow-lg shadow-[#059669]/30"
          >
            <div className="w-12 h-12 rounded-full bg-white/20 flex items-center justify-center">
              <UploadCloud className="w-6 h-6 text-white" />
            </div>
            <div className="text-center">
              <p className="text-sm font-bold text-white leading-tight">Upload Image</p>
              <p className="text-[10px] text-white/60 mt-0.5">From Gallery</p>
            </div>
          </button>
          <input
            type="file"
            ref={fileInputRef}
            onChange={handleFileChange}
            accept="image/*,application/pdf"
            className="hidden"
          />
        </div>

        {/* ── Drag & Drop zone ── */}
        <div
          onDragEnter={handleDrag}
          onDragOver={handleDrag}
          onDragLeave={handleDrag}
          onDrop={handleDrop}
          onClick={() => fileInputRef.current?.click()}
          className={`w-full cursor-pointer border-2 border-dashed rounded-2xl py-5 flex flex-col items-center gap-1.5 transition-all ${
            dragActive
              ? "border-[#0052cc] bg-[#0052cc]/15"
              : "border-white/15 bg-white/5 hover:bg-white/10 hover:border-white/30"
          }`}
        >
          <UploadCloud className="w-7 h-7 text-neutral-400" />
          <p className="text-xs font-bold text-neutral-300 uppercase tracking-wider">
            Drag &amp; Drop Report Here
          </p>
          <p className="text-[10px] text-neutral-500">PNG · JPG · PDF supported</p>
        </div>

        {/* ── Scanner frame ── */}
        <div className="w-full aspect-[4/3] relative rounded-2xl overflow-hidden border border-dashed border-[#0052cc]/50">
          {/* Animated laser line */}
          <div className="absolute left-0 right-0 h-[2px] bg-cyan-400 shadow-[0_0_12px_#22d3ee] z-10 animate-[scannerSwipe_3s_infinite_ease-in-out]" />

          {/* Corner marks */}
          <div className="absolute top-3 left-3 w-5 h-5 border-t-[3px] border-l-[3px] border-white rounded-tl" />
          <div className="absolute top-3 right-3 w-5 h-5 border-t-[3px] border-r-[3px] border-white rounded-tr" />
          <div className="absolute bottom-3 left-3 w-5 h-5 border-b-[3px] border-l-[3px] border-white rounded-bl" />
          <div className="absolute bottom-3 right-3 w-5 h-5 border-b-[3px] border-r-[3px] border-white rounded-br" />

          {/* BG */}
          <div className="absolute inset-0 bg-neutral-950 flex items-center justify-center">
            <FileText className="w-16 h-16 text-neutral-800/40" />
          </div>

          {/* Label */}
          <div className="absolute bottom-4 left-4 right-4 text-center z-10">
            <span className="text-[10px] font-semibold text-white bg-black/60 px-3 py-1 rounded-full">
              Align medical document within frame
            </span>
          </div>
        </div>

        {/* ── Quick demo scans ── */}
        <div className="w-full">
          <p className="text-[9px] font-bold text-[#0052cc] uppercase tracking-[2px] text-center mb-2.5">
            Quick Demo Scans
          </p>
          <div className="grid grid-cols-3 gap-2">
            {["CBC Blood", "Lipid Panel", "Vitamin D"].map((label, i) => (
              <button
                key={i}
                onClick={() => handleSimulate(i)}
                className="py-2.5 rounded-xl text-[10px] font-bold bg-white/5 hover:bg-[#0052cc]/30 border border-white/10 text-neutral-300 transition-all active:scale-95"
              >
                {label}
              </button>
            ))}
          </div>
        </div>

        {/* ── Error message ── */}
        {errorMsg && (
          <div className="w-full p-3 bg-red-950/40 border border-red-900/50 rounded-xl flex items-start gap-2 text-xs">
            <AlertCircle className="w-4 h-4 shrink-0 text-red-400 mt-0.5" />
            <span className="text-red-400 leading-snug">{errorMsg}</span>
          </div>
        )}

        <div className="h-6" />
      </div>

      {/* ── Processing overlay ── */}
      {processing && (
        <div className="fixed inset-0 z-50 bg-[#07090e]/95 backdrop-blur-xl flex flex-col items-center justify-center p-8 text-center">
          <div className="relative w-36 h-36 mb-8">
            <div className="absolute inset-0 border-4 border-[#0052cc]/10 rounded-full" />
            <div className="absolute inset-0 border-4 border-[#0052cc] border-t-transparent rounded-full animate-spin" />
            <div className="absolute inset-0 flex items-center justify-center">
              <svg className="w-14 h-14 text-[#0052cc] fill-none stroke-2 animate-pulse" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" d="M19.5 14.25v-2.625a3.375 3.375 0 0 0-3.375-3.375h-1.5A1.125 1.125 0 0 1 13.5 7.125v-1.5a3.375 3.375 0 0 0-3.375-3.375H8.25m6.75 12H9m1.5-12H5.625c-.621 0-1.125.504-1.125 1.125v17.25c0 .621.504 1.125 1.125 1.125h12.75c.621 0 1.125-.504 1.125-1.125V11.25a9 9 0 0 0-9-9Z" />
              </svg>
            </div>
          </div>
          <h2 className="text-2xl font-bold text-white mb-2">Analyzing Report...</h2>
          <p className="text-sm text-neutral-400 max-w-xs leading-relaxed">{statusMsg}</p>
          <div className="flex gap-2 mt-8 items-center">
            <span className="w-3 h-3 bg-[#0052cc] rounded-full animate-ping" />
            <span className="text-[10px] font-bold text-neutral-500 tracking-[2px] uppercase">AI Decoders Active</span>
          </div>
        </div>
      )}

      <style>{`
        @keyframes scannerSwipe {
          0%   { top: 4%; }
          50%  { top: 92%; }
          100% { top: 4%; }
        }
      `}</style>
    </div>
  );
}

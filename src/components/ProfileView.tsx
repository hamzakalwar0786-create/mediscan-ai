import { useState } from "react";
import { User, FolderHeart, ShieldCheck, Moon, Globe, HelpCircle, LogOut, Edit, HelpCircle as HelpIcon } from "lucide-react";

interface ProfileViewProps {
  onLogout: () => void;
  darkMode: boolean;
  onToggleDarkMode: () => void;
}

export default function ProfileView({ onLogout, darkMode, onToggleDarkMode }: ProfileViewProps) {
  const [userName, setUserName] = useState("Dr. Sarah Mitchell");
  const [bloodType, setBloodType] = useState("O Positive (O+)");

  const [personalInfoOpen, setPersonalInfoActive] = useState(false);

  return (
    <div className="w-full max-w-2xl mx-auto space-y-6 animate-fadeIn pb-16">
      
      {/* Profile Avatar Header Section */}
      <section className="flex flex-col items-center select-none text-center bg-white p-6 rounded-2xl border border-neutral-100 shadow-sm relative">
        <div className="relative mb-4 group">
          {/* Main User Avatar */}
          <div className="w-24 h-24 rounded-full overflow-hidden border-4 border-neutral-100 shadow-sm bg-neutral-100">
            <img 
              alt="Dr. Sarah Mitchell Avatar" 
              className="w-full h-full object-cover"
              src="https://lh3.googleusercontent.com/aida-public/AB6AXuDA-go2n7N_c0kYxmhJ7PH3JzPpOtXvMURkzRfIDYQXrBsFC1KXEPHk3CMyDQpepOKHwebgudmsAuAAVBCp-dsn2SheNGHcvHQXb6W0EcaTqiCzvzh6Ld6YHJUnI9sL0Ufryi0DJogEUugfDBtYN1nMC6Wc1JjJgbROQl7FYDGpziy2isL1l2c3QMHEExJ_RNPZJzX8FBt2xhe3VXXhFuNa-zWDKIezgMtLFEcJfdJOLlMBU3Pwzhg-fIXqTsESjm758c8MAfzbXNwG"
            />
          </div>
          {/* Edit icon circle */}
          <button 
            onClick={() => {
              const newName = prompt("Enter your custom name:", userName);
              if (newName && newName.trim() !== "") setUserName(newName);
            }}
            className="absolute bottom-0 right-0 bg-[#0052cc] p-2 rounded-full text-white shadow-lg border-2 border-white hover:scale-105 active:scale-95 transition-transform"
          >
            <Edit className="w-3.5 h-3.5 text-white" />
          </button>
        </div>

        {/* Dynamic Name */}
        <h2 className="text-xl font-extrabold text-neutral-800">{userName}</h2>
        
        {/* Blood group indicator banner */}
        <button 
          onClick={() => {
            const bt = prompt("Update your blood group:", bloodType);
            if (bt && bt.trim() !== "") setBloodType(bt);
          }}
          className="inline-flex items-center gap-1 bg-red-50 text-[#ef4444] px-3 py-1 rounded-full text-xs font-bold mt-2.5"
        >
          <span className="material-symbols-outlined !text-sm">bloodtype</span>
          <span>{bloodType}</span>
        </button>
      </section>

      {/* Menu Options lists */}
      <div className="space-y-4">
        
        {/* Category Panel 1: Profile Info */}
        <div className="bg-white rounded-2xl shadow-sm border border-neutral-100 overflow-hidden flex flex-col">
          {/* Personal Info */}
          <button 
            onClick={() => setPersonalInfoActive(!personalInfoOpen)}
            className="w-full flex items-center justify-between p-4 hover:bg-neutral-50 transition-colors text-left"
          >
            <div className="flex items-center gap-4">
              <div className="w-10 h-10 rounded-xl bg-[#0052cc]/10 flex items-center justify-center text-[#0052cc]">
                <User className="w-5 h-5" />
              </div>
              <span className="text-sm font-bold text-slate-800">Personal Information</span>
            </div>
            <span className="material-symbols-outlined text-neutral-400">chevron_right</span>
          </button>

          {personalInfoOpen && (
            <div className="p-4 bg-neutral-50/50 border-t border-neutral-100 text-left text-xs font-medium space-y-2 text-neutral-600">
              <p>Email Address: <span className="font-semibold text-neutral-800">john.doe@wellness.com</span></p>
              <p>Status: <span className="font-semibold text-neutral-800">Verified Health Patient</span></p>
              <p>Location: <span className="font-semibold text-neutral-800">San Francisco, CA</span></p>
            </div>
          )}

          <div className="h-px bg-neutral-100 mx-4"></div>

          {/* Health records directory */}
          <button 
            onClick={() => alert("Loading clinic cloud directories...")}
            className="w-full flex items-center justify-between p-4 hover:bg-neutral-50 transition-colors text-left"
          >
            <div className="flex items-center gap-4">
              <div className="w-10 h-10 rounded-xl bg-green-50 flex items-center justify-center text-green-600">
                <FolderHeart className="w-5 h-5" />
              </div>
              <span className="text-sm font-bold text-slate-800">Health Records</span>
            </div>
            <span className="material-symbols-outlined text-neutral-400">chevron_right</span>
          </button>

          <div className="h-px bg-neutral-100 mx-4"></div>

          {/* Insurance overview */}
          <button 
            onClick={() => alert("Validating insurance ledger context...")}
            className="w-full flex items-center justify-between p-4 hover:bg-neutral-50 transition-colors text-left"
          >
            <div className="flex items-center gap-4">
              <div className="w-10 h-10 rounded-xl bg-orange-50 flex items-center justify-center text-orange-600">
                <ShieldCheck className="w-5 h-5" />
              </div>
              <span className="text-sm font-bold text-slate-800">Insurance Details</span>
            </div>
            <span className="material-symbols-outlined text-neutral-400">chevron_right</span>
          </button>
        </div>

        {/* Category Panel 2: Preferences */}
        <div className="bg-white rounded-2xl shadow-sm border border-neutral-100 overflow-hidden flex flex-col">
          {/* Dark Mode switcher */}
          <div className="w-full flex items-center justify-between p-4 text-left">
            <div className="flex items-center gap-4">
              <div className="w-10 h-10 rounded-xl bg-neutral-100 flex items-center justify-center text-neutral-600">
                <Moon className="w-5 h-5" />
              </div>
              <span className="text-sm font-bold text-slate-800">Dark Mode</span>
            </div>
            {/* Toggle switch */}
            <button 
              onClick={onToggleDarkMode}
              className={`w-11 h-6 rounded-full p-1 transition-all ${
                darkMode ? "bg-slate-800" : "bg-neutral-200"
              }`}
            >
              <div className={`w-4 h-4 bg-white rounded-full transition-all shadow-sm ${
                darkMode ? "translate-x-5" : "translate-x-0"
              }`}></div>
            </button>
          </div>

          <div className="h-px bg-neutral-100 mx-4"></div>

          {/* Language setup */}
          <button 
            onClick={() => {
              const lang = prompt("Set language choice (e.g. English, Urdu, Hindi):", "English");
              if (lang) alert(`Aesthetic language is set to ${lang}`);
            }}
            className="w-full flex items-center justify-between p-4 hover:bg-neutral-50 transition-colors text-left"
          >
            <div className="flex items-center gap-4">
              <div className="w-10 h-10 rounded-xl bg-neutral-100 flex items-center justify-center text-neutral-600">
                <Globe className="w-5 h-5" />
              </div>
              <div className="flex flex-col text-left">
                <span className="text-sm font-bold text-slate-800 leading-none">Language</span>
                <span className="text-[10px] text-neutral-400 font-bold mt-1">English / Urdu / Hindi support</span>
              </div>
            </div>
            <span className="material-symbols-outlined text-neutral-400">chevron_right</span>
          </button>
        </div>

        {/* Category Panel 3: Support desk */}
        <div className="bg-white rounded-2xl shadow-sm border border-neutral-100 overflow-hidden flex flex-col">
          <button 
            onClick={() => alert("MediScan AI Knowledge Base & Support line is online.")}
            className="w-full flex items-center justify-between p-4 hover:bg-neutral-50 transition-colors text-left"
          >
            <div className="flex items-center gap-4">
              <div className="w-10 h-10 rounded-xl bg-[#0052cc]/10 flex items-center justify-center text-[#0052cc]">
                <HelpCircle className="w-5 h-5" />
              </div>
              <span className="text-sm font-bold text-slate-800">Help & Support</span>
            </div>
            <span className="material-symbols-outlined text-neutral-400">chevron_right</span>
          </button>
        </div>

        {/* Signout button */}
        <button 
          onClick={onLogout}
          className="w-full bg-red-50 hover:bg-red-100/60 p-4 rounded-xl border border-red-100 text-[#ef4444] font-bold text-sm transition-colors flex items-center justify-center gap-2 active:scale-[0.98]"
        >
          <LogOut className="w-4 h-4 text-[#ef4444]" />
          <span>Logout</span>
        </button>

      </div>
    </div>
  );
}

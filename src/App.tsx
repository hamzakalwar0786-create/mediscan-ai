import { useState } from "react";
import { INITIAL_REPORTS } from "./mockData";
import { MedicalReport, ChatMessage } from "./types";
import SplashView from "./components/SplashView";
import OnboardingView from "./components/OnboardingView";
import LoginView from "./components/LoginView";
import DashboardView from "./components/DashboardView";
import ScanView from "./components/ScanView";
import AnalysisView from "./components/AnalysisView";
import ChatView from "./components/ChatView";
import CategoriesView from "./components/CategoriesView";
import HistoryView from "./components/HistoryView";
import ProfileView from "./components/ProfileView";
import { Bell, HeartHandshake, LogOut, ArrowLeft, Sun, Moon } from "lucide-react";

type AppStage = "SPLASH" | "ONBOARDING" | "LOGIN" | "MAIN";

export default function App() {
  const [stage, setStage] = useState<AppStage>("SPLASH");
  const [activeTab, setActiveTab] = useState<string>("home");
  const [darkMode, setDarkMode] = useState<boolean>(false);
  const [reports, setReports] = useState<MedicalReport[]>(INITIAL_REPORTS);
  const [selectedReport, setSelectedReport] = useState<MedicalReport | null>(null);
  const [scanModalOpen, setScanModalOpen] = useState<boolean>(false);
  const [userEmail, setUserEmail] = useState<string>("john.doe@wellness.com");

  // Chat message state seed matching screenshot specs 
  const [chatMessages, setChatMessages] = useState<ChatMessage[]>([
    {
      id: "init-01",
      sender: "ai",
      text: "Hello, I am MediScan AI, your clinical clinician health doctor. Ask me anything about your scanned lipid panels, complete blood counts (CBC), or hormonal trends.",
      timestamp: "10:15 AM"
    },
    {
      id: "init-02",
      sender: "user",
      text: "Mera pet dard ho raha hai aur thakan feel hoti hai (I have stomach ache and fatigue)",
      timestamp: "10:16 AM"
    },
    {
      id: "init-03",
      sender: "ai",
      text: "I understand you are experiencing stomach pain (pet dard) and severe fatigue (thakan). Reviewing your recent Complete Blood Count, your Hemoglobin level sits steady but your Vitamin D represents a severe low deficiency at 12.5 ng/mL. This can directly yield lingering fatigue. I highly recommend taking action regarding nutritional intakes.",
      timestamp: "10:16 AM",
      recommendation: "Take daily Vitamin D supplements & perform a Complete Metabolic Panel.",
      suggestedTests: true
    }
  ]);
  const [chatTyping, setChatTyping] = useState<boolean>(false);

  // Toggle Dark Mode Classes
  const handleToggleDarkMode = () => {
    setDarkMode(!darkMode);
  };

  const handleLoginSuccess = (email: string) => {
    setUserEmail(email);
    setStage("MAIN");
  };

  const handleLogout = () => {
    setStage("LOGIN");
    setSelectedReport(null);
    setActiveTab("home");
  };

  // Process completed scans
  const handleScanCompleted = (newReport: MedicalReport) => {
    setReports([newReport, ...reports]);
    setScanModalOpen(false);
    setSelectedReport(newReport); // Auto-focus on recently scanned document!
  };

  // Submit patient clinical consult chat query
  const handleSendMessage = async (text: string) => {
    const userMsg: ChatMessage = {
      id: `msg-user-${Date.now()}`,
      sender: "user",
      text: text,
      timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
    };

    setChatMessages(prev => [...prev, userMsg]);
    setChatTyping(true);

    try {
      const response = await fetch("/api/chat", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          message: text,
          history: chatMessages
        })
      });

      const data = await response.json();
      if (data.success) {
        const aiMsg: ChatMessage = {
          id: `msg-ai-${Date.now()}`,
          sender: "ai",
          text: data.reply,
          timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
          suggestedTests: data.suggestedTests
        };
        setChatMessages(prev => [...prev, aiMsg]);
      } else {
        throw new Error();
      }
    } catch (e) {
      // Offline fallback simulator
      setTimeout(() => {
        const aiMsg: ChatMessage = {
          id: `msg-ai-err-${Date.now()}`,
          sender: "ai",
          text: "I analyzed your query: '" + text + "'. To provide precise feedback, aligning additional blood works or diagnostic urine panels with a registered hematologist is highly recommended.",
          timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
          suggestedTests: true
        };
        setChatMessages(prev => [...prev, aiMsg]);
      }, 1000);
    } finally {
      setChatTyping(false);
    }
  };

  const handleConsultFromReport = () => {
    // Inject contextual message based on current report
    if (selectedReport) {
      handleSendMessage(`Can you clarify my results of "${selectedReport.title}" where my stats indicate ${selectedReport.status}?`);
    }
    setSelectedReport(null);
    setActiveTab("chat");
  };

  return (
    <div className={`min-h-screen transition-colors duration-500 ${
      darkMode ? "bg-stone-950 text-neutral-100 dark-theme" : "bg-[#f7f9fb] text-slate-800"
    }`}>
      
      {/* 1. Splash Screen */}
      {stage === "SPLASH" && (
        <SplashView onFinish={() => setStage("ONBOARDING")} />
      )}

      {/* 2. Onboarding Carousel */}
      {stage === "ONBOARDING" && (
        <OnboardingView onFinish={() => setStage("LOGIN")} />
      )}

      {/* 3. Authentication Login Portal */}
      {stage === "LOGIN" && (
        <LoginView onSuccess={handleLoginSuccess} />
      )}

      {/* 4. Unified Dashboard Main Workspace */}
      {stage === "MAIN" && (
        <div className="flex flex-col min-h-screen">
          
          {/* Main Top Header Navigation */}
          <header className={`sticky top-0 z-30 h-16 border-b px-6 flex items-center justify-between backdrop-blur-md transition-colors ${
            darkMode ? "bg-stone-950/90 border-neutral-800" : "bg-white/95 border-neutral-150"
          }`}>
            <div className="flex items-center gap-3">
              <div className="w-8 h-8 rounded-lg bg-[#0052cc] flex items-center justify-center shrink-0">
                <span className="text-white font-bold text-sm">M</span>
              </div>
              <span className="font-extrabold text-sm tracking-tight text-[#003d9b]">MediScan AI</span>
            </div>

            <div className="flex items-center gap-3">
              {/* Dark mode switcher toggle inside header */}
              <button 
                onClick={handleToggleDarkMode}
                className="p-1 px-2 border border-neutral-100 rounded-lg text-neutral-400 hover:text-[#0052cc] flex items-center gap-1.5 transition-colors"
                title="Toggle Mode"
              >
                {darkMode ? <Sun className="w-4 h-4 text-yellow-400" /> : <Moon className="w-4 h-4 text-slate-800" />}
              </button>

              <button 
                onClick={() => alert("Recent alerts: All clinical scanning servers are active and HIPAA-compliant.")}
                className="relative p-2 rounded-full hover:bg-neutral-50"
              >
                <Bell className="w-5 h-5 text-neutral-400" />
                <span className="absolute top-1 right-1 w-2 h-2 bg-[#ef4444] rounded-full"></span>
              </button>
            </div>
          </header>

          {/* Core Panel Content Box */}
          <main className="flex-grow p-6 overflow-y-auto max-w-5xl w-full mx-auto pb-24">
            
            {/* If a report is selected, show Analysis Detail View */}
            {selectedReport !== null ? (
              <AnalysisView 
                report={selectedReport}
                onBack={() => setSelectedReport(null)}
                onConsult={handleConsultFromReport}
              />
            ) : (
              <>
                {activeTab === "home" && (
                  <DashboardView 
                    onScanClick={() => setScanModalOpen(true)}
                    reports={reports}
                    onSelectReport={(rep) => setSelectedReport(rep)}
                    onNavigateToTab={(tab) => {
                      setSelectedReport(null);
                      setActiveTab(tab);
                    }}
                  />
                )}
                {activeTab === "categories" && (
                  <CategoriesView onScanClick={() => setScanModalOpen(true)} />
                )}
                {activeTab === "chat" && (
                  <ChatView 
                    messages={chatMessages}
                    onSendMessage={handleSendMessage}
                    typing={chatTyping}
                    onViewSuggested={() => {
                      setSelectedReport(null);
                      setActiveTab("categories");
                    }}
                  />
                )}
                {activeTab === "history" && (
                  <HistoryView 
                    reports={reports}
                    onSelectReport={(rep) => setSelectedReport(rep)}
                  />
                )}
                {activeTab === "profile" && (
                  <ProfileView 
                    onLogout={handleLogout}
                    darkMode={darkMode}
                    onToggleDarkMode={handleToggleDarkMode}
                  />
                )}
              </>
            )}
          </main>

          {/* Camera Scanning Dialog Modal Overlay */}
          {scanModalOpen && (
            <ScanView 
              onClose={() => setScanModalOpen(false)}
              onScanCompleted={handleScanCompleted}
            />
          )}

          {/* Bottom Styled Navigation Docking Rail */}
          <nav className={`fixed bottom-0 left-0 right-0 h-16 border-t flex justify-around items-center px-4 z-40 select-none ${
            darkMode ? "bg-stone-950 border-neutral-800" : "bg-white border-neutral-150"
          }`}>
            <button 
              onClick={() => { setSelectedReport(null); setActiveTab("home"); }}
              className={`flex flex-col items-center justify-center transition-colors ${
                activeTab === "home" && !selectedReport ? "text-[#0052cc]" : "text-neutral-400"
              }`}
            >
              <span className="material-symbols-outlined">dashboard</span>
              <span className="text-[9px] font-bold mt-1">Home</span>
            </button>

            <button 
              onClick={() => { setSelectedReport(null); setActiveTab("categories"); }}
              className={`flex flex-col items-center justify-center transition-colors ${
                activeTab === "categories" ? "text-[#0052cc]" : "text-neutral-400"
              }`}
            >
              <span className="material-symbols-outlined">search</span>
              <span className="text-[9px] font-bold mt-1">Search</span>
            </button>

            {/* Central prominent SCAN FAB button */}
            <div className="relative -top-5">
              <button 
                onClick={() => setScanModalOpen(true)}
                className="w-14 h-14 bg-[#0052cc] hover:bg-[#003d9b] rounded-full flex items-center justify-center text-white shadow-xl shadow-[#0052cc]/30 hover:scale-105 transition-all"
              >
                <span className="material-symbols-outlined !text-3xl text-white">document_scanner</span>
              </button>
            </div>

            <button 
              onClick={() => { setSelectedReport(null); setActiveTab("chat"); }}
              className={`flex flex-col items-center justify-center transition-colors ${
                activeTab === "chat" ? "text-[#0052cc]" : "text-neutral-400"
              }`}
            >
              <span className="material-symbols-outlined">chat_bubble</span>
              <span className="text-[9px] font-bold mt-1">Doctor AI</span>
            </button>

            <button 
              onClick={() => { setSelectedReport(null); setActiveTab("history"); }}
              className={`flex flex-col items-center justify-center transition-colors ${
                activeTab === "history" ? "text-[#0052cc]" : "text-neutral-400"
              }`}
            >
              <span className="material-symbols-outlined">history</span>
              <span className="text-[9px] font-bold mt-1">History</span>
            </button>

            <button 
              onClick={() => { setSelectedReport(null); setActiveTab("profile"); }}
              className={`flex flex-col items-center justify-center transition-colors ${
                activeTab === "profile" ? "text-[#0052cc]" : "text-neutral-400"
              }`}
            >
              <span className="material-symbols-outlined">settings</span>
              <span className="text-[9px] font-bold mt-1">Settings</span>
            </button>
          </nav>

        </div>
      )}

      {/* Basic global dark-theme override variables */}
      <style>{`
        .dark-theme {
          background-color: #0c0a09 !important;
          color: #f5f5f4 !important;
        }
        .dark-theme header, .dark-theme nav {
          background-color: #1c1917 !important;
          border-color: #292524 !important;
        }
        .dark-theme .bg-white {
          background-color: #1c1917 !important;
          border-color: #292524 !important;
          color: #f5f5f4 !important;
        }
        .dark-theme .text-slate-800, .dark-theme .text-neutral-900, .dark-theme .text-neutral-800 {
          color: #e7e5e4 !important;
        }
        .dark-theme .text-neutral-500, .dark-theme .text-neutral-400 {
          color: #a8a29e !important;
        }
        .dark-theme .bg-neutral-50, .dark-theme .bg-neutral-100 {
          background-color: #292524 !important;
        }
        .dark-theme .report-card {
          background-color: #1c1917 !important;
          border-color: #292524 !important;
        }
        .dark-theme .divide-neutral-100 > * {
          border-color: #292524 !important;
        }
        .dark-theme table th, .dark-theme tr {
          color: #d6d3d1 !important;
        }
        .dark-theme .text-[#0052cc] {
          color: #60a5fa !important;
        }
        .dark-theme .bg-[#0052cc]/10 {
          background-color: rgba(96, 165, 250, 0.15) !important;
        }
        .dark-theme .bg-[#0052cc]/5 {
          background-color: rgba(96, 165, 250, 0.08) !important;
        }
        .dark-theme .border-neutral-100 {
          border-color: #292524 !important;
        }
      `}</style>
    </div>
  );
}

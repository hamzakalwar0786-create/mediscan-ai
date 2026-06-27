import React, { useState, useRef, useEffect } from "react";
import { Send, Bot, Shield, Plus, Paperclip, Camera, Mic, CheckCircle } from "lucide-react";
import { ChatMessage } from "../types";

interface ChatViewProps {
  messages: ChatMessage[];
  onSendMessage: (text: string) => void;
  typing: boolean;
  onViewSuggested: () => void;
}

export default function ChatView({ messages, onSendMessage, typing, onViewSuggested }: ChatViewProps) {
  const [input, setInput] = useState("");
  const endRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    endRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages, typing]);

  const handleSend = (e: React.FormEvent) => {
    e.preventDefault();
    if (!input.trim()) return;
    onSendMessage(input);
    setInput("");
  };

  const handleSuggestedTest = () => {
    onViewSuggested();
  };

  return (
    <div className="flex flex-col h-[calc(100vh-10rem)] max-w-4xl mx-auto rounded-3xl border border-neutral-100 bg-[#f8f9fc] overflow-hidden shadow-sm animate-fadeIn">
      
      {/* Header section with Doctor Avatar bio */}
      <div className="px-6 py-4 bg-white border-b border-neutral-150 flex items-center justify-between shrink-0">
        <div className="flex items-center gap-3">
          <div className="relative">
            {/* High trust practitioner avatar provided in HTML specs */}
            <img 
              alt="AI Doctor Avatar" 
              className="w-11 h-11 rounded-full object-cover border-2 border-[#0052cc]"
              src="https://lh3.googleusercontent.com/aida-public/AB6AXuDw1TM6n6w5HMfhaEFwrExWwVc8y3oBhMagjKUudIX8AiAKi42EDtACacVW0vMwg4-FUKIEePnVhBj1_Hhz_3SUuaeISR-iBmRB14FS4Ik-pxM3XOaPcZLDkFIw41a-RxymVhmGF0LduXrsUvsgOUibf6o2cvD3athbgCDvEdPQRbZT9vJ6N8di11pNlKjnizSnKJ5BwlyAf9IcVXJGd3SfUdpgn0hQcOlUktRO6ur9g552DlZfOLI9BM28oFDks6O4tMk5wLEn3LKP"
            />
            {/* Glowing online led badge */}
            <div className="absolute bottom-0 right-0 w-3 h-3 bg-[#22c55e] rounded-full border-2 border-white animate-pulse"></div>
          </div>
          <div>
            <h1 className="text-base font-bold text-[#003d9b] tracking-tight leading-none">MediScan AI</h1>
            <p className="text-[10px] font-bold text-[#007432] uppercase tracking-wider mt-1">AI Health Assistant</p>
          </div>
        </div>

        {/* Action icons placeholders */}
        <div className="flex items-center gap-1.5 text-neutral-400">
          <button className="p-2 rounded-full hover:bg-neutral-100 transition-colors">
            <span className="material-symbols-outlined !text-xl">videocam</span>
          </button>
          <button className="p-2 rounded-full hover:bg-neutral-100 transition-colors">
            <span className="material-symbols-outlined !text-xl">call</span>
          </button>
        </div>
      </div>

      {/* Message history layout */}
      <div className="flex-grow overflow-y-auto p-6 space-y-4 select-text">
        {/* Date stamp */}
        <div className="flex justify-center">
          <span className="bg-neutral-200/60 text-neutral-600 font-semibold text-[10px] tracking-widest px-3 py-1 rounded-full uppercase">
            Today
          </span>
        </div>

        {messages.map((msg) => {
          const isUser = msg.sender === "user";
          return (
            <div 
              key={msg.id}
              className={`flex flex-col ${isUser ? "items-end" : "items-start"} w-full`}
            >
              {/* Message Bubble box */}
              <div className={`p-4 max-w-[85%] shadow-sm ${
                isUser 
                  ? "bg-[#0052cc] text-white rounded-2xl rounded-tr-none" 
                  : "bg-white text-neutral-800 rounded-2xl rounded-tl-none border border-neutral-100"
              }`}>
                {!isUser && (
                  <div className="flex items-center gap-1.5 mb-2">
                    <CheckCircle className="w-3.5 h-3.5 text-[#0052cc]" />
                    <span className="text-[9px] font-extrabold text-[#0052cc] uppercase tracking-widest">Clinical Analysis</span>
                  </div>
                )}
                
                <p className="text-sm font-medium leading-relaxed whitespace-pre-wrap">
                  {msg.text}
                </p>

                {/* Simulated suggestion recommendation lists if present */}
                {!isUser && msg.recommendation && (
                  <div className="mt-4 bg-neutral-50 rounded-xl p-3 border-l-4 border-[#0052cc] flex flex-col gap-1">
                    <span className="text-[10px] font-bold text-[#0052cc] uppercase tracking-wider">Recommendation</span>
                    <span className="text-xs text-neutral-600 italic">
                      "{msg.recommendation}"
                    </span>
                  </div>
                )}

                {/* View suggested tests checklist target */}
                {!isUser && msg.suggestedTests && (
                  <button 
                    onClick={handleSuggestedTest}
                    className="w-full mt-4 h-10 rounded-xl bg-[#0052cc] text-white font-bold text-xs flex items-center justify-center gap-2 hover:bg-[#003d9b] transition-colors shadow-sm"
                  >
                    <span className="material-symbols-outlined !text-sm">biotech</span>
                    <span>View Suggested Tests</span>
                  </button>
                )}
              </div>

              {/* Timestamp label */}
              <span className={`text-[9px] text-neutral-400 mt-1 ${isUser ? "mr-1" : "ml-1"}`}>
                {msg.timestamp}
              </span>
            </div>
          );
        })}

        {/* Dynamic Typing Indicator lights */}
        {typing && (
          <div className="flex flex-col items-start w-full">
            <div className="bg-white px-4 py-3.5 rounded-2xl rounded-tl-none border border-neutral-100 flex items-center gap-1.5 shadow-sm">
              <span className="w-2 h-2 bg-[#0052cc] rounded-full animate-bounce" style={{ animationDelay: '0s' }}></span>
              <span className="w-2 h-2 bg-[#0052cc] rounded-full animate-bounce" style={{ animationDelay: '0.2s' }}></span>
              <span className="w-2 h-2 bg-[#0052cc] rounded-full animate-bounce" style={{ animationDelay: '0.4s' }}></span>
            </div>
          </div>
        )}

        <div ref={endRef} />
      </div>

      {/* Input panel container */}
      <div className="p-4 bg-white border-t border-neutral-150 shrink-0 select-none">
        <form onSubmit={handleSend} className="flex items-end gap-3 max-w-4xl mx-auto">
          
          <div className="flex-1 flex items-center bg-neutral-100 rounded-2xl px-3.5 py-1.5 border border-transparent focus-within:border-[#0052cc] focus-within:bg-white transition-all">
            <button 
              type="button"
              onClick={() => alert("Simulation attachment interface opened.")}
              className="p-1 rounded-full text-neutral-400 hover:text-[#0052cc]"
            >
              <Plus className="w-5 h-5" />
            </button>
            
            {/* Input field text area */}
            <input
              type="text"
              value={input}
              onChange={(e) => setInput(e.target.value)}
              placeholder="Describe your symptoms..."
              className="flex-grow bg-transparent border-none text-sm text-neutral-800 placeholder:text-neutral-400 focus:ring-0 py-2 outline-none h-11"
            />

            <div className="flex items-center gap-1.5 text-neutral-450 shrink-0">
              <button 
                type="button"
                onClick={() => alert("Ready to attach files.")}
                className="p-1 text-neutral-400 hover:text-[#0052cc]"
              >
                <Paperclip className="w-4 h-4" />
              </button>
              <button 
                type="button"
                onClick={() => alert("Accessing camera profile roll.")}
                className="p-1 text-neutral-400 hover:text-[#0052cc]"
              >
                <Camera className="w-4 h-4" />
              </button>
            </div>
          </div>

          <button 
            type="submit"
            className="w-12 h-12 bg-[#0052cc] rounded-full flex items-center justify-center text-white shrink-0 hover:bg-[#003d9b] active:scale-95 transition-transform"
          >
            <Send className="w-4 h-4 text-white" />
          </button>
        </form>
      </div>
    </div>
  );
}

import React, { useState } from "react";
import { Eye, EyeOff, Lock, Mail, ShieldCheck } from "lucide-react";

interface LoginViewProps {
  onSuccess: (email: string) => void;
}

export default function LoginView({ onSuccess }: LoginViewProps) {
  const [email, setEmail] = useState("john.doe@wellness.com");
  const [password, setPassword] = useState("••••••••");
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState("");

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!email || !email.includes("@")) {
      setError("Please key in a valid credentials email address.");
      return;
    }
    // Success simulation
    onSuccess(email);
  };

  return (
    <main className="min-h-screen bg-[#f7f9fb] flex flex-col justify-center items-center px-6 py-10 select-none">
      {/* Brand Title Frame */}
      <div className="flex flex-col items-center mb-8">
        <div className="w-14 h-14 bg-[#0052cc] rounded-2xl flex items-center justify-center shadow-lg shadow-[#0052cc]/20 relative overflow-hidden mb-3">
          <div className="relative flex items-center justify-center w-full h-full">
            <div className="absolute w-2 h-9 bg-white rounded-full"></div>
            <div className="absolute w-9 h-2 bg-white rounded-full"></div>
            <svg className="absolute w-9 h-8 text-[#22c55e] stroke-[6] fill-none drop-shadow-[0_1px_2px_rgba(0,0,0,0.2)]" viewBox="0 0 100 100">
              <path d="M10 50 L35 50 L45 25 L55 75 L65 50 L90 50" strokeLinecap="round" strokeLinejoin="round" />
            </svg>
          </div>
        </div>
        <h1 className="text-2xl font-extrabold text-[#003d9b] tracking-tight">MediScan AI</h1>
        <p className="text-xs font-semibold text-neutral-400 mt-1 uppercase tracking-wider">Clinical Intelligence Portal</p>
      </div>

      {/* Main Login Card panel */}
      <div className="w-full max-w-sm bg-white rounded-3xl p-6 md:p-8 shadow-xl border border-neutral-100/80">
        <div className="mb-6">
          <h2 className="text-xl font-bold text-neural-900 tracking-tight">Welcome Back</h2>
          <p className="text-xs text-neutral-500 mt-1">Secure access to your medical analysis</p>
        </div>

        {error && (
          <div className="mb-4 text-xs font-semibold text-red-600 bg-red-50 p-3 rounded-xl border border-red-100 leading-normal">
            {error}
          </div>
        )}

        <form onSubmit={handleSubmit} className="space-y-4">
          {/* Email input field */}
          <div>
            <label className="block text-xs font-semibold text-neutral-500 mb-1.5 uppercase tracking-wider">Email Address</label>
            <div className="relative">
              <Mail className="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-neutral-400" />
              <input
                type="email"
                required
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="name@example.com"
                className="w-full h-11 pl-10 pr-4 bg-neutral-50 hover:bg-neutral-100/50 focus:bg-white rounded-xl border-none outline-none ring-2 ring-transparent focus:ring-[#0052cc] text-sm text-neutral-800 transition-all font-medium"
              />
            </div>
          </div>

          {/* Password input field with toggle */}
          <div>
            <div className="flex justify-between items-center mb-1.5">
              <label className="block text-xs font-semibold text-neutral-500 uppercase tracking-wider">Password</label>
              <button 
                type="button" 
                onClick={() => alert("Simulated password reset email sent.")}
                className="text-[11px] font-bold text-[#0052cc] hover:underline"
              >
                Forgot Password?
              </button>
            </div>
            <div className="relative">
              <Lock className="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-neutral-400" />
              <input
                type={showPassword ? "text" : "password"}
                required
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="••••••••"
                className="w-full h-11 pl-10 pr-10 bg-neutral-50 hover:bg-neutral-100/50 focus:bg-white rounded-xl border-none outline-none ring-2 ring-transparent focus:ring-[#0052cc] text-sm text-neutral-800 transition-all font-medium"
              />
              <button
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                className="absolute right-3 top-1/2 -translate-y-1/2 text-neutral-400 hover:text-neutral-500 cursor-pointer"
              >
                {showPassword ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
              </button>
            </div>
          </div>

          {/* Sign In button */}
          <button
            type="submit"
            className="w-full h-12 mt-6 bg-[#0052cc] hover:bg-[#003d9b] text-white rounded-xl font-bold text-sm shadow-md shadow-[#0052cc]/10 transition-transform active:scale-[0.98] flex items-center justify-center gap-2"
          >
            <span>Sign In</span>
            <span>→</span>
          </button>
        </form>

        {/* Divider standard OR list */}
        <div className="relative flex py-5 items-center">
          <div className="flex-grow border-t border-neutral-100"></div>
          <span className="flex-shrink mx-4 text-[10px] font-bold text-neutral-400 uppercase tracking-widest">or continue with</span>
          <div className="flex-grow border-t border-neutral-100"></div>
        </div>

        {/* Google coloured SSO simulated button */}
        <button
          onClick={() => onSuccess("google.oauth@sample.com")}
          className="w-full h-11 bg-white hover:bg-neutral-50 text-neutral-700 rounded-xl font-bold text-sm border border-neutral-200 shadow-sm transition-transform active:scale-[0.98] flex items-center justify-center gap-3"
        >
          {/* Custom vector representation of Google */}
          <svg className="w-4 h-4" viewBox="0 0 24 24">
            <path
              fill="#4285F4"
              d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
            />
            <path
              fill="#34A853"
              d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
            />
            <path
              fill="#FBBC05"
              d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.06H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.94l2.85-2.22.81-.63z"
            />
            <path
              fill="#EA4335"
              d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.06l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"
            />
          </svg>
          <span>Google</span>
        </button>

        {/* Link creating sign up */}
        <div className="text-center mt-6 text-xs text-neutral-500 font-medium">
          New to MediScan AI?{" "}
          <button 
            onClick={() => alert("Simulated account creation requested.")}
            className="font-bold text-[#0052cc] hover:underline"
          >
            Create an account
          </button>
        </div>
      </div>

      {/* Embedded security legal lock foot label */}
      <footer className="mt-8 flex flex-col items-center select-none text-neutral-400">
        <div className="flex items-center gap-1.5 mb-1.5 opacity-80">
          <ShieldCheck className="w-4 h-4 text-[#22c55e]" />
          <span className="text-[10px] font-bold uppercase tracking-wider">HIPAA Compliant • 256-bit Encryption</span>
        </div>
        <div className="flex items-center gap-2 text-[11px] font-semibold">
          <button className="hover:text-[#0052cc]">Privacy Policy</button>
          <span>•</span>
          <button className="hover:text-[#0052cc]">Terms of Service</button>
          <span>•</span>
          <button className="hover:text-[#0052cc]">Help</button>
        </div>
      </footer>
    </main>
  );
}

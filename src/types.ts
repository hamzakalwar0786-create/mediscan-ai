export interface DiagnosticParameter {
  name: string;
  result: string;
  unit: string;
  referenceRange: string;
  status: 'LOW' | 'NORMAL' | 'HIGH' | 'ABNORMAL';
  valueAsNumber?: number; // for charts
}

export interface MedicalReport {
  id: string;
  title: string;
  type: string;
  date: string;
  location: string;
  parameters: DiagnosticParameter[];
  status: 'Normal' | 'Abnormal';
  trendSummary?: string;
  insights?: string;
  recommendations?: { task: string; detail: string; icon?: string }[];
}

export interface ChatMessage {
  id: string;
  sender: 'user' | 'ai';
  text: string;
  timestamp: string;
  recommendation?: string;
  suggestedTests?: boolean;
}

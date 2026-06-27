import { MedicalReport } from "./types";

export const INITIAL_REPORTS: MedicalReport[] = [
  {
    id: "rep-cbc-01",
    title: "Complete Blood Count (CBC)",
    type: "Blood Test",
    date: "Aug 12, 2023",
    location: "Metro General Hospital Lab",
    status: "Normal",
    parameters: [
      { name: "Hemoglobin", result: "14.2", unit: "g/dL", referenceRange: "13.5 – 17.5 g/dL", status: "NORMAL" },
      { name: "WBC Count", result: "7.2", unit: "x10³/µL", referenceRange: "4.5 – 11.0 x10³/µL", status: "NORMAL" },
      { name: "Platelets", result: "210", unit: "x10³/µL", referenceRange: "150 – 450 x10³/µL", status: "NORMAL" },
      { name: "MCV", result: "88", unit: "fL", referenceRange: "80 – 100 fL", status: "NORMAL" }
    ],
    trendSummary: "Hemoglobin level is steady at 14.2 g/dL over the past 6 months compared to baseline.",
    insights: "Your Complete Blood Count is fully within normal limits. This indicates robust red and white cell production and normal clotting capability.",
    recommendations: [
      { task: "Maintain Balanced Diet", detail: "Continue a diet rich in trace minerals, iron, and leafy greens.", icon: "restaurant" },
      { task: "Routine Annual Checkup", detail: "General follow-up schedule remains unchanged.", icon: "calendar_today" }
    ]
  },
  {
    id: "rep-lipid-02",
    title: "Lipid Profile",
    type: "Blood Test",
    date: "July 28, 2023",
    location: "City Health Diagnostics Lab",
    status: "Abnormal",
    parameters: [
      { name: "Total Cholesterol", result: "245", unit: "mg/dL", referenceRange: "< 200 mg/dL", status: "HIGH" },
      { name: "Triglycerides", result: "185", unit: "mg/dL", referenceRange: "< 150 mg/dL", status: "HIGH" },
      { name: "HDL Cholesterol", result: "38", unit: "mg/dL", referenceRange: "> 40 mg/dL", status: "LOW" },
      { name: "LDL Cholesterol", result: "160", unit: "mg/dL", referenceRange: "< 100 mg/dL", status: "HIGH" }
    ],
    trendSummary: "Cholesterol levels are elevated with high LDL and low protective HDL, showing a steady rise from the previous checkups.",
    insights: "Your elevated Total and LDL cholesterol levels (hyperlipidemia) pose an increased risk of cardiovascular deposits. HDL is also slightly sub-optimal, highlighting a clear need for lifestyle adjustment.",
    recommendations: [
      { task: "Reduce Saturated Fats", detail: "Cut down on deep-fried food, red meat, and processed snacks.", icon: "restaurant" },
      { task: "Aerobic Exercise", detail: "Engage in 30 minutes of brisk walking or cardio 5 days a week.", icon: "directions_run" },
      { task: "Re-test lipid panel", detail: "Monitor LDL metrics in 6 weeks.", icon: "repeat" }
    ]
  },
  {
    id: "rep-vit-03",
    title: "Vitamin D Panel",
    type: "Blood Test",
    date: "July 02, 2023",
    location: "City Health Diagnostics Lab",
    status: "Abnormal",
    parameters: [
      { name: "25-Hydroxy Vitamin D", result: "12.5", unit: "ng/mL", referenceRange: "30.0 – 100.0 ng/mL", status: "LOW" }
    ],
    trendSummary: "Severe deficiency observed at 12.5 ng/mL - represents a downward trajectory over the last 90 days.",
    insights: "Your screening indicates severe Vitamin D deficiency. This essential hormone supports bone dense signaling, immunity pathways, and general wellness. Low counts can directly yield chronic fatigue.",
    recommendations: [
      { task: "Supplementation", detail: "Consult with a physician regarding oral weekly Vitamin D3 supplements.", icon: "pill" },
      { task: "Sunlight exposure", detail: "Spend 15-20 minutes in early morning sunlight daily.", icon: "wb_sunny" },
      { task: "Calcium-rich diet", detail: "Incorporate fortified dairy, milk, or calcium foods.", icon: "local_cafe" }
    ]
  }
];

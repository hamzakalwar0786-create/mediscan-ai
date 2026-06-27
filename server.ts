import express from "express";
import path from "path";
import { createServer as createViteServer } from "vite";
import { GoogleGenAI, Type } from "@google/genai";
import dotenv from "dotenv";

dotenv.config();

// Simple mock reports for fallback or quick scanning
const MOCK_REPORTS = [
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
      { task: "Maintain Balanced Diet", detail: "Continue a diet rich in trace minerals and leafy greens.", icon: "restaurant" },
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
      { task: "Re-test lipid panel", detail: "Monitor progress in 6 weeks.", icon: "repeat" }
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
      { task: "Sunlight exposure", detail: "Try to spend 15-20 minutes in early morning sunlight daily.", icon: "wb_sunny" },
      { task: "Calcium-rich diet", detail: "Incorporate fortified dairy, milk, or calcium foods.", icon: "local_cafe" }
    ]
  }
];

let aiClient: GoogleGenAI | null = null;

// Lazy initialization of active Gemini client
function getAI() {
  if (!aiClient) {
    const key = process.env.GEMINI_API_KEY;
    if (key && key !== "MY_GEMINI_API_KEY" && key.trim() !== "") {
      aiClient = new GoogleGenAI({
        apiKey: key,
        httpOptions: {
          headers: {
            'User-Agent': 'aistudio-build',
          }
        }
      });
    }
  }
  return aiClient;
}

async function startServer() {
  const app = express();
  const PORT = 3000;

  // Set limits for parsing high-resolution report PDFs/photos
  app.use(express.json({ limit: "15mb" }));

  // API 1: Analyze Report using Gemini or Mock Fallback
  app.post("/api/analyze-report", async (req, res) => {
    try {
      const { image, text, fileName } = req.body;
      const ai = getAI();

      if (!ai) {
        console.log("No GEMINI_API_KEY provided or using placeholder. Returning high-fidelity mock reports.");
        // Pick custom fallback depending on filename pattern or random selection
        const lowerName = (fileName || "").toLowerCase();
        let fallback = MOCK_REPORTS[2]; // Default to deficiency low hemoglobin/vitamin D style
        if (lowerName.includes("cbc") || lowerName.includes("blood") || lowerName.includes("complete")) {
          fallback = MOCK_REPORTS[0];
        } else if (lowerName.includes("lipid") || lowerName.includes("cholesterol") || lowerName.includes("fat")) {
          fallback = MOCK_REPORTS[1];
        } else if (image || text) {
          // Send simulated random report
          fallback = {
            ...MOCK_REPORTS[Math.floor(Math.random() * MOCK_REPORTS.length)],
            id: `rep-${Date.now()}`,
            date: new Date().toLocaleDateString('en-US', { month: 'short', day: '2-digit', year: 'numeric' })
          };
        }
        return res.json({ success: true, report: fallback, isMock: true });
      }

      console.log(`Decoding report file: ${fileName} using gemini-3.5-flash`);

      // Build structured prompt for report extractor
      const prompt = `
        You are a highly precise clinical scanner. Extract diagnostic parameters from this medical report.
        If it's an image, do OCR. If standard text is pasted, parse it as-is.
        Return raw clinical metrics, matching reference ranges, and evaluate whether each parameter is LOW, NORMAL, or HIGH.
        Generate doctor-grade insights, health trend explanations, and actionable clinical recommendation bullet list with a clear title and details.
      `;

      let contents: any[] = [];
      if (image) {
        // base64 image input
        contents = [
          {
            inlineData: {
              data: image.split(",")[1] || image,
              mimeType: "image/jpeg"
            }
          },
          { text: prompt }
        ];
      } else if (text) {
        contents = [{ text: `${prompt}\n\nReport Text Content:\n${text}` }];
      } else {
        return res.status(400).json({ error: "Missing image/text content to analyze." });
      }

      const response = await ai.models.generateContent({
        model: "gemini-3.5-flash",
        contents: contents,
        config: {
          systemInstruction: "You are professional clinical scanner. Be extremely accurate. Ensure reference ranges match verbatim what is in the report.",
          responseMimeType: "application/json",
          responseSchema: {
            type: Type.OBJECT,
            properties: {
              title: { type: Type.STRING, description: "Name of the medical report (e.g. Complete Blood Count)" },
              status: { type: Type.STRING, description: "Overall health categorization ('Normal' or 'Abnormal')" },
              trendSummary: { type: Type.STRING, description: "Comparison of current results against historical trends" },
              insights: { type: Type.STRING, description: "Clinical breakdown of the findings for the patient in simple high-trust terms" },
              parameters: {
                type: Type.ARRAY,
                items: {
                  type: Type.OBJECT,
                  properties: {
                    name: { type: Type.STRING, description: "The biomarker or parameter (e.g. Hemoglobin)" },
                    result: { type: Type.STRING, description: "Numeric or text result found (e.g. 10.5)" },
                    unit: { type: Type.STRING, description: "Measurement unit (e.g. g/dL)" },
                    referenceRange: { type: Type.STRING, description: "Standard range of values for normal outcome" },
                    status: { type: Type.STRING, description: "Evaluation status: 'LOW' | 'NORMAL' | 'HIGH' | 'ABNORMAL'" }
                  },
                  required: ["name", "result", "unit", "referenceRange", "status"]
                }
              },
              recommendations: {
                type: Type.ARRAY,
                items: {
                  type: Type.OBJECT,
                  properties: {
                    task: { type: Type.STRING, description: "What target action to perform (e.g. Drink more Vitamin C)" },
                    detail: { type: Type.STRING, description: "Actionable details on why and how" }
                  },
                  required: ["task", "detail"]
                }
              }
            },
            required: ["title", "status", "trendSummary", "insights", "parameters", "recommendations"]
          }
        }
      });

      const resultText = response.text;
      if (!resultText) {
        throw new Error("Empty response from AI engine");
      }

      const parsedJSON = JSON.parse(resultText);
      const generatedReport = {
        id: `rep-gen-${Date.now()}`,
        title: parsedJSON.title || "Clinical Report Summary",
        type: parsedJSON.title && parsedJSON.title.toLowerCase().includes("blood") ? "Blood Test" : "Diagnostic Scan",
        date: new Date().toLocaleDateString('en-US', { month: 'short', day: '2-digit', year: 'numeric' }),
        location: "AI Diagnosed Clinical Insights",
        status: parsedJSON.status || "Normal",
        parameters: parsedJSON.parameters || [],
        trendSummary: parsedJSON.trendSummary || "",
        insights: parsedJSON.insights || "",
        recommendations: (parsedJSON.recommendations || []).map((rec: any, idx: number) => {
          // Assign visual icons dynamically based on task properties
          let icon = "assignment_turned_in";
          const lowerTask = rec.task.toLowerCase();
          if (lowerTask.includes("eat") || lowerTask.includes("food") || lowerTask.includes("diet") || lowerTask.includes("iron")) {
            icon = "restaurant";
          } else if (lowerTask.includes("supplement") || lowerTask.includes("pill") || lowerTask.includes("vitamin")) {
            icon = "pill";
          } else if (lowerTask.includes("sun") || lowerTask.includes("outdoor")) {
            icon = "wb_sunny";
          } else if (lowerTask.includes("repeat") || lowerTask.includes("re-test") || lowerTask.includes("test")) {
            icon = "repeat";
          } else if (lowerTask.includes("exercise") || lowerTask.includes("run") || lowerTask.includes("walk")) {
            icon = "directions_run";
          }
          return { task: rec.task, detail: rec.detail, icon };
        })
      };

      res.json({ success: true, report: generatedReport, isMock: false });

    } catch (e: any) {
      console.error("AI Report Scanning Error: ", e);
      res.status(500).json({ error: "Failed to scan report. Please verify configuration.", details: e.message });
    }
  });

  // API 2: Consult AI Doctor (Chat Room)
  app.post("/api/chat", async (req, res) => {
    try {
      const { message, history } = req.body;
      const ai = getAI();

      if (!ai) {
        console.log("No GEMINI_API_KEY provided. Chat falling back to smart mockup doctor.");
        // Produce automated conversational helpers including support for Hinglish/Urdu as seen in screenshot!
        const trimmed = message.toLowerCase().trim();
        let reply = "Hello! I am your clinical health assistant. How can I guide you with your health records today?";
        let suggestedTests = false;

        if (trimmed.includes("pet dard") || trimmed.includes("stomach") || trimmed.includes("dard")) {
          reply = "I understand you are experiencing stomach pain (pet dard) and fatigue. This, when correlated with potential low iron or low hemoglobin levels, suggests mild anemia. I highly suggest monitoring your nutrition and conducting additional lab tests.";
          suggestedTests = true;
        } else if (trimmed.includes("thakan") || trimmed.includes("fatigue") || trimmed.includes("tired")) {
          reply = "Chronic fatigue (thakan) is often closely bounded with oxygen-carrying capabilities in our red blood cells (low hemoglobin) or standard Vitamin D/B12 shortages. It's recommended to do a targeted Vitamin checklist.";
          suggestedTests = true;
        } else if (trimmed.includes("hemoglobin") || trimmed.includes("blood")) {
          reply = "Hemoglobin serves to carry oxygen in your blood. If it falls below 13.5 g/dL, you may feel tired, weak, or slightly dizzy. Dietary adjustments like eating iron-enriched foods, alongside consulting your general practitioner, can naturally strengthen this marker.";
        } else if (trimmed.includes("hello") || trimmed.includes("hi ") || trimmed.includes("ola")) {
          reply = "Hello! I am your clinical health assistant. I can help interpret checkup documents, clarify medical findings, and recommend the best actionable recovery pathway. How can I help you today?";
        } else {
          reply = `I have received your message regarding: "${message}". In clinical analysis, standard monitoring of trace nutrients (Vit D, Iron saturation) and routine checkups with medical doctors provide the ultimate safety pathway. How would you like me to clarify your diagnostic trends?`;
        }

        return res.json({
          success: true,
          reply,
          suggestedTests
        });
      }

      // Convert user chat history object format to standard Gemini chat model
      const contents = (history || []).map((msg: any) => ({
        role: msg.sender === "user" ? "user" : "model",
        parts: [{ text: msg.text }]
      }));

      // Add the current user query to the contents
      contents.push({
        role: "user",
        parts: [{ text: message }]
      });

      console.log(`Sending clinical chat request to gemini-3.5-flash`);

      const response = await ai.models.generateContent({
        model: "gemini-3.5-flash",
        contents: contents,
        config: {
          systemInstruction: `
            You are 'MediScan AI', an elite, highly empathetic, clear clinican companion.
            You help interpret diagnostic lab results (Complete Blood Count, Urine, Cardio reports).
            Always communicate with professional composure. Keep insights patient-friendly, helpful, and easily digestible.
            IMPORTANT:
            - If the user writes in Hinglish or romanized Urdu/Hindi (e.g. "Mera pet dard ho raha hai aur thakan feel hoti hai"),
              respond natively inside standard romanized Urdu/Hindi or clear multilingual clinical style! This maintains optimal compatibility.
            - Ensure to indicate when further clinical diagnostic tests are highly recommended (e.g. suggesting Vitamin B12, iron, etc.).
            - Never state clinical diagnostic certainty, advise consulting standard physicians or GPs for ultimate diagnostics.
            - Give direct actionable bullet guides for standard health queries.
          `
        }
      });

      const reply = response.text || "I was unable to analyze that query. Please consult with our primary healthcare assistants.";
      const lowerReply = reply.toLowerCase();
      // Identify if the clinical conversation warrants recommending a diagnostic blood profile test
      const suggestedTests = lowerReply.includes("test") || lowerReply.includes("checkup") || lowerReply.includes("cbc") || lowerReply.includes("vitamin");

      res.json({ success: true, reply, suggestedTests });

    } catch (e: any) {
      console.error("Clinical Chat Error: ", e);
      res.status(500).json({ error: "Failed to query clinical health assistant.", details: e.message });
    }
  });

  // Mount Vite development layers or serve compiled production bundles
  if (process.env.NODE_ENV !== "production") {
    const vite = await createViteServer({
      server: { middlewareMode: true },
      appType: "spa",
    });
    app.use(vite.middlewares);
  } else {
    const distPath = path.join(process.cwd(), "dist");
    app.use(express.static(distPath));
    app.get("*", (req, res) => {
      res.sendFile(path.join(distPath, "index.html"));
    });
  }

  app.listen(PORT, "0.0.0.0", () => {
    console.log(`MediScan AI clinician backend boot complete: http://localhost:${PORT}`);
  });
}

startServer();

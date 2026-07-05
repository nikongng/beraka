import { onCall } from "firebase-functions/v2/https";
import { defineString } from "firebase-functions/params";
import { GoogleGenerativeAI } from "@google/generative-ai";

const geminiApiKey = defineString("GEMINI_API_KEY");

export const askGemini = onCall(async (request) => {
  const prompt = request.data.prompt;

  if (!prompt) {
    throw new Error("Aucun prompt fourni.");
  }

  const apiKey = geminiApiKey.value();
  const genAI = new GoogleGenerativeAI(apiKey);
  const model = genAI.getGenerativeModel({model: "gemini-2.5-flash"});

  try {
    const result = await model.generateContent(prompt);
    const response = await result.response;
    return {text: response.text()};
  } catch (error) {
    console.error("Erreur Gemini:", error);
    throw new Error("Erreur de communication avec l'IA.");
  }
});
# 🍏 Intake AI - The Next-Gen Computer Vision Nutrition Tracker

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Google Gemini](https://img.shields.io/badge/Google%20Gemini-8E75B2?style=for-the-badge&logo=google&logoColor=white)
![SQLite](https://img.shields.io/badge/sqlite-%2307405e.svg?style=for-the-badge&logo=sqlite&logoColor=white)
![GitLab](https://img.shields.io/badge/gitlab-%23181717.svg?style=for-the-badge&logo=gitlab&logoColor=white)

**Stop typing, start snapping.** Intake AI is a premium, AI-powered health and fitness tracker that eliminates the friction of manual calorie logging. Just point your camera at your food, and let the AI Vision engine do the magic!

---

## 🏆 Built for Frostbyte Hackathon 2026

Intake AI was developed specifically for the Frostbyte Hackathon, targeting two major themes:
1. **Artificial Intelligence & Machine Learning:** Utilizing LLMs for real-time image recognition and strict JSON macro extraction.
2. **Healthcare & BioTech:** Providing users with an effortless, highly visual way to track their daily nutrition and metabolic health.

---

## 📸 Project Gallery & Demo

### 🎥 [Watch the Full App Demo on YouTube](YOUR_YOUTUBE_VIDEO_LINK_HERE)

<div align="center">
  <img src="1000129858.png" width="800" alt="Intake AI Mockups"/>
</div>
*(Note: Replace `1000129858.png` with your actual mockup image file name once uploaded)*

---

## ✨ God-Level Features

* 🤖 **AI Vision Scanner (Gemini 1.5 Flash):** Snap a picture of any meal (from a simple apple to complex local dishes like *Fried Empanadas*). The AI instantly recognizes the food and extracts accurate Macros (Calories, Protein, Carbs, Fats).
* 🛡️ **Crash-Proof Smart Extractor:** Engineered a custom `try-catch` JSON extractor that perfectly cleans and parses AI responses, ensuring the app never crashes even if the LLM hallucinates markdown text.
* 🧍‍♂️ **3D Hologram Body Analytics:** A dynamic, futuristic dashboard that tracks your real-time body progress and macro intake visually.
* 🕸️ **Macro Balance Matrix:** Advanced spider radar charts (`fl_chart`) to visualize your health, consistency, and macronutrient balance.
* 📈 **Predictive AI Forecast:** Line charts providing actionable fitness insights and predicting your caloric trend for the upcoming week based on historical data.
* ✨ **Premium SaaS UI/UX:** Built with buttery smooth staggered cascade animations (`animate_do`, `flutter_animate`), tactile haptic feedback (bouncy buttons), and sleek dark-mode glass-morphism elements.
* 💾 **Offline-First Architecture:** Lightning-fast local storage using `sqflite` (Version 2 with automatic schema upgrades) ensures your daily logs are always private and available instantly.

---
⏭️ What's Next? (Future Scope)
Wearable Integration: Syncing with Apple Health & Google Fit to automatically map "Calories Burned vs. Calories Consumed".
Personal AI Nutritionist: A chat interface where Gemini acts as your personal coach based on your 30-day Intake data.
Barcode API Integration: Connecting the existing UI to a massive global UPC food database.
---
📂 Folder Structure
lib/
 ┣ core/               # Constants, Colors, Globals, API Keys
 ┣ features/           # App Features (Home, Scanner, Progress, Profile)
 ┣ services/           # AI Vision Service, Camera Helper, Database Helper
 ┣ app.dart            # Main App Wrapper & Theme Notifier
 ┗ main.dart           # Application Entry Point


## 🛠️ Tech Stack & Architecture

* **Frontend:** Flutter & Dart (Cross-platform, 60fps performance)
* **AI Engine:** `google_generative_ai` (Google Gemini 1.5 Flash API)
* **Local Database:** `sqflite` (Relational SQL Database for offline logging)
* **State Management:** `setState` & `shared_preferences`
* **Hardware Integrations:** `camera` (for custom scanner UI) & `image_picker`
* **Visuals & Charts:** `fl_chart`, `flutter_animate`, `animate_do`

---

## 🚀 Getting Started (Run Locally)

Want to test the magic yourself? Follow these steps:

### Prerequisites
* Flutter SDK (^3.9.0)
* Android Studio / Xcode
* **Google Gemini API Key**

### Installation

1. **Clone the repository:**
   ```bash
   git clone [https://gitlab.com/roshancodes036-su/Intake-Ai.git](https://gitlab.com/roshancodes036-su/Intake-Ai.git)
   cd Intake-Ai

Install dependencies:
flutter pub get

Setup your Gemini API Key:
Navigate to lib/core/constants/api_keys.dart and add your API key:
class ApiKeys {
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY_HERE';
}

Run the app:
flutter run

👨‍💻 Developed By
Roshan Chaurasiya Or Akash Chaurasiya 
Full-Stack Application Developer
Passionate about AI, UI/UX, and building SaaS products.
Let's connect!
LinkedIn | GitHub
If you liked this project, don't forget to give it a ⭐!

# 🍏 Intake AI - Next-Gen AI Nutrition Tracker

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Google Gemini](https://img.shields.io/badge/Google%20Gemini-8E75B2?style=for-the-badge&logo=google&logoColor=white)
![SQLite](https://img.shields.io/badge/sqlite-%2307405e.svg?style=for-the-badge&logo=sqlite&logoColor=white)

**Intake AI** is a premium, million-dollar UI/UX fitness and nutrition tracking application. Say goodbye to manual calorie logging—just point your camera at your food, and let the AI Vision engine do the magic! 

Designed with buttery-smooth animations, a futuristic 3D body hologram, and advanced predictive analytics, Intake AI redefines how you track your health.

---

## ✨ Key Features

* 🤖 **AI Vision Scanner:** Powered by Google Gemini 1.5 Flash. Snap a picture of your meal or barcode, and the AI instantly extracts accurate Macros (Calories, Protein, Carbs, Fats).
* 🧍‍♂️ **3D Hologram Body Analytics:** A dynamic, visually rich dashboard that tracks your real-time body progress and macro intake visually.
* 🕸️ **Macro Balance Matrix:** Advanced spider radar charts to visualize your health, consistency, and macronutrient balance.
* 📈 **Predictive AI Forecast:** Line charts providing actionable fitness insights and predicting your caloric trend for the upcoming week.
* ✨ **"God-Level" UI/UX:** Built with buttery smooth staggered animations, tactile haptic feedback (bouncy buttons), and floating glass-morphism elements.
* 🌙 **Premium Theming:** Fully responsive Dark and Light modes tailored for a premium SaaS feel.
* 💾 **Offline First:** Lightning-fast local storage using `sqflite` ensures your daily logs are always available.

---

## 📸 Screenshots

<div align="center">
  <img src="Home%20Dashboard.png" width="250" alt="Home Dashboard"/>
  &nbsp;&nbsp;&nbsp;
  <img src="AI%20Scanner.png" width="250" alt="AI Scanner"/>
  &nbsp;&nbsp;&nbsp;
  <img src="Progress%20Hologram.png" width="250" alt="Progress Hologram"/>
</div>

---

## 🛠️ Tech Stack

* **Framework:** Flutter (Dart)
* **AI Engine:** `google_generative_ai` (Gemini 1.5 Flash)
* **Database:** `sqflite` (Local SQL Database)
* **Animations:** `animate_do`, `flutter_animate`
* **Charts:** `fl_chart`
* **Camera:** `camera`, `image_picker`
* **State Management & Storage:** `setState`, `shared_preferences`

---

## 🚀 Getting Started

Follow these steps to run the project locally on your machine.

### Prerequisites
* Flutter SDK (^3.9.0)
* Dart SDK
* Android Studio / VS Code
* **Google Gemini API Key**

### Installation

1. **Clone the repository:**
   ```bash
   git clone [https://github.com/roshancodes036-su/Intake-Ai.git](https://github.com/roshancodes036-su/Intake-Ai.git)
   cd Intake-Ai

Install dependencies:
flutter pub get

Setup your Gemini API Key:
Navigate to lib/core/constants/api_keys.dart and add your API key:
class ApiKeys {
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY_HERE';
}

Generate App Icons (Optional):
dart run flutter_launcher_icons

Run the app:
flutter run

📂 Folder Structure
lib/
 ┣ core/               # Constants, Colors, Globals, API Keys
 ┣ features/           # App Features (Home, Scanner, Progress, Profile)
 ┣ services/           # AI Vision Service, Camera Helper, Database Helper
 ┣ app.dart            # Main App Wrapper & Theme Notifier
 ┗ main.dart           # Application Entry Point

👨‍💻 Developed By
Roshan Chaurasiya Or Akash Chaurasiya 
Full-Stack Application Developer
Passionate about AI, UI/UX, and building SaaS products.
Let's connect!
LinkedIn | GitHub
If you liked this project, don't forget to give it a ⭐!

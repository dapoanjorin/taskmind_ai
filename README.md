# TaskMind AI

A modern mobile Task Management App with AI-powered productivity features.  
Built in Flutter using clean architecture, Riverpod, Hive, and Gemini AI.

---

## 🚀 Features

- 📂 Project & Task Management
- 🔄 Offline-first (Hive)
- 🧠 AI Assistant (Gemini 2.5 Flash)
    - "Plan my week" → Generates structured tasks
- 🔁 Smart Task Rescheduler for overdue tasks
- 🔔 Push Notifications (due task reminders)
- 🌓 Dark Mode Support
- ✅ Clean Architecture (Presentation / Domain / Data)
- 🧪 Unit + Widget Tests

---

## 🏗️ Architecture

### Clean Architecture Implementation
lib/
│
├── core/     
├── data
│   ├── models/           
│   └── repositories/     
├── domain/               
│   ├── entities/         
│   ├── repositories/      
│   └── usecases/         
├── presentation/         
│   ├── screens/          
│   └── providers/        
├── router/           
│   ├── pages/        
│   ├── widgets/     
│   └── providers/
├── services/        
└── main.dart

### State Management

- Riverpod: Chosen for its compile-time safety and testability
- StateNotifier: For complex state management scenarios
- FutureProvider: For asynchronous operations
- Consumer: For reactive UI updates

### Data Layer

- Hive: Local NoSQL database for offline storage
- HTTP: REST API communication
- Repository Pattern: Abstracts data sources from business logic




## 🔧 Setup

### Environment Setup

- Create a .env file in the root directory:

```
GEMINI_API_KEY=your_gemini_api_key_here
```


---

## 🧠 AI Prompt Design & Fallback Strategy

- The project users Gemini API and the prompts are designed to return structured JSON.
- Prompts include strict formatting rules to ensure valid parsing.
- Fallbacks:
  - Exceptions are thrown and handled in the UI when API fails or returns an invalid JSON.

---

## ✅ Test Coverage

- Includes unit test for `aiAssistantProvider`:
  - Ensures initial state is not loading, has no errors, and no generated tasks.
- All business logic is testable due to clean architecture separation.

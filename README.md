# ecommerce_app_task

A new Flutter project.

# 🛍️ Flutter E-Commerce Application

A feature-rich, cross-platform e-commerce mobile application built with Flutter, designed with a clean architecture and efficient state management.

---

## ✨ Key Features
* **Product Catalog & Categories:** Browse products dynamically with search and filter capabilities.
* **Product Details:** High-resolution image galleries, descriptions, and variant selection.
* **Cart & Wishlist Management:** Add, remove, and update quantities seamlessly.
* **Responsive UI:** Clean, intuitive layouts optimized for various screen sizes.

---

## 🏗️ Architecture Explanation

The project is structured following a clean architecture pattern to maintain high testability, scalability, and separation of concerns:

* **Presentation Layer:** Contains UI screens, reusable widgets, and UI state handling. Views remain reactive and delegate business logic to the providers.
* **Domain Layer:** Houses core business entities and logic.
* **Data Layer:** Manages remote API services (fetching products, authentication) and repository implementations.

---

## ⚡ State Management Approach

* **Framework:** **Provider** is utilized for reactive state management and dependency injection.
* **Why this approach?**
    * **ChangeNotifier & Consumer:** Efficiently rebuilds only the specific UI components that depend on state changes, preventing unnecessary widget tree rebuilds.
    * **Separation of Concerns:** Keeps business logic clean and decoupled from the UI widgets.

---

## 🚀 Steps to Run the Application

### Prerequisites
* Flutter SDK and Dart installed.
* Android Emulator, iOS Simulator, or a physical device.

### Installation Steps

1. **Clone the repository:**
   ```bash
   git clone [https://github.com/Harshvikadia/ecommerce-app.git](https://github.com/Harshvikadia/ecommerce-app.git)
   cd ecommerce-app
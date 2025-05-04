📝 **Offline Tasks App**
A cross-platform Flutter application enabling users to manage their to-do list fully offline, with seamless data syncing when connectivity is restored—built using the MVC (Model-View-Controller) pattern and optimized for reliability on the go.

📲 **Overview**
Offline Tasks App empowers users to create, organize, and track tasks without ever needing an internet connection. Leveraging intelligent local storage and a clear MVC structure, it ensures snappy performance, easy offline-first workflows, and conflict-free sync once back online.

✨ **Features**
🆕 **Task Management**

* Create, edit, delete tasks and subtasks
* Due dates, priorities, and categories
* Recurring tasks (daily, weekly, custom intervals)
* Drag-and-drop reordering

📥 **Offline-First**

* Full local persistence via Sqlite (SQL)
* Change journal for offline operations
* Automatic two-way sync when connectivity resumes

🔔 **Reminders & Notifications**

* Local scheduled notifications (via system\_notifications plugin)
* Snooze and repeat reminders
* Badge counts on app icon

📂 **Organization Tools**

* Customizable tags and filters
* Search by title, tag, or date
* Kanban-style board view

🚀 **Performance & Reliability**

* MVC pattern for separation of concerns
* Lazy loading of large task lists
* Error handling and retry logic
* Crash reporting via default Flutter error handler

🔒 **User Preferences**

* Dark/light mode support
* Local backup & restore (export/import JSON)
* Theme color customization

🧱 **Architecture (MVC)**

```
├── models/              # Task, Tag, Reminder data classes
├── views/               # UI screens & widgets
├── controllers/         # Business logic and interaction handlers
└── services/            # Data persistence & sync
```

This MVC structure keeps UI, data, and logic decoupled for easy maintenance and testing.

📦 **Tech Stack**

| Package                        | Purpose                          |
| ------------------------------ | -------------------------------- |
| get (optional)                 | Lightweight dependency injection |
| sqflite                        | Local SQL data persistence       |
| connectivity\_plus             | Network status monitoring        |
| flutter\_slidable              | Swipeable task list items        |
| flutter\_staggered\_grid\_view | Kanban-style board layout        |
| pull\_to\_refresh              | Pull-to-refresh functionality    |

⚙️ **Getting Started**

```bash
# Clone the repository
git clone https://github.com/abu-arandas/tasks_app.git
cd offline_tasks_app

# Install dependencies
flutter pub get

# Run the app
flutter run
```

🗂 **Project Structure**

```
lib/
├── main.dart                # App entry point
├── models/                  # Data classes
├── views/                   # UI layer
├── controllers/             # Controllers connecting models and views
└── services/                # Data storage & sync logic
```

🤝 **Contribution Guide**

1. Fork the repo
2. Create your branch:

   ```bash
   git checkout -b feature/YourFeature
   ```
3. Commit your changes:

   ```bash
   git commit -am 'Add new feature'
   ```
4. Push to your branch and open a Pull Request:

   ```bash
   git push origin feature/YourFeature
   ```

🧭 **Roadmap**

* 🌐 Real-time multi-device sync (WebSocket or Firebase)
* 🔄 Conflict resolution UI for merge conflicts
* 🤖 Smart task suggestions using ML
* 🛠️ Plugin system for custom integrations (e.g., calendar, email)
* 🗣️ Multi-language localization

📄 **License**
Distributed under the MIT License. See [LICENSE](https://github.com/your-org/offline_tasks_app/blob/main/LICENSE) for details.

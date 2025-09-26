# tab_drawer_app
# 📱 Experiment 7 - Flutter App using Tab-based Navigation and Drawer Navigation

This Flutter application demonstrates the use of **Tab-based navigation** (via `BottomNavigationBar`) and **Drawer-based navigation** (via `Drawer` widget) in a multi-page mobile app. The app also supports dynamic **theme switching (light/dark mode)** and a simple **search functionality**.

---

## 🔧 Features

- ✅ **Tab-based Navigation** using `BottomNavigationBar`
- ✅ **Drawer Navigation** using `Drawer`
- ✅ **Theme Toggle** (Light/Dark Mode)
- ✅ **Search Filter** on list of fruits
- ✅ **Floating Action Button (FAB)** with snackbar feedback
- ✅ **Navigation to Profile Page** via Drawer
- ✅ Well-structured, stateful widget management

---

## 📁 App Structure

```plaintext
main.dart
├── MyApp (Root Widget with Theme toggle)
├── HomeScreen (Holds Tab and Drawer Navigation)
│   ├── Home Page
│   ├── Search Page (with filterable list)
│   ├── Settings Page (with theme toggle)
│   └── Profile Page (navigated via drawer)
📌 Widgets and Packages Used

MaterialApp, Scaffold, AppBar, Drawer

BottomNavigationBar, TextField, ListView, ListTile

StatefulWidget, StatelessWidget, Navigator

ThemeData.dark(), ThemeData(primarySwatch: Colors.teal)

👤 Developer Info

Name: Veda Pednekar

Email: vedapednekar2106@gmail.com

Experiment: 7

Topic: App using Tab-based Navigation and Drawer Navigation

📄 License

This project is for educational purposes only as part of a Flutter learning experiment. No license is attached.

# Experiment 5: Setting up React Native and Creating a To-Do List App

## Aim

To set up the **React Native** and create a **To-Do List App** that allows users to **add, mark as complete, and delete tasks**.

## Steps Followed

1. **Environment Setup**

   * Installed **Node.js** and **npm**.
   * Installed **React Native CLI / Expo CLI**.
   * Configured **Android Studio Emulator** or real device for testing.

2. **Project Creation**

   * Created a new project named **`TodoListApp`** using React Native.
   * Installed required dependencies (default React Native packages).

3. **UI Design (`App.js`)**

   * **Title**: Added a heading `"My To-Do List"`.
   * **Task Input**: `TextInput` for entering new tasks.
   * **Add Button**: `TouchableOpacity` to add tasks to the list.
   * **Task List**: `FlatList` to display all tasks dynamically.
   * **Checkbox**: Allows marking tasks as completed ✅.
   * **Delete Button**: Removes tasks ❌ from the list.

4. **Logic Implementation**

   * **Add Task**: Saves input task to the list (with unique ID).
   * **Toggle Task**: Marks tasks as completed/incomplete (strike-through effect).
   * **Delete Task**: Removes a task from the list.

5. **Styling**

   * Used `StyleSheet` for modern and clean UI design.
   * Different colors for title, buttons, completed tasks, and background.

6. **Testing**

   * Ran the app on **Android Emulator** and **physical device**.
   * Verified that **adding, toggling, and deleting tasks** works correctly.

## Features Implemented

* Add new tasks.
* Mark tasks as complete/incomplete.
* Delete tasks from the list.
* Clean and responsive UI.

## Expected Output

* **Initial Screen** → Empty task list with input field and `"Add"` button.
* **Add Task** → Typing a task and pressing `"Add"` displays it in the list.
* **Toggle Task** → Tapping the checkbox marks it ✅ completed with strike-through text.

* **Delete Task** → Pressing ❌ removes the selected task.
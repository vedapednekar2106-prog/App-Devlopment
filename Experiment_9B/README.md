# Experiment 9: To-Do List App with SQLite

## Aim
To develop a simple To-Do List application in **React Native** using **Expo SQLite** that allows users to **add, complete, and delete tasks**, with all tasks **persisted locally** in a SQLite database.

---

## Steps Followed

1. **Project Setup**  
   - Created a React Native project using Expo.  
   - Installed SQLite support:  
     ```bash
     expo install expo-sqlite
     ```

2. **Database Setup**  
   - Opened or created the SQLite database:  
     ```javascript
     import * as SQLite from 'expo-sqlite';
     const db = SQLite.openDatabaseSync('tasks.db');
     ```
   - Created a `tasks` table using `runAsync`:  
     ```javascript
     await db.runAsync(`
       CREATE TABLE IF NOT EXISTS tasks (
         id INTEGER PRIMARY KEY AUTOINCREMENT,
         value TEXT,
         completed INTEGER
       );
     `);
     ```

3. **Load Tasks**  
   - Fetched all tasks from the database on app start:  
     ```javascript
     const rows = await db.getAllAsync('SELECT * FROM tasks');
     const tasksFromDB = rows.map(item => ({
       id: item.id.toString(),
       value: item.value,
       completed: item.completed === 1
     }));
     setTaskList(tasksFromDB);
     ```

4. **Add Task**  
   - Inserted a new task into the database:  
     ```javascript
     await db.runAsync('INSERT INTO tasks (value, completed) VALUES (?, ?)', [task, 0]);
     await loadTasks();
     ```

5. **Toggle Task Completion**  
   - Updated the `completed` status in the database:  
     ```javascript
     await db.runAsync('UPDATE tasks SET completed = ? WHERE id = ?', [completed ? 1 : 0, id]);
     await loadTasks();
     ```

6. **Delete Task**  
   - Removed a task from the database:  
     ```javascript
     await db.runAsync('DELETE FROM tasks WHERE id = ?', [id]);
     await loadTasks();
     ```

7. **UI Implementation**  
   - Used `FlatList` to display tasks.  
   - Added a checkbox to toggle completion and a delete button for each task.  
   - Applied strikethrough styling for completed tasks.

---

## Expected Outcome

- Users can **add tasks** using the input field.  
- Tasks are **displayed immediately** in the list.  
- Users can **mark tasks as completed**, which will show **strikethrough text**.  
- Users can **delete tasks**, which removes them from the list and database.  
- All tasks are **persisted locally** in SQLite and remain after closing the app.
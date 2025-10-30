import React, { useEffect, useState } from "react";
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  FlatList,
  StyleSheet,
} from "react-native";
import {
  createTable,
  getAllTasks,
  addTask,
  toggleTask,
  deleteTask,
} from "./dbHelper"; // 👈 import helper functions

export default function App() {
  const [task, setTask] = useState("");
  const [tasks, setTasks] = useState([]);

  useEffect(() => {
    const setup = async () => {
      await createTable();
      await loadTasks();
    };
    setup();
  }, []);

  const loadTasks = async () => {
    const result = await getAllTasks();
    setTasks(result);
  };

  const handleAddTask = async () => {
    if (!task.trim()) return;
    await addTask(task);
    setTask("");
    await loadTasks();
  };

  const handleToggleTask = async (id, isDone) => {
    await toggleTask(id, isDone);
    await loadTasks();
  };

  const handleDeleteTask = async (id) => {
    await deleteTask(id);
    await loadTasks();
  };

  const renderTask = ({ item }) => (
    <View style={styles.taskContainer}>
      <TouchableOpacity onPress={() => handleToggleTask(item.id, item.isDone)}>
        <Text
          style={[
            styles.taskText,
            item.isDone ? styles.completedTask : null,
          ]}
        >
          {item.title}
        </Text>
      </TouchableOpacity>
      <TouchableOpacity onPress={() => handleDeleteTask(item.id)}>
        <Text style={styles.delete}>❌</Text>
      </TouchableOpacity>
    </View>
  );

  return (
    <View style={styles.container}>
      <Text style={styles.title}>My To-Do List</Text>

      <View style={styles.inputContainer}>
        <TextInput
          style={styles.input}
          placeholder="Enter a new task..."
          value={task}
          onChangeText={setTask}
        />
        <TouchableOpacity style={styles.addButton} onPress={handleAddTask}>
          <Text style={styles.addText}>Add</Text>
        </TouchableOpacity>
      </View>

      <FlatList
        data={tasks}
        keyExtractor={(item) => item.id.toString()}
        renderItem={renderTask}
        style={{ marginTop: 20 }}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#d9d9d9",
    padding: 20,
    paddingTop: 60,
  },
  title: {
    fontSize: 24,
    fontWeight: "bold",
  },
  inputContainer: {
    flexDirection: "row",
    alignItems: "center",
    marginTop: 20,
  },
  input: {
    flex: 1,
    borderColor: "#ccc",
    borderWidth: 1,
    borderRadius: 10,
    paddingHorizontal: 10,
    backgroundColor: "#fff",
    height: 40,
  },
  addButton: {
    backgroundColor: "#007bff",
    marginLeft: 8,
    paddingVertical: 10,
    paddingHorizontal: 15,
    borderRadius: 8,
  },
  addText: {
    color: "#fff",
    fontWeight: "bold",
  },
  taskContainer: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    backgroundColor: "#f9f9f9",
    padding: 10,
    borderRadius: 10,
    marginVertical: 5,
  },
  taskText: {
    fontSize: 18,
  },
  completedTask: {
    textDecorationLine: "line-through",
    color: "gray",
  },
  delete: {
    fontSize: 22,
    color: "red",
  },
});

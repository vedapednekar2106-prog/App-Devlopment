# Experiment 1 – JavaScript CRUD Operations on an Array

## Aim
To demonstrate **CRUD (Create, Read, Update, Delete) operations** on an array using JavaScript.

## Theory
- **CRUD** stands for:
  - **Create** → Insert elements into an array.
  - **Read** → Display all elements of the array.
  - **Update** → Modify elements at a specific index.
  - **Delete** → Remove elements from a specific index.
- Arrays in JavaScript are dynamic and allow easy manipulation using built-in methods like:
  - `.push()` → Add element at the end.
  - `.splice()` → Add/Remove elements.
  - Direct indexing (`arr[index]`) → Update an element.

## Steps
1. Initialize an empty array.
2. Implement `create()` function to insert values.
3. Implement `read()` function to display array contents.
4. Implement `update()` function to modify a value at a given index.
5. Implement `remove()` function to delete a value from a given index.
6. Demonstrate the functions using sample data.

## Source Code
You can view the full source code [here](./crud.js).

## Expected output
Inserted 10
Inserted 20
Inserted 30
Array: [10, 20, 30]
Updated 20 to 25
Array: [10, 25, 30]
Deleted 10
Array: [25, 30]
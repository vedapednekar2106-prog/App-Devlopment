# Experiment 2 – Dart I/O and Loops

## Aim
To demonstrate the use of **Dart I/O operations** (input/output) and different types of **loops** in Dart.

## Theory
- `dart:io` library is used for input and output operations in console-based Dart applications.
- `stdin.readLineSync()` is used to take input from the user.
- `stdout.write()` is used to print text without adding a new line.
- Loops in Dart:
  - **For loop** – Used when the number of iterations is known.
  - **While loop** – Runs as long as the condition is true.
  - **Do-while loop** – Executes at least once, even if the condition is false.

## Steps
1. Import the `dart:io` package for input/output operations.
2. Take user input (name and number).
3. Display the input values using `print()`.
4. Implement:
   - **For loop** – Count from `1` to the given number.
   - **While loop** – Countdown from the given number to `1`.
   - **Do-while loop** – Run a block of code at least once.
5. Display outputs for all the above cases.


## Source Code
You can view the full source code [here](./IO&loop.dart).

## Expected Output
Enter your name: Siya Gaonkar
Enter a number: 5
Hello, Siya Gaonkar!
You entered: 5

For loop from 1 to 5:
i = 1
i = 2
i = 3
i = 4
i = 5

While loop countdown:
5
4
3
2
1

Do-while loop runs at least once:
x = 0
x = 1
x = 2
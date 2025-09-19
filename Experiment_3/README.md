#  Experiment 3: Counter App

This project is a simple **Counter App** built using **Android Studio**. It allows users to increment, decrement, and reset a numerical value displayed on the screen.

---

##  Setting Up Android Studio

### Prerequisites:
- Android Studio installed (Arctic Fox or newer)
- JDK 8 or above
- Minimum SDK: API 21 (Lollipop)

### Installation Steps:
1. Download and install **Android Studio** from the [official website](https://developer.android.com/studio).
2. Launch Android Studio and select **"Start a new Android Studio project"**.
3. Choose **"Empty Activity"** and click **Next**.
4. Configure the project:
   - **Name**: Counter App  
   - **Package name**: *(your.package.name)*
   - **Language**: Java or Kotlin
   - **Minimum SDK**: API 21 or above
5. Click **Finish** and wait for the Gradle build to complete.

---

##  Steps Followed in App Development

1. **UI Design (activity_main.xml):**
   - Used `TextView` to display the counter value.
   - Used three `Button` elements: Increase (`+`), Decrease (`-`), and Reset.
   - Used `ConstraintLayout` or `LinearLayout` for basic layout structure.

2. **Strings Resource (res/values/strings.xml):**
   ```xml
   <resources>
       <string name="app_name">counter app</string>
       <string name="increase">+</string>
       <string name="decrease">-</string>
       <string name="reset">Reset</string>
       <string name="textViewDefault">0</string>
   </resources>
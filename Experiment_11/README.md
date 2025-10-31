# **Experiment 11: Fetch Data from TMDB API and Display Movie Results in the App**

---

## **Aim**

To build a **Flutter mobile app** that fetches movie data from the **TMDB (The Movie Database) API**, parses JSON responses, and displays **popular and trending movies** in a scrollable list. The app also provides a **movie details page**, and allows users to **mark favorites**, showcasing different app states like loading and error.

---

## **Materials / Tools Used**

* **Flutter SDK**
* **Dart Programming Language**
* **TMDB API** (Free developer key)
* **Visual Studio Code / Android Studio**
* **Dependencies:**

  * `http` → for REST API calls
  * `provider` → for state management
  * `cupertino_icons` → for iOS-style icons

---

## **Steps Followed**

1. **API Setup**

   * Created an account on [TMDB Developers](https://developer.themoviedb.org/).
   * Generated a **personal API key**.
   * Used TMDB’s `/movie/popular` and `/movie/top_rated` endpoints to fetch movie data.

2. **Project Setup**

   * Created a new Flutter project.
   * Added required dependencies in `pubspec.yaml`:

     ```bash
     flutter pub get
     ```

3. **Folder Structure**

   * `models/` → defines the **Movie** model.
   * `services/` → `ApiService` handles TMDB API calls.
   * `repositories/` → separates data access from UI.
   * `screens/` → contains UI pages like **HomeScreen** and **MovieDetailScreen**.
   * `ui/` → includes reusable widgets and layout components.
   * `main.dart` → serves as the app entry point.

4. **Model Creation**

   * Defined a `Movie` class to store data such as:

     * Movie title
     * Poster image URL
     * Overview/description
     * Release date and rating

5. **API Integration**

   * Used the `http` package to send GET requests.
   * Parsed the JSON response into a list of `Movie` objects.
   * Handled loading and error cases gracefully.

6. **State Management**

   * Used the `provider` package to manage app states:

     * **Loading** → when data is being fetched.
     * **Loaded** → when movie list is ready.
     * **Error** → when API call fails (e.g., network issue or invalid key).

7. **UI Design**

   * Displayed **Popular Movies** using a **ListView** with image thumbnails and descriptions.
   * Added a **Movie Details screen** to show extended information on tap.
   * Implemented a **Favorites section** (optional enhancement).
   * Designed a clean Material UI layout with padding, rounded cards, and responsive elements.

8. **Testing**

   * Verified API calls and JSON parsing.
   * Tested on both emulator and physical device to ensure performance and layout correctness.

---

## **Expected Output**

* **Loading State:** Circular progress indicator shown while fetching movie data.
* **Loaded State:** List of **popular movies** with title, poster, and short overview.
* **Error State:** Message displayed if API request fails.
* **Movie Details View:** Shows poster, title, overview, and release info.
* **Favorites Section:** User can view their marked favorite movies.

---

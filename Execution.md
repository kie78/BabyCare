# Flutter Build Execution Instruction: BabyCare Mobile System

**Reference Files:** `Parents.md`, `Sitters.md`
**Platform Target:** Android & iOS (Strictly)
**Framework:** Flutter
**Objective:** Build the BabyCare system one role at a time, and one screen at a time, using professional-grade Flutter optimization.

---

## 1. Global System & Performance Constraints
* **Design Language:** Custom Theme using **Anika** font family.
* **Color Palette:** Backgrounds: **Universal White** (#FFFFFF); Accents/CTAs: **Berry/Magenta**; Secondary Text: **Dark Grey**.
* **UI Geometry:** High border-radii (**25px–40px**) for all cards, inputs, and primary buttons.
* **Optimization Standards:**
    * Use **const** constructors wherever possible to reduce widget rebuilds.
    * Implement **State Management** (e.g., Provider, Riverpod, or Bloc) to ensure efficient data flow.
    * Optimize assets and images for mobile performance.
    * Ensure responsive layouts using `LayoutBuilder` or `MediaQuery` to match both Android and iOS aspect ratios.
* **Parent-Side Navigation:** In all parent-related screens, the bottom navigation MUST be labeled: **Discover**, **Messages**, and **Account**. There are to be zero instances of "Home" on the parent's side.

---

## 2. Phase 1: The Gateway (Initial Entry)
**Source:** Refer to the "Gateway (Role Selection)" section in `Sitters.md`.
* **Task:** Build the entry screen allowing a user to select between "Parent" or "Babysitter."
* **Requirement:** Ensure smooth Hero animations or transitions between the gateway and the chosen role's auth flow.

---

## 3. Phase 2: The Babysitter Role (Build First)
**Source:** Refer to `Sitters.md`.
Build this role in its entirety immediately after the Gateway. Follow this sequence:
1.  **Sitter Registration Flow:** Step 1 (Personal Info) -> Step 2 (Work Preferences) -> Step 3 (Document Upload).
2.  **Authentication/Status:** Sitter Login and "Application Under Review" (Pending) state.
3.  **Sitter Dashboard:** The main active screen for sitters.
4.  **Sitter Messages & Account:** Sitter-specific communication and profile views.

---

## 4. Phase 3: The Parent Role
**Source:** Refer to `Parents.md`.
Build this role only after Phase 2 is 100% complete:
1.  **Parent Login & Registration:** Standard entry and account creation forms.
2.  **Discover:** The primary sitter search dashboard (Ensure nav label is "Discover").
3.  **Sitter Profile:** The parent-facing view of a specific sitter.
4.  **Messaging:** The "Messages" list and the specific "Inbox" chat thread.
5.  **Account Management:** The "Account" settings menu, "My Profile" edit screen, and "Saved Sitters" list.

---

## Execution Command
**Start now with Phase 1: The Gateway Screen.** Provide the Flutter code (organized into clean, modular widgets) and a visual preview. Do not proceed to any other screen until I have confirmed the Gateway is correct. Once confirmed, you will move to **Phase 2: Sitter Registration Step 1**.

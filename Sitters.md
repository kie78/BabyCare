# BabyCare Mobile Application: Technical UI Architecture

**Role:** Source of Truth Documentation
**Project:** BabyCare Mobile App (Sitter & Gateway Sections)
**Date:** March 2026

---

## 1. Global Visual Standards
* **Background:** Universal White (#FFFFFF)
* **Primary Brand Color:** Berry/Magenta (Used in gradients and solid fills)
* **Secondary Text/Accents:** Dark Grey
* **Typography:** Anika (Applied with varying weights for hierarchy)
* **Aesthetic:** High border-radii (25px–40px) and soft drop shadows for depth.

---

## 2. Gateway (Role Selection)
**Header & Navigation (20%)**
* **Logo:** Centered circular icon with a smiling face/crescent moon in Berry/Magenta.
* **Branding:** "BabyCare" in bold Berry/Magenta; Slogan "Managing trusted care, one family at a time" in lighter weight.

**Main Content Body (55%)**
* **Feature Cards:** Three vertical rounded Universal White cards (90% width).
    * **Connections:** Handshake icon (light pink circle) with Dark Grey body text.
    * **Safety:** Shield icon (light purple circle) regarding admin approval.
    * **Privacy:** Lock icon (light red circle) regarding secure messaging.

**Action Elements**
* **Parent CTA:** Rounded Berry/Magenta gradient button. Label: "I am a Parent" (Universal White).
* **Sitter CTA:** Rounded Universal White button with Berry/Magenta border. Label: "I am a Babysitter" (Berry/Magenta).

---

## 3. Sitter Registration Flow

### Step 1: Personal Information
* **Progress:** 33% (Horizontal Berry/Magenta bar).
* **Form:** Six rounded inputs (90% width) with Berry/Magenta prefix icons: Full Name, Email, Gender (dropdown), Phone (+256 flag), Location, and Password (eye toggle).
* **Action:** Berry/Magenta gradient button "Next: Work Preferences".

### Step 2: Work Preferences
* **Progress:** 66%.
* **Availability:** Calendar icon header. Mon, Tue, Wed pills active in Berry/Magenta.
* **Rates:** "Hourly" dropdown and "UGX" numeric input field.
* **Languages:** Tag-input with English/Luganda chips (Berry/Magenta).
* **Payment:** "Mobile Money" radio button active.
* **Navigation:** Sticky footer with "BACK" (Dark Grey) and "NEXT: DOCUMENT UPLOAD" (Berry/Magenta).

### Step 3: Verification Documents
* **Progress:** 100%.
* **Upload Cards:** Circular Profile Picture placeholder, National ID, LCI Letter, and Resume/CV cards. Icons in light-pink square containers.
* **Action:** Berry/Magenta gradient button "Complete Registration" with checkmark icon.

---

## 4. Authentication & Onboarding Status

### Babysitter Login
* **Inputs:** Email and Password (rounded, Universal White).
* **Status Alert:** Light purple info card: "Your account is pending admin approval."
* **Action:** Solid Berry/Magenta button "Login". Links: "Forgot Password?" and "Sign Up".

### Pending Confirmation
* **Illustration:** Large Berry/Magenta square with white hourglass.
* **Tracking:** Stacked cards for "DOCUMENTS" (3 Files Received) and "VERIFICATION" (In Progress/Ellipsis).
* **Action:** Outlined "Check Status" (refresh icon) and solid Berry/Magenta "LOG OUT" (exit icon).

---

## 5. Sitter-Side Experience

### Home Dashboard
* **Header:** "Hello, Elena" (Bold Berry/Magenta) with profile thumbnail.
* **Availability:** Toggle (Active: Berry/Magenta) with visibility status pill.
* **Analytics:** Light-pink card; metric "48" (Weekly Reach) in large Berry/Magenta.
* **Visitors:** Vertical list of rounded cards; names in bold Dark Grey, timestamps in Berry/Magenta.
* **Bottom Nav:** Persistent rounded Universal White bar. **Home** active in Berry/Magenta.

### Messages & Inbox
* **List View:** Rounded conversation cards. Unread messages marked by Berry/Magenta avatar rings and dot indicators.
* **Inbox Thread:** Back arrow/Call icon in Berry/Magenta. Incoming messages (Light Grey, Left); Outgoing messages (Berry/Magenta, Right). Pill-shaped input field + circular Berry/Magenta send button.

### Account (Profile)
* **Avatar:** Large profile image with Berry/Magenta border ring and camera overlay.
* **Cards:** "Work Preferences" (Rate/Days/Location) and "Preferred Payment Method" cards with edit icons.
* **Action:** Full-width solid Berry/Magenta "Save Changes" button.
* **Bottom Nav:** **Account** active in Berry/Magenta.

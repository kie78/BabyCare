# BabyCare Mobile Application: Parent-Side UI Architecture

**Role:** Technical Source of Truth
**Target:** Parent User Interface
**Revision:** 2.0 (Discover Navigation Update)

---

## 1. Global Design System
* **Primary Theme:** Universal White (#FFFFFF)
* **Accent Color:** Berry/Magenta (Used for branding, active states, and CTAs)
* **Typography:** **Anika** * *Headers:* Bold Berry/Magenta or Bold Dark Grey.
    * *Labels/Placeholders:* Regular Dark Grey.
* **Components:** Rounded inputs/cards (25px–40px radius) with soft elevation shadows.

---

## 2. Authentication & Onboarding

### Parent Login
* **Header:** Centered white circle with Berry/Magenta heart icon. "Welcome Back" header.
* **Form:** Rounded inputs for "Phone or Email" (@ icon) and "Password" (lock icon).
* **Interactions:** "Show" password toggle and "Forgot Password?" link in Berry/Magenta.
* **Primary CTA:** Solid Berry/Magenta button: **Log In**.
* **Footer:** "New to BabyCare? **Create Account**" (Underlined/Bold Magenta).

### Parent Account Creation
* **Header:** Left-aligned "Join BabyCare" with descriptive subtitle.
* **Inputs:** Seven rounded fields with leading icons:
    * Full Name (Person)
    * Occupation (Briefcase)
    * Email Address (Envelope)
    * Preferred Hours (Clock)
    * Phone Number (Flag/+256 selector)
    * Primary Location (Map Pin)
    * Password (Lock + Eye visibility toggle)
* **Primary CTA:** Solid Berry/Magenta button: **Create Account**.

---

## 3. Core Navigation & Discovery

### Discover (Main Search)
* **Header:** "Discover" (Bold Magenta) with user profile thumbnail.
* **Search Utility:** Rounded search bar ("Search for a sitter...") + Square Magenta filter/location button.
* **Section:** "Available Sitters" header with "See all" link.
* **Sitter Cards:** Vertical list of White rounded cards.
    * *Left:* Name (Verified), Gender, Rate (Bold Magenta), and Location.
    * *Right:* Profile avatar with Magenta border-ring and floating Bookmark toggle.
* **Bottom Nav:** **Discover** (Active: Solid icon/Label/Dot indicator), Messages, Account.

### Sitter Profile (Detailed View)
* **Header:** "Sitter Profile" title with Back arrow and Heart (Save) icon.
* **Identity:** Large centered avatar with Magenta ring; Sitter Name in bold.
* **Info Card:** White rounded container.
    * *Metadata:* Gender, Location, and Rate rows with light-pink circular icons.
    * *Availability:* Horizontal pill-tags (Active: Light Pink; Inactive: Light Grey).
    * *Languages:* Text list (e.g., English, Luganda).
* **Primary CTA:** Fixed footer button: **Message [Sitter Name]**.

---

## 4. Communication & Messaging

### Messages (Inbox List)
* **Header:** "Messages" (Bold Magenta) with Back arrow.
* **List:** Vertical stack of conversation cards.
    * *Visuals:* Avatars with Magenta rings for active threads; Unread dot indicators.
    * *Meta:* Bold names, message snippet, and Magenta timestamps (e.g., 5M AGO).
* **Bottom Nav:** Discover, **Messages** (Active: Solid icon/Label/Dot indicator), Account.

### Chat Thread (Inbox)
* **Header:** Sitter name/avatar with Magenta Phone (Call) icon.
* **Messages:** * *Incoming:* Light Grey bubbles (Left-aligned) with Dark Grey text.
    * *Outgoing:* Solid Berry/Magenta bubbles (Right-aligned) with White text.
* **Input:** Pill-shaped text field ("Type a message...") + Circular Magenta Send button.

---

## 5. Account & Profile Management

### Account Settings
* **Menu Cards:** Two large White cards with Magenta icons.
    * "My Profile" (Edit name, phone, location).
    * "Saved Sitters" (Access bookmarked sitters).
* **Primary CTA:** Outlined Berry/Magenta button: **Log Out**.
* **Bottom Nav:** Discover, Messages, **Account** (Active: Solid icon/Label/Dot indicator).

### My Profile (Edit View)
* **Header:** "Profile" title (Dark Grey) with Back arrow.
* **Identity:** Avatar with Magenta ring and Camera overlay icon.
* **Fields:** Six rounded cards (Name, Occupation, Hours, Phone, Location, Email) each featuring a Magenta pencil Edit icon.
* **Primary CTA:** Solid Berry/Magenta button: **Save Changes**.

### Saved Sitters
* **Header:** "Saved Sitters" (Magenta) with overflow (ellipsis) menu.
* **List:** Displays bookmarked sitter cards. Includes Magenta gender symbols and active (filled) Bookmark icons on avatars.

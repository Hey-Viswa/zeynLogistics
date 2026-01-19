# 🗺️ Project Roadmap & Todo

## 🚀 Frontend Remaining Structure

### 1. Maps Integration (High Priority)
- [ ] **Google Maps / Mapbox Setup**: Get API Keys.
- [ ] **Home Screen**: Show user/driver current location.
- [ ] **Booking Flow**: Allow users to drag/drop pins for Pickup and Drop-off.
- [ ] **Live Tracking**: Display polyline route from Driver to Pickup, and Pickup to Drop.

### 2. Profile & Settings
- [x] **Profile Screen**: Edit Name, Phone, Email.
- [x] **Trip History**: List of past completes trips.
- [x] **Settings**: Toggle Theme (Light/Dark/Dynamic), Notifications.
- [x] **Internal Logistics**: Removed pricing and payment methods.

---

## ⚙️ Backend Architecture (The "Real" Work)

### 1. Authentication Service
- [x] **Phone/Google Auth**: Firebase Auth Logic Implemented.
- [x] **Session Management**: Secure handling for "Driver" vs "Requester" sessions.

### 2. Database (Firestore)
- [x] **Users Collection**: Profiles, roles, compressed Base64 images.
- [x] **Trips Collection**: Pickup/Drop, vehicle details, internal booking status.

### 3. Trip Logic & Matchmaking API
- [x] **Create Trip**: Internal booking request creation.
- [x] **Accept Trip**: Driver finding and acceptance logic.
- [x] **Update Status**: Driver marks "On Way", "Completed".

### 4. Real-time Layer (StreamProvider)
- [x] **Live Updates**: UI updates instantly when trips are created or modifying.

### 5. Admin Panel / Verification
- [ ] **Driver Verification**: Dashboard to view and approve/reject driver documents.
- [ ] **Trip Monitoring**: View active trips map.

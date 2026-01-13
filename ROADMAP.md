# 🗺️ Project Roadmap & Todo

## 🚀 Frontend Remaining Structure

### 1. Maps Integration (High Priority)
- [ ] **Google Maps / Mapbox Setup**: Get API Keys.
- [ ] **Home Screen**: Show user/driver current location.
- [ ] **Booking Flow**: Allow users to drag/drop pins for Pickup and Drop-off.
- [ ] **Live Tracking**: Display polyline route from Driver to Pickup, and Pickup to Drop.

### 2. Profile & Settings
- [ ] **Profile Screen**: Edit Name, Phone, Email.
- [ ] **Trip History**: List of past completes trips.
- [ ] **Settings**: Toggle Theme (Light/Dark), Notifications.

---

## ⚙️ Backend Architecture (The "Real" Work)

### 1. Authentication Service
- [ ] **Phone Auth**: Integrate Firebase Auth or Twilio for real SMS OTP.
- [ ] **Session Management**: Secure JWT handling for "Driver" vs "Requester" sessions.

### 2. Database (PostgreSQL / MongoDB)
- [ ] **Users Table**: Store profiles, ratings, and auth IDs.
- [ ] **Drivers Table**: Vehicle details, license status (`pending`, `verified`, `rejected`).
- [ ] **Trips Table**: Pickup/Drop coords, fare, status, timestamps.

### 3. Trip Logic & Matchmaking API
- [ ] **Create Trip**: Endpoint to calculate fare and broadcast to drivers.
- [ ] **Accept Trip**: Race condition handling (first driver gets it).
- [ ] **Update Status**: Driver marks "Arrived", "Picked Up", "Dropped".

### 4. Real-time Layer (Socket.io / Firebase)
- [ ] **Location Streaming**: Websocket channel for drivers to stream `lat,lng`.
- [ ] **Status Updates**: Push notifications for "Driver Found", "Trip Started".

### 5. Admin Panel
- [ ] **Driver Verification**: Dashboard to view and approve/reject driver documents.
- [ ] **Trip Monitoring**: View active trips map.

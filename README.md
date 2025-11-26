# ZenScore - Health & Recovery Tracking iOS App

<div align="center">

![iOS](https://img.shields.io/badge/iOS-18.6+-black.svg)
![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)
![Firebase](https://img.shields.io/badge/Firebase-12.6.0-yellow.svg)
![HealthKit](https://img.shields.io/badge/HealthKit-Enabled-green.svg)

**ZenScore** is a powerful iOS application that tracks your health metrics and calculates a personalized daily recovery score. By integrating with Apple HealthKit, ZenScore provides actionable insights, trends, and recommendations to optimize your wellness and training.

</div>

---

## 📱 Features

### 🏠 Health Dashboard
- **Daily Recovery Score** - Real-time calculation (0-100) based on multiple health metrics
- **Circular Progress Visualization** - Beautiful animated recovery score display with color-coded status
- **Key Metrics Cards** - Sleep duration, resting heart rate, HRV (SDNN), and activity load
- **Auto-refresh** - Automatically fetches latest health data when app opens

### 📊 Trends & Analytics
- **Weekly and Monthly Views** - Toggle between time periods
- **Interactive Line Charts** - Visualize recovery score trends over time
- **Metric-Specific Charts** - Deep dive into sleep, HRV, resting HR, and activity load
- **Percentage Change Indicators** - Track improvement or decline in metrics
- **Summary Statistics** - Average scores, peak activity days, and key insights
- **Monthly Progress Reports** - Automated insights comparing first and second half of month

### 💡 Personalized Insights
- **Weekly Metrics Analysis** - Compare current week to previous week with trend indicators
- **Smart Recommendations** - AI-driven suggestions based on your health data
  - Sleep optimization tips
  - Activity level adjustments
  - Stress management techniques
  - Hydration and wellness reminders
- **Mark as Done** - Track completion of recommended actions
- **Weekly Summary** - Natural language insights about your overall wellness

### 🔐 Authentication & User Management
- **Firebase Authentication** - Secure email/password login
- **User Profile Creation** - Store user data in Firestore
- **Social Login Ready** - UI prepared for Google and Apple Sign-In
- **Password Reset** - Email-based password recovery

### 🏥 HealthKit Integration
- **Sleep Analysis** - Track sleep duration and quality
- **Resting Heart Rate** - Monitor cardiovascular recovery
- **Heart Rate Variability (HRV SDNN)** - Measure nervous system balance
- **Active Energy** - Calculate calories burned
- **Step Count** - Track daily movement
- **Activity Load** - Combined metric from energy and steps

### 🎨 Modern UI/UX
- **Dark Theme** - Beautiful black background with purple accents
- **Custom Tab Bar** - Smooth animations and active state indicators
- **Gradient Buttons** - Eye-catching interactive elements with glow effects
- **Animated Splash Screen** - Professional app launch experience
- **Color-Coded Status** - Green (excellent) to red (poor) recovery indicators

---

## 🔧 Requirements

### System Requirements
- **iOS:** 18.6 or later
- **Xcode:** 16.0 or later (for iOS 18.6 support)
- **macOS:** Sonoma 14.0 or later
- **Device:** iPhone or iPad
- **Swift:** 5.0+

### Dependencies

The app uses **Swift Package Manager** with the following packages:

- **Firebase iOS SDK** (v12.6.0)
  - FirebaseAuth
  - FirebaseFirestore
  - FirebaseAnalytics
  - FirebaseMessaging
  - FirebaseStorage

### HealthKit Entitlements

The app requires the following HealthKit capabilities:
- Sleep Analysis (read)
- Resting Heart Rate (read)
- Heart Rate Variability SDNN (read)
- Active Energy Burned (read)
- Step Count (read)

---

## 🚀 Installation Instructions

### 1. Clone the Repository

```bash
cd ~/Desktop
git clone <your-repository-url>
cd ZenScoreOne
```

### 2. Firebase Setup

**Important:** You need to set up your own Firebase project.

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or use an existing one
3. Add an iOS app with your bundle identifier: `com.yourcompany.ZenScoreOne`
4. Download the `GoogleService-Info.plist` file
5. Replace the existing `GoogleService-Info.plist` in `ZenScoreOne/` directory
6. Enable the following in Firebase Console:
   - **Authentication** → Email/Password provider
   - **Firestore Database** → Create database in production mode
   - **Analytics** (optional)

### 3. Open Project in Xcode

```bash
open ZenScoreOne.xcodeproj
```

### 4. Install Dependencies

Xcode will automatically resolve Swift Package Manager dependencies on first build. If not:

1. Go to **File** → **Packages** → **Resolve Package Versions**
2. Wait for Firebase SDK to download

### 5. Configure Signing & Capabilities

1. Select the **ZenScoreOne** target
2. Go to **Signing & Capabilities**
3. Select your **Development Team**
4. Change **Bundle Identifier** if needed
5. Verify **HealthKit** capability is enabled

### 6. Build and Run

1. Select a physical iOS device (Simulator doesn't support HealthKit)
2. Click **Run** (⌘R)
3. Grant HealthKit permissions when prompted

---

## 📁 Project Structure

```
ZenScoreOne/
├── ZenScoreOne/
│   ├── App Entry
│   │   ├── ZenScoreOneApp.swift          # App initialization with Firebase
│   │   ├── SplashScreenView.swift        # Splash screen with animation
│   │   └── ZenScoreOne.entitlements      # HealthKit capabilities
│   │
│   ├── Views/
│   │   ├── ContentView.swift             # Main container with tab navigation
│   │   ├── HomeView.swift                # Recovery score dashboard
│   │   ├── Trends&Analytics.swift        # Charts and trends visualization
│   │   ├── InsightView.swift             # Recommendations and insights
│   │   ├── LogInView.swift               # Authentication - Login
│   │   └── SignUpView.swift              # Authentication - Sign Up
│   │
│   ├── Services/
│   │   ├── HealthDataService.swift       # High-level HealthKit data processing
│   │   ├── RecommendationService.swift   # Generate personalized recommendations
│   │   └── TrendService.swift            # Compute trends and insights
│   │
│   ├── Managers/
│   │   ├── HealthKitManager.swift        # Low-level HealthKit operations
│   │   ├── AuthManager.swift             # Firebase Authentication
│   │   └── FirestoreManager.swift        # Firebase Firestore operations
│   │
│   ├── Models/
│   │   └── HealthModels.swift            # Data models (DailyHealthSnapshot, etc.)
│   │
│   ├── Extensions/
│   │   └── ColorExtensions.swift         # Custom colors and theme
│   │
│   ├── TestingAndOptimization/
│   │   ├── UnitTests.swift               # Unit tests for services
│   │   ├── UITestSuite.swift             # UI automation tests
│   │   ├── PerformanceTests.swift        # Performance benchmarks
│   │   ├── HealthKitTestUtils.swift      # Testing utilities
│   │   ├── CacheManager.swift            # Data caching
│   │   ├── OptimizedHealthDataService.swift
│   │   └── PerformanceOptimizationHelpers.swift
│   │
│   ├── Resources/
│   │   ├── Assets.xcassets/              # Images, icons, colors
│   │   ├── GoogleService-Info.plist      # Firebase configuration
│   │   └── Info.plist                    # App configuration
│   │
│   └── README.txt
│
└── ZenScoreOne.xcodeproj/                # Xcode project file
```

### Architecture Pattern

The app follows **MVVM (Model-View-ViewModel)** architecture:
- **Views:** SwiftUI views for UI
- **ViewModels:** `@StateObject` and `@ObservedObject` for state management
- **Models:** Data structures for health metrics
- **Services:** Business logic and data processing
- **Managers:** Low-level API interactions (HealthKit, Firebase)

---

## 🛠 Technologies Used

### Core Technologies
- **Swift 5.0** - Primary programming language
- **SwiftUI** - Modern declarative UI framework
- **Combine** - Reactive programming for data flow
- **MVVM Architecture** - Separation of concerns

### Apple Frameworks
- **HealthKit** - Access to health and fitness data
- **Foundation** - Core functionality
- **UIKit** (limited) - Interoperability where needed

### Third-Party Services
- **Firebase Auth** - User authentication
- **Firebase Firestore** - NoSQL cloud database
- **Firebase Analytics** - User behavior tracking
- **Firebase Messaging** - Push notifications (prepared)
- **Firebase Storage** - File storage (prepared)

### UI Components
- Custom circular progress indicators
- Animated line charts
- Gradient buttons with glow effects
- Custom tab bar with image assets
- Dark theme with purple accent colors

---

## ⚙️ Configuration

### Firebase Configuration

**Required:** `GoogleService-Info.plist` must be properly configured with your Firebase project.

```
ZenScoreOne/GoogleService-Info.plist
```

This file contains:
- API keys
- Project IDs
- Bundle identifiers
- OAuth client IDs

### HealthKit Permissions

The app requests the following permissions on first launch:
- Sleep Analysis
- Resting Heart Rate
- Heart Rate Variability
- Active Energy Burned
- Step Count

**Note:** These permissions can be managed in iOS Settings → Privacy & Security → Health → ZenScore

### Color Theme Customization

Colors are defined in `ColorExtensions.swift`:

```swift
// Primary Colors
Color.zenAccent      // Purple: #A201E5
Color.zenPrimary     // Black: #000000
Color.zenSecondary   // Light Purple: #ECA9FF

// Metric Colors
Color.zenSleep       // Blue: #60a5fa
Color.zenHeart       // Red: #ef4444
Color.zenHRV         // Green: #22c55e
Color.zenActivity    // Orange: #f97316
```

### Recovery Score Algorithm

The recovery score (0-100) is calculated from:
- **Sleep Duration (25%)** - Optimal: 7-9 hours
- **Resting Heart Rate (25%)** - Optimal: 50-60 bpm
- **HRV SDNN (30%)** - Higher is better (50+ ms)
- **Activity Load (20%)** - Optimal: 300-600 load

Implementation: `DailyHealthSnapshot.calculateRecoveryScore()` in `HealthModels.swift`

---

## 🐛 Known Issues & Limitations

### Current Limitations

1. **Profile Tab** - Not yet implemented (shows "Coming Soon")
2. **Social Login** - Google and Apple Sign-In UI present but not functional
3. **Push Notifications** - Firebase Messaging integrated but not activated
4. **Data Sync** - Health data saved to Firestore but not retrieved on other devices
5. **iOS Simulator** - HealthKit not available in simulator, must use physical device

### Troubleshooting

**HealthKit Authorization Issues:**
- Ensure you're running on a physical device
- Check Settings → Privacy → Health → ZenScore for permissions
- Restart the app if data doesn't load

**Firebase Authentication Errors:**
- Verify `GoogleService-Info.plist` is correct
- Check Firebase Console for enabled auth methods
- Ensure internet connection is active

**Build Errors:**
- Clean build folder: Product → Clean Build Folder (⇧⌘K)
- Reset packages: File → Packages → Reset Package Caches
- Update to latest Xcode version

---

## 🗺 Roadmap

### Planned Features

- [ ] **User Profile Screen** - View and edit user information
- [ ] **Google Sign-In** - Implement Google OAuth
- [ ] **Apple Sign-In** - Implement Sign in with Apple
- [ ] **Push Notifications** - Daily recovery score reminders
- [ ] **Data Export** - Export health data as CSV/PDF
- [ ] **Widget Support** - Home screen widget for quick recovery score
- [ ] **Apple Watch App** - Companion watchOS app
- [ ] **Social Features** - Share achievements with friends
- [ ] **Goal Setting** - Set and track wellness goals
- [ ] **Advanced Analytics** - ML-powered predictions
- [ ] **Dark/Light Mode Toggle** - User preference for theme
- [ ] **Localization** - Multi-language support

### In Development

- Performance optimizations (caching layer)
- Enhanced error handling
- Comprehensive unit test coverage
- UI/UX improvements based on user feedback

---

## 🧪 Testing

### Unit Tests

Located in `TestingAndOptimization/UnitTests.swift`

```bash
# Run tests in Xcode
Product → Test (⌘U)
```

Tests cover:
- Recovery score calculation
- Health data processing
- Recommendation generation
- Trend analysis algorithms

### UI Tests

Located in `TestingAndOptimization/UITestSuite.swift`

- Login flow
- Navigation between tabs
- Data refresh operations

### Performance Tests

Located in `TestingAndOptimization/PerformanceTests.swift`

- HealthKit data fetch performance
- Chart rendering speed
- Memory usage optimization

---

## 🤝 Contributing

We welcome contributions to ZenScore! Here's how you can help:

### Getting Started

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/AmazingFeature`
3. Commit your changes: `git commit -m 'Add some AmazingFeature'`
4. Push to the branch: `git push origin feature/AmazingFeature`
5. Open a Pull Request

### Development Guidelines

- Follow Swift API Design Guidelines
- Write descriptive commit messages
- Add unit tests for new features
- Update documentation as needed
- Ensure code builds without warnings
- Test on physical devices before submitting PR

### Code Style

- Use SwiftLint for code formatting (if available)
- Follow MVVM architecture patterns
- Keep views under 300 lines
- Extract reusable components
- Document complex algorithms

---

## 📄 License

This project is created for educational purposes. 

---

## 👥 Contact & Support

### Developer

**Supuni Nethsarani**
- Project Created: November 19, 2025

### Support

- **Issues:** [GitHub Issues](https://github.com/yourusername/ZenScoreOne/issues)
- **Discussions:** [GitHub Discussions](https://github.com/yourusername/ZenScoreOne/discussions)
- **Email:** your.email@example.com

### Acknowledgments

- Apple HealthKit Documentation
- Firebase iOS SDK
- SwiftUI Community
- MADD Project Contributors

---

## 🔒 Privacy & Security

### Data Collection

- **Health Data:** Stored locally and optionally synced to Firebase Firestore
- **User Credentials:** Managed securely by Firebase Authentication
- **Analytics:** Basic usage analytics through Firebase (can be disabled)

### Data Protection

- All health data requests require explicit user permission
- Firebase security rules should be configured for production
- No health data is shared with third parties
- Users can delete their account and data at any time

### Security Best Practices

- Never commit `GoogleService-Info.plist` to public repositories
- Use environment variables for sensitive configuration
- Enable Firebase security rules in production
- Regular security audits recommended

---

<div align="center">

**Built with ❤️ using SwiftUI and HealthKit**

⭐ Star this repo if you find it helpful!

</div>

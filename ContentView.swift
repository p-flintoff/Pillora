//
//  ContentView.swift
//  Medication Tracking App
//
//  Created by Thomas Flintoff on 24/08/2025.
//
import SwiftUI
import UIKit
import UserNotifications

func requestNotificationPermission() {
    let center = UNUserNotificationCenter.current()
    center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        if granted {
            print("Notifications allowed")
        } else {
            print("Notifications denied")
        }
    }
}

func scheduleMedicationNotification(for medication: MedicationSchedule) {
    let content = UNMutableNotificationContent()
    content.title = "Time for \(medication.name)"
    content.body = "Don't forget to take your medication at \(medication.time)!"
    content.sound = .default
    
    // Extract hour and minute from medication time (assuming "08:00 AM" format)
    let formatter = DateFormatter()
    formatter.dateFormat = "hh:mm a"
    if let date = formatter.date(from: medication.time) {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: medication.id.uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
}



// MARK: - Sample Medication Generator
func generateSampleMedications() -> [MedicationSchedule] {
    let calendar = Calendar.current
    let today = Date()
    var meds: [MedicationSchedule] = []

    for dayOffset in 0..<7 {
        let date = calendar.date(byAdding: .day, value: dayOffset, to: today)!
        meds.append(contentsOf: [
            MedicationSchedule(name: "Aspirin", time: "08:00 AM", status: .completed, color: .blue, date: date),
            MedicationSchedule(name: "Vitamin D", time: "12:00 PM", status: .pending, color: .green, date: date),
            MedicationSchedule(name: "Ibuprofen", time: "06:00 PM", status: .missed, color: .red, date: date),
            MedicationSchedule(name: "Omega 3", time: "09:00 PM", status: .pending, color: .purple, date: date)
        ])
    }
    return meds
}


struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) private var presentationMode
    var sourceType: UIImagePickerController.SourceType = .camera

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
// MARK: - Medication Models
struct MedicationSchedule: Identifiable {
    let id = UUID()
    let name: String
    let time: String
    var status: MedicationStatus
    let color: Color
    let date: Date
}


struct MedicationScheduleView: View {
    @Binding var currentScreen: AppScreen
    
    
    // Sample medication data
    struct Medication: Identifiable {
        let id = UUID()
        let name: String
        let time: String
        let status: MedicationStatus
        let color: Color
        let streakDays: Int
        let achievements: [String]
    }

    let medications: [Medication] = [
        Medication(name: "Aspirin", time: "08:00 AM", status: .pending, color: .blue, streakDays: 3, achievements: ["7-Day Streak"]),
        Medication(name: "Vitamin D", time: "12:00 PM", status: .completed, color: .green, streakDays: 7, achievements: ["First 10 Medications"]),
        Medication(name: "Ibuprofen", time: "06:00 PM", status: .missed, color: .red, streakDays: 0, achievements: []),
        Medication(name: "Omega 3", time: "09:00 PM", status: .pending, color: .purple, streakDays: 5, achievements: ["Perfect Week"])
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Medication Schedule")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(medications) { med in
                            VStack(spacing: 10) {
                                HStack(spacing: 16) {
                                    // Status circle
                                    ZStack {
                                        Circle()
                                            .fill(med.color.opacity(0.2))
                                            .frame(width: 60, height: 60)
                                        Image(systemName: med.status.icon)
                                            .font(.title2)
                                            .foregroundColor(med.color)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(med.name)
                                            .font(.headline)
                                            .fontWeight(.medium)
                                        Text(med.time)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Button(action: {}) {
                                        Image(systemName: "ellipsis")
                                            .font(.title3)
                                            .foregroundColor(.gray)
                                    }
                                }
                                
                                // Streak & Achievements
                                if med.streakDays > 0 || !med.achievements.isEmpty {
                                    HStack(spacing: 10) {
                                        if med.streakDays > 0 {
                                            HStack(spacing: 4) {
                                                Image(systemName: "flame.fill")
                                                    .foregroundColor(.orange)
                                                Text("\(med.streakDays)-day streak")
                                                    .font(.caption)
                                                    .foregroundColor(.orange)
                                            }
                                        }
                                        
                                        ForEach(med.achievements, id: \.self) { achievement in
                                            HStack(spacing: 4) {
                                                Image(systemName: "star.fill")
                                                    .foregroundColor(.yellow)
                                                Text(achievement)
                                                    .font(.caption2)
                                                    .foregroundColor(.yellow)
                                            }
                                            .padding(4)
                                            .background(Color.yellow.opacity(0.2))
                                            .cornerRadius(8)
                                        }
                                    }
                                    .padding(.top, 4)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(LinearGradient(
                                        colors: [Color.white, Color.gray.opacity(0.05)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                            )
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 4)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
                
                Button(action: {
                    currentScreen = .settings
                }) {
                    Text("Go to Settings")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(25)
                        .padding(.horizontal)
                }
                .padding(.bottom, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
        }
    }
}
// MARK: - Main Content View
struct ContentView: View {
    @State private var currentScreen: AppScreen = .onboarding
    @State private var selectedUserType: UserType = .patient
    @State private var medications: [MedicationSchedule] = generateSampleMedications()
    
    @ViewBuilder
    var body: some View {
        
        switch currentScreen {
        case .onboarding:
            OnboardingView(
                selectedUserType: $selectedUserType,
                currentScreen: $currentScreen
            )
        case .createAccount:
            CreateAccountView(currentScreen: $currentScreen)
        case .termsAndConditions:
            TermsAndConditionsView(currentScreen: $currentScreen)
        case .pillScanning:
            PillScanningView(currentScreen: $currentScreen)
        case .medicationSchedule:
            MedicationScheduleView(currentScreen: $currentScreen)
        case .settings:
            SettingsView(currentScreen: $currentScreen)
        case .profile:
            ProfileView(currentScreen: $currentScreen, selectedUserType: selectedUserType)
        case .statistics:
            StatisticsView(currentScreen: $currentScreen, medications: medications)
        case .caregivers:
            CaregiversView(currentScreen: $currentScreen)

        }
        }

}

// MARK: - Enums
enum AppScreen {
    case onboarding, createAccount, termsAndConditions, pillScanning, medicationSchedule, settings, profile, statistics, caregivers
}

enum UserType {
    case patient, caregiver
}

// MARK: - Onboarding View
struct OnboardingView: View {
    @Binding var selectedUserType: UserType
    @Binding var currentScreen: AppScreen
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.blue]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                Text("Who are you")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                HStack(spacing: 30) {
                    UserTypeButton(
                        title: "Patient",
                        icon: "person.circle",
                        isSelected: selectedUserType == .patient
                    ) {
                        selectedUserType = .patient
                    }
                    
                    UserTypeButton(
                        title: "Caregiver",
                        icon: "person.2.circle",
                        isSelected: selectedUserType == .caregiver
                    ) {
                        selectedUserType = .caregiver
                    }
                }
                
                Spacer()
                
                Button(action: {
                    currentScreen = .createAccount
                }) {
                    Text("NEXT")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(25)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
            }
        }
    }
}

// MARK: - User Type Button
struct UserTypeButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Circle()
                    .fill(isSelected ? Color.white : Color.white.opacity(0.3))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 30))
                            .foregroundColor(isSelected ? .blue : .white)
                    )
                
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
        }
    }
}

struct StatisticsView: View {
    @Binding var currentScreen: AppScreen
    let medications: [MedicationSchedule]
    
    var totalMedications: Int {
        medications.count
    }
    
    var takenOnTime: Int {
        medications.filter { $0.status == .completed }.count
    }
    
    var missed: Int {
        medications.filter { $0.status == .missed }.count
    }
    
    var pending: Int {
        medications.filter { $0.status == .pending }.count
    }
    
    var adherencePercentage: Double {
        guard totalMedications > 0 else { return 0 }
        return Double(takenOnTime) / Double(totalMedications)
    }
    
    var achievements: [String] {
        var list = [String]()
        if takenOnTime >= 7 { list.append("7-Day Streak") }
        if takenOnTime >= 10 { list.append("First 10 Medications") }
        if adherencePercentage == 1.0 { list.append("Perfect Week") }
        return list
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.2)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Header
                        Text("📊 My Statistics")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.top)
                        
                        // Ring progress chart
                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                                .frame(width: 150, height: 150)
                            
                            Circle()
                                .trim(from: 0.0, to: CGFloat(adherencePercentage))
                                .stroke(
                                    AngularGradient(
                                        gradient: Gradient(colors: [.blue, .green]),
                                        center: .center
                                    ),
                                    style: StrokeStyle(lineWidth: 20, lineCap: .round)
                                )
                                .rotationEffect(.degrees(-90))
                                .frame(width: 150, height: 150)
                                .animation(.easeInOut, value: adherencePercentage)
                            
                            VStack {
                                Text("\(Int(adherencePercentage * 100))%")
                                    .font(.title2)
                                    .bold()
                                Text("Adherence")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // Stats cards
                        HStack(spacing: 16) {
                            StatCard(title: "Taken", value: takenOnTime, color: .green, icon: "checkmark.circle.fill")
                            StatCard(title: "Missed", value: missed, color: .red, icon: "xmark.circle.fill")
                            StatCard(title: "Pending", value: pending, color: .orange, icon: "clock.fill")
                        }
                        .padding(.horizontal)
                        
                        // Achievements section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("🏅 Achievements")
                                .font(.headline)
                                .padding(.leading)
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                ForEach(achievements, id: \.self) { achievement in
                                    VStack(spacing: 8) {
                                        Image(systemName: "star.fill")
                                            .foregroundColor(.yellow)
                                            .font(.title2)
                                        Text(achievement)
                                            .font(.caption)
                                            .multilineTextAlignment(.center)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 3)
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            currentScreen = .medicationSchedule
                        }) {
                            Text("Back to Schedule")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.blue, .purple]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(25)
                                .padding(.horizontal)
                        }
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        currentScreen = .settings
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
    }
}

// MARK: - Stat Card Component
struct StatCard: View {
    let title: String
    let value: Int
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.largeTitle)
            Text("\(value)")
                .font(.title)
                .bold()
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 3)
    }
}

struct CaregiversView: View {
    @Binding var currentScreen: AppScreen
    
    // Sample caregiver data
    struct Caregiver: Identifiable {
        let id = UUID()
        let name: String
        let role: String
        let imageName: String
        let color: Color
    }
    
    let caregivers: [Caregiver] = [
        Caregiver(name: "Jeff Bezos", role: "Primary Caregiver", imageName: "stethoscope.circle.fill", color: .green),
        Caregiver(name: "Jane Doe", role: "Assistant Caregiver", imageName: "person.circle.fill", color: .blue),
        Caregiver(name: "John Smith", role: "Family Caregiver", imageName: "person.crop.circle.fill", color: .purple)
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("My Caregivers")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)
                
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(caregivers) { caregiver in
                            HStack(spacing: 16) {
                                Image(systemName: caregiver.imageName)
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(caregiver.color)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(caregiver.name)
                                        .font(.headline)
                                    Text(caregiver.role)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    // Action for contacting or viewing caregiver details
                                }) {
                                    Image(systemName: "ellipsis")
                                        .font(.title3)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 4)
                            )
                            .padding(.horizontal)
                        }
                    }
                }
                
                Spacer()
                
                Button(action: {
                    currentScreen = .settings
                }) {
                    Text("Back to Settings")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(25)
                        .padding(.horizontal)
                }
                .padding(.bottom, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        currentScreen = .settings
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
    }
}
struct PatientScheduleView: View {
    @Binding var currentScreen: AppScreen
    let patientName: String
    @State var medications: [MedicationSchedule] = generateSampleMedications()
    
    var body: some View {
        NavigationView {
            VStack {
                Text("\(patientName)'s Schedule")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)
                
                ScrollView {
                    ForEach(medications) { med in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(med.name)
                                    .font(.headline)
                                Text(med.time)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Button(action: {
                                // Caregiver marks dose as taken/missed
                                toggleMedicationStatus(med)
                            }) {
                                Image(systemName: med.status.icon)
                                    .foregroundColor(med.color)
                                    .font(.title2)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                        .padding(.horizontal)
                    }
                }
                
                Button(action: {
                    currentScreen = .caregivers
                }) {
                    Text("Back to Caregivers")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(25)
                        .padding()
                }
            }
        }
    }
    
    private func toggleMedicationStatus(_ medication: MedicationSchedule) {
        // Simple status toggle
        if let index = medications.firstIndex(where: { $0.id == medication.id }) {
            switch medications[index].status {
            case .pending: medications[index].status = .completed
            case .completed: medications[index].status = .missed
            case .missed: medications[index].status = .pending
            }
        }
    }
}


    
// MARK: - Create Account View
struct CreateAccountView: View {
    @Binding var currentScreen: AppScreen
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                VStack(spacing: 20) {
                    Text("Create An Account")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.top, 20)
                    
                    VStack(spacing: 16) {
                        CustomTextField(placeholder: "Name", text: $name)
                        CustomTextField(placeholder: "Email", text: $email)
                        CustomTextField(placeholder: "Password", text: $password, isSecure: true)
                    }
                    .padding(.horizontal, 20)
                    
                    Button(action: {
                        currentScreen = .termsAndConditions
                    }) {
                        Text("Continue")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(25)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
                
                VStack(spacing: 16) {
                    Text("or")
                        .foregroundColor(.gray)
                    
                    SocialLoginButton(provider: "Google", icon: "G")
                    SocialLoginButton(provider: "Apple", icon: "")
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        currentScreen = .onboarding
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
    }
}

// MARK: - Custom Text Field
struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    
    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

// MARK: - Social Login Button
struct SocialLoginButton: View {
    let provider: String
    let icon: String
    
    var body: some View {
        Button(action: {}) {
            HStack {
                Text(icon)
                    .font(.title2)
                    .frame(width: 20)
                Text("Continue with \(provider)")
                    .font(.subheadline)
                Spacer()
            }
            .foregroundColor(.black)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
    }
}

// MARK: - Terms and Conditions View
struct TermsAndConditionsView: View {
    @Binding var currentScreen: AppScreen
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Terms and Conditions")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        TermsSection(
                            title: "Acceptance of Terms",
                            content: "By using our app, you accept these terms and conditions in full. If you disagree with any part of these terms, you must not use our app."
                        )
                        
                        TermsSection(
                            title: "Medical Disclaimer",
                            content: "This app is for informational purposes only and should not replace professional medical advice. Always consult your healthcare provider for medical decisions."
                        )
                        
                        TermsSection(
                            title: "Privacy Policy",
                            content: "We respect your privacy and are committed to protecting your personal data. Your health information is encrypted and stored securely."
                        )
                        
                        TermsSection(
                            title: "Data Usage",
                            content: "The app may collect usage data to improve functionality. No personal health data will be shared with third parties without consent."
                        )
                    }
                    
                    Button(action: {
                        currentScreen = .pillScanning
                    }) {
                        Text("Accept and Continue")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(25)
                    }
                    .padding(.top, 20)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        currentScreen = .createAccount
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
    }
}

// MARK: - Terms Section
struct TermsSection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}



struct PillScanningView: View {
    @Binding var currentScreen: AppScreen
    @State private var isScanning = false
    
    @State private var isShowingCamera = false
    @State private var scannedImage: UIImage? = nil
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("PILL SCANNING")
                    .font(.headline)
                    .fontWeight(.bold)
                    .padding(.top)
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 200, height: 200)
                    
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 150, height: 150)
                        .overlay(
                            Image(systemName: "camera")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                        )
                        .scaleEffect(isScanning ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isScanning)
                        .onTapGesture {
                            isShowingCamera = true
                        }
                }
                .onAppear {
                    isScanning = true
                }
                .sheet(isPresented: $isShowingCamera) {
                    ImagePicker(selectedImage: $scannedImage, sourceType: .camera)
                }
                
                VStack(spacing: 16) {
                    Text("Scan your medication")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text("Position the pill in the center of the camera viewfinder and tap to scan")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Spacer()
                
                Button(action: {
                    currentScreen = .medicationSchedule
                }) {
                    Text("Continue to Schedule")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(25)
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        currentScreen = .termsAndConditions
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
    }
}

struct ProfileView: View{
    @Binding var currentScreen: AppScreen
    var selectedUserType: UserType
    
    
    var body: some View {
        NavigationView{
            VStack(spacing: 20){
                if selectedUserType == .patient{
                    
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 120, height: 120)
                        .foregroundColor(.blue)
                        .padding(.top, 40)
                    Text("Sam Altman")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Patient")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }else{
                    
                    Image(systemName: "stethoscope.circle.fill")
                        .resizable()
                        .frame(width: 120, height: 120)
                        .foregroundColor(.green)
                        .padding(.top, 40)
                    
                    Text("Jeff Bezos")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Caregiver")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    currentScreen = .settings
                }) {
                    Text("Back to Settings")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(25)
                }
                .padding()
            }
            .navigationBarTitle("Profile", displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading){
                    Button(action: {
                        currentScreen = .settings
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
    }
}


enum MedicationStatus {
    case completed, missed, pending
    
    var icon: String {
        switch self {
        case .completed: return "checkmark.circle.fill"
        case .missed: return "exclamationmark.circle.fill"
        case .pending: return "clock.circle.fill"
        }
    }
}

// MARK: - Medication Row
struct MedicationRow: View {
    let medication: MedicationSchedule
    
    var body: some View {
        HStack(spacing: 16) {
            // Status Icon
            Image(systemName: medication.status.icon)
                .font(.title2)
                .foregroundColor(medication.color)
            
            // Medication Info
            VStack(alignment: .leading, spacing: 4) {
                Text(medication.name)
                    .font(.headline)
                    .fontWeight(.medium)
                
                Text(medication.time)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Action Button
            Button(action: {}) {
                Image(systemName: "ellipsis")
                    .font(.title3)
                    .foregroundColor(.gray)
            }
        }
        .padding()
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @Binding var currentScreen: AppScreen
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("Settings")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)
                
                VStack(spacing: 0) {
                    SettingsRow(title: "Profile", icon: "person.circle"){
                        currentScreen = .profile
                    }
                    SettingsRow(title: "My Statistics", icon: "chart.bar") {
                        currentScreen = .statistics
                    }
                    SettingsRow(title: "My Caregivers", icon: "stethoscope.circle") {
                        currentScreen = .caregivers
                    }

                    SettingsRow(title: "Notifications", icon: "bell") {}
                    SettingsRow(title: "Privacy", icon: "lock"){}
                    SettingsRow(title: "Help & Support", icon: "questionmark.circle"){}
                    SettingsRow(title: "About", icon: "info.circle"){}
                }
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)
                .padding(.horizontal)
                
                Spacer()
                
                Button(action: {
                    currentScreen = .medicationSchedule
                }) {
                    Text("Back to Schedule")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(25)
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
        }
    }
}
// MARK: - Settings Row
struct SettingsRow: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(title)
                .font(.body)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.clear)
        .contentShape(Rectangle())
        .onTapGesture {
            action()
            // Handle settings row tap
        }
    }
}

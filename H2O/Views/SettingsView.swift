import SwiftUI
import Combine

struct SettingsView: View {
    @ObservedObject var viewModel: HydrationViewModel

    @State private var weight: Int = 160
    @State private var heightFeet: Int = 5
    @State private var heightInches: Int = 9
    @State private var age: Int = 30
    @State private var selectedSex: BiologicalSex = .male
    @State private var wakeUpTime: Date = SettingsView.makeTime(hour: 7, minute: 0)
    @State private var sleepTime: Date = SettingsView.makeTime(hour: 22, minute: 0)
    @State private var notificationsOn: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.large) {
                // Header
                Text("Settings")
                    .font(AppTheme.Fonts.largeTitle())
                    .foregroundStyle(AppTheme.Colors.deepOcean)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, AppTheme.Spacing.small)

                // Profile section
                VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
                    Label("Profile", systemImage: "person.fill")
                        .font(AppTheme.Fonts.title())
                        .foregroundStyle(AppTheme.Colors.deepOcean)

                    // Weight
                    HStack {
                        Text("Weight")
                            .font(AppTheme.Fonts.headline())
                        Spacer()
                        Picker("Weight", selection: $weight) {
                            ForEach(80..<401, id: \.self) { lbs in
                                Text("\(lbs) lbs").tag(lbs)
                            }
                        }
                        .tint(AppTheme.Colors.oceanBlue)
                        .onChange(of: weight) { _, _ in saveProfile() }
                    }

                    // Height
                    HStack {
                        Text("Height")
                            .font(AppTheme.Fonts.headline())
                        Spacer()
                        Picker("Feet", selection: $heightFeet) {
                            ForEach(3..<8, id: \.self) { ft in
                                Text("\(ft) ft").tag(ft)
                            }
                        }
                        .tint(AppTheme.Colors.oceanBlue)
                        .onChange(of: heightFeet) { _, _ in saveProfile() }

                        Picker("Inches", selection: $heightInches) {
                            ForEach(0..<12, id: \.self) { inch in
                                Text("\(inch) in").tag(inch)
                            }
                        }
                        .tint(AppTheme.Colors.oceanBlue)
                        .onChange(of: heightInches) { _, _ in saveProfile() }
                    }

                    // Age
                    HStack {
                        Text("Age")
                            .font(AppTheme.Fonts.headline())
                        Spacer()
                        Picker("Age", selection: $age) {
                            ForEach(13..<101, id: \.self) { yr in
                                Text("\(yr) yrs").tag(yr)
                            }
                        }
                        .tint(AppTheme.Colors.oceanBlue)
                        .onChange(of: age) { _, _ in saveProfile() }
                    }

                    // Sex picker
                    HStack {
                        Text("Sex")
                            .font(AppTheme.Fonts.headline())
                        Spacer()
                        Picker("Sex", selection: $selectedSex) {
                            ForEach(BiologicalSex.allCases) { s in
                                Text(s.displayName).tag(s)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 180)
                        .onChange(of: selectedSex) { _, _ in saveProfile() }
                    }

                    // Goal display
                    HStack {
                        Text("Daily Goal")
                            .font(AppTheme.Fonts.headline())
                        Spacer()
                        Text("\(viewModel.dailyGoalGlasses) glasses (\(Int(viewModel.dailyGoalOunces)) oz)")
                            .font(AppTheme.Fonts.body())
                            .foregroundStyle(AppTheme.Colors.teal)
                    }
                }
                .cardStyle()
                .padding(.horizontal)

                // Reminders section
                VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
                    Label("Reminders", systemImage: "bell.badge.fill")
                        .font(AppTheme.Fonts.title())
                        .foregroundStyle(AppTheme.Colors.deepOcean)

                    Toggle("Enable Reminders", isOn: $notificationsOn)
                        .tint(AppTheme.Colors.aqua)
                        .font(AppTheme.Fonts.headline())
                        .onChange(of: notificationsOn) { _, newVal in
                            Task { await viewModel.toggleNotifications(newVal) }
                        }

                    if notificationsOn {
                        // Wake up time
                        DatePicker(selection: $wakeUpTime, displayedComponents: .hourAndMinute) {
                            HStack {
                                Image(systemName: "sunrise.fill")
                                    .foregroundStyle(.orange)
                                Text("Wake Up")
                                    .font(AppTheme.Fonts.body())
                            }
                        }
                        .onChange(of: wakeUpTime) { _, newVal in
                            let comps = Calendar.current.dateComponents([.hour, .minute], from: newVal)
                            viewModel.updateWakeUpTime(hour: comps.hour ?? 7, minute: comps.minute ?? 0)
                        }

                        // Sleep time
                        DatePicker(selection: $sleepTime, displayedComponents: .hourAndMinute) {
                            HStack {
                                Image(systemName: "moon.fill")
                                    .foregroundStyle(AppTheme.Colors.oceanBlue)
                                Text("Bedtime")
                                    .font(AppTheme.Fonts.body())
                            }
                        }
                        .onChange(of: sleepTime) { _, newVal in
                            let comps = Calendar.current.dateComponents([.hour, .minute], from: newVal)
                            viewModel.updateSleepTime(hour: comps.hour ?? 22, minute: comps.minute ?? 0)
                        }

                        Text("Reminders will be spaced evenly between wake up and bedtime")
                            .font(AppTheme.Fonts.caption())
                            .foregroundStyle(.secondary)
                    }
                }
                .cardStyle()
                .padding(.horizontal)

                // App info
                VStack(spacing: 8) {
                    Image(systemName: "drop.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(AppTheme.Colors.aqua)
                    Text("YourH20")
                        .font(AppTheme.Fonts.headline())
                        .foregroundStyle(AppTheme.Colors.deepOcean)
                    Text("Version 1.0")
                        .font(AppTheme.Fonts.caption())
                        .foregroundStyle(.secondary)
                }
                .padding(.top, AppTheme.Spacing.extraLarge)

                Spacer(minLength: AppTheme.Spacing.extraLarge)
            }
        }
        .appBackground()
        .onAppear {
            weight = Int(viewModel.userProfile.weightInPounds)
            heightFeet = viewModel.userProfile.heightFeet
            heightInches = viewModel.userProfile.heightInches
            age = viewModel.userProfile.age
            selectedSex = viewModel.userProfile.sex
            wakeUpTime = SettingsView.makeTime(hour: viewModel.userProfile.wakeUpHour, minute: viewModel.userProfile.wakeUpMinute)
            sleepTime = SettingsView.makeTime(hour: viewModel.userProfile.sleepHour, minute: viewModel.userProfile.sleepMinute)
            notificationsOn = viewModel.notificationsEnabled
        }
    }

    private func saveProfile() {
        viewModel.updateProfile(
            weight: weight,
            heightFeet: heightFeet,
            heightInches: heightInches,
            sex: selectedSex,
            age: age
        )
    }

    static func makeTime(hour: Int, minute: Int) -> Date {
        var comps = DateComponents()
        comps.hour = hour
        comps.minute = minute
        return Calendar.current.date(from: comps) ?? Date()
    }
}

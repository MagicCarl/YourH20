import SwiftUI
import Combine

struct SettingsView: View {
    @ObservedObject var viewModel: HydrationViewModel

    @State private var weight: Double = 160
    @State private var age: Double = 30
    @State private var selectedSex: BiologicalSex = .male
    @State private var wakeUpHour: Int = 7
    @State private var sleepHour: Int = 22
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
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Weight")
                                .font(AppTheme.Fonts.headline())
                            Spacer()
                            Text("\(Int(weight)) lbs")
                                .font(AppTheme.Fonts.headline())
                                .foregroundStyle(AppTheme.Colors.oceanBlue)
                        }
                        Slider(value: $weight, in: 80...400, step: 1)
                            .tint(AppTheme.Colors.aqua)
                            .onChange(of: weight) { _, newVal in
                                viewModel.updateProfile(weight: newVal, sex: selectedSex, age: Int(age))
                            }
                    }

                    // Age
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Age")
                                .font(AppTheme.Fonts.headline())
                            Spacer()
                            Text("\(Int(age)) years")
                                .font(AppTheme.Fonts.headline())
                                .foregroundStyle(AppTheme.Colors.oceanBlue)
                        }
                        Slider(value: $age, in: 13...100, step: 1)
                            .tint(AppTheme.Colors.aqua)
                            .onChange(of: age) { _, newVal in
                                viewModel.updateProfile(weight: weight, sex: selectedSex, age: Int(newVal))
                            }
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
                        .onChange(of: selectedSex) { _, newVal in
                            viewModel.updateProfile(weight: weight, sex: newVal, age: Int(age))
                        }
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
                        HStack {
                            Image(systemName: "sunrise.fill")
                                .foregroundStyle(.orange)
                            Text("Wake Up")
                                .font(AppTheme.Fonts.body())
                            Spacer()
                            Picker("Wake Up", selection: $wakeUpHour) {
                                ForEach(4..<13, id: \.self) { h in
                                    Text(formatHour(h)).tag(h)
                                }
                            }
                            .onChange(of: wakeUpHour) { _, newVal in
                                viewModel.updateWakeUpHour(newVal)
                            }
                        }

                        // Sleep time
                        HStack {
                            Image(systemName: "moon.fill")
                                .foregroundStyle(AppTheme.Colors.oceanBlue)
                            Text("Bedtime")
                                .font(AppTheme.Fonts.body())
                            Spacer()
                            Picker("Bedtime", selection: $sleepHour) {
                                ForEach(19..<25, id: \.self) { h in
                                    Text(formatHour(h % 24)).tag(h % 24)
                                }
                            }
                            .onChange(of: sleepHour) { _, newVal in
                                viewModel.updateSleepHour(newVal)
                            }
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
                    Text("H2O")
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
            weight = viewModel.userProfile.weightInPounds
            age = Double(viewModel.userProfile.age)
            selectedSex = viewModel.userProfile.sex
            wakeUpHour = viewModel.userProfile.wakeUpHour
            sleepHour = viewModel.userProfile.sleepHour
            notificationsOn = viewModel.notificationsEnabled
        }
    }

    private func formatHour(_ hour: Int) -> String {
        var components = DateComponents()
        components.hour = hour
        guard let date = Calendar.current.date(from: components) else { return "\(hour)" }
        let formatter = DateFormatter()
        formatter.dateFormat = "h a"
        return formatter.string(from: date)
    }
}

import SwiftUI
import Combine

struct OnboardingView: View {
    @ObservedObject var viewModel: HydrationViewModel

    @State private var weight: Int = 160
    @State private var heightFeet: Int = 5
    @State private var heightInches: Int = 9
    @State private var age: Int = 30
    @State private var selectedSex: BiologicalSex = .male

    private var calculatedOunces: Double {
        let base = Double(weight) / 2.0
        let ageFactor: Double
        if age < 30 {
            ageFactor = 1.08
        } else if age < 55 {
            ageFactor = 1.0
        } else {
            ageFactor = 0.92
        }
        let totalInches = heightFeet * 12 + heightInches
        let heightAdjust = Double(max(0, totalInches - 65))
        return (base * ageFactor) + heightAdjust
    }

    private var calculatedGlasses: Int {
        Int(ceil(calculatedOunces / 8.0))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.large) {
                // Logo
                WaterDropView(size: 80)
                    .padding(.top, AppTheme.Spacing.medium)

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

                        Picker("Inches", selection: $heightInches) {
                            ForEach(0..<12, id: \.self) { inch in
                                Text("\(inch) in").tag(inch)
                            }
                        }
                        .tint(AppTheme.Colors.oceanBlue)
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
                    }

                    // Sex picker
                    HStack {
                        Text("Sex")
                            .font(AppTheme.Fonts.headline())
                        Spacer()
                        Picker("Sex", selection: $selectedSex) {
                            ForEach(BiologicalSex.allCases) { sex in
                                Text(sex.displayName).tag(sex)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 180)
                    }
                }
                .cardStyle()
                .padding(.horizontal)

                // Goal preview
                VStack(spacing: 4) {
                    Text("Your daily goal")
                        .font(AppTheme.Fonts.caption())
                        .foregroundStyle(.secondary)
                    Text("\(calculatedGlasses) glasses")
                        .font(AppTheme.Fonts.title())
                        .foregroundStyle(AppTheme.Colors.deepOcean)
                    Text("\(Int(calculatedOunces)) oz per day")
                        .font(AppTheme.Fonts.body())
                        .foregroundStyle(AppTheme.Colors.teal)
                }
                .padding()
                .animation(.easeInOut, value: weight)
                .animation(.easeInOut, value: heightFeet)
                .animation(.easeInOut, value: heightInches)
                .animation(.easeInOut, value: age)
                .animation(.easeInOut, value: selectedSex)

                // Get Started
                Button(action: {
                    viewModel.completeOnboarding(weight: Double(weight), heightFeet: heightFeet, heightInches: heightInches, sex: selectedSex, age: age)
                }) {
                    Text("Get Started")
                        .font(AppTheme.Fonts.headline())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.Gradients.button)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: AppTheme.Colors.aqua.opacity(0.3), radius: 8, y: 4)
                }
                .padding(.horizontal)

                Spacer(minLength: AppTheme.Spacing.extraLarge)
            }
        }
        .appBackground()
    }
}

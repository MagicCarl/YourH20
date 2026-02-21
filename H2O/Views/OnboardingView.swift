import SwiftUI
import Combine

struct OnboardingView: View {
    @ObservedObject var viewModel: HydrationViewModel

    @State private var weight: Double = 160
    @State private var age: Double = 30
    @State private var selectedSex: BiologicalSex = .male

    private var calculatedOunces: Double {
        let base = weight / 2.0
        let ageFactor: Double
        if Int(age) < 30 {
            ageFactor = 1.08
        } else if Int(age) < 55 {
            ageFactor = 1.0
        } else {
            ageFactor = 0.92
        }
        return base * ageFactor
    }

    private var calculatedGlasses: Int {
        Int(ceil(calculatedOunces / 8.0))
    }

    var body: some View {
        VStack(spacing: AppTheme.Spacing.large) {
            Spacer()

            // Logo
            WaterDropView(size: 80)

            // Title
            Text("Welcome to H2O")
                .font(AppTheme.Fonts.largeTitle())
                .foregroundStyle(AppTheme.Colors.deepOcean)
            Text("Let's set up your hydration goal")
                .font(AppTheme.Fonts.body())
                .foregroundStyle(.secondary)

            Spacer()

            // Weight slider
            VStack(spacing: AppTheme.Spacing.small) {
                HStack {
                    Image(systemName: "scalemass.fill")
                        .foregroundStyle(AppTheme.Colors.teal)
                    Text("Weight")
                        .font(AppTheme.Fonts.headline())
                    Spacer()
                    Text("\(Int(weight)) lbs")
                        .font(AppTheme.Fonts.title())
                        .foregroundStyle(AppTheme.Colors.oceanBlue)
                }
                Slider(value: $weight, in: 80...400, step: 1)
                    .tint(AppTheme.Colors.aqua)
            }
            .cardStyle()

            // Age slider
            VStack(spacing: AppTheme.Spacing.small) {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundStyle(AppTheme.Colors.teal)
                    Text("Age")
                        .font(AppTheme.Fonts.headline())
                    Spacer()
                    Text("\(Int(age)) years")
                        .font(AppTheme.Fonts.title())
                        .foregroundStyle(AppTheme.Colors.oceanBlue)
                }
                Slider(value: $age, in: 13...100, step: 1)
                    .tint(AppTheme.Colors.aqua)
            }
            .cardStyle()

            // Sex picker
            VStack(spacing: AppTheme.Spacing.small) {
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundStyle(AppTheme.Colors.teal)
                    Text("Sex")
                        .font(AppTheme.Fonts.headline())
                    Spacer()
                }
                Picker("Sex", selection: $selectedSex) {
                    ForEach(BiologicalSex.allCases) { sex in
                        Text(sex.displayName).tag(sex)
                    }
                }
                .pickerStyle(.segmented)
            }
            .cardStyle()

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
            .animation(.easeInOut, value: age)
            .animation(.easeInOut, value: selectedSex)

            Spacer()

            // Get Started
            Button(action: {
                viewModel.completeOnboarding(weight: weight, sex: selectedSex, age: Int(age))
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
        }
        .padding()
        .appBackground()
    }
}

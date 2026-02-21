import SwiftUI

struct InfoView: View {
    @ObservedObject var viewModel: HydrationViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.large) {
                // Header
                Text("How We Calculate")
                    .font(AppTheme.Fonts.largeTitle())
                    .foregroundStyle(AppTheme.Colors.deepOcean)
                    .padding(.horizontal)
                    .padding(.top, AppTheme.Spacing.small)

                // Your personalized goal
                VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
                    Label("Your Daily Goal", systemImage: "drop.fill")
                        .font(AppTheme.Fonts.title())
                        .foregroundStyle(AppTheme.Colors.deepOcean)

                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(viewModel.dailyGoalGlasses) glasses")
                                .font(AppTheme.Fonts.largeTitle())
                                .foregroundStyle(AppTheme.Colors.aqua)
                            Text("\(Int(viewModel.dailyGoalOunces)) oz per day")
                                .font(AppTheme.Fonts.body())
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "person.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(AppTheme.Colors.aqua.opacity(0.3))
                    }

                    Text("Based on your weight (\(Int(viewModel.userProfile.weightInPounds)) lbs), height (\(viewModel.userProfile.heightFeet)'\(viewModel.userProfile.heightInches)\"), age (\(viewModel.userProfile.age)), and sex (\(viewModel.userProfile.sex.displayName.lowercased())).")
                        .font(AppTheme.Fonts.caption())
                        .foregroundStyle(.secondary)
                }
                .cardStyle()
                .padding(.horizontal)

                // Formula breakdown
                VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
                    Label("The Formula", systemImage: "function")
                        .font(AppTheme.Fonts.title())
                        .foregroundStyle(AppTheme.Colors.deepOcean)

                    FormulaRow(
                        step: "1",
                        title: "Base Intake",
                        detail: "Body weight (lbs) \u{00F7} 2 = ounces per day",
                        source: "The baseline \"half your body weight in ounces\" guideline is derived from the National Academies of Sciences Dietary Reference Intakes for Water (2004), which established adequate intake levels of 3.7 L / 125 oz / 15.5 cups per day for men and 2.7 L / 91 oz / 11.5 cups per day for women."
                    )

                    FormulaRow(
                        step: "2",
                        title: "Age Adjustment",
                        detail: "Under 30: +8%  \u{2022}  30\u{2013}54: baseline  \u{2022}  55+: \u{2212}8%",
                        source: "Younger adults have higher metabolic rates and water turnover. The European Journal of Clinical Nutrition (2003) found water requirements decrease with age due to changes in body composition and renal concentrating ability."
                    )

                    FormulaRow(
                        step: "3",
                        title: "Height Adjustment",
                        detail: "+1 oz per inch above 5'5\"",
                        source: "Taller individuals have greater body surface area and lean mass, which increases water needs. Research published in the Annals of Human Biology (2010) correlates total body water with height and body surface area."
                    )
                }
                .cardStyle()
                .padding(.horizontal)

                // Research sources
                VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
                    Label("Research Sources", systemImage: "book.fill")
                        .font(AppTheme.Fonts.title())
                        .foregroundStyle(AppTheme.Colors.deepOcean)

                    SourceRow(
                        title: "Dietary Reference Intakes for Water",
                        author: "National Academies of Sciences, Engineering, and Medicine",
                        year: "2004",
                        detail: "Established adequate intake levels for water based on median consumption data. Recommends 3.7 L / 125 oz / 15.5 cups per day total water for men and 2.7 L / 91 oz / 11.5 cups per day for women from all beverages and food."
                    )

                    SourceRow(
                        title: "Water Requirements and Aging",
                        author: "European Journal of Clinical Nutrition",
                        year: "2003",
                        detail: "Examined how aging affects hydration needs, noting that older adults have reduced thirst perception and renal concentrating ability, but also lower total body water requirements."
                    )

                    SourceRow(
                        title: "Body Composition and Total Body Water",
                        author: "Annals of Human Biology",
                        year: "2010",
                        detail: "Demonstrated the relationship between height, body surface area, lean body mass, and total body water content across populations."
                    )

                    SourceRow(
                        title: "Water, Hydration and Health",
                        author: "Nutrition Reviews (Popkin, D'Anci, Rosenberg)",
                        year: "2010",
                        detail: "Comprehensive review of water's role in health, examining evidence for hydration recommendations and the physiological basis for individual variation in water needs."
                    )

                    SourceRow(
                        title: "Adequate Intake of Water Guidelines",
                        author: "Mayo Clinic Staff",
                        year: "2024",
                        detail: "Clinical guidance recommending approximately 3.7 L / 125 oz / 15.5 cups for men and 2.7 L / 91 oz / 11.5 cups for women daily, adjusted for activity, climate, and health conditions."
                    )
                }
                .cardStyle()
                .padding(.horizontal)

                // Disclaimer
                VStack(alignment: .leading, spacing: 8) {
                    Label("Important Note", systemImage: "exclamationmark.triangle.fill")
                        .font(AppTheme.Fonts.headline())
                        .foregroundStyle(.orange)

                    Text("This app provides general hydration estimates based on published research. Individual needs vary based on activity level, climate, health conditions, and medications. Consult your healthcare provider for personalized hydration advice.")
                        .font(AppTheme.Fonts.caption())
                        .foregroundStyle(.secondary)
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
                .frame(maxWidth: .infinity)
                .padding(.top, AppTheme.Spacing.extraLarge)

                Spacer(minLength: AppTheme.Spacing.extraLarge)
            }
        }
        .appBackground()
    }
}

// MARK: - Supporting Views

private struct FormulaRow: View {
    let step: String
    let title: String
    let detail: String
    let source: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top, spacing: 10) {
                Text(step)
                    .font(AppTheme.Fonts.title())
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
                    .background(AppTheme.Colors.aqua)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(AppTheme.Fonts.headline())
                        .foregroundStyle(AppTheme.Colors.deepOcean)
                    Text(detail)
                        .font(AppTheme.Fonts.body())
                        .foregroundStyle(AppTheme.Colors.oceanBlue)
                }
            }

            Text(source)
                .font(AppTheme.Fonts.caption())
                .foregroundStyle(.secondary)
                .padding(.leading, 42)
        }
        .padding(.vertical, 4)
    }
}

private struct SourceRow: View {
    let title: String
    let author: String
    let year: String
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(AppTheme.Fonts.headline())
                .foregroundStyle(AppTheme.Colors.deepOcean)
            Text("\(author) (\(year))")
                .font(AppTheme.Fonts.caption())
                .foregroundStyle(AppTheme.Colors.teal)
            Text(detail)
                .font(AppTheme.Fonts.caption())
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

import SwiftUI

/// A view that displays application settings.
/// Currently supports configuring the vector calculation method.
public struct SettingsView: View {
    // MARK: - Properties

    @AppStorage("vectorCalculationMethod") private var vectorCalcMethod = 0

    // MARK: - Body

    public var body: some View {
        Form {
            Menu("Vector Calculation Method") {
                Button("Vector-Doubling") {
                    vectorCalcMethod = 0
                }
                Button("Standa") {
                    vectorCalcMethod = 1
                }
            }
            .padding()
        }
        .frame(width: 400, height: 200)
        .padding()
    }

    // MARK: - Initialization

    public init() {}
}

#Preview {
    SettingsView()
        .frame(width: 400, height: 300)
}

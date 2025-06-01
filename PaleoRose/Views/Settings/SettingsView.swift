import SwiftUI
import SwiftUICore

/// A view that displays application settings.
/// Currently supports configuring the vector calculation method.
public struct SettingsView: View {
    // MARK: - Properties

    @DefaultsStorage(
        .vectorCalculationMethod,
        defaultValue: 0
    ) private var vectorCalcMethod: Int
    @State private var showingHelp = false

    // MARK: - Private Properties

    private let vectorCalculationMethods = [
        (id: 0, name: "Vector-Doubling", description: "Standard method for most cases"),
        (id: 1, name: "Standard", description: "Alternative method for specific use cases")
    ]

    // MARK: - Body

    public var body: some View {
        // swiftlint:disable:next closure_body_length
        VStack(alignment: .leading, spacing: 20) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text("Settings")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("Configure application preferences")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 10)

            Divider()

            // Vector Calculation Section
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Vector Calculation Method")
                        .font(.headline)
                    // swiftlint:disable:next multiple_closures_with_trailing_closure
                    Button(action: { showingHelp = true }) {
                        Image(systemName: "questionmark.circle")
                            .foregroundColor(.accentColor)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help("Learn more about calculation methods")
                }

                Picker("Vector Calculation Method", selection: $vectorCalcMethod) {
                    ForEach(vectorCalculationMethods, id: \.id) { method in
                        Text(method.name).tag(method.id)
                    }
                }
                .pickerStyle(.radioGroup)
                .padding(.leading, 8)

                if let selectedMethod = vectorCalculationMethods.first(where: { $0.id == vectorCalcMethod }) {
                    Text(selectedMethod.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.leading, 8)
                        .transition(.opacity)
                        .animation(.easeInOut, value: vectorCalcMethod)
                }
            }

            Spacer()

            // Footer
            HStack {
                Spacer()
                Button("Done") {
                    NSApp.keyWindow?.close()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(24)
        .frame(width: 480, height: 280)
        .alert("About Vector Calculation Methods", isPresented: $showingHelp) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("""
            • Vector-Doubling: The standard method for most cases, providing a good balance of accuracy and performance.

            • Standard: An alternative method that may be more suitable for specific datasets or use cases.
            """)
        }
    }

    // MARK: - Initialization

    public init() {}
}

#Preview {
    SettingsView()
}

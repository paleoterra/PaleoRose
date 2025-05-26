import SwiftUI

/// A view that displays application settings.
/// Currently supports configuring the vector calculation method.
public struct SettingsView: View {
    // MARK: - Properties

    @AppStorage("vectorCalculationMethod") private var vectorCalcMethod = 0
    @State private var showingHelp = false

    private let methods = [
        (0, "Vector-Doubling", "Standard method for most cases"),
        (1, "Standard", "Alternative method for specific use cases")
    ]

    // MARK: - Body

    public var body: some View {
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

                    Button(action: { showingHelp = true }) {
                        Image(systemName: "questionmark.circle")
                            .foregroundColor(.accentColor)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help("Learn more about calculation methods")
                }

                Picker("Vector Calculation Method", selection: $vectorCalcMethod) {
                    ForEach(methods, id: \.0) { id, name, _ in
                        Text(name).tag(id)
                    }
                }
                .pickerStyle(.radioGroup)
                .padding(.leading, 8)

                if let description = methods.first(where: { $0.0 == vectorCalcMethod })?.2 {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.leading, 8)
                        .transition(.opacity)
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

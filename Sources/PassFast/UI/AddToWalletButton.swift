#if canImport(PassKit) && canImport(SwiftUI) && os(iOS)
import PassKit
import SwiftUI

/// A SwiftUI wrapper around `PKAddPassButton`.
///
/// ```swift
/// AddToWalletButton {
///     let (pass, _) = try await client.passes.generatePKPass(...)
///     return pass
/// }
/// ```
public struct AddToWalletButton: View {
    private let style: PKAddPassButtonStyle
    private let generatePass: () async throws -> PKPass
    @State private var pass: PKPass?
    @State private var showSheet = false
    @State private var isLoading = false
    @State private var error: PassFastError?

    public init(
        style: PKAddPassButtonStyle = .black,
        generatePass: @escaping () async throws -> PKPass
    ) {
        self.style = style
        self.generatePass = generatePass
    }

    public var body: some View {
        PaymentButtonRepresentable(style: style) {
            guard !isLoading else { return }
            isLoading = true
            Task {
                do {
                    pass = try await generatePass()
                    showSheet = true
                } catch let err as PassFastError {
                    error = err
                } catch {
                    self.error = .network(error)
                }
                isLoading = false
            }
        }
        .frame(height: 48)
        .opacity(isLoading ? 0.6 : 1.0)
        .sheet(isPresented: $showSheet) {
            if let pass {
                PassSheet(pass: pass)
            }
        }
    }
}

private struct PaymentButtonRepresentable: UIViewRepresentable {
    let style: PKAddPassButtonStyle
    let action: () -> Void

    func makeUIView(context: Context) -> PKAddPassButton {
        let button = PKAddPassButton(addPassButtonStyle: style)
        button.addTarget(context.coordinator, action: #selector(Coordinator.tapped), for: .touchUpInside)
        return button
    }

    func updateUIView(_ uiView: PKAddPassButton, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(action: action)
    }

    class Coordinator: NSObject {
        let action: () -> Void
        init(action: @escaping () -> Void) { self.action = action }
        @objc func tapped() { action() }
    }
}
#endif

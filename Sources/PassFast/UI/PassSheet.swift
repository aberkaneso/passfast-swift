#if canImport(PassKit) && canImport(SwiftUI) && os(iOS)
import PassKit
import SwiftUI

/// A SwiftUI sheet that presents `PKAddPassesViewController` for adding a pass to Apple Wallet.
///
/// ```swift
/// .sheet(isPresented: $showPass) {
///     PassSheet(pass: myPKPass) {
///         print("Sheet dismissed")
///     }
/// }
/// ```
public struct PassSheet: UIViewControllerRepresentable {
    private let pass: PKPass
    private let onDismiss: (() -> Void)?

    public init(pass: PKPass, onDismiss: (() -> Void)? = nil) {
        self.pass = pass
        self.onDismiss = onDismiss
    }

    public func makeUIViewController(context: Context) -> PKAddPassesViewController {
        let controller = PKAddPassesViewController(pass: pass)!
        controller.delegate = context.coordinator
        return controller
    }

    public func updateUIViewController(_ uiViewController: PKAddPassesViewController, context: Context) {}

    public func makeCoordinator() -> Coordinator {
        Coordinator(onDismiss: onDismiss)
    }

    public class Coordinator: NSObject, PKAddPassesViewControllerDelegate {
        let onDismiss: (() -> Void)?

        init(onDismiss: (() -> Void)?) {
            self.onDismiss = onDismiss
        }

        public func addPassesViewControllerDidFinish(_ controller: PKAddPassesViewController) {
            controller.dismiss(animated: true) {
                self.onDismiss?()
            }
        }
    }
}
#endif

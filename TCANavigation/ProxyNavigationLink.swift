import SwiftUI
import SwiftUINavigation

struct ProxyNavigationLink<Label: View, Destination: View>: View {
    @State var _isActive: Bool = false

    private let binding: Binding<Bool>
    private let content: (Binding<Bool>) -> NavigationLink<Label, Destination>

    public init(
        @ViewBuilder destination: @escaping () -> Destination,
        isActive: Binding<Bool>,
        label: @escaping () -> Label
    ) {
        self.binding = isActive
        self.content = { $isActive in
            NavigationLink(
                isActive: $isActive,
                destination: destination,
                label: label
            )
        }
    }

    public init(
        _ titleKey: LocalizedStringKey,
        isActive: Binding<Bool>,
        @ViewBuilder destination: @escaping () -> Destination
    ) where Label == Text {
        self.init(
            destination: destination,
            isActive: isActive,
            label: { Text(titleKey) }
        )
    }

    var body: some View {
        self.content($_isActive).onChange(of: _isActive) { newValue in
            self.binding.wrappedValue = newValue
        }
    }
}

// MARK: - Unwrapping Helpers

extension ProxyNavigationLink {
    public init<Value, WrappedDestination>(
        unwrapping value: Binding<Value?>,
        @ViewBuilder destination: @escaping (Binding<Value>) -> WrappedDestination,
        onNavigate: @escaping (_ isActive: Bool) -> Void,
        @ViewBuilder label: @escaping () -> Label
    ) where Destination == WrappedDestination? {
        self.init(
            destination: { Binding(unwrapping: value).map(destination) },
            isActive: value.isPresent().didSet(onNavigate),
            label: label
        )
    }

    public init<Enum, Case, WrappedDestination>(
        unwrapping enum: Binding<Enum?>,
        case casePath: CasePath<Enum, Case>,
        @ViewBuilder destination: @escaping (Binding<Case>) -> WrappedDestination,
        onNavigate: @escaping (Bool) -> Void,
        @ViewBuilder label: @escaping () -> Label
    ) where Destination == WrappedDestination? {
        self.init(
            unwrapping: `enum`.case(casePath),
            destination: destination,
            onNavigate: onNavigate,
            label: label
        )
    }
}

extension Binding {
    func didSet(_ perform: @escaping (Value) -> Void) -> Self {
        .init(
            get: { self.wrappedValue },
            set: { newValue, transaction in
                self.transaction(transaction).wrappedValue = newValue
                perform(newValue)
            }
        )
    }
}

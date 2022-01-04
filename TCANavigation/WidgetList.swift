import Foundation
import ComposableArchitecture
import SwiftUI

struct Widget: Equatable, Identifiable {
    let id: UUID
    let name: String
}

// MARK: - Widget List

struct WidgetListState: Equatable {
    var widgets: IdentifiedArrayOf<WidgetListRowState>
}

extension WidgetListState {
    init(widgets: [Widget]) {
        self.widgets = IdentifiedArray(uniqueElements: widgets.map { .init(widget: $0) })
    }
}

enum WidgetListAction: Equatable, BindableAction {
    case binding(BindingAction<WidgetListState>)
    case row(id: UUID, action: WidgetListRowAction)
}

struct WidgetListEnvironment {}

let _widgetListReducer = Reducer<
    WidgetListState,
    WidgetListAction,
    WidgetListEnvironment
> { state, action, environment in
    switch action {
    case .binding:
        return .none
    case .row:
        return .none
    }
}
.binding()

let widgetListReducer = Reducer<
    WidgetListState,
    WidgetListAction,
    WidgetListEnvironment
>
.combine(
    widgetListRowReducer.forEach(
        state: \.widgets,
        action: /WidgetListAction.row,
        environment: { _ in .init() }
    ),
    _widgetListReducer
)

// MARK: - Widget List Row

struct WidgetListRowState: Equatable, Identifiable {
    let widget: Widget
    @BindableState var route: Route?
    var id: UUID { widget.id }

    enum Route: Equatable {
        case detail(WidgetDetailState)
    }
}

enum WidgetListRowAction: Equatable, BindableAction {
    case binding(BindingAction<WidgetListRowState>)
    case detail(WidgetDetailAction)
    case navigate(isActive: Bool)
}

struct WidgetListRowEnvironment {}

let widgetListRowReducer = Reducer<
    WidgetListRowState,
    WidgetListRowAction,
    WidgetListRowEnvironment
> { state, action, environment in
    switch action {
    case .binding:
        return .none
    case .detail:
        return .none
    case let .navigate(isActive):
        state.route = isActive ? .detail(.init(widget: state.widget)) : nil
        return .none
    }
}
.combined(
    with: widgetDetailReducer
        .pullback(
            state: /WidgetListRowState.Route.detail,
            action: /WidgetListRowAction.detail,
            environment: { $0 }
        )
        .pullback(
            state: \.route,
            action: /.`self`,
            environment: { _ in .init() }
        )
)
.binding()

// MARK: - Widget Detail

struct WidgetDetailState: Equatable {
    let widget: Widget
}

enum WidgetDetailAction: Equatable {
    case stub
}

struct WidgetDetailEnvironment {}

let widgetDetailReducer = Reducer<
    WidgetDetailState,
    WidgetDetailAction,
    WidgetDetailEnvironment
>.empty

// MARK: - Widget Views

struct WidgetList: View {
    let store: Store<WidgetListState, WidgetListAction>

    var body: some View {
        NavigationView {
            List {
                ForEachStore(
                    store.scope(state: \.widgets, action: WidgetListAction.row),
                    content: WidgetListRow.init
                )
            }
        }
        .navigationTitle("Widgets")
    }
}

struct WidgetListRow: View {
    let store: Store<WidgetListRowState, WidgetListRowAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationLink(
                unwrapping: viewStore.binding(\.$route),
                case: /WidgetListRowState.Route.detail,
                destination: { _ in WidgetDetail() },
                onNavigate: { viewStore.send(.navigate(isActive: $0)) },
                label: { Text(viewStore.widget.name) }
            )
        }
    }
}

struct WidgetDetail: View {
    var body: some View {
        Text("Detail")
    }
}

let exampleWidgets: [Widget] = [
    .init(id: UUID(), name: "Keyboard"),
    .init(id: UUID(), name: "Trackpad"),
    .init(id: UUID(), name: "iPhone")
]

struct WidgetList_Previews: PreviewProvider {
    static var previews: some View {
        WidgetList(
            store: .init(
                initialState: .init(widgets: [
                    .init(widget: exampleWidgets[0], route: nil),
                    .init(widget: exampleWidgets[1], route: nil),
                    .init(widget: exampleWidgets[2], route: nil)
                ]),
                reducer: widgetListReducer,
                environment: .init()
            )
        )
    }
}

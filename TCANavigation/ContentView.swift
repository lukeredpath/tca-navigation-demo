//
//  ContentView.swift
//  TCANavigation
//
//  Created by Luke Redpath on 04/01/2022.
//

import ComposableArchitecture
import SwiftUI
import SwiftUINavigation

struct AppState: Equatable {
    @BindableState var route: Route?

    enum Route: Equatable {
        case widgets(WidgetListState)
    }
}

enum AppAction: Equatable, BindableAction {
    case binding(BindingAction<AppState>)
    case tappedOpenWidgets
}

let appReducer = Reducer<AppState, AppAction, Void> { state, action, _ in
    switch action {
    case .tappedOpenWidgets:
        state.route = .widgets(.init(widgets: exampleWidgets))
        return .none
    case .binding:
        return .none
    }
}
.binding()

struct ContentView: View {
    let store: Store<AppState, AppAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            Button("Open Widgets") {
                viewStore.send(.tappedOpenWidgets)
            }
            .sheet(
                unwrapping: viewStore.binding(\.$route),
                case: /AppState.Route.widgets,
                content: { $widgetListState in // we really need a scoped store here
                    WidgetList(
                        store: .init(
                            initialState: widgetListState,
                            reducer: widgetListReducer,
                            environment: .init()
                        )
                    )
                }
            )
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(
            store: .init(
                initialState: .init(),
                reducer: appReducer,
                environment: ()
            )
        )
    }
}

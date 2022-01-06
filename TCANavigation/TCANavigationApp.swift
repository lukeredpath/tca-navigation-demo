//
//  TCANavigationApp.swift
//  TCANavigation
//
//  Created by Luke Redpath on 04/01/2022.
//

import ComposableArchitecture
import SwiftUI
import SwiftUINavigation

@main
struct TCANavigationApp: App {
    let store = Store(
        initialState: .init(),
        reducer: appReducer.debug(),
        environment: ()
    )

    var body: some Scene {
        WindowGroup {
            ContentView(store: store)
        }
    }
}

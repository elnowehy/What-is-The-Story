//
//  Injection.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-02-20.
//

import Foundation
import Swinject

// Singilton
final class Injection {
    static let shared = Injection()
    var container: Container {
        get {
            if _container == nil {
                _container = buildContainer()
            }
            return _container!
        }
        set {
            _container = newValue
        }
    }
    private var _container: Container?
    
    private func buildContainer() -> Container {
        let container = Container()
        container.register(Profile.self) { _ in
            return Profile()
        }
        return container
    }
}

@propertyWrapper struct Injected<Dependency> {
    let wrappedValue: Dependency
    init(wrappedValue: Dependency) {
        self.wrappedValue = Injection.shared.container.resolve(Dependency.self)!
    }
}

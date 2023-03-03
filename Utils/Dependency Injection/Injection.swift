//
//  Injection.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-02-20.
//

import Foundation
import Swinject
import SwinjectAutoregistration

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
        
        container.autoregister(Profile.self, initializer: Profile.init)
        container.autoregister(User.self, initializer: User.init)
        /* // one day
        for serviceType in registeredServices {
            container.autoregister(serviceType, initializer: serviceType.init)
        }
         */
        return container
    }
}

@propertyWrapper struct Injected<Dependency> {
    var wrappedValue: Dependency

    init() {
        guard let resolvedDependency = Injection.shared.container.resolve(Dependency.self) else {
            fatalError("Failed to resolve \(Dependency.self)")
        }
        self.wrappedValue = resolvedDependency
    }
}

/*
protocol ServiceType {
    static func makeService(for container: Container) -> Self
}
*/
protocol RegistrationType {
    init()
}

protocol ServiceType: RegistrationType {
    static func makeService(for container: Container) -> Self
}

extension ServiceType {
    init() {
        self = Self.makeService(for: Container())
    }
}

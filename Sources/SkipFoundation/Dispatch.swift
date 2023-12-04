// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

// Stubs that allow SkipModel to implement Publisher.receive(on:) for the main queue

public protocol Scheduler {
}

public struct RunLoop : Scheduler {
    public static let main = RunLoop()

    private init() {
    }
}

public struct DispatchQueue : Scheduler {
    public static let main = DispatchQueue()

    private init() {
    }
}

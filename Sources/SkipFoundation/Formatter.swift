// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP

public class Formatter {
    public func string(for obj: Any?) -> String? {
        return nil
    }

    @available(*, unavailable)
    public func attributedString(for obj: Any, withDefaultAttributes attrs: [AnyHashable : Any]? = nil) -> Any? {
        return nil
    }

    @available(*, unavailable)
    public func editingString(for obj: Any) -> String? {
        return nil
    }

    @available(*, unavailable)
    public func getObjectValue(_ obj: Any?, for string: String, errorDescription error: Any?) -> Bool {
        return false
    }

    @available(*, unavailable)
    public func isPartialStringValid(_ partialString: String, newEditingString newString: Any?, errorDescription error: Any?) -> Bool {
        return false
    }

    @available(*, unavailable)
    public func isPartialStringValid(_ partialStringPtr: Any, proposedSelectedRange proposedSelRangePtr: Any?, originalString origString: String, originalSelectedRange origSelRange: Any, errorDescription error: Any?) -> Bool {
        return false
    }

    @available(*, unavailable)
    public var formattingContext: Any {
        fatalError()
    }

    @available(*, unavailable)
    public func getObjectValue(_ obj: Any?, for string: String, range rangep: Any?, unusedp: Nothing? = nil) throws {
    }
}

#endif

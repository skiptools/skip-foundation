// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP

public enum ComparisonResult : Int {
    case ascending = -1
    case same = 0
    case descending = 1
}

public extension ComparisonResult {
    static var orderedAscending: ComparisonResult { .ascending }
    static var orderedSame: ComparisonResult { .same }
    static var orderedDescending: ComparisonResult { .descending }
}
#endif

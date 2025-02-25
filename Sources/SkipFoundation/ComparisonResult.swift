// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
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

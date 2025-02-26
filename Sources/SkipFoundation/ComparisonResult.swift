// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
#if SKIP

public enum ComparisonResult : Int {
    case orderedAscending = -1
    case orderedSame = 0
    case orderedDescending = 1
}

extension ComparisonResult {
    public static var ascending: ComparisonResult { .orderedAscending }
    public static var same: ComparisonResult { .orderedSame }
    public static var descending: ComparisonResult { .orderedDescending }
}
#endif

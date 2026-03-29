// Copyright 2023–2026 Skip
// SPDX-License-Identifier: MPL-2.0
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

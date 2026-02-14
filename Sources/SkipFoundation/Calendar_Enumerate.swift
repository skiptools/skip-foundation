// Copyright 2023–2026 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception

// This class is adapted from https://github.com/swiftlang/swift-foundation/blob/main/Sources/FoundationEssentials/Calendar/Calendar_Enumerate.swift which has the following license:

// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2022 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//

#if SKIP

/* SKIP NOWARN */
extension Calendar {
    struct SearchStepResult {
        var result: (Date, Bool)?
        var newSearchDate: Date
    }
    
    enum CalendarEnumerationError: Error {
        case dateOutOfRange(Calendar.Component, Date /* failing date */)
        case notAdvancing(Date, Date)
        case unexpectedResult(Calendar.Component, Date /* failing date */)
    }
    
    func _enumerateDatesStep(startingAfter start: Date, matching matchingComponents: DateComponents, matchingPolicy: MatchingPolicy, repeatedTimePolicy: RepeatedTimePolicy, direction: SearchDirection, inSearchingDate searchingDate: Date, previouslyReturnedMatchDate: Date?) throws -> SearchStepResult {
        
        // Step A: Call helper method that does the searching
        let compsToMatch = _adjustedComponents(matchingComponents, date: searchingDate, direction: direction)
        guard let unadjustedMatchDate = try _matchingDate(after: searchingDate, matching: compsToMatch, direction: direction, matchingPolicy: matchingPolicy, repeatedTimePolicy: repeatedTimePolicy) else {
            return SearchStepResult(result: nil, newSearchDate: searchingDate)
        }
        
        let adjustedMatchDate = try _adjustedDate(unadjustedMatchDate, startingAfter: start, matching: matchingComponents, adjustedMatchingComponents: compsToMatch , matchingPolicy: matchingPolicy, repeatedTimePolicy: repeatedTimePolicy, direction: direction, inSearchingDate: searchingDate, previouslyReturnedMatchDate: previouslyReturnedMatchDate)
        
        return adjustedMatchDate
    }
}

// MARK: - Date Matching
/* SKIP NOWARN */
extension Calendar {
    func _matchingDate(after startDate: Date, matching comps: DateComponents, direction: SearchDirection, matchingPolicy: MatchingPolicy, repeatedTimePolicy: RepeatedTimePolicy) throws -> Date? {
        
        var matchedEra = true
        var searchStartDate = startDate
        let isStrictMatching = matchingPolicy == .strict
        
        if let result = dateAfterMatchingEra(startingAt: searchStartDate, components: comps, direction: direction, matchedEra: &matchedEra) {
            searchStartDate = result
        }
        
        // If era doesn't match we can just bail here instead of continuing on. A date from another era can't match. It's up to the caller to decide how to handle this mismatch.
        if !matchedEra {
            return nil
        }
        
        if let result = try dateAfterMatchingYear(startingAt: searchStartDate, components: comps, direction: direction) {
            searchStartDate = result
        }
        
        if let result = try dateAfterMatchingQuarter(startingAt: searchStartDate, components: comps, direction: direction) {
            searchStartDate = result
        }
        
        if let result = try dateAfterMatchingWeekOfYear(startingAt: searchStartDate, components: comps, direction: direction) {
            searchStartDate = result
        }
        
        if let result = try dateAfterMatchingDayOfYear(startingAt: searchStartDate, components: comps, direction: direction) {
            searchStartDate = result
        }
        
        if let result = try dateAfterMatchingMonth(startingAt: searchStartDate, components: comps, direction: direction, strictMatching: isStrictMatching) {
            searchStartDate = result
        }
        
        if let result = try dateAfterMatchingWeekOfMonth(startingAt: searchStartDate, components: comps, direction: direction) {
            searchStartDate = result
        }
        
        if let result = try dateAfterMatchingWeekdayOrdinal(startingAt: searchStartDate, components: comps, direction: direction) {
            searchStartDate = result
        }
        
        if let result = try dateAfterMatchingWeekday(startingAt: searchStartDate, components: comps, direction: direction) {
            searchStartDate = result
        }
        
        if let result = try dateAfterMatchingDay(startingAt: searchStartDate, originalStartDate: startDate, components: comps, direction: direction, isStrictMatching: isStrictMatching) {
            searchStartDate = result
        }
        
        if let result = try dateAfterMatchingHour(startingAt: searchStartDate, originalStartDate: startDate, components: comps, direction: direction, findLastMatch: repeatedTimePolicy == .last, isStrictMatching: isStrictMatching, matchingPolicy: matchingPolicy) {
            searchStartDate = result
        }
        
        if let result = try dateAfterMatchingMinute(startingAt: searchStartDate, components: comps, direction: direction) {
            searchStartDate = result
        }
        
        if let result = try dateAfterMatchingSecond(startingAt: searchStartDate, originalStartDate: startDate, components: comps, direction: direction) {
            searchStartDate = result
        }
        
        return searchStartDate
    }
    
    func _matchingDate(after startDate: Date, matching comps: DateComponents, inNextHighestUnit: Component, direction: SearchDirection, matchingPolicy: MatchingPolicy, repeatedTimePolicy: RepeatedTimePolicy) throws -> Date? {
        
        guard let foundRange = dateInterval(of: inNextHighestUnit, for: startDate) else {
            throw CalendarEnumerationError.dateOutOfRange(inNextHighestUnit, startDate)
        }
        
        var nextSearchDate: Date?
        var innerDirection = direction
        
        if innerDirection == .backward {
            if inNextHighestUnit == .day {
                /*
                 If nextHighestUnit is day, it's a safe assumption that the highest actual set unit is the hour.
                 There are cases where we're looking for a minute and/or second within the first hour of the day. If we start just at the top of the day and go backwards, we could end up missing the minute/second we're looking for.
                 E.g.
                 We're looking for { hour: 0, minute: 30, second: 0 } in the day before the start date 2017-05-26 07:19:50 UTC. At this point, foundRange.start would be 2017-05-26 07:00:00 UTC.
                 In this case, the algorithm would do the following:
                 start at 2017-05-26 07:00:00 UTC, see that the hour is already set to what we want, jump to minute.
                 when checking for minute, it will cycle forward to 2017-05-26 07:30:00 +0000 but then compare to the start and see that that date is incorrect because it's in the future. Then it will cycle the date back to 2017-05-26 06:30:00 +0000.
                 the matchingDate call below will exit with 2017-05-26 06:30:00 UTC and the algorithm will see that date is incorrect and reset the new search date go back a day to 2017-05-25 07:19:50 UTC. Then we get back here to this method and move the start to 2017-05-25 07:00:00 UTC and the call to matchingDate below will return 2017-05-25 06:30:00 UTC, which skips what we want (2017-05-25 07:30:00 UTC) and the algorithm eventually keeps moving further and further into the past until it exhausts itself and returns nil.
                 To adjust for this scenario, we add this line below that sets nextSearchDate to the last minute of the previous day (using the above example, 2017-05-26 06:59:59 UTC), which causes the algorithm to not skip the minutes/seconds within the first hour of the previous day. (<rdar://problem/32609242>)
                 */
                nextSearchDate = foundRange.start.addingTimeInterval(-1)
                
                // One caveat: if we are looking for a date within the first hour of the day (i.e. between 12 and 1 am), we want to ensure we go forwards in time to hit the exact minute and/or second we're looking for since nextSearchDate is now in the previous day. (<rdar://problem/33944890>).
                if comps.hour == 0 {
                    innerDirection = .forward
                }
            } else {
                nextSearchDate = foundRange.start
            }
        } else {
            nextSearchDate = foundRange.start.addingTimeInterval(foundRange.duration)
        }
        
        return try _matchingDate(after: nextSearchDate!, matching: comps, direction: innerDirection, matchingPolicy: matchingPolicy, repeatedTimePolicy: repeatedTimePolicy)
    }
}

// MARK: - Component Matchers
/* SKIP NOWARN */
extension Calendar {
    func dateAfterMatchingEra(startingAt: Date, components: DateComponents, direction: SearchDirection, matchedEra: inout Bool) -> Date? {
        
        guard let era = components.era else {
            // Nothing to do
            return nil
        }
        
        let dateEra = component(.era, from: startingAt)
        guard era != dateEra else {
            // Already matches
            return nil
        }
        
        if (direction == .backward && era <= dateEra) || (direction == .forward && era >= dateEra) {
            var dateComp = DateComponents()
            dateComp.era = era
            dateComp.year = 1
            dateComp.month = 1
            dateComp.day = 1
            dateComp.hour = 0
            dateComp.minute = 0
            dateComp.second = 0
            dateComp.nanosecond = 0
            
            if let result = self.date(from: dateComp) {
                let dateCompEra = component(.era, from: result)
                if dateCompEra != era {
                    matchedEra = false
                }
                return result
            } else {
                matchedEra = false
                return nil
            }
        } else {
            matchedEra = false
            return nil
        }
    }
    
    func dateAfterMatchingYear(startingAt: Date, components: DateComponents, direction: SearchDirection) throws -> Date? {
        
        guard let year = components.year else {
            // Nothing to do
            return nil
        }
        
        let dateYear = component(.year, from: startingAt)
        let dateEra = component(.era, from: startingAt)
        
        guard year != dateYear else {
            // Already matches
            return nil
        }
        
        guard let yearBegin = dateIfEraHasYear(era: dateEra, year: year) else {
            // TODO: Consider if this is an error or not
            return nil
        }
        
        if direction == .backward ? year > dateYear : year < dateYear {
            // Out of range
            throw CalendarEnumerationError.dateOutOfRange(.hour, startingAt)
        }
        
        // We set searchStartDate to the end of the year ONLY if we know we will be trying to match anything else beyond just the year and it'll be a backwards search; otherwise, we set searchStartDate to the start of the year.
        let totalSetUnits = components.setUnitCount
        if direction == .backward && totalSetUnits > 1 {
            guard let foundRange = dateInterval(of: .year, for: yearBegin) else {
                // Out of range
                throw CalendarEnumerationError.dateOutOfRange(.year, yearBegin)
            }
            
            return yearBegin.addingTimeInterval(foundRange.duration - 1)
        } else {
            return yearBegin
        }
    }
    
    func dateAfterMatchingQuarter(startingAt: Date, components: DateComponents, direction: SearchDirection) throws -> Date? {
        
        guard let quarter = components.quarter else {
            // Nothing to do
            return nil
        }
        
        // Get the beginning of the year we need.
        guard let foundRange = dateInterval(of: .year, for: startingAt) else {
            throw CalendarEnumerationError.dateOutOfRange(.year, startingAt)
        }
        
        if quarter < 1 || quarter > 4 {
            // Out of range
            throw CalendarEnumerationError.dateOutOfRange(.quarter, startingAt)
        }
        
        if direction == .backward {
            var count = 4
            var quarterBegin = foundRange.start.addingTimeInterval(foundRange.duration - 1)
            while count != quarter && count > 0 {
                guard let quarterRange = dateInterval(of: .quarter, for: quarterBegin) else {
                    // Out of range
                    throw CalendarEnumerationError.dateOutOfRange(.quarter, quarterBegin)
                }
                
                quarterBegin = quarterRange.start.addingTimeInterval(-quarterRange.duration)
                count -= 1
            }
            
            return quarterBegin
        } else {
            var count = 1
            var quarterBegin = foundRange.start
            while count != quarter && count < 5 {
                guard let quarterRange = dateInterval(of: .quarter, for: quarterBegin) else {
                    // Out of range
                    throw CalendarEnumerationError.dateOutOfRange(.quarter, quarterBegin)
                }
                
                // Move past this quarter. The is the first instant of the next quarter.
                quarterBegin = quarterRange.start.addingTimeInterval(quarterRange.duration)
                count += 1
            }
            
            return quarterBegin
        }
    }
    
    func dateAfterMatchingMonth(startingAt: Date, components: DateComponents, direction: SearchDirection, strictMatching: Bool) throws -> Date? {
        
        guard let month = components.month else {
            // Nothing to do
            return nil
        }
        
        if month < 1 || month > 12 {
            // Out of range
            throw CalendarEnumerationError.dateOutOfRange(.month, startingAt)
        }
        
        // After this point, result is at least startDate.
        var result = startingAt
        var dateMonth = component(.month, from: result)
        if month != dateMonth {
            repeat {
                let lastResult = result
                guard let foundRange = dateInterval(of: .month, for: result) else {
                    throw CalendarEnumerationError.dateOutOfRange(.month, result)
                }
                
                var duration = foundRange.duration
                if direction == .backward {
                    let numMonth = component(.month, from: foundRange.start)
                    if numMonth == 3 && (self.identifier == .gregorian || self.identifier == .buddhist || self.identifier == .japanese || self.identifier == .iso8601 || self.identifier == .republicOfChina) {
                        // Take it back 3 days so we land in february.  That is, March has 31 days, and Feb can have 28 or 29, so to ensure we get to either Feb 1 or 2, we need to take it back 3 days.
                        duration -= 86400 * 3
                    } else {
                        // Take it back a day.
                        duration -= 86400
                    }
                    
                    // So we can go backwards in time.
                    duration *= -1
                }
                
                let searchDate = foundRange.start.addingTimeInterval(duration)
                dateMonth = component(.month, from: searchDate)
                result = searchDate
                
                try verifyAdvancingResult(result, previous: lastResult, direction: direction)
            } while month != dateMonth
        }
        
        return result
    }
    
    func dateAfterMatchingWeekOfYear(startingAt: Date, components: DateComponents, direction: SearchDirection) throws -> Date? {
        
        guard let weekOfYear = components.weekOfYear else {
            // Nothing to do
            return nil
        }
        
        var dateWeekOfYear = component(.weekOfYear, from: startingAt)
        guard weekOfYear != dateWeekOfYear else {
            // Already matches
            return nil
        }
        
        if weekOfYear < 1 || weekOfYear > 53 {
            // Out of range
            throw CalendarEnumerationError.dateOutOfRange(.month, startingAt)
        }
        
        // After this point, the result is at least the start date.
        var result = startingAt
        repeat {
            // Used to check if we are not advancing the week of year.
            let lastResult = result
            guard let foundRange = dateInterval(of: .weekOfYear, for: result) else {
                // Out of range
                throw CalendarEnumerationError.dateOutOfRange(.weekOfYear, result)
            }
            
            if direction == .backward {
                let searchDate = foundRange.start.addingTimeInterval(-foundRange.duration)
                dateWeekOfYear = component(.weekOfYear, from: searchDate)
                result = searchDate
            } else {
                let searchDate = foundRange.start.addingTimeInterval(foundRange.duration)
                dateWeekOfYear = component(.weekOfYear, from: searchDate)
                result = searchDate
            }
            
            try verifyAdvancingResult(result, previous: lastResult, direction: direction)
        } while weekOfYear != dateWeekOfYear
        
        return result
    }
    
    func dateAfterMatchingWeekOfMonth(startingAt: Date, components: DateComponents, direction: SearchDirection) throws -> Date? {
        
        guard let weekOfMonth = components.weekOfMonth else {
            // Nothing to do
            return nil
        }
        
        var dateWeekOfMonth = component(.weekOfMonth, from: startingAt)
        guard weekOfMonth != dateWeekOfMonth else {
            // Already matches
            return nil
        }
        
        // After this point, result is at least startDate.
        var result = startingAt
        repeat {
            guard let foundRange = dateInterval(of: .weekOfMonth, for: result) else {
                // Out of range
                throw CalendarEnumerationError.dateOutOfRange(.weekOfMonth, result)
            }
            
            // We need to advance or rewind to the next week.
            // This is simple when we can jump by a whole week interval, but there are complications around WoM == 1 because it can start on any day of the week. Jumping forward/backward by a whole week can miss it.
            //
            // A week 1 which starts on any day but Sunday contains days from week 5 of the previous month, e.g.
            //
            //        June 2018
            //   Su Mo Tu We Th Fr Sa
            //                   1  2
            //    3  4  5  6  7  8  9
            //   10 11 12 13 14 15 16
            //   17 18 19 20 21 22 23
            //   24 25 26 27 28 29 30
            //
            // Week 1 of June 2018 starts on Friday; any day before that is week 5 of May.
            // We can jump by a week interval if we're not looking for WoM == 2 or we're not close.
            var advanceDaily = weekOfMonth == 1 // we're looking for WoM == 1
            if direction == .backward {
                // Last week/earlier this week is week 1.
                advanceDaily = advanceDaily && dateWeekOfMonth <= 2
            } else {
                // We need to be careful if it's the last week of the month. We can't assume what number week that would be, so figure it out.
                let range = range(of: .weekOfMonth, in: .month, for: result) ?? 0..<Int.max
                advanceDaily = advanceDaily && dateWeekOfMonth == (range.upperBound - range.lowerBound)
            }
            
            var tempSearchDate: Date?
            if !advanceDaily {
                // We can jump directly to next/last week. There's just one further wrinkle here when doing so backwards: due to DST, it's possible that this week is longer/shorter than last week.
                // That means that if we rewind by womInv (the length of this week), we could completely skip last week, or end up not at its first instant.
                //
                // We can avoid this by not rewinding by womInv, but by going directly to the start.
                if direction == .backward {
                    // Any instant before foundRange.start is last week
                    let lateLastWeek = foundRange.start.addingTimeInterval(-1)
                    if let interval = dateInterval(of: .weekOfMonth, for: lateLastWeek) {
                        tempSearchDate = interval.start
                    } else {
                        // Fall back to below case
                        advanceDaily = true
                    }
                } else {
                    // Skipping forward doesn't have these DST concerns, since foundRange already represents the length of this week.
                    tempSearchDate = foundRange.start.addingTimeInterval(foundRange.duration)
                }
            }
            
            // This is a separate condition because it represents a "possible" fallthrough from above.
            if advanceDaily {
                var today = foundRange.start
                while component(.day, from: today) != 1 {
                    if let next = date(byAdding: .day, value: direction == .backward ? -1 : 1, to: today) {
                        today = next
                    } else {
                        break
                    }
                }
                
                tempSearchDate = today
            }
            
            dateWeekOfMonth = component(.weekOfMonth, from: tempSearchDate!)
            try verifyAdvancingResult(tempSearchDate, previous: result, direction: direction)
            result = tempSearchDate
        } while weekOfMonth != dateWeekOfMonth
        
        return result
    }
    
    func dateAfterMatchingDayOfYear(startingAt: Date, components: DateComponents, direction: SearchDirection) throws -> Date? {
        
        guard let dayOfYear = components.dayOfYear else {
            // Nothing to do
            return nil
        }
        
        var dateDayOfYear = component(.dayOfYear, from: startingAt)
        guard dayOfYear != dateDayOfYear else {
            // Already matches
            return nil
        }
        
        let year = components.year ?? component(.year, from: startingAt)
        let isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
        if dayOfYear < 1 || dayOfYear > (isLeapYear ? 366 : 365) {
            // Out of range
            throw CalendarEnumerationError.dateOutOfRange(.dayOfYear, startingAt)
        }
        
        var result = startingAt
        repeat {
            let lastResult = result
            guard let foundRange = dateInterval(of: .dayOfYear, for: result) else {
                throw CalendarEnumerationError.dateOutOfRange(.dayOfYear, result)
            }
            
            if direction == .backward {
                let searchDate = foundRange.start.addingTimeInterval(-foundRange.duration)
                dateDayOfYear = component(.dayOfYear, from: searchDate)
                result = searchDate
            } else {
                let searchDate = foundRange.start.addingTimeInterval(foundRange.duration)
                dateDayOfYear = component(.dayOfYear, from: searchDate)
                result = searchDate
            }
            
            try verifyAdvancingResult(result, previous: lastResult, direction: direction)
        } while dayOfYear != dateDayOfYear
        
        return result
    }
    
    func dateAfterMatchingDay(startingAt: Date, originalStartDate: Date, components: DateComponents, direction: SearchDirection, isStrictMatching: Bool) throws -> Date? {
        
        guard let day = components.day else {
            // Nothing to do
            return nil
        }
        
        var result = startingAt
        let month = components.month
        var dateDay = component(.day, from: startingAt)
        if month != nil && direction == .backward {
            // Are we in the right month already?  If we are and backwards is set, we should move to the beginning of the last day of the month and work backwards.
            if let foundRange = dateInterval(of: .month, for: result) {
                let tempSearchDate = foundRange.end.addingTimeInterval(-1)
                // Check the order to make sure we didn't jump ahead of the start date.
                if tempSearchDate > originalStartDate {
                    // We went too far ahead. Just go back to using the start date as our upper bound.
                    result = originalStartDate
                } else {
                    if let anotherFoundRange = dateInterval(of: .day, for: tempSearchDate) {
                        result = anotherFoundRange.start
                        dateDay = component(.day, from: result)
                    }
                }
            }
        }
        
        if day != dateDay {
            // The condition below keeps us from blowing past a month day by day to find a day which does not exist.
            // e.g. trying to find the 30th of February starting in January would go to March 30th if we don't stop here
            let originalMonth = component(.month, from: result)
            var advancedPastWholeMonth = false
            var lastFoundDuration: TimeInterval = 0.0
            
            repeat {
                guard let foundRange = dateInterval(of: .day, for: result) else {
                    throw CalendarEnumerationError.dateOutOfRange(.day, result)
                }
                
                // Used to track if we went past end of month below.
                lastFoundDuration = foundRange.duration
                
                // We need to either advance or rewind by a day.
                // * Advancing to tomorrow is relatively simple: get the start of today and get the length of that day — then, advance by that length
                // * Rewinding to the start of yesterday is more complicated: the length of today is not necessarily the length of yesterday if DST transitions are involved:
                //   * Today can have 25 hours: if we rewind 25 hours from the start of today, we'll skip yesterday altogether
                //   * Today can have 24 hours: if we rewind 24 hours from the start of today, we might skip yesterday if it had 23 hours, or end up at the wrong time if it had 25
                //   * Today can have 23 hours: if we rewind 23 hours from the start of today, we'll end up at the wrong time yesterday
                //
                // We need to account for DST by ensuring we rewind to exactly the time we want.
                
                let tempSearchDate: Date
                if direction == .backward {
                    // Any time prior to dayBegin is yesterday. Since we want to rewind to the start of yesterday, do that directly.
                    let lateYesterday = foundRange.start.addingTimeInterval(-1)
                    
                    // Now we can get the exact moment that yesterday began on.
                    // It shouldn't be possible to fail to find this interval, but if that somehow happens, we can try to fall back to the simple but wrong method.
                    if let yesterdayRange = dateInterval(of: .day, for: lateYesterday) {
                        tempSearchDate = yesterdayRange.start
                    } else {
                        // This fallback is only really correct when today and yesterday have the same length.
                        // Again, it shouldn't be possible to hit this case.
                        tempSearchDate = foundRange.start.addingTimeInterval(-foundRange.duration)
                    }
                } else {
                    // This is always correct to do since we are using today's length on today -- there can't be a mismatch.
                    tempSearchDate = foundRange.end
                 }
                
                dateDay = component(.day, from: tempSearchDate)
                let dateMonth = component(.month, from: tempSearchDate)
                try verifyAdvancingResult(tempSearchDate, previous: result, direction: direction)
                result = tempSearchDate
                
                if abs(dateMonth - originalMonth) >= 2 {
                    advancedPastWholeMonth = true
                    break
                }
            } while day != dateDay
            
            // If we blew past a month in its entirety, roll back by a day to the very end of the month.
            if (advancedPastWholeMonth) {
                result = result.addingTimeInterval(-lastFoundDuration)
            }
        } else {
            // When the search date matches the day we're looking for, we still need to clear the lower components in case they are not part of the components we're looking for.
            if let foundRange = dateInterval(of: .day, for: result) {
                result = foundRange.start
            }
        }
        
        return result
    }
    
    func dateAfterMatchingWeekdayOrdinal(startingAt: Date, components: DateComponents, direction: SearchDirection) throws -> Date? {
        
        guard let weekdayOrdinal = components.weekdayOrdinal else {
            // Nothing to do
            return nil
        }
        
        var dateWeekdayOrdinal = self.component(.weekdayOrdinal, from: startingAt)
        guard weekdayOrdinal != dateWeekdayOrdinal else {
            // Nothing to do
            return nil
        }
        
        // After this point, result is at least startDate.
        var result = startingAt
        repeat {
            let lastResult = result
            guard let foundRange = self.dateInterval(of: .weekdayOrdinal, for: result) else {
                // Out of range
                throw CalendarEnumerationError.dateOutOfRange(.weekdayOrdinal, result)
            }
            
            if direction == .backward {
                let searchDate = foundRange.start.addingTimeInterval(-foundRange.duration)
                dateWeekdayOrdinal = self.component(.weekdayOrdinal, from: searchDate)
                result = searchDate
            } else {
                let searchDate = foundRange.start.addingTimeInterval(foundRange.duration)
                dateWeekdayOrdinal = self.component(.weekdayOrdinal, from: searchDate)
                result = searchDate
            }
            
            try verifyAdvancingResult(result, previous: lastResult, direction: direction)
        } while weekdayOrdinal != dateWeekdayOrdinal
        
        // NOTE: In order for an ordinal weekday to not be ambiguous, it needs both
        //  - the ordinality (e.g. 1st)
        //  - the weekday (e.g. Tuesday)
        // If the weekday is not set, we assume the client just wants the first time in a month where the number of occurrences of a day matches the weekdayOrdinal value (e.g. for weekdayOrdinal = 4, this means the first time a weekday is the 4th of that month. So if the start date is 2017-06-01, then the first time we hit a day that is the 4th occurrence of a weekday would be 2017-06-22. I recommend looking at the month in its entirety on a calendar to see what I'm talking about.).  This is an odd request, but we will return that result to the client while silently judging them.
        // For a non-ambiguous ordinal weekday (i.e. the ordinality and the weekday have both been set), we need to ensure that we get the exact ordinal day that we are looking for. Hence the below weekday check.
        guard let weekday = components.weekday else {
            // Skip weekday
            return result
        }
        
        // Once we're here, it means we found a day with the correct ordinality, but it may not be the specific weekday we're also looking for (e.g. we found the 2nd Thursday of the month when we're looking for the 2nd Friday).
        var dateWeekday = self.component(.weekday, from: result)
        if weekday == dateWeekday {
            // Already matches
            return result
        }
        
        // Start result over (it is reset in all paths below).
        if dateWeekday > weekday {
            // We're past the weekday we want. Go to the beginning of the week.
            // We use startDate again here, not result.
            if let foundRange = self.dateInterval(of: .weekdayOrdinal, for: startingAt) {
                result = foundRange.start
                let units: Set<Calendar.Component> = [.weekday, .weekdayOrdinal]
                let startingDayWeekdayComps = self.dateComponents(units, from: result)
                
                guard let weekday = startingDayWeekdayComps.weekday, let weekdayOrdinal = startingDayWeekdayComps.weekdayOrdinal
                else {
                    // This should not be possible
                    throw CalendarEnumerationError.unexpectedResult(.weekdayOrdinal, result)
                }
                dateWeekday = weekday
                dateWeekdayOrdinal = weekdayOrdinal
            } else {
                // We need to have a value here - use the start date.
                result = startingAt
            }
        } else {
            result = startingAt
        }
        
        while (weekday != dateWeekday) || (weekdayOrdinal != dateWeekdayOrdinal) {
            // Now iterate through each day of the week until we find the specific weekday we're looking for.
            let lastResult = result
            guard let foundRange = self.dateInterval(of: .day, for: result) else {
                throw CalendarEnumerationError.unexpectedResult(.day, result)
            }
            
            let nextDay = foundRange.start.addingTimeInterval(foundRange.duration)
            let units: Set<Calendar.Component> = [.weekday, .weekdayOrdinal]
            let nextDayComponents = self.dateComponents(units, from: nextDay)
            
            guard let weekday = nextDayComponents.weekday, let weekdayOrdinal = nextDayComponents.weekdayOrdinal else {
                // This should not be possible
                throw CalendarEnumerationError.unexpectedResult(.weekday, nextDay)
            }
            
            dateWeekday = weekday
            dateWeekdayOrdinal = weekdayOrdinal
            result = nextDay
            
            try verifyAdvancingResult(result, previous: lastResult, direction: direction)
        }
        
        return result
    }
    
    func dateAfterMatchingWeekday(startingAt: Date, components: DateComponents, direction: SearchDirection) throws -> Date? {
        
        guard let weekday = components.weekday else {
            // Nothing to do
            return nil
        }
        
        // NOTE: This differs from the weekday check in weekdayOrdinal because weekday is meant to be ambiguous and can be set without setting the ordinality.
        // e.g. inquiries like "find the next Tuesday after 2017-06-01" or "find every Wednesday before 2012-12-25"
        var dateWeekday = self.component(.weekday, from: startingAt)
        guard weekday != dateWeekday else {
            // Already matches
            return nil
        }
        
        if weekday < 1 || weekday > 7 {
            // Out of range
            throw CalendarEnumerationError.dateOutOfRange(.weekday, startingAt)
        }
        
        // After this point, result is at least startDate.
        var result = startingAt
        repeat {
            guard let foundRange = self.dateInterval(of: .weekday, for: result) else {
                throw CalendarEnumerationError.dateOutOfRange(.weekday, result)
            }
            
            // We need to either advance or rewind by a day.
            // * Advancing to tomorrow is relatively simple: get the start of today and get the length of that day — then, advance by that length
            // * Rewinding to the start of yesterday is more complicated: the length of today is not necessarily the length of yesterday if DST transitions are involved:
            //   * Today can have 25 hours: if we rewind 25 hours from the start of today, we'll skip yesterday altogether
            //   * Today can have 24 hours: if we rewind 24 hours from the start of today, we might skip yesterday if it had 23 hours, or end up at the wrong time if it had 25
            //   * Today can have 23 hours: if we rewind 23 hours from the start of today, we'll end up at the wrong time yesterday
            //
            // We need to account for DST by ensuring we rewind to exactly the time we want.
            let tempSearchDate: Date
            if direction == .backward {
                let lateYesterday = foundRange.start.addingTimeInterval(-1)
                if let anotherFoundRange = self.dateInterval(of: .day, for: lateYesterday) {
                    tempSearchDate = anotherFoundRange.start
                } else {
                    // This fallback is only really correct when today and yesterday have the same length.
                    // Again, it shouldn't be possible to hit this case.
                    tempSearchDate = foundRange.start.addingTimeInterval(-foundRange.duration)
                }
            } else {
                // This is always correct to do since we are using today's length on today — there can't be a mismatch.
                tempSearchDate = foundRange.start.addingTimeInterval(foundRange.duration)
            }
            
            dateWeekday = self.component(.weekday, from: tempSearchDate)
            try verifyAdvancingResult(tempSearchDate, previous: result, direction: direction)
            result = tempSearchDate
        } while weekday != dateWeekday
        
        return result
    }
    
    func dateAfterMatchingHour(startingAt startDate: Date, originalStartDate: Date, components: DateComponents, direction: SearchDirection, findLastMatch: Bool, isStrictMatching: Bool, matchingPolicy: MatchingPolicy) throws -> Date? {
        
        guard let hour = components.hour else {
            // Nothing to do
            return nil
        }
        
        if hour < 0 || hour > 23 {
            // Out of range
            throw CalendarEnumerationError.dateOutOfRange(.hour, startingAt)
        }
        
        var result = startDate
        var adjustedSearchStartDate = false
        
        var dateHour = self.component(.hour, from: result)
        
        // The loop below here takes care of advancing forward in the case of an hour mismatch, taking DST into account.
        // However, it does not take into account a unique circumstance: searching for hour 0 of a day on a day that has no hour 0 due to DST.
        //
        // America/Sao_Paulo, for instance, is a time zone which has DST at midnight -- an instant after 11:59:59 PM can become 1:00 AM, which is the start of the new day:
        //
        //            2018-11-03                      2018-11-04
        //    ┌─────11:00 PM (GMT-3)─────┐ │ ┌ ─ ─ 12:00 AM (GMT-3)─ ─ ─┐ ┌─────1:00 AM (GMT-2) ─────┐
        //    │                          │ │ |                          │ │                          │
        //    └──────────────────────────┘ │ └ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─┘ └▲─────────────────────────┘
        //                                            Nonexistent           └── Start of Day
        //
        // The issue with this specifically is that parts of the rewinding algorithm that handle overshooting rewind to the start of the day to search again (or alternatively, adjusting higher components tends to send us to the start of the day).
        // This doesn't work when the day starts past the time we're looking for if we're looking for hour 0.
        //
        // If we're not matching strictly, we need to check whether we're already a non-strict match and not an overshoot.
        if hour == 0 /* searching for hour 0 */ && !isStrictMatching {
            if let foundRange = self.dateInterval(of: .day, for: result) {
                let dayBegin = foundRange.start
                let firstHourOfTheDay = self.component(.hour, from: dayBegin)
                if firstHourOfTheDay != 0 && dateHour == firstHourOfTheDay {
                    // We're at the start of the day; it's just not hour 0.
                    // We have a candidate match. We can modify that match based on the actual options we need to set.
                    
                    if matchingPolicy == .nextTime {
                        // We don't need to preserve the smallest components. We can wipe them out.
                        // Note that we rewind to the start of the hour by rewinding to the start of the day -- normally we'd want to rewind to the start of _this_ hour in case there were a difference in a first/last scenario (repeated hour DST transition), but we can't both be missing hour 0 _and_ be the second hour in a repeated transition.
                        result = dayBegin
                    } else if matchingPolicy == .nextTimePreservingSmallerComponents || matchingPolicy == .previousTimePreservingSmallerComponents {
                        // We want to preserve any currently set smaller units (hour and minute), so don't do anything.
                        // If we need to match the previous time (i.e. go back an hour), that adjustment will be made elsewhere, in the generalized isForwardDST adjustment in the main loop.
                    }
                    
                    // Avoid making any further adjustments again.
                    adjustedSearchStartDate = true
                }
            }
        }
        
        // This is a real mismatch and not due to hour 0 being missing.
        // NOTE: The behavior of generalized isForwardDST checking depends on the behavior of this loop!
        //        Right now, in the general case, this loop stops iteration _before_ a forward DST transition. If that changes, please take a look at the isForwardDST code for when `beforeTransition = false` and adjust as necessary.
        if hour != dateHour && !adjustedSearchStartDate {
            repeat {
                let lastResult = result
                guard let foundRange = self.dateInterval(of: .hour, for: result) else {
                    throw CalendarEnumerationError.dateOutOfRange(.hour, result)
                }
                
                let prevDateHour = dateHour
                let tempSearchDate = foundRange.start.addingTimeInterval(foundRange.duration)
                
                dateHour = self.component(.hour, from: tempSearchDate)
                
                // Sometimes we can get into a position where the next hour is also equal to hour (as in we hit a backwards DST change). In this case, we could be at the first time this hour occurs. If we want the next time the hour is technically the same (as in we need to go to the second time this hour occurs), we check to see if we hit a backwards DST change.
                let possibleBackwardDSTDate = foundRange.start.addingTimeInterval(foundRange.duration * 2.0)
                let secondDateHour = self.component(.hour, from: possibleBackwardDSTDate)
                
                if ((dateHour - prevDateHour) == 2) || (prevDateHour == 23 && dateHour == 1) {
                    // We've hit a forward DST transition.
                    dateHour = dateHour - 1
                    result = foundRange.start
                } else if (secondDateHour == dateHour) && findLastMatch {
                    // If we're not trying to find the last match, just pass on the match we already found.
                    // We've hit a backwards DST transition.
                    result = possibleBackwardDSTDate
                } else {
                    result = tempSearchDate
                }
                
                adjustedSearchStartDate = true
                
                // Verify the hour value (it changes even if the result does not)
                if (result == lastResult && prevDateHour == dateHour) {
                    // We are not advancing. Bail out of the loop
                    throw CalendarEnumerationError.notAdvancing(result, lastResult)
                }
            } while hour != dateHour
            
            if direction == .backward && originalStartDate < result {
                // We've gone into the future when we were supposed to go into the past.  We're ahead by a day.
                if let rolledBack = self.date(byAdding: .day, value: -1, to: result) {
                    result = rolledBack
                }
                
                // Check hours again to see if they match (they may not because of DST change already being handled implicitly by dateByAddingUnit:)
                dateHour = self.component(.hour, from: result)
                if (dateHour - hour) == 1 {
                    // Detecting a DST transition
                    // We have moved an hour ahead of where we want to be so we go back 1 hour to readjust.
                    if let adjusted = self.date(byAdding: .hour, value: -1, to: result) { result = adjusted }
                } else if (hour - dateHour) == 1 {
                    // <rdar://problem/31051045>
                    // This is a weird special edge case that only gets hit when you're searching backwards and move past a forward (skip an hour) DST transition.
                    // We're not at a DST transition but the hour of our date got moved because the previous day had a DST transition.
                    // So we're an hour before where we want to be. We move an hour ahead to correct and get back to where we need to be.
                    if let adjusted = self.date(byAdding: .hour, value: 1, to: result) { result = adjusted }
                }
            }
        }
        
        if findLastMatch {
            if let foundRange = self.dateInterval(of: .hour, for: result) {
                // Rewind forward/back hour-by-hour until we get to a different hour. A loop here is necessary because not all DST transitions are only an hour long.
                var next = foundRange.start
                var nextHour = hour
                while nextHour == hour {
                    result = next
                    let offset = (direction == .backward ? -1 : 1)
                    if let nextDate = self.date(byAdding: .hour, value: offset, to: next) {
                        next = nextDate
                    } else {
                        break
                    }
                    nextHour = self.component(.hour, from: next)
                }
            }
        }
        
        if !adjustedSearchStartDate {
            // This applies if we didn't hit the above cases to adjust the search start date, i.e. the hour already matches the start hour and either:
            // 1) We're not looking to match the "last" (repeated) hour in a DST transition (regardless of whether we're in a DST transition), or
            // 2) We are looking to match that hour, but we're not in that DST transition.
            //
            // In either case, we need to clear the lower components in case they are not part of the components we're looking for.
            if let foundRange = self.dateInterval(of: .hour, for: result) {
                result = foundRange.start
                adjustedSearchStartDate = true
            }
        }
        
        return result
    }
    
    func dateAfterMatchingMinute(startingAt: Date, components: DateComponents, direction: SearchDirection) throws -> Date? {
        
        guard let minute = components.minute else {
            // Nothing to do
            return nil
        }
        
        if minute < 0 || minute > 60 {
            // Out of range
            throw CalendarEnumerationError.dateOutOfRange(.minute, startingAt)
        }
        
        var result = startingAt
        var dateMinute = self.component(.minute, from: result)
        if minute != dateMinute {
            repeat {
                guard let foundRange = self.dateInterval(of: .minute, for: result) else {
                    throw CalendarEnumerationError.dateOutOfRange(.minute, result)
                }
                
                let tempSearchDate = foundRange.start.addingTimeInterval(foundRange.duration)
                dateMinute = self.component(.minute, from: tempSearchDate)
                
                try verifyUnequalResult(tempSearchDate, previous: result, startingAt: startingAt, components: components, direction: direction, strict: nil)
                
                result = tempSearchDate
            } while minute != dateMinute
        } else {
            // When the search date matches the minute we're looking for, we need to clear the lower components in case they are not part of the components we're looking for.
            if let foundRange = self.dateInterval(of: .minute, for: result) {
                result = foundRange.start
            }
        }
        
        return result
    }
    
    func dateAfterMatchingSecond(startingAt startDate: Date, originalStartDate: Date, components: DateComponents, direction: SearchDirection) throws -> Date? {
        
        guard let second = components.second else {
            // Nothing to do
            return nil
        }
        
        if second < 0 || second > 60 {
            // Out of range
            throw CalendarEnumerationError.dateOutOfRange(.minute, startingAt)
        }
        
        // After this point, result is at least startDate.
        var result = startDate
        var dateSecond = self.component(.second, from: result)
        if second != dateSecond {
            repeat {
                guard let foundRange = self.dateInterval(of: .second, for: result) else {
                    throw CalendarEnumerationError.dateOutOfRange(.second, result)
                }
                
                let tempSearchDate = foundRange.start.addingTimeInterval(foundRange.duration)
                dateSecond = self.component(.second, from: tempSearchDate)
                try verifyUnequalResult(tempSearchDate, previous: result, startingAt: startDate, components: components, direction: direction, strict: nil)
                result = tempSearchDate
            } while second != dateSecond

            if originalStartDate < result {
                if direction == .backward {
                    // We've gone into the future when we were supposed to go into the past.
                    // There are multiple times a day where the seconds repeat.  Need to take that into account.
                    let originalStartSecond = self.component(.second, from: originalStartDate)
                    if dateSecond > originalStartSecond {
                        guard let new = self.date(byAdding: .minute, value: -1, to: result) else {
                            return nil
                        }
                        result = new
                    }
                } else {
                    // This handles the case where dateSecond started ahead of second, so doing the above landed us in the next minute.  If minute is not set, we are fine.  But if minute is set, then we are now in the wrong minute and we have to readjust. <rdar://problem/31098131>
                    var searchStartMin = self.component(.minute, from: result)
                    if let minute = components.minute {
                        if searchStartMin > minute {
                            // We've gone ahead of where we needed to be.
                            repeat {
                                // Reset to beginning of minute.
                                guard let foundRange = self.dateInterval(of: .minute, for: result) else {
                                    throw CalendarEnumerationError.dateOutOfRange(.minute, result)
                                }
                                
                                let tempSearchDate = foundRange.start.addingTimeInterval(-foundRange.duration)
                                searchStartMin = self.component(.minute, from: tempSearchDate)
                                try verifyAdvancingResult(tempSearchDate, previous: result, direction: direction)
                                result = tempSearchDate
                            } while searchStartMin > minute
                        }
                    }
                }
            }
        } else {
            // When the search date matches the second we're looking for, we need to clear the lower components in case they are not part of the components we're looking for.
            guard let anotherFoundRange = self.dateInterval(of: .second, for: result) else {
                throw CalendarEnumerationError.dateOutOfRange(.second, result)
            }
            result = anotherFoundRange.start
            // Now searchStartDate <= startDate.
        }
        
        return result
    }
}

// MARK: - Date Verification
/* SKIP NOWARN */
extension Calendar {
    private func verifyAdvancingResult(_ next: Date, previous: Date, direction: Calendar.SearchDirection) throws {
        if (direction == .forward && next <= previous) || (direction == .backward && next >= previous) {
            // We are not advancing. Bail out of the loop.
            throw CalendarEnumerationError.notAdvancing(next, previous)
        }
    }
    
    private func verifyUnequalResult(_ next: Date, previous: Date, startingAt: Date, components: DateComponents, direction: Calendar.SearchDirection, strict: Bool?) throws {
        if (next == previous) {
            // We are not advancing. Bail out of the loop.
            throw CalendarEnumerationError.notAdvancing(next, previous)
        }
    }
}

// MARK: - Date Adjustment
/* SKIP NOWARN */
extension Calendar {
    func _adjustedDate(_ unadjustedMatchDate: Date, startingAfter start: Date, allowStartDate: Bool = false, matching matchingComponents: DateComponents, adjustedMatchingComponents compsToMatch: DateComponents, matchingPolicy: MatchingPolicy, repeatedTimePolicy: RepeatedTimePolicy, direction: SearchDirection, inSearchingDate: Date, previouslyReturnedMatchDate: Date?) throws -> SearchStepResult {
        
        var exactMatch = true
        var isLeapDay = false
        var searchingDate = inSearchingDate
        
        // NOTE: Several comments reference "isForwardDST" as a way to relate areas in forward DST handling.
        var isForwardDST = false
        
        // matchDate may be nil, which indicates a need to keep iterating
        // Step C: Validate what we found and then run block. Then prepare the search date for the next round of the loop.
        guard let matchDate = try _adjustedDateForMismatches(start: start, searchingDate: searchingDate, matchDate: unadjustedMatchDate, matchingComponents: matchingComponents, compsToMatch: compsToMatch, direction: direction, matchingPolicy: matchingPolicy, repeatedTimePolicy: repeatedTimePolicy, isForwardDST: &isForwardDST, isExactMatch: &exactMatch, isLeapDay: &isLeapDay) else {
            
            // Try again with a bumped up date
            if let newSearchingDate = bumpedDateUpToNextHigherUnitInComponents(searchingDate, matchingComponents, direction, nil) {
                searchingDate = newSearchingDate
            }
            
            return SearchStepResult(result: nil, newSearchDate: searchingDate)
        }
        
        // Check the components to see if they match what was desired.
        let matchResult = self.date(matchDate, containsMatchingComponents: matchingComponents)
        let mismatchedUnits = matchResult.0
        let dateMatchesComps = matchResult.1
        if dateMatchesComps && !exactMatch {
            exactMatch = true
        }
        
        // Bump up the next highest unit.
        if let newSearchingDate = bumpedDateUpToNextHigherUnitInComponents(searchingDate, matchingComponents, direction, matchDate) {
            searchingDate = newSearchingDate
        }
        
        // Nanosecond and quarter mismatches are not considered inexact.
        let notAnExactMatch = (dateMatchesComps == false) && (mismatchedUnits.contains(.nanosecond) == false) && (mismatchedUnits.contains(.quarter) == false)
        if notAnExactMatch {
            exactMatch = false
        }
        
        let order: ComparisonResult
        if let previouslyReturnedMatchDate = previouslyReturnedMatchDate {
            order = previouslyReturnedMatchDate.compare(matchDate)
        } else {
            order = start.compare(matchDate)
        }
        
        if ((direction == .backward && order == .orderedAscending) || (direction == .forward && order == .orderedDescending)) && mismatchedUnits.contains(.nanosecond) == false {
            // We've gone ahead when we should have gone backwards or we went in the past when we were supposed to move forwards.
            // Normally, it's sufficient to set matchDate to nil and move on with the existing searching date. However, the searching date has been bumped forward by the next highest date component, which isn't always correct.
            // Specifically, if we're in a type of transition when the highest date component can repeat between now and the next highest date component, then we need to move forward by less.
            //
            // This can happen during a "fall back" DST transition in which an hour is repeated:
            //
            //   ┌─────1:00 PDT─────┐ ┌─────1:00 PST─────┐
            //   │                  │ │                  │
            //   └───────────▲───▲──┘ └───────────▲──────┘
            //               │   │                │
            //               |   |                valid
            //               │   last match/start
            //               │
            //               matchDate
            //
            // Instead of jumping ahead by a whole day, we can jump ahead by an hour to the next appropriate match. `valid` here would be the result found by searching with matchLast.
            // In this case, before giving up on the current match date, we need to adjust the next search date with this information.
            //
            // Currently, the case we care most about is adjusting for DST, but we might need to expand this to handle repeated months in some calendars.
            if compsToMatch.highestSetUnit == .hour {
                let matchHour = component(.hour, from: matchDate)
                let hourAdjustment = direction == .backward ? -3600.0 : 3600.0
                let potentialNextMatchDate = matchDate.addingTimeInterval(hourAdjustment)
                let potentialMatchHour = component(.hour, from: potentialNextMatchDate)
                
                if matchHour == potentialMatchHour {
                    // We're in a DST transition where the hour repeats. Use this date as the next search date.
                    searchingDate = potentialNextMatchDate
                }
            }
            
            // In any case, return nil.
            return SearchStepResult(result: nil, newSearchDate: searchingDate)
        }
        
        // At this point, the date we matched is allowable unless:
        // 1) It's not an exact match AND
        // 2) We require an exact match (strict) OR
        // 3) It's not an exact match but not because we found a DST hour or day that doesn't exist in the month (i.e. it's truly the wrong result)
        let allowInexactMatchingDueToTimeSkips = isForwardDST || isLeapDay
        if !exactMatch && (matchingPolicy == .strict || !allowInexactMatchingDueToTimeSkips) {
            return SearchStepResult(result: nil, newSearchDate: searchingDate)
        }
        
        // If we get a result that is exactly the same as the start date, skip.
        if !allowStartDate, order == .orderedSame {
            return SearchStepResult(result: nil, newSearchDate: searchingDate)
        }
        
        return SearchStepResult(result: (matchDate, exactMatch), newSearchDate: searchingDate)
    }
    
    func _adjustedDateForMismatches(start: Date, searchingDate: Date, matchDate: Date, matchingComponents: DateComponents, compsToMatch: DateComponents, direction: SearchDirection, matchingPolicy: MatchingPolicy, repeatedTimePolicy: RepeatedTimePolicy, isForwardDST: inout Bool, isExactMatch: inout Bool, isLeapDay: inout Bool) throws -> Date? {
        
        // Set up some default answers for the out args.
        isForwardDST = false
        isExactMatch = true
        isLeapDay = false
        
        // Use this to find the units that don't match and then those units become the bailedUnit.
        let result = date(matchDate, containsMatchingComponents: compsToMatch)
        let mismatchedUnits = result.0
        let dateMatchesComps = result.1
        
        // Skip trying to correct nanoseconds or quarters. We don't want differences in these two (partially unsupported) fields to cause mismatched dates. <rdar://problem/30229247> / <rdar://problem/30229506>
        let nanoSecondsMismatch = mismatchedUnits.contains(.nanosecond)
        let quarterMismatch = mismatchedUnits.contains(.quarter)
        if nanoSecondsMismatch || quarterMismatch {
            // Everything else is fine. Just return this date.
            return matchDate
        }
        
        // Check if *only* the hour is mismatched.
        if mismatchedUnits.count == 1 && mismatchedUnits.contains(.hour) {
            if let resultAdjustedForDST = _adjustedDateForMismatchedHour(matchDate: matchDate, compsToMatch: compsToMatch, matchingPolicy: matchingPolicy, repeatedTimePolicy: repeatedTimePolicy, isExactMatch: &isExactMatch) {
                isForwardDST = true
                // Skip the next set of adjustments too.
                return resultAdjustedForDST
            }
        }
        
        if dateMatchesComps {
            // Everything is already fine. Just return the value.
            return matchDate
        }
        
        guard let bailedUnit = mismatchedUnits.highestSetUnit else {
            // There was no real mismatch, apparently. Return the matchDate.
            return matchDate
        }
        
        var nextHighestUnit = bailedUnit.nextHigherUnit
        if nextHighestUnit == nil {
            // Just return the original date in this case.
            return matchDate
        }
        
        // Corrective measures.
        if bailedUnit == .era {
            nextHighestUnit = .year
        } else if bailedUnit == .year || bailedUnit == .yearForWeekOfYear {
            nextHighestUnit = bailedUnit
        }
        
        // We need to check for leap* situations.
        let isGregorianCalendar = identifier == .gregorian
        if nextHighestUnit == .year {
            let desiredMonth = compsToMatch.month
            let desiredDay = compsToMatch.day
            
            if !((desiredMonth != nil) && (desiredDay != nil)) {
                // Just return the original date in this case.
                return matchDate
            }
            
            // Here is where we handle the other leap* situations (e.g. leap years in Gregorian calendar, leap months in Hebrew calendar).
            let monthMismatched = mismatchedUnits.contains(.month)
            let dayMismatched = mismatchedUnits.contains(.day)
            if monthMismatched || dayMismatched {
                // Force unwrap nextHighestUnit because it must be set here (or we should have gone down the path).
                return try _adjustedDateForMismatchedLeapMonthOrDay(start: start, searchingDate: searchingDate, matchDate: matchDate, matchingComponents: matchingComponents, compsToMatch: compsToMatch, nextHighestUnit: nextHighestUnit!, direction: direction, matchingPolicy: matchingPolicy, repeatedTimePolicy: repeatedTimePolicy, isExactMatch: &isExactMatch, isLeapDay: &isLeapDay)
            }
            
            // Last opportunity here is just to return the original match date.
            return matchDate
        } else if nextHighestUnit == .month && isGregorianCalendar && component(.month, from: matchDate) == 2 {
            // We've landed here because we couldn't find the date we wanted in February, because it doesn't exist (e.g. Feb 31st or 30th, or 29th on a non-leap-year).
            // matchDate is the end of February, so we need to advance to the beginning of March.
            if let february = dateInterval(of: .month, for: matchDate) {
                var adjustedDate = february.start.addingTimeInterval(february.duration)
                if matchingPolicy == .nextTimePreservingSmallerComponents {
                    // Advancing has caused us to lose all smaller units, so if we're looking to preserve them we need to add them back.
                    let smallerUnits = dateComponents([.hour, .minute, .second, .nanosecond], from: start)
                    if let tempSearchDate = date(byAdding: smallerUnits, to: adjustedDate) {
                        adjustedDate = tempSearchDate
                    } else {
                        // TODO: Assert?
                        return nil
                    }
                }
                
                // This isn't strictly a leap day, just a day that doesn't exist.
                isLeapDay = true
                isExactMatch = false
                return adjustedDate
            }
            
            return matchDate
        } else {
            // Go to the top of the next period for the next highest unit of the one that bailed.
            // Force unwrap nextHighestUnit because it must be set here (or we should have gone down the leapMonthMismatch path).
            return try _matchingDate(after: searchingDate, matching: matchingComponents, inNextHighestUnit: nextHighestUnit!, direction: direction, matchingPolicy: matchingPolicy, repeatedTimePolicy: repeatedTimePolicy)
        }
    }
    
    func _adjustedDateForMismatchedHour(matchDate: Date, compsToMatch:DateComponents, matchingPolicy: MatchingPolicy, repeatedTimePolicy: RepeatedTimePolicy, isExactMatch: inout Bool) -> Date? {
        
        // It's possible this is a DST time. Let's check.
        guard let found = dateInterval(of: .hour, for: matchDate) else {
            // Not DST
            return nil
        }
        
        // matchDate may not match because of a forward DST transition (e.g. spring forward, hour is lost).
        // matchDate may be before or after this lost hour, so look in both directions.
        let currentHour = component(.hour, from: found.start)
        
        var isForwardDST = false
        var beforeTransition = true
        
        let next = found.start.addingTimeInterval(found.duration)
        let nextHour = component(.hour, from: next)
        if (nextHour - currentHour) > 1 || (currentHour == 23 && nextHour > 0) {
            // We're just before a forward DST transition, e.g., for America/Sao_Paulo:
            //
            //            2018-11-03                      2018-11-04
            //    ┌─────11:00 PM (GMT-3)─────┐ │ ┌ ─ ─ 12:00 AM (GMT-3)─ ─ ─┐ ┌─────1:00 AM (GMT-2) ─────┐
            //    │                          │ │ |                          │ │                          │
            //    └──────▲───────────────────┘ │ └ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─┘ └──────────────────────────┘
            //           └── Here                        Nonexistent
            //
            isForwardDST = true
        } else {
            // We might be just after such a transition.
            let previous = found.start.addingTimeInterval(-1)
            let previousHour = component(.hour, from: previous)
            
            if ((currentHour - previousHour) > 1 || (previousHour == 23 && currentHour > 0)) {
                // We're just after a forward DST transition, e.g., for America/Sao_Paulo:
                //
                //            2018-11-03                      2018-11-04
                //    ┌─────11:00 PM (GMT-3)─────┐ │ ┌ ─ ─ 12:00 AM (GMT-3)─ ─ ─┐ ┌─────1:00 AM (GMT-2) ─────┐
                //    │                          │ │ |                          │ │                          │
                //    └──────────────────────────┘ │ └ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─┘ └──▲───────────────────────┘
                //                                            Nonexistent            └── Here
                //
                isForwardDST = true
                beforeTransition = false
            }
        }
        
        // We can only adjust when matches need not be strict.
        if !(isForwardDST && matchingPolicy != .strict) {
            return nil
        }

        // We can adjust the time as necessary to make this match close enough.
        // Since we aren't trying to strictly match and are now going to make a best guess approximation, we set exactMatch to false.
        isExactMatch = false

        if beforeTransition {
            if matchingPolicy == .nextTimePreservingSmallerComponents {
                return date(byAdding: .hour, value: 1, to: matchDate)
            } else if matchingPolicy == .nextTime {
                return next
            } else {
                // No need to check `previousTimePreservingSmallerUnits` or `strict`:
                // * If we're matching the previous time, `matchDate` is already correct because we're pre-transition
                // * If we're matching strictly, we shouldn't be here (should be guarded by the if-statement condition): we can't adjust a strict match
                return matchDate
            }
        } else {
            if matchingPolicy == .nextTime {
                // `startOfHour` is the start of the hour containing `matchDate` (i.e. take `matchDate` but wipe the minute and second)
                return found.start
            } else if matchingPolicy == .previousTimePreservingSmallerComponents {
                // We've arrived here after a mismatch due to a forward DST transition, and specifically, one which produced a candidate matchDate which was _after_ the transition.
                // At the time of writing this (2018-07-11), the only way to hit this case is under the following circumstances:
                //
                //   * DST transition in a time zone which transitions at `hour = 0` (i.e. 11:59:59 -> 01:00:00)
                //   * Components request `hour = 0`
                //   * Components contain a date component higher than hour which advanced us to the start of the day from a prior day
                //
                // If the DST transition is not at midnight, the components request any other hour, or there is no higher date component, we will have fallen into the usual hour-rolling loop.
                // That loop right now takes care to stop looping _before_ the transition.
                //
                // This means that right now, if we attempt to match the previous time while preserving smaller components (i.e. rewinding by an hour), we will no longer match the higher date component which had been requested.
                // For instance, if searching for `weekday = 1` (Sunday) got us here, rewinding by an hour brings us back to Saturday. Similarly, if asking for `month = x` got us here, rewinding by an hour would bring us to `month = x - 1`.
                // These mismatches are not proper candidates and should not be accepted.
                //
                // However, if the conditions of the hour-rolling loop ever change, I am including the code which would be correct to use here: attempt to roll back by an hour, and check whether we've introduced a new mismatch.

                // We don't actually have a match. Claim it's not DST too, to avoid accepting matchDate as-is anyway further on (which is what isForwardDST = true allows for).
                return nil
            } else {
                // No need to check `nextTimePreservingSmallerUnits` or `strict`:
                // * If we're matching the next time, `matchDate` is already correct because we're post-transition
                // * If we're matching strictly, we shouldn't be here (should be guarded by the if-statement condition): we can't adjust a strict match
                return matchDate
            }
        }
    }
    
    func _adjustedDateForMismatchedLeapMonthOrDay(start: Date, searchingDate: Date, matchDate: Date, matchingComponents: DateComponents, compsToMatch: DateComponents, nextHighestUnit: Calendar.Component, direction: SearchDirection, matchingPolicy: MatchingPolicy, repeatedTimePolicy: RepeatedTimePolicy, isExactMatch: inout Bool, isLeapDay: inout Bool) throws -> Date? {
        let searchDateComps = self.dateComponents([.year, .month, .day], from: searchingDate)
        
        let searchDateDay = searchDateComps.day
        let searchDateMonth = searchDateComps.month
        let searchDateYear = searchDateComps.year
        let desiredMonth = compsToMatch.month
        let desiredDay = compsToMatch.day
        
        let detectedLeapYearSituation = ((desiredDay != nil) && (searchDateDay != desiredDay)) || ((desiredMonth != nil) && (searchDateMonth != desiredMonth))
        if detectedLeapYearSituation == false {
            return nil
        }
        
        guard let sYear = searchDateYear, let sMonth = searchDateMonth, let dDay = desiredDay, let dMonth = desiredMonth else {
            return nil
        }
        
        var foundGregLeapMatchesComps = false
        var result: Date? = matchDate
        
        if identifier == .gregorian {
            if dMonth == 2 && matchingComponents.month == 2 {
                var amountToAdd: Int
                if direction == .backward {
                    amountToAdd = (sYear % 4) * -1
                    if amountToAdd == 0 && sMonth >= dMonth {
                        amountToAdd = amountToAdd - 4
                    }
                } else {
                    amountToAdd = 4 - (sYear % 4)
                }
                
                if let searchDateInLeapYear = self.date(byAdding: .year, value: amountToAdd, to: searchingDate),
                   let leapYearInterval = self.dateInterval(of: .year, for: searchDateInLeapYear) {
                    
                    guard let inner = try _matchingDate(after: leapYearInterval.start, matching: compsToMatch, direction: .forward, matchingPolicy: matchingPolicy, repeatedTimePolicy: repeatedTimePolicy) else {
                        return nil
                    }
                    
                    let leapCheck = self.date(inner, containsMatchingComponents: compsToMatch)
                    foundGregLeapMatchesComps = leapCheck.1
                    result = inner
                }
            }
        }
        
        if foundGregLeapMatchesComps == false {
            if matchingPolicy == .strict {
                if identifier == .gregorian {
                    isExactMatch = false
                } else {
                    result = try _matchingDate(after: searchingDate, matching: matchingComponents, inNextHighestUnit: nextHighestUnit, direction: direction, matchingPolicy: matchingPolicy, repeatedTimePolicy: repeatedTimePolicy)
                }
            } else {
                var compsCopy = compsToMatch
                var tempComps = DateComponents()
                tempComps.year = sYear
                tempComps.month = dMonth
                tempComps.day = 1
                
                if matchingPolicy == .nextTime {
                    if let cYear = compsToMatch.year {
                        compsCopy.year = cYear > sYear ? cYear : sYear
                    } else {
                        compsCopy.year = sYear
                    }
                    
                    guard let tempDate = self.date(from: tempComps),
                          let followingMonthDate = self.date(byAdding: .month, value: 1, to: tempDate) else {
                        return nil
                    }
                    
                    compsCopy.month = self.component(.month, from: followingMonthDate)
                    compsCopy.day = 1
                    
                    guard let inner = try _matchingDate(after: start, matching: compsCopy, direction: direction, matchingPolicy: matchingPolicy, repeatedTimePolicy: repeatedTimePolicy) else {
                        return nil
                    }
                    
                    let innerCheck = self.date(inner, containsMatchingComponents: compsCopy)
                    if innerCheck.1 {
                        if let foundRange = self.dateInterval(of: .day, for: inner) {
                            result = foundRange.start
                        } else {
                            result = inner
                        }
                    } else {
                        result = nil
                    }
                } else {
                    preserveSmallerUnits(start, compsToMatch: compsToMatch, compsToModify: &compsCopy)
                    if matchingPolicy == .nextTimePreservingSmallerComponents {
                        if let cYear = compsToMatch.year {
                            compsCopy.year = cYear > sYear ? cYear : sYear
                        } else {
                            compsCopy.year = sYear
                        }

                        tempComps.year = compsCopy.year
                        guard let tempDate = self.date(from: tempComps),
                              let followingMonthDate = self.date(byAdding: .month, value: 1, to: tempDate) else {
                            return nil
                        }
                        
                        compsCopy.month = self.component(.month, from: followingMonthDate)
                        compsCopy.day = 1
                    } else {
                        guard let tempDate = self.date(from: tempComps),
                              let range = self.range(of: .day, in: .month, for: tempDate) else {
                            return nil
                        }
                        
                        let lastDayOfMonth = range.upperBound - range.lowerBound
                        if dDay >= lastDayOfMonth {
                            compsCopy.day = lastDayOfMonth
                        } else {
                            compsCopy.day = dDay - 1
                        }
                    }
                    
                    guard let inner = try _matchingDate(after: searchingDate, matching: compsCopy, direction: direction, matchingPolicy: matchingPolicy, repeatedTimePolicy: repeatedTimePolicy) else {
                        return nil
                    }
                    
                    let finalCheck = self.date(inner, containsMatchingComponents: compsCopy)
                    if finalCheck.1 == false {
                        result = nil
                    } else {
                        result = inner
                    }
                }

                isExactMatch = false
                isLeapDay = true
            }
        }

        return result
    }
    
    func _adjustedComponents(_ comps: DateComponents, date: Date, direction: SearchDirection) -> DateComponents {
        // This method ensures that the algorithm enumerates through each year or month if they are not explicitly set in the DateComponents passed into enumerateDates.  This only applies to cases where the highest set unit is month or day (at least for now).  For full in context explanation, see where it gets called in enumerateDates.
        let highestSetUnit = comps.highestSetUnit
        switch highestSetUnit {
        case .month:
            var adjusted = comps
            adjusted.year = component(.year, from: date)
            // TODO: can year ever be nil here?
            if let adjustedDate = self.date(from: adjusted) {
                if direction == .forward && date > adjustedDate {
                    adjusted.year = (adjusted.year ?? 0) + 1
                } else if direction == .backward && date < adjustedDate {
                    adjusted.year = (adjusted.year ?? 0) - 1
                }
            }
            return adjusted
        case .day:
            var adjusted = comps
            if direction == .backward {
                let dateDay = component(.day, from: date)
                // We need to make sure we don't surpass the day we want.
                if comps.day ?? Int.max >= dateDay {
                    let tempDate = self.date(byAdding: .month, value: -1, to: date)!
                    adjusted.month = component(.month, from: tempDate)
                } else {
                    // Adjusted is the date components we're trying to match against; dateDay is the current day of the current search date.
                    // See the comment in enumerateDates for the justification for adding the month to the components here.
                    //
                    // However, we can't unconditionally add the current month to these components. If the current search date is on month M and day D, and the components we're trying to match have day D' set, the resultant date components to match against are {day=D', month=M}.
                    // This is only correct sometimes:
                    //
                    //  * If D' > D (e.g. we're on Nov 05, and trying to find the next 15th of the month), then it's okay to try to match Nov 15.
                    //  * However, if D' <= D (e.g. we're on Nov 05, and are trying to find the next 2nd of the month), then it's not okay to try to match Nov 02.
                    //
                    // We can only adjust the month if it won't cause us to search "backwards" in time (causing us to elsewhere end up skipping the first [correct] match we find).
                    // These same changes apply to the backwards case above.
                    let dateMonth = component(.month, from: date)
                    adjusted.month = dateMonth
                }
            } else {
                let dateDay = component(.day, from: date)
                if comps.day ?? Int.max > dateDay {
                    adjusted.month = component(.month, from: date)
                }
            }
            return adjusted
        default:
            // Nothing to adjust
            return comps
        }
    }
}

// MARK: - Helpers
/* SKIP NOWARN */
extension Calendar {
    func dateIfEraHasYear(era: Int, year: Int) -> Date? {
        var dateComp = DateComponents()
        dateComp.era = era
        dateComp.year = year
        dateComp.month = 1
        dateComp.day = 1
        
        guard var date = self.date(from: dateComp) else { return nil }
        
        var currentEra = component(.era, from: date)
        var currentYear = component(.year, from: date)
        
        if year == 1 {
            let addingComp = DateComponents(day: 1)
            
            // This is needed for Japanese calendar (and maybe other calendars with more than a few eras too).
            while currentEra < era {
                guard let newDate = self.date(byAdding: addingComp, to: date!) else { return nil }
                date = newDate
                currentEra = component(.era, from: date)
            }
            
            currentYear = component(.year, from: date)
        }
        
        if currentEra == era && currentYear == year {
            // For Gregorian calendar at least, era and year should always match up so date should always be assigned to result.
            return date
        }
        
        return nil
    }
    
    func date(_ date: Date, containsMatchingComponents compsToMatch: DateComponents) -> (Set<Calendar.Component>, Bool) {
        var dateMatchesComps = true
        let units = compsToMatch.setUnits
        var compsFromDate = self.dateComponents(units, from: date)
        
        if compsToMatch.calendar != nil {
            compsFromDate.calendar = compsToMatch.calendar
        }
        if compsToMatch.timeZone != nil {
            compsFromDate.timeZone = compsToMatch.timeZone
        }
        
        if compsFromDate != compsToMatch {
            dateMatchesComps = false
            var mismatchedUnitsOut = compsFromDate.mismatchedUnits(comparedTo: compsToMatch)
            if mismatchedUnitsOut.isEmpty {
                return ([], true)
            }
            
            return (mismatchedUnitsOut, false)
        } else {
            return ([], true)
        }
    }
    
    func bumpedDateUpToNextHigherUnitInComponents(_ searchingDate: Date, _ components: DateComponents, _ direction: SearchDirection, _ matchDate: Date?) -> Date? {
        guard let highestSetUnit = components.highestSetUnit else {
            // Empty components?
            return nil
        }
        
        let nextUnitAboveHighestSet: Component
        
        if highestSetUnit == .era {
            nextUnitAboveHighestSet = .year
        } else if highestSetUnit == .year || highestSetUnit == .yearForWeekOfYear {
            nextUnitAboveHighestSet = highestSetUnit
        } else {
            guard let next = highestSetUnit.nextHigherUnit else {
                return nil
            }
            nextUnitAboveHighestSet = next
        }
        
        // Advance to the start or end of the next highest unit. Old code here used to add `±1 nextUnitAboveHighestSet` to searchingDate and manually adjust afterwards, but this is incorrect in many cases.
        // For instance, this is wrong when searching forward looking for a specific Week of Month. Take for example, searching for WoM == 1:
        //
        //           January 2018           February 2018
        //       Su Mo Tu We Th Fr Sa    Su Mo Tu We Th Fr Sa
        //  W1       1  2  3  4  5  6                 1  2  3
        //  W2    7  8  9 10 11 12 13     4  5  6  7  8  9 10
        //  W3   14 15 16 17 18 19 20    11 12 13 14 15 16 17
        //  W4   21 22 23 24 25 26 27    18 19 20 21 22 23 24
        //  W5   28 29 30 31             25 26 27 28
        //
        // Consider searching for `WoM == 1` when searchingDate is *in* W1 of January. Because we're looking to advance to next month, we could simply add a month, right?
        // Adding a month from Monday, January 1st lands us on Thursday, February 1st; from Tuesday, January 2nd we get Friday, February 2nd, etc. Note though that for January 4th, 5th, and 6th, adding a month lands us in **W2** of February!
        // This means that if we continue searching forward from there, we'll have completely skipped W1 of February as a candidate week, and search forward until we hit W1 of March. This is incorrect.
        //
        // What we really want is to skip to the _start_ of February and search from there -- if we undershoot, we can always keep looking.
        // Searching backwards is similar: we can overshoot if we were subtracting a month, so instead we want to jump back to the very end of the previous month.
        // In general, this translates to jumping to the very beginning of the next period of the next highest unit when searching forward, or jumping to the very end of the last period when searching backward.
        guard let foundRange = dateInterval(of: nextUnitAboveHighestSet, for: searchingDate) else {
            return nil
        }
        
        var result = foundRange.start.addingTimeInterval(direction == .backward ? -1.0 : foundRange.duration)
        if let matchDate {
            let ordering = matchDate.compare(result)
            if (ordering != .orderedAscending && direction == .forward) || (ordering != .orderedDescending && direction == .backward) {
                // We need to advance searchingDate so that it starts just after matchDate.
                // We already guarded against an empty components above, so force unwrap here.
                if let lowestSetUnit = components.lowestSetUnit {
                    guard let date = self.date(byAdding: lowestSetUnit, value: direction == .backward ? -1 : 1, to: matchDate) else {
                        return nil
                    }
                    result = date
                }
            }
        }
        
        return result
    }
    
    func preserveSmallerUnits(_ date: Date, compsToMatch: DateComponents, compsToModify: inout DateComponents) {
        let smallerUnits = self.dateComponents([.hour, .minute, .second], from: date)
        
        // Either preserve the units we're trying to match if they are explicitly defined or preserve the hour/min/sec in the date.
        compsToModify.hour = compsToMatch.hour ?? smallerUnits.hour
        compsToModify.minute = compsToMatch.minute ?? smallerUnits.minute
        compsToModify.second = compsToMatch.second ?? smallerUnits.second
    }
}

// MARK: - Private Extensions
private extension Calendar.Component {
    var nextHigherUnit: Self? {
        switch self {
        case .timeZone, .calendar:
            return nil // not really components
        case .era:
            return nil
        case .year, .yearForWeekOfYear:
            return .era
        case .weekOfYear:
            return .yearForWeekOfYear
        case .quarter, .month, .dayOfYear:
            return .year
        case .day, .weekOfMonth, .weekdayOrdinal:
            return .month
        case .weekday:
            return .weekOfMonth
        case .hour:
            return .day
        case .minute:
            return .hour
        case .second:
            return .minute
        case .nanosecond:
            return .second
        }
    }
}

private extension Set where Element == Calendar.Component {
    var highestSetUnit: Calendar.Component? {
        if self.contains(Calendar.Component.era) { return .era }
        if self.contains(Calendar.Component.year) { return .year }
        if self.contains(Calendar.Component.dayOfYear) { return .dayOfYear }
        if self.contains(Calendar.Component.quarter) { return .quarter }
        if self.contains(Calendar.Component.month) { return .month }
        if self.contains(Calendar.Component.day) { return .day }
        if self.contains(Calendar.Component.hour) { return .hour }
        if self.contains(Calendar.Component.minute) { return .minute }
        if self.contains(Calendar.Component.second) { return .second }
        if self.contains(Calendar.Component.weekday) { return .weekday }
        if self.contains(Calendar.Component.weekdayOrdinal) { return .weekdayOrdinal }
        if self.contains(Calendar.Component.weekOfMonth) { return .weekOfMonth }
        if self.contains(Calendar.Component.weekOfYear) { return .weekOfYear }
        if self.contains(Calendar.Component.yearForWeekOfYear) { return .yearForWeekOfYear }
        if self.contains(Calendar.Component.nanosecond) { return .nanosecond }
        
        // The calendar and timeZone properties do not count as a 'highest unit set', since they are not ordered in time like the others are.
        return nil
    }
}

private extension DateComponents {
    var highestSetUnit: Calendar.Component? {
        // A note on performance: this approach is much faster than using key paths, which require a lot more allocations.
        if self.era != nil { return .era }
        if self.year != nil { return .year }
        if self.dayOfYear != nil { return .dayOfYear }
        if self.quarter != nil { return .quarter }
        if self.month != nil { return .month }
        if self.day != nil { return .day }
        if self.hour != nil { return .hour }
        if self.minute != nil { return .minute }
        if self.second != nil { return .second }

        // It may seem a bit odd to check in this order, but it's been a longstanding behavior.
        if self.weekday != nil { return .weekday }
        if self.weekdayOrdinal != nil { return .weekdayOrdinal }
        if self.weekOfMonth != nil { return .weekOfMonth }
        if self.weekOfYear != nil { return .weekOfYear }
        if self.yearForWeekOfYear != nil { return .yearForWeekOfYear }
        if self.nanosecond != nil { return .nanosecond }
        return nil
    }
    
    var lowestSetUnit: Calendar.Component? {
        // A note on performance: this approach is much faster than using key paths, which require a lot more allocations.
        if self.nanosecond != nil { return .nanosecond }

        // It may seem a bit odd to check in this order, but it's been a longstanding behavior.
        if self.yearForWeekOfYear != nil { return .yearForWeekOfYear }
        if self.weekOfYear != nil { return .weekOfYear }
        if self.weekOfMonth != nil { return .weekOfMonth }
        if self.weekdayOrdinal != nil { return .weekdayOrdinal }
        if self.weekday != nil { return .weekday }
        if self.second != nil { return .second }
        if self.minute != nil { return .minute }
        if self.hour != nil { return .hour }
        if self.day != nil { return .day }
        if self.month != nil { return .month }
        if self.quarter != nil { return .quarter }
        if self.dayOfYear != nil { return .dayOfYear }
        if self.year != nil { return .year }
        if self.era != nil { return .era }
        return nil
    }

    var setUnits: Set<Calendar.Component> {
        var units = Set<Calendar.Component>()
        if self.era != nil { units.insert(.era) }
        if self.year != nil { units.insert(.year) }
        if self.quarter != nil { units.insert(.quarter) }
        if self.month != nil { units.insert(.month) }
        if self.day != nil { units.insert(.day) }
        if self.hour != nil { units.insert(.hour) }
        if self.minute != nil { units.insert(.minute) }
        if self.second != nil { units.insert(.second) }
        if self.weekday != nil { units.insert(.weekday) }
        if self.weekdayOrdinal != nil { units.insert(.weekdayOrdinal) }
        if self.weekOfMonth != nil { units.insert(.weekOfMonth) }
        if self.weekOfYear != nil { units.insert(.weekOfYear) }
        if self.yearForWeekOfYear != nil { units.insert(.yearForWeekOfYear) }
        if self.dayOfYear != nil { units.insert(.dayOfYear) }
        if self.nanosecond != nil { units.insert(.nanosecond) }
        return units
    }
    
    var setUnitCount: Int {
        return self.setUnits.count
    }
    
    func mismatchedUnits(comparedTo other: DateComponents) -> Set<Calendar.Component> {
        var mismatched = Set<Calendar.Component>()
        if self.era != other.era { mismatched.insert(.era) }
        if self.year != other.year { mismatched.insert(.year) }
        if self.quarter != other.quarter { mismatched.insert(.quarter) }
        if self.month != other.month { mismatched.insert(.month) }
        if self.day != other.day { mismatched.insert(.day) }
        if self.hour != other.hour { mismatched.insert(.hour) }
        if self.minute != other.minute { mismatched.insert(.minute) }
        if self.second != other.second { mismatched.insert(.second) }
        if self.weekday != other.weekday { mismatched.insert(.weekday) }
        if self.weekdayOrdinal != other.weekdayOrdinal { mismatched.insert(.weekdayOrdinal) }
        if self.weekOfMonth != other.weekOfMonth { mismatched.insert(.weekOfMonth) }
        if self.weekOfYear != other.weekOfYear { mismatched.insert(.weekOfYear) }
        if self.yearForWeekOfYear != other.yearForWeekOfYear { mismatched.insert(.yearForWeekOfYear) }
        if self.nanosecond != other.nanosecond { mismatched.insert(.nanosecond) }
        return mismatched
    }
}

#endif

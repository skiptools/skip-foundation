// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org
import Foundation
import XCTest

@available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
final class DateTests: XCTestCase {
    func testDateTime() throws {
        let date: Date = Date()
        XCTAssertNotEqual(0, date.timeIntervalSince1970)
    }

    func testMultipleConstructorsSameParams() throws {
        let d1 = Date(timeIntervalSince1970: 99999)
        let d2 = Date(timeIntervalSinceReferenceDate: 99999)

        XCTAssertEqual(99999.0, d1.timeIntervalSince1970)
        XCTAssertEqual(978407199.0, d2.timeIntervalSince1970)

        XCTAssertEqual(-978207201.0, d1.timeIntervalSinceReferenceDate)
        XCTAssertEqual(99999.0, d2.timeIntervalSinceReferenceDate)
    }

    func testTimeInterval() throws {
        let d = Date(timeIntervalSince1970: TimeInterval(Int64(99999)))
        XCTAssertEqual(99999.0, d.timeIntervalSince1970)
    }

    func testISOFormatting() throws {
        let d = Date(timeIntervalSince1970: 172348932)
        XCTAssertEqual(172348932.0, d.timeIntervalSince1970)
        //logger.info("date: \(d.ISO8601Format())")
        XCTAssertEqual("1975-06-18T18:42:12Z", d.ISO8601Format())

        let d2 = Date(timeIntervalSince1970: 999999999)
        XCTAssertEqual(999999999.0, d2.timeIntervalSince1970)
        //logger.info("date: \(d2.ISO8601Format())")
        XCTAssertEqual("2001-09-09T01:46:39Z", d2.ISO8601Format())

        let d3030 = Date(timeIntervalSince1970: 33450382800.0 - TimeInterval(5 * 60 * 60))
        XCTAssertEqual(33450382800.0 - (5 * 60 * 60), d3030.timeIntervalSince1970)
        //logger.info("date: \(d3030.ISO8601Format())")
        XCTAssertEqual("3030-01-01T00:00:00Z", d3030.ISO8601Format())

        XCTAssertEqual(-62135769600.0, Date.distantPast.timeIntervalSince1970)
        XCTAssertEqual("0001-01-01T00:00:00Z", Date.distantPast.ISO8601Format())

        XCTAssertEqual(64092211200.0, Date.distantFuture.timeIntervalSince1970)
        XCTAssertEqual("4001-01-01T00:00:00Z", Date.distantFuture.ISO8601Format())
    }

    func testDateFormatting() throws {
        func fmt(_ format: String, _ date: Date) -> String {
            let fmt = DateFormatter()
            fmt.timeZone = TimeZone(secondsFromGMT: 0)
            fmt.dateFormat = format
            return fmt.string(from: date)
        }

        let zeroHour = Date(timeIntervalSince1970: 0.0)

        XCTAssertEqual("1970", fmt("yyyy", zeroHour))
        XCTAssertEqual("1", fmt("M", zeroHour))
        XCTAssertEqual("01", fmt("MM", zeroHour))
        XCTAssertEqual("000", fmt("mmm", zeroHour))
        XCTAssertEqual("01", fmt("dd", zeroHour))
        XCTAssertEqual("70/00/01", fmt("yy/mm/dd", zeroHour))
        XCTAssertEqual("1970-01-01 00:00:00 GMT", fmt("yyyy-MM-dd HH:mm:ss z", zeroHour))
    }

    func testDateFormatStyle() throws {
        let zeroHour = Date(timeIntervalSinceReferenceDate: 12345.0)

        let _ = zeroHour.formatted()

        //XCTAssertEqual("12/31/2000, 22:25", zeroHour.formatted(date: .omitted, time: .omitted))
        //XCTAssertEqual("12/31/2000", zeroHour.formatted(date: .numeric, time: .omitted))

        // removed due to timezome issues on CI
//        XCTAssertEqual("Dec 31, 2000", zeroHour.formatted(date: .abbreviated, time: .omitted))
//        XCTAssertEqual("December 31, 2000", zeroHour.formatted(date: .long, time: .omitted))
//        XCTAssertEqual("Sunday, December 31, 2000", zeroHour.formatted(date: .complete, time: .omitted))

        //XCTAssertEqual("22:25", zeroHour.formatted(date: .omitted, time: .shortened))
        //XCTAssertEqual("12/31/2000, 22:25", zeroHour.formatted(date: .numeric, time: .shortened))
        //XCTAssertEqual("Dec 31, 2000 at 22:25", zeroHour.formatted(date: .abbreviated, time: .shortened))
        //XCTAssertEqual("December 31, 2000 at 22:25", zeroHour.formatted(date: .long, time: .shortened))
        //XCTAssertEqual("Sunday, December 31, 2000 at 22:25", zeroHour.formatted(date: .complete, time: .shortened))

        //XCTAssertEqual("22:25:45", zeroHour.formatted(date: .omitted, time: .standard))
        //XCTAssertEqual("12/31/2000, 22:25:45", zeroHour.formatted(date: .numeric, time: .standard))
        //XCTAssertEqual("Dec 31, 2000 at 22:25:45", zeroHour.formatted(date: .abbreviated, time: .standard))
        //XCTAssertEqual("December 31, 2000 at 22:25:45", zeroHour.formatted(date: .long, time: .standard))
        //XCTAssertEqual("Sunday, December 31, 2000 at 22:25:45", zeroHour.formatted(date: .complete, time: .standard))

        //XCTAssertEqual("22:25:45 EST", zeroHour.formatted(date: .omitted, time: .complete))
        //XCTAssertEqual("12/31/2000, 22:25:45 EST", zeroHour.formatted(date: .numeric, time: .complete))
        //XCTAssertEqual("Dec 31, 2000 at 22:25:45 EST", zeroHour.formatted(date: .abbreviated, time: .complete))
        //XCTAssertEqual("December 31, 2000 at 22:25:45 EST", zeroHour.formatted(date: .long, time: .complete))
        //XCTAssertEqual("Sunday, December 31, 2000 at 22:25:45 EST", zeroHour.formatted(date: .complete, time: .complete))

        //XCTAssertEqual("12/31/2000, 22:25", zeroHour.formatted())
    }

    func testAbsoluteTimeGetCurrent() {
        XCTAssertNotEqual(0, CFAbsoluteTimeGetCurrent())
    }

    func testDateComponentsLeapYears() {
        XCTAssertTrue(DateComponents(calendar: Calendar.current, year: 1928, month: 2, day: 29).isValidDate)
        #if SKIP // validation not yet correct
        throw XCTSkip("TODO")
        #endif

        XCTAssertFalse(DateComponents(calendar: Calendar.current, year: 1928 + 1, month: 2, day: 29).isValidDate)

        XCTAssertTrue(DateComponents(calendar: Calendar.current, year: 1956, month: 2, day: 29).isValidDate)
        XCTAssertFalse(DateComponents(calendar: Calendar.current, year: 1956 + 1, month: 2, day: 29).isValidDate)

        XCTAssertTrue(DateComponents(calendar: Calendar.current, year: 2000, month: 2, day: 29).isValidDate)
        XCTAssertFalse(DateComponents(calendar: Calendar.current, year: 2000 + 1, month: 2, day: 29).isValidDate)

        XCTAssertTrue(DateComponents(calendar: Calendar.current, year: 2020, month: 2, day: 29).isValidDate)
        XCTAssertFalse(DateComponents(calendar: Calendar.current, year: 2020 + 1, month: 2, day: 29).isValidDate)

        XCTAssertTrue(DateComponents(calendar: Calendar.current, year: 800, month: 2, day: 29).isValidDate)
        XCTAssertFalse(DateComponents(calendar: Calendar.current, year: 800 + 1, month: 2, day: 29).isValidDate)

        XCTAssertTrue(DateComponents(calendar: Calendar.current, year: 8, month: 2, day: 29).isValidDate)
        XCTAssertFalse(DateComponents(calendar: Calendar.current, year: 8 + 1, month: 2, day: 29).isValidDate)
    }

    func testUSCalendarSymbols() {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "en_US")
        XCTAssertEqual("AM", calendar.amSymbol)
        XCTAssertEqual("PM", calendar.pmSymbol)
        XCTAssertEqual(["BC", "AD"], calendar.eraSymbols)
        XCTAssertEqual(["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"], calendar.monthSymbols)
        XCTAssertEqual(["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"], calendar.shortMonthSymbols)
        XCTAssertEqual(["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"], calendar.weekdaySymbols)
        XCTAssertEqual(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], calendar.shortWeekdaySymbols)
    }

    func testFrenchCalendarSymbols() {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "fr_FR")
        XCTAssertEqual("AM", calendar.amSymbol)
        XCTAssertEqual("PM", calendar.pmSymbol)
        XCTAssertEqual(["av. J.-C.", "ap. J.-C."], calendar.eraSymbols)
        XCTAssertEqual(["janvier", "février", "mars", "avril", "mai", "juin", "juillet", "août", "septembre", "octobre", "novembre", "décembre"], calendar.monthSymbols)
        XCTAssertEqual(["janv.", "févr.", "mars", "avr.", "mai", "juin", "juil.", "août", "sept.", "oct.", "nov.", "déc."], calendar.shortMonthSymbols)
        XCTAssertEqual(["dimanche", "lundi", "mardi", "mercredi", "jeudi", "vendredi", "samedi"], calendar.weekdaySymbols)
        XCTAssertEqual(["dim.", "lun.", "mar.", "mer.", "jeu.", "ven.", "sam."], calendar.shortWeekdaySymbols)
    }

    func testChineseCalendarSymbols() {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "zh_Hans")
        XCTAssertEqual("上午", calendar.amSymbol)
        XCTAssertEqual("下午", calendar.pmSymbol)
        XCTAssertEqual(["公元前", "公元"], calendar.eraSymbols)
        XCTAssertEqual(["一月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "十一月", "十二月"], calendar.monthSymbols)
        XCTAssertEqual(["1月", "2月", "3月", "4月", "5月", "6月", "7月", "8月", "9月", "10月", "11月", "12月"], calendar.shortMonthSymbols)
        XCTAssertEqual(["星期日", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六"], calendar.weekdaySymbols)
        XCTAssertEqual(["周日", "周一", "周二", "周三", "周四", "周五", "周六"], calendar.shortWeekdaySymbols)
    }

    func testJapaneseCalendarSymbols() {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "ja_JP")
        XCTAssertEqual("午前", calendar.amSymbol)
        XCTAssertEqual("午後", calendar.pmSymbol)
        XCTAssertEqual(["紀元前", "西暦"], calendar.eraSymbols)
        XCTAssertEqual(["1月", "2月", "3月", "4月", "5月", "6月", "7月", "8月", "9月", "10月", "11月", "12月"], calendar.monthSymbols)
        XCTAssertEqual(["1月", "2月", "3月", "4月", "5月", "6月", "7月", "8月", "9月", "10月", "11月", "12月"], calendar.shortMonthSymbols)
        XCTAssertEqual(["日曜日", "月曜日", "火曜日", "水曜日", "木曜日", "金曜日", "土曜日"], calendar.weekdaySymbols)
        XCTAssertEqual(["日", "月", "火", "水", "木", "金", "土"], calendar.shortWeekdaySymbols)
    }

    func testArabicCalendarSymbols() {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "ar_AR")
        XCTAssertEqual("ص", calendar.amSymbol)
        XCTAssertEqual("م", calendar.pmSymbol)
        XCTAssertEqual(["ق.م", "م"], calendar.eraSymbols)
        XCTAssertEqual(["يناير", "فبراير", "مارس", "أبريل", "مايو", "يونيو", "يوليو", "أغسطس", "سبتمبر", "أكتوبر", "نوفمبر", "ديسمبر"], calendar.monthSymbols)
        XCTAssertEqual(["يناير", "فبراير", "مارس", "أبريل", "مايو", "يونيو", "يوليو", "أغسطس", "سبتمبر", "أكتوبر", "نوفمبر", "ديسمبر"], calendar.shortMonthSymbols)
        XCTAssertEqual(["الأحد", "الاثنين", "الثلاثاء", "الأربعاء", "الخميس", "الجمعة", "السبت"], calendar.weekdaySymbols)

        // java.lang.AssertionError: expected:<الأحد, الاثنين, الثلاثاء, الأربعاء, الخميس, الجمعة, السبت> but was:<أحد, اثنين, ثلاثاء, أربعاء, خميس, جمعة, سبت>

        #if !SKIP
        XCTAssertEqual(["أحد" ,"اثنين" ,"ثلاثاء" ,"أربعاء" ,"خميس" ,"جمعة" ,"سبت"], calendar.shortWeekdaySymbols)
        #else
        // shortWeekdaySymbols == weekdaySymbols for Java's Arabic localization
        XCTAssertEqual(["الأحد", "الاثنين", "الثلاثاء", "الأربعاء", "الخميس", "الجمعة", "السبت"], calendar.shortWeekdaySymbols)
        #endif
    }

    func testThaiCalendarSymbols() {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "th_TH")
        #if !SKIP
        // it seems Foundation is missing these Thai symbols
        XCTAssertEqual("AM", calendar.amSymbol)
        XCTAssertEqual("PM", calendar.pmSymbol)
        #else
        XCTAssertEqual("ก่อนเที่ยง", calendar.amSymbol)
        XCTAssertEqual("หลังเที่ยง", calendar.pmSymbol)
        #endif
        XCTAssertEqual(["ก่อน ค.ศ.", "ค.ศ."], calendar.eraSymbols)
        XCTAssertEqual(["มกราคม", "กุมภาพันธ์", "มีนาคม", "เมษายน", "พฤษภาคม", "มิถุนายน", "กรกฎาคม", "สิงหาคม", "กันยายน", "ตุลาคม", "พฤศจิกายน", "ธันวาคม"], calendar.monthSymbols)
        XCTAssertEqual(["ม.ค.", "ก.พ.", "มี.ค.", "เม.ย.", "พ.ค.", "มิ.ย.", "ก.ค.", "ส.ค.", "ก.ย.", "ต.ค.", "พ.ย.", "ธ.ค."], calendar.shortMonthSymbols)
        XCTAssertEqual(["วันอาทิตย์", "วันจันทร์", "วันอังคาร", "วันพุธ", "วันพฤหัสบดี", "วันศุกร์", "วันเสาร์"], calendar.weekdaySymbols)
        XCTAssertEqual(["อา.", "จ.", "อ.", "พ.", "พฤ.", "ศ.", "ส."], calendar.shortWeekdaySymbols)
    }
}

//
//  UILunarDatePicker.swift
//  lunar
//
//  Created by Le Van Long on 8/23/16.
//  Copyright © 2016 Le Van Long. All rights reserved.
//

import UIKit

class LunarDatePicker: UIView, UIPickerViewDataSource, UIPickerViewDelegate {

    private var pickerView: UIPickerView?
    private var m_baseFullMonthIndex = 0
    private var m_leapMonth = 0
    private var m_dayIndex = 0
    private var m_monthIndex = 0
    private var m_yearIndex = 0
    private var m_isNotify = false
    
    private let BASE_YEAR = 1900
    private var YEAR_COUNT = 201
    var delegate: LunarDatePickerDelegate?
    
    var timeZone: Double = 7.0
    var monthLabel = "Tháng"
    var showYearName = true
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    private func setupUI() {
        pickerView = UIPickerView(frame: self.bounds)
        self.addSubview(pickerView!)
        pickerView?.translatesAutoresizingMaskIntoConstraints = false
        let views = ["pickerView" : pickerView!]
        var constrains = NSLayoutConstraint.constraintsWithVisualFormat("V:|[pickerView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        constrains += NSLayoutConstraint.constraintsWithVisualFormat("H:|[pickerView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        NSLayoutConstraint.activateConstraints(constrains)
        pickerView?.dataSource = self
        pickerView?.delegate = self
        setGRDate(NSDate(timeIntervalSinceNow: 0))
    }
    
    func setGRDate(date: NSDate, isNotify: Bool = false ) {
        m_isNotify = isNotify
        let (lunarDate, dateCount) = LunarUtils.sharedInstance().getLunarCalDetail(date, timeZone: timeZone)
        m_baseFullMonthIndex = dateCount == 30 ? lunarDate.month - 1 : lunarDate.month
        setLunarDate(lunarDate)
    }
    
    private func setLunarDate(lunarDate: LunarCal) {
        m_leapMonth = lunarDate.leap
        let yearRowIndex = lunarDate.year - BASE_YEAR
        var monthRowIndex = lunarDate.month - 1
        if lunarDate.leap != 0 && ((lunarDate.month > lunarDate.leap) || (lunarDate.month == lunarDate.leap && lunarDate.isLeap == 1)) {
            monthRowIndex += 1
        }
        let dateRowIndex = lunarDate.day - 1
        
        setYearIndex(yearRowIndex)
        setMonthIndex(monthRowIndex)
        setDayIndex(dateRowIndex)
        
        pickerView?.selectRow(yearRowIndex, inComponent: 2, animated: true)
        pickerView?.selectRow(monthRowIndex, inComponent: 1, animated: true)
        pickerView?.selectRow(dateRowIndex, inComponent: 0, animated: true)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return 30
        }
        else if component == 1 {
            return m_leapMonth == 0 ? 12 : 13
        }
        else {
            return YEAR_COUNT
        }
    }
    
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40.0
    }
    
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        // [20] [30] [50]
        if component == 0 {
            return pickerView.bounds.width * 0.2
        }
        else if component == 1 {
            return pickerView.bounds.width * 0.30
        }
        else {
            return pickerView.bounds.width * 0.50
        }
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        var label = view as? UILabel
        if label == nil {
            label = UILabel()
            label?.adjustsFontSizeToFitWidth = false
            if component == 0 {
                label?.textAlignment = .Right
            }
            else if component == 2 {
                label?.textAlignment = .Left
            }
            else {
                label?.textAlignment = .Center
            }
            label?.font = UIFont.systemFontOfSize(20)
            label?.backgroundColor = UIColor.clearColor()
        }
        
        switch  component {
        case 0:
            label?.text = String(row + 1)
        case 1:
            if m_leapMonth == 0 {
                label?.text = String(format: "%@ %d", monthLabel, row + 1)
            }
            else {
                if row < m_leapMonth {
                    label?.text = String(format: "%@ %d", monthLabel, row + 1)
                }
                else if row == m_leapMonth {
                    label?.text = String(format: "%@ %d (N)", monthLabel, row)
                }
                else {
                    label?.text = String(format: "%@ %d", monthLabel, row)
                }
            }
        case 2:
            if showYearName {
                let year = BASE_YEAR + row
                let yearName = LunarUtils.sharedInstance().getLunarYearName(year)
                label?.text = String(format: "%@-%d\t", yearName, year)
            }
            else {
                label?.text = String(BASE_YEAR + row)
            }
        default:
            break
        }
        return label!
    }

    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            setDayIndex(row)
        case 1:
            setMonthIndex(row)
        case 2:
            setYearIndex(row)
        default:
            break
        }
        notifyDateChanged()
    }
    
    private func notifyDateChanged() {
//        if !m_isNotify {
//            m_isNotify = true
//            return
//        }
        let year = BASE_YEAR + m_yearIndex
        let origMonth = m_monthIndex + 1
        var month = origMonth
        if m_leapMonth != 0 {
            if m_monthIndex >= m_leapMonth {
                month = m_monthIndex
            }
        }
        let day = m_dayIndex + 1
        var leap = 0
        if m_leapMonth == month && month != origMonth {
            leap = 1
        }
        
        let lunarDate = LunarCal(day: day, month: month, year: year, leap: leap, isLeap: leap)
        let solarDate = LunarUtils.sharedInstance().convertLunar2Solar(lunarDate, timeZone: 7.0)
        let dateFormater = NSDateFormatter()
        dateFormater.dateFormat = "dd-MM-yyyy"
        let solarDateString = String(format: "%2d-%2d-%4d", solarDate.day, solarDate.month, solarDate.year)
        delegate?.onLunarDateChanged!(dateFormater.dateFromString(solarDateString)!)
        //m_isNotify = true
    }
    
    private func setYearIndex(index: Int) {
        m_yearIndex = index
        let year = BASE_YEAR + m_yearIndex
        let (_, leapMonth, baseMonth) = LunarUtils.sharedInstance().eastimateLeapYear(year)
        
        m_baseFullMonthIndex = baseMonth + 1
        m_leapMonth = leapMonth
        
        pickerView?.reloadComponent(1)
        
        if leapMonth == 0 && m_monthIndex > 11 {
            setMonthIndex(11)
        }
        else {
            setMonthIndex(m_monthIndex)
        }
    }
    
    private func setMonthIndex(index: Int) {
        m_monthIndex = index
        if abs(m_monthIndex - m_baseFullMonthIndex) % 2 != 0 && m_dayIndex > 28 {
            pickerView?.selectRow(28, inComponent: 0, animated: true)
            setDayIndex(28)
        }
    }
    
    private func setDayIndex(index: Int) {
        if abs(m_monthIndex - m_baseFullMonthIndex) % 2 != 0 && index > 28 {
            pickerView?.selectRow(28, inComponent: 0, animated: true)
            m_dayIndex = 28
        }
        else {
            m_dayIndex = index
        }
    }
}

@objc protocol LunarDatePickerDelegate {
    optional func onLunarDateChanged(date: NSDate)
}


class LunarUtils: NSObject {
    
    private static var m_instance = LunarUtils()
    
    static func sharedInstance() -> LunarUtils {
        return m_instance
    }
    
    private override init() {
        dateFormater = NSDateFormatter()
        dateFormater.dateFormat = "dd-MM-yyyy"
    }
    
    private let CAN_ARR = ["Canh", "Tân", "Nhâm", "Quý", "Giáp", "Ất", "Bính", "Đinh", "Mậu", "Kỷ"]
    private let CHI_ARR = ["Thân", "Dậu", "Tuất", "Hợi", "Tý", "Sửu", "Dần", "Mão", "Thìn", "Tỵ", "Ngọ", "Mùi"]
    private var dateFormater: NSDateFormatter!
    let PI = M_PI
    
    func jdFromDate( dd:Int, mm:Int, yy:Int) -> Int {
        let a:Int = (14 - mm) / 12
        let y:Int = yy+4800-a
        let m:Int = mm+12*a-3
        var jd:Int = dd + (153*m+2)/5 + 365*y + y/4 - y/100 + y/400 - 32045
        if (jd < 2299161) {
            jd = dd + (153*m+2)/5 + 365*y + y/4 - 32083
        }
        return jd
    }
    
    func jdToDate( jd:Int ) -> SolarCal {
        let a:Int
        let b:Int
        let c:Int
        if (jd > 2299160) {             a = jd + 32044
            b = (4*a+3)/146097
            c = a - (b*146097)/4
        } else {
            b = 0
            c = jd + 32082
        }
        let d:Int = (4*c+3)/1461
        let e:Int = c - (1461*d)/4
        let m:Int = (5*e+2)/153
        let day:Int = e - (153*m+2)/5 + 1
        let month:Int = m + 3 - 12*(m/10)
        let year:Int = b*100 + d - 4800 + m/10
        return SolarCal(day: day, month: month, year: year)
    }
    func SunLongitude(jdn:Double) -> Double {
        return SunLongitudeAA98(jdn)
    }
    
    func SunLongitudeAA98(jdn:Double) -> Double {
        let T:Double = (jdn - 2451545.0 ) / 36525 // Time in Julian centuries from 2000-01-01 12:00:00 GMT
        let T2:Double = T*T
        let dr:Double = PI/180 // degree to radian
        let M:Double = 357.52910 + 35999.05030*T - 0.0001559 * T2 - 0.00000048 * T * T2 // mean anomaly, degree
        let L0:Double = 280.46645 + 36000.76983*T + 0.0003032*T2 // mean longitude, degree
        var DL:Double = (1.914600 - 0.004817*T - 0.000014*T2) * sin(dr*M)
        
        let x1:Double = sin(dr*2*M)
        let x2:Double = sin(dr*3*M)
        
        DL = DL + (0.019993 - 0.000101*T) * x1 + 0.000290 * x2
        var L:Double = L0 + DL // true longitude, degree
        
        let x3:Double = Double(360*ConvertINT(L/360))
        L = L - x3 // Normalize to (0, 360)
        return L
    }
    
    func NewMoon(k:Int) -> Double {
        return NewMoonAA98(Double(k))
    }
    
    func NewMoonAA98(k:Double) -> Double {
        let T:Double = k/1236.85
        let T2:Double = T * T
        let T3:Double = T2 * T
        let dr:Double = PI/180
        var Jd1:Double = 2415020.75933 + 29.53058868*k + 0.0001178*T2 - 0.000000155*T3
        
        Jd1 = Jd1 + 0.00033*sin((166.56 + 132.87*T - 0.009173*T2)*dr)
        let M:Double = 359.2242 + 29.10535608*k - 0.0000333*T2 - 0.00000347*T3
        let Mpr:Double = 306.0253 + 385.81691806*k + 0.0107306*T2 + 0.00001236*T3
        let F:Double = 21.2964 + 390.67050646*k - 0.0016528*T2 - 0.00000239*T3
        var C1:Double = (0.1734 - 0.000393*T)*sin(M*dr) + 0.0021*sin(2*dr*M)
        C1 = C1 - 0.4068*sin(Mpr*dr) + 0.0161*sin(dr*2*Mpr)
        C1 = C1 - 0.0004*sin(dr*3*Mpr)
        C1 = C1 + 0.0104*sin(dr*2*F) - 0.0051*sin(dr*(M+Mpr))
        C1 = C1 - 0.0074*sin(dr*(M-Mpr)) + 0.0004*sin(dr*(2*F+M))
        C1 = C1 - 0.0004*sin(dr*(2*F-M)) - 0.0006*sin(dr*(2*F+Mpr))
        C1 = C1 + 0.0010*sin(dr*(2*F-Mpr)) + 0.0005*sin(dr*(2*Mpr+M))
        var deltat:Double
        if (T < -11) {
            deltat = 0.001 + 0.000839*T + 0.0002261*T2 - 0.00000845*T3 - 0.000000081*T*T3
        } else {
            deltat = -0.000278 + 0.000265*T + 0.000262*T2
        }
        let JdNew:Double = Jd1 + C1 - deltat
        return JdNew
    }
    
    func ConvertINT(d:Double)->Int {
        return Int(floor(d))
    }
    
    func getSunLongitude(dayNumber:Int, timeZone:Double) -> Double {
        return SunLongitude( Double(dayNumber) - 0.5 - timeZone/24)
    }
    
    func getNewMoonDay(k:Int, timeZone:Double) -> Int{
        let jd:Double = NewMoon(k)
        return ConvertINT(jd + 0.5 + timeZone / 24)
    }
    
    func getLunarMonth11( yy:Int, timeZone:Double) -> Int {
        let off:Double = Double(jdFromDate(31, mm: 12, yy: yy)) - 2415021.076998695
        let k:Int = ConvertINT(off / 29.530588853)
        var nm:Int = getNewMoonDay(k, timeZone: timeZone)
        
        let sunLong:Int = ConvertINT(getSunLongitude(nm, timeZone: timeZone) / 30)
        if (sunLong >= 9) {
            nm = getNewMoonDay(k-1, timeZone: timeZone)
        }
        return nm
    }
    
    func getLeapMonthOffset(a11:Int, timeZone:Double) -> Int {
        let k:Int = ConvertINT(0.5 + ( Double(a11) - 2415021.076998695) / 29.530588853)
        var last:Int
        var i:Int = 1
        var arc:Int = ConvertINT(getSunLongitude(getNewMoonDay(k+i, timeZone: timeZone), timeZone: timeZone)/30)
        repeat{
            last = arc
            i += 1
            arc = ConvertINT(getSunLongitude(getNewMoonDay(k+i, timeZone: timeZone), timeZone: timeZone)/30)
        } while (arc != last && i < 14)
        return i-1
    }
    
    func convertSolar2Lunar(solarDate: SolarCal, timeZone:Double) -> LunarCal {
        let dd = solarDate.day
        let mm = solarDate.month
        let yy = solarDate.year
        var lunarDay:Int
        var lunarMonth:Int
        var lunarLeap:Int
        var lunarYear:Int
        
        let dayNumber:Int = jdFromDate(dd, mm: mm, yy: yy)
        let k:Int = ConvertINT(( Double(dayNumber) - 2415021.076998695) / 29.530588853)
        var monthStart:Int = getNewMoonDay(k + 1, timeZone: timeZone)
        if (monthStart > dayNumber) {
            monthStart = getNewMoonDay(k, timeZone: timeZone)
        }
        var a11:Int = getLunarMonth11(yy, timeZone: timeZone)
        var b11:Int = a11
        if (a11 >= monthStart) {
            lunarYear = yy
            a11 = getLunarMonth11(yy-1, timeZone: timeZone)
        } else {
            lunarYear = yy+1
            b11 = getLunarMonth11(yy+1, timeZone: timeZone)
        }
        
        lunarDay = dayNumber-monthStart+1
        let diff:Int = ConvertINT(Double((monthStart - a11)/29))
        lunarLeap = 0
        lunarMonth = diff+11
        var isLeap = 0
        if (b11 - a11 > 365) {
            let leapMonthDiff:Int = getLeapMonthOffset(a11, timeZone: timeZone)
            lunarLeap = leapMonthDiff + 11 - 13
            if (diff >= leapMonthDiff) {
                lunarMonth = diff + 10
                if (diff == leapMonthDiff) {
                    isLeap = 1
                }
            }
        }
        if (lunarMonth > 12) {
            lunarMonth = lunarMonth - 12
        }
        if (lunarMonth >= 11 && diff < 4) {
            lunarYear -= 1
        }
        lunarLeap = lunarLeap < 0 ? lunarLeap + 12 : lunarLeap
        return LunarCal(day: lunarDay, month: lunarMonth, year: lunarYear, leap: lunarLeap, isLeap: isLeap)
    }
    
    func convertLunar2Solar( lunarDate: LunarCal, timeZone:Double) -> SolarCal {
        let lunarDay = lunarDate.day
        let lunarMonth = lunarDate.month
        let lunarYear = lunarDate.year
        let lunarLeap = lunarDate.leap
        var a11:Int
        var b11:Int
        if (lunarMonth < 11) {
            a11 = getLunarMonth11(lunarYear-1, timeZone: timeZone)
            b11 = getLunarMonth11(lunarYear, timeZone: timeZone)
        } else {
            a11 = getLunarMonth11(lunarYear, timeZone: timeZone)
            b11 = getLunarMonth11(lunarYear+1, timeZone: timeZone)
        }
        let k:Int = ConvertINT(0.5 + (Double(a11) - 2415021.076998695) / 29.530588853)
        var off:Int = lunarMonth - 11
        if (off < 0) {
            off += 12
        }
        if (b11 - a11 > 365) {
            let leapOff:Int = getLeapMonthOffset(a11, timeZone: timeZone)
            var leapMonth:Int = leapOff - 2
            if (leapMonth < 0) {
                leapMonth += 12
            }
            if (lunarLeap != 0 && lunarMonth != leapMonth) {
                print("Invalid input!")
                return SolarCal(day: 1, month: 1, year: 1800)
            } else if (lunarLeap != 0 || off >= leapOff) {
                off += 1
            }
        }
        let monthStart:Int = getNewMoonDay(k+off, timeZone: timeZone)
        
        return jdToDate(monthStart+lunarDay-1)
    }
    
    func getLunarCalDetail(date: NSDate, timeZone: Double) -> (LunarCal, Int) {
        let components = NSCalendar.currentCalendar().components([.Year, .Month, .Day], fromDate: date)
        let baseSolarDate = SolarCal(day: components.day, month: components.month, year: components.year)
        let datePlus30 = NSDate(timeInterval: 30 * 86400, sinceDate: date)
        let componentsPlus30 = NSCalendar.currentCalendar().components([.Year, .Month, .Day], fromDate: datePlus30)
        let solarDatePlus30 = SolarCal(day: componentsPlus30.day, month: componentsPlus30.month, year: componentsPlus30.year)
        let baseLunarDate = convertSolar2Lunar(baseSolarDate, timeZone: timeZone)
        let lunarDatePlus30 = convertSolar2Lunar(solarDatePlus30, timeZone: timeZone)
        
        if baseSolarDate.day == lunarDatePlus30.day {
            return (baseLunarDate, 30)
        }
        else {
            return (baseLunarDate, 29)
        }
    }
    
    func getLunarYearName(year: Int) -> String {
        let canIndex = year % 10
        let chiIndex = year % 12
        return String(format: "%@ %@", CAN_ARR[canIndex], CHI_ARR[chiIndex])
    }
    
    func eastimateLeapYear(year: Int) -> (Bool, Int, Int) {
        let dateString = String(format: "21-06-%d", year)
        let date = dateFormater.dateFromString(dateString)!
        let (lunarDate, dateCount) = getLunarCalDetail(date, timeZone: 7.0)
        let baseFullMonth = dateCount == 30 ? lunarDate.month : lunarDate.month + 1
        return (lunarDate.leap != 0, lunarDate.leap, baseFullMonth)
    }
    
    func getLeapMonthOfYear(year: Int) -> Int {
        let summerSolsticeDate = SolarCal(day: 21, month: 6, year: year)
        let lunarDate = convertSolar2Lunar(summerSolsticeDate, timeZone: 7)
        return lunarDate.leap
    }
}

struct SolarCal {
    var day: Int = 0
    var month: Int = 0
    var year: Int = 0
}

struct LunarCal {
    var day: Int = 0
    var month: Int = 0
    var year: Int = 0
    var leap: Int = 0
    var isLeap: Int = 0
}
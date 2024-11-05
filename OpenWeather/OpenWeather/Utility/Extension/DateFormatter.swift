//
//  DateFormatter.swift
//  OpenWeather
//
//  Created by Hayun Park on 11/5/24.
//

import Foundation

// MARK: - Date Formatter
extension ISO8601DateFormatter {
  static let weatherDateFormatter: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withYear, .withMonth, .withDay, .withTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
    return formatter
  }()
}

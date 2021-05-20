

import Foundation

final class Acronym: Codable {
  var id: Int?
  var short: String
  var long: String
  var userID: UUID

  init(short: String, long: String, userID: UUID) {
    self.short = short
    self.long = long
    self.userID = userID
  }
}

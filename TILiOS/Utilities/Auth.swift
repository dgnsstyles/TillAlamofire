import Foundation
import UIKit
import Alamofire

class Auth {
  static let defaultsKey = "TIL-API-KEY"
  let defaults = UserDefaults.standard

  var token: String? {
    get {
      return defaults.string(forKey: Auth.defaultsKey)
    }
    set {
      defaults.set(newValue, forKey: Auth.defaultsKey)
    }
  }
  
  func logout() {
    self.token = nil
    DispatchQueue.main.async {
      guard let applicationDelegate = UIApplication.shared.delegate as? AppDelegate else {
        return
      }
      let rootController = UIStoryboard(name: "Login", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginNavigation")
      applicationDelegate.window?.rootViewController = rootController
    }
  }

  func login(username: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
    let path = "http://localhost:8080/api/users/login"
    let credentialHeader = HTTPHeader.authorization(username: username, password: password)
    AF.request(path, method: .post, headers: [credentialHeader]).validate().responseDecodable(of: Token.self) { response in
      switch response.result {
      case .success(let token):
        self.token = token.token
        completion(.success(()))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
}



import UIKit
import Alamofire

class CreateAcronymTableViewController: UITableViewController {
  
  @IBOutlet weak var acronymShortTextField: UITextField!
  @IBOutlet weak var acronymLongTextField: UITextField!
  var acronym: Acronym?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    acronymShortTextField.becomeFirstResponder()
  }
  
  @IBAction func cancel(_ sender: UIBarButtonItem) {
    navigationController?.popViewController(animated: true)
  }
  
  @IBAction func save(_ sender: UIBarButtonItem) {
    guard let shortText = acronymShortTextField.text, !shortText.isEmpty else {
      ErrorPresenter.showError(message: "You must specify an acronym!", on: self)
      return
    }
    guard let longText = acronymLongTextField.text, !longText.isEmpty else {
      ErrorPresenter.showError(message: "You must specify a meaning!", on: self)
      return
    }
    let acronym = Acronym(short: shortText, long: longText, userID: UUID())
    saveAcronym(acronym) { [weak self] result in
      switch result {
      case .failure:
        ErrorPresenter.showError(message: "There was a problem saving the acronym", on: self)
      case .success:
        DispatchQueue.main.async { [weak self] in
          self?.navigationController?.popViewController(animated: true)
        }
      }
    }
  }
  
  func saveAcronym(_ acronym: Acronym, completion: @escaping (Result<Void, Error>) -> Void) {
    guard let token = Auth().token else {
      fatalError()
    }
    let authHeader = HTTPHeader.authorization(bearerToken: token)
    AF.request("http://localhost:8080/api/acronyms", method: .post, parameters: acronym, encoder: JSONParameterEncoder.default, headers: [authHeader])
      .validate()
      .response { response in
      switch response.result {
      case .success:
        completion(.success(()))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
}

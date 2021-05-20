

import UIKit
import Alamofire

class CreateCategoryTableViewController: UITableViewController {

  @IBOutlet weak var nameTextField: UITextField!

  override func viewDidLoad() {
    super.viewDidLoad()
    nameTextField.becomeFirstResponder()
  }

  @IBAction func cancel(_ sender: Any) {
    navigationController?.popViewController(animated: true)
  }

  @IBAction func save(_ sender: Any) {
    guard let name = nameTextField.text,
      !name.isEmpty else {
        ErrorPresenter.showError(message: "You must specify a name", on: self)
        return
    }

    let category = TILCategory(name: name)
    saveCategory(category) { [weak self] result in
      switch result {
      case .failure:
        ErrorPresenter.showError(message: "There was a problem saving the category", on: self)
      case .success:
        DispatchQueue.main.async { [weak self] in
          self?.navigationController?.popViewController(animated: true)
        }
      }
    }
  }
  
  func saveCategory(_ category: TILCategory, completion: @escaping (Result<Void, Error>) -> Void) {
    AF.request("http://localhost:8080/api/categories", method: .post, parameters: category, encoder: JSONParameterEncoder.default).validate().response { response in
      switch response.result {
      case .success:
        completion(.success(()))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
}

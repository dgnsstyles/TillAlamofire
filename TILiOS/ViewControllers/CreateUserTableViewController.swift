
import UIKit
import Alamofire

class CreateUserTableViewController: UITableViewController {

  @IBOutlet weak var nameTextField: UITextField!
  @IBOutlet weak var usernameTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!

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

    guard let username = usernameTextField.text,
      !username.isEmpty else {
        ErrorPresenter.showError(message: "You must specify a username", on: self)
        return
    }

    guard let password = passwordTextField.text, !password.isEmpty else {
      ErrorPresenter.showError(message: "You must specify a password", on: self)
      return
    }

    let user = CreateUser(name: name, username: username, password: password)
    saveUser(user) { [weak self] result in
      switch result {
      case .failure:
        ErrorPresenter.showError(message: "There was a problem saving the user", on: self)
      case .success:
        DispatchQueue.main.async { [weak self] in
          self?.navigationController?.popViewController(animated: true)
        }
      }
    }
  }
  
  func saveUser(_ user: CreateUser, completion: @escaping (Result<Void, Error>) -> Void) {
    AF.request("http://localhost:8080/api/users", method: .post, parameters: user, encoder: JSONParameterEncoder.default).validate().response { response in
      switch response.result {
      case .success:
        completion(.success(()))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
}

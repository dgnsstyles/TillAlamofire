

import UIKit
import Alamofire

class UsersTableViewController: UITableViewController {

  // MARK: - Properties
  var users: [User] = []

  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.tableFooterView = UIView()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    refresh(nil)
  }

  func refresh() {
    if refreshControl != nil {
      refreshControl?.beginRefreshing()
    }
    refresh(refreshControl)
  }

  @IBAction func refresh(_ sender: UIRefreshControl?) {
    getAllUsers { [weak self] result in
      DispatchQueue.main.async {
        sender?.endRefreshing()
      }
      switch result {
      case .failure:
        ErrorPresenter.showError(message: "There was an error getting the users", on: self)
      case .success(let users):
        DispatchQueue.main.async { [weak self] in
          guard let self = self else { return }
          self.users = users
          self.tableView.reloadData()
        }
      }
    }
  }

  @IBAction func logoutTapped(_ sender: UIBarButtonItem) {
    Auth().logout()
  }
  
  func getAllUsers(completion: @escaping (Result<[User], Error>) -> Void) {
    AF.request("http://localhost:8080/api/users").validate().responseDecodable(of: [User].self) { response in
      switch response.result {
      case .success(let users):
        completion(.success(users))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
}

// MARK: - UITableViewDataSource
extension UsersTableViewController {

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return users.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let user = users[indexPath.row]
    let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath)
    cell.textLabel?.text = user.name
    cell.detailTextLabel?.text = user.username
    return cell
  }
}

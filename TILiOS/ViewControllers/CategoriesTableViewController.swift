import UIKit
import Alamofire

class CategoriesTableViewController: UITableViewController {

  // MARK: - Properties

  var categories: [TILCategory] = []

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
    getAllCategories { [weak self] result in
      DispatchQueue.main.async {
        sender?.endRefreshing()
      }
      switch result {
      case .failure:
        ErrorPresenter.showError(message: "There was an error getting the categories", on: self)
      case .success(let categories):
        DispatchQueue.main.async { [weak self] in
          guard let self = self else { return }
          self.categories = categories
          self.tableView.reloadData()
        }
      }
    }
  }
  
  func getAllCategories(completion: @escaping (Result<[TILCategory], Error>) -> Void) {
    AF.request("http://localhost:8080/api/categories").validate().responseDecodable(of: [TILCategory].self) { response in
      switch response.result {
      case .success(let categories):
        completion(.success(categories))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
}

// MARK: - UITableViewDataSource
extension CategoriesTableViewController {

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return categories.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
    cell.textLabel?.text = categories[indexPath.row].name
    return cell
  }
}

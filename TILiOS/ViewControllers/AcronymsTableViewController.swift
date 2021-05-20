
import UIKit
import Alamofire

class AcronymsTableViewController: UITableViewController {

  // MARK: - Properties

  var acronyms: [Acronym] = []

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
    getAllAcronyms { [weak self] acronymResult in
      DispatchQueue.main.async {
        sender?.endRefreshing()
      }

      switch acronymResult {
      case .failure:
        ErrorPresenter.showError(message: "There was an error getting the acronyms", on: self)
      case .success(let acronyms):
        DispatchQueue.main.async { [weak self] in
          guard let self = self else { return }
          self.acronyms = acronyms
          self.tableView.reloadData()
        }
      }
    }
  }
  
  
  func getAllAcronyms(completion: @escaping (Result<[Acronym], Error>) -> Void) {
    AF.request("http://localhost:8080/api/acronyms").validate().responseDecodable(of: [Acronym].self) { response in
      switch response.result {
      case .success(let acronyms):
        completion(.success(acronyms))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
}

// MARK: - UITableViewDataSource
extension AcronymsTableViewController {

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return acronyms.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let acronym = acronyms[indexPath.row]
    let cell = tableView.dequeueReusableCell(withIdentifier: "AcronymCell", for: indexPath)
    cell.textLabel?.text = acronym.short
    cell.detailTextLabel?.text = acronym.long
    return cell
  }
}

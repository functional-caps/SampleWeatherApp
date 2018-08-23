import UIKit
import SafariServices

public class ReposViewController: UITableViewController {
    var repos: [GitHub.Repo] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Point-Free Repos"
        self.view.backgroundColor = .white

        Current.gitHub.fetchRepos { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case let .success(repos):
                    self?.repos = repos
                        .filter { !$0.archived }
                        .sorted(by: {
                            guard let lhs = $0.pushedAt, let rhs = $1.pushedAt else { return false }
                            return lhs > rhs
                        })
                case let .failure(error):
                    let alert = UIAlertController(
                        title: "Something went wrong",
                        message: error.localizedDescription,
                        preferredStyle: .alert
                    )
                    self?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.repos.count
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let repo = self.repos[indexPath.row]

        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = repo.name
        cell.detailTextLabel?.text = repo.description

        let dateComponentsFormatter = Current.produceFormatter()
        dateComponentsFormatter.allowedUnits = [.day, .hour, .minute, .second]
        dateComponentsFormatter.maximumUnitCount = 1
        dateComponentsFormatter.unitsStyle = .abbreviated

        let label = UILabel()
        if let pushedAt = repo.pushedAt {
            label.text = dateComponentsFormatter.string(from: pushedAt, to: Current.date())
        }
        label.sizeToFit()

        cell.accessoryView = label

        return cell
    }

    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let repo = self.repos[indexPath.row]
        Current.analytics.track(.tappedRepo(repo))
        let vc = SFSafariViewController(url: repo.htmlUrl)
        self.present(vc, animated: true, completion: nil)
    }
}

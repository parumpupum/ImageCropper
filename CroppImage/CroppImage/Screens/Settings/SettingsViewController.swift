import UIKit

class SettingsViewController: UIViewController {
    
    // - UI
    @IBOutlet weak var tableView: SettingsTableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }

    private func showAddingAlert() {
        let alert = UIAlertController(title: "Add new cell", message: "For example enter your first ans last names", preferredStyle: .alert)
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelButton)
        
        alert.addTextField { textField in
            textField.placeholder = "Enter text"
        }
        
        let addButton = UIAlertAction(title: "Add", style: .default) { _ in
            let text = alert.textFields?.first?.text ?? ""
            self.tableView.append(title: text)
        }
        alert.addAction(addButton)
        
        present(alert, animated: true)
    }
}

//MARK: -
//MARK: - Configure

private extension SettingsViewController {
    func configure() {
        configureTableView()
    }
    
    func configureTableView() {
        tableView.didSelect = {
            self.showAddingAlert()
        }
    }
}

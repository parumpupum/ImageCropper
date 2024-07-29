import UIKit

class SettingsTableView: UITableView {
    
    // - Data
    private var titles: [String] = ["About App"]
    
    // - Completion
    var didSelect: (() -> Void)?

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    func append(title: String) {
        titles.append(title)
        reloadData()
    }
}

//MARK: -
//MARK: - DataSource, Delegate

extension SettingsTableView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dequeueReusableCell(withIdentifier: SettingsTableViewCell.cellID, for: indexPath) as! SettingsTableViewCell
        cell.setUp(title: titles[indexPath.item])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelect?()
    }
}

//MARK: -
//MARK: - Configure

private extension SettingsTableView {
    func configure() {
        registerNib()
        dataSource = self
        delegate = self
        reloadData()
    }
    
    func registerNib() {
        let nib = UINib(nibName: SettingsTableViewCell.cellID, bundle: nil)
        register(nib, forCellReuseIdentifier: SettingsTableViewCell.cellID)
    }
}

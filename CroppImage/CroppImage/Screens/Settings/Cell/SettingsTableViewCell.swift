import UIKit

class SettingsTableViewCell: UITableViewCell {
    
    // - ID
    static let cellID = "SettingsTableViewCell"
    
    // - UI
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.text = ""
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setUp(title: String) {
        titleLabel.text = title
    }
    
}

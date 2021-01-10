//
//  ScribeTableViewCell.swift
//  nba2
//
//  Created by 刘少冬 on 2021/1/9.
//

import UIKit

class ScribeTableViewCell: UITableViewCell {

    
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var teamName: UILabel!
    @IBOutlet weak var swich: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set {
            var frame = newValue
            frame.origin.x += 5
            frame.origin.y += 3
            frame.size.width -= 2 * 5
            frame.size.height -= 2*3
            super.frame = frame
        }
    }
    
    @IBAction func onSwich(_ sender: Any) {
//        let tableView = sender.superview?.superview as! UITableView
//        let indexPath = tableView?.indexPath(for: self)
//        print(self.teams[indexPath])
    }

    override func layoutSubviews() {
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        // 设置阴影
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOpacity = 0.8
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
        super.layoutSubviews()
    }
    
}

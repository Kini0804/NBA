//
//  TeamTableViewCell.swift
//  nba2
//
//  Created by 刘少冬 on 2021/1/7.
//

import UIKit

class TeamTableViewCell: UITableViewCell {

    @IBOutlet weak var imgA: UIImageView!
    @IBOutlet weak var imgB: UIImageView!
    @IBOutlet weak var nameA: UILabel!
    @IBOutlet weak var nameB: UILabel!
    @IBOutlet weak var ymd: UILabel!
    @IBOutlet weak var hm: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var scoreA: UILabel!
    @IBOutlet weak var scoreB: UILabel!
    @IBOutlet weak var vsButton: UIButton!
    var linkUrl: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }
    @IBAction func onClick(_ sender: Any) {
//        if(linkUrl != nil){
//            let url:URL?=URL.init(string: linkUrl!)
//            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
//        }
        let url:URL?=URL.init(string: "http://m.nowqiu.com/live/lanqiu/nba/")
        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
    }
    
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//        print("select")
//        print(animated)
//    }
//    @IBAction func onClick(_ sender: Any) {
//        print(nameA.text)
//        print(nameB.text)
//    }
    
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
    
    override var layer: CALayer{
        get {
            return super.layer
        }
        set {
            super.layer.cornerRadius = 10
            super.layer.masksToBounds = true
            // 设置阴影
            super.layer.shadowColor = UIColor.gray.cgColor
            super.layer.shadowOpacity = 0.8
            super.layer.shadowOffset = CGSize(width: 0, height: 4)
            
        }
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

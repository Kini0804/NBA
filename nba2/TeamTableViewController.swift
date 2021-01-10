//
//  TeamTableViewController.swift
//  nba2
//
//  Created by 刘少冬 on 2021/1/7.
//

import UIKit
import Alamofire
import WidgetKit

class TeamTableViewController: UITableViewController {

    var  sches = [Sche]()
    var scheDict =  [Int : Sche]()
    var lock = NSLock()
    var urls: [String] = []
//    var urls = ["https://china.nba.com/static/data/team/schedule_lakers.json", "https://china.nba.com/static/data/team/schedule_nets.json", "https://china.nba.com/static/data/team/schedule_warriors.json"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.backBarButtonItem?.title = "返回"
        
        tableView.separatorInset = .zero
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemGray6
        let rc = UIRefreshControl()
        rc.attributedTitle = NSAttributedString(string: "下拉刷新")
        rc.addTarget(self, action: #selector(self.refreshTableView),for: UIControl.Event.valueChanged)
        self.refreshControl = rc
        
       
        
//        loadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("appear")
        urls.removeAll()

        let userDe = UserDefaults(suiteName: "group.liu.nba")
        urls = userDe?.stringArray(forKey: "URLS") ?? []
        print(urls)
        WidgetCenter.shared.reloadAllTimelines()
        loadData()
    }
    
    
    
    @objc func refreshTableView() {
        if self.refreshControl!.isRefreshing {
            self.refreshControl!.attributedTitle = NSAttributedString(string: "加载中...")
            var index = 0;
            self.scheDict.removeAll()
            if urls.count == 0 {
                self.refreshControl!.endRefreshing()
                self.tableView.reloadData()
                self.refreshControl!.attributedTitle = NSAttributedString(string: "下拉刷新")
            }
            for url in urls {
                AF.request(url).responseJSON { response in
                    switch response.result {
                    case .success(let JSON):
//                        print("Success with JSON")
                        self.scheDict =  self.scheDict.merging(self.dealDate(dict: JSON as! Dictionary<String,AnyObject>, index: index)) { (first, _) -> Sche in return first }
                        
                        self.lock.lock()
                        index += 1
                        if index==self.urls.count {
                            let ds = self.scheDict.sorted(by: {$0.0 < $1.0})
                            var tempSches = [Sche]()
                            for d in ds {
                                if !self.judgeEquale(sches: tempSches, obj: d.value) {
                                    tempSches.append(d.value)
                                    if tempSches.count >= 100 {
                                        break
                                    }
                                }
                            }
                            self.sches = tempSches
                            self.refreshControl!.endRefreshing()
                            self.tableView.reloadData()
                            self.refreshControl!.attributedTitle = NSAttributedString(string: "下拉刷新")
                        }
                        self.lock.unlock()
                    case .failure(let error):
                        print("Request failed with error: \(error)")
                    }
                }
            }
        }
    }
    
    func judgeEquale(sches: [Sche], obj: Sche) -> Bool {
        for sche in sches {
            if sche == obj {
                return true
            }
        }
        return false;
    }
    
    func dealDate(dict: Dictionary<String,AnyObject>, index: Int) -> [Int : Sche]{
        var scheDict =  [Int : Sche]()
        let current = Date().milliStamp - 86400000/2
        var month = Date().getMonth()
        let payload = dict["payload"] as! Dictionary<String,AnyObject>
         let monthGroups = payload["monthGroups"] as! NSArray
         for item  in monthGroups {
             let group = item as! Dictionary<String,AnyObject>
             if month ==  group["number"] as! Int{
                let games = group["games"] as! NSArray
                for item in games {
                    let game = item as! Dictionary<String,AnyObject>
                    let profile = game["profile"] as! Dictionary<String,AnyObject>
                    let utcMillis = profile["utcMillis"] as! String
                    let utc = Int(utcMillis)!
                    if current < utc {
                        scheDict[utc + index] = getSche(game: game, utc: utc/1000)
                    }
                }
                month = (month+1)%12
             }
         }
        return scheDict
    }
    
    func getSche(game: Dictionary<String,AnyObject>, utc: Int) -> Sche {
        let homeTeam = game["homeTeam"] as! Dictionary<String,AnyObject>
        let homePro = homeTeam["profile"] as! Dictionary<String,AnyObject>
        let codeA = homePro["code"] as! String
        let nameA = homePro["displayAbbr"] as! String
        
        let awayTeam = game["awayTeam"] as! Dictionary<String,AnyObject>
        let awayPro = awayTeam["profile"] as! Dictionary<String,AnyObject>
        let codeB = awayPro["code"] as! String
        let nameB = awayPro["displayAbbr"] as! String
        
        let boxscore = game["boxscore"] as! Dictionary<String,AnyObject>
        let scoreA = boxscore["homeScore"] as! Int
        let scoreB = boxscore["awayScore"] as! Int
        let status = boxscore["status"] as! String
        
        let urls = game["urls"] as! NSArray
        var urlString: String = ""
        for item in urls {
            let url = item as! Dictionary<String,AnyObject>
            let value = url["value"] as! String
            if(value != ""){
                urlString = value
                break
            }
        }
        
        let ymd = Date.timeStampToString(String(utc), "yyyy-MM-dd")
        let hm = Date.timeStampToString(String(utc), "HH:mm")
        
        return Sche(nameA: nameA, nameB: nameB, imageA: codeA, imageB: codeB, scoreA: String(scoreA), scoreB: String(scoreB), status: status, ymd: ymd, hm: hm, url: urlString)
    }

    
//    func loadData2() {
//        self.sches.removeAll()
//        self.sches = [Sche(nameA: "nets", nameB: "nets", imageA: "logo", imageB: "logo", ymd: "2020-10-2", hm: "08:00")]
//    }
    
    private func loadData() {
        var index = 0;
        self.scheDict.removeAll()
        self.sches.removeAll()
        if urls.count == 0 {
            self.tableView.reloadData()
        }
        for url in urls {
            AF.request(url).responseJSON { response in
                switch response.result {
                case .success(let JSON):
//                    print("Success with JSON")
                    self.scheDict =  self.scheDict.merging(self.dealDate(dict: JSON as! Dictionary<String,AnyObject>, index: index)) { (first, _) -> Sche in return first }
//                    print(self.scheDict)
                    
                    self.lock.lock()
                    index += 1
                    if index==self.urls.count {
                        let ds = self.scheDict.sorted(by: {$0.0 < $1.0})
                        self.sches.removeAll()
                        for d in ds {
                            if !self.judgeEquale(sches: self.sches, obj: d.value) {
                                self.sches.append(d.value)
                                if self.sches.count >= 100 {
                                    break
                                }
                            }
                        }
                        self.tableView.reloadData()
                    }
                    self.lock.unlock()
                case .failure(let error):
                    print("Request failed with error: \(error)")
                }
            }
        }

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return sches.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "TeamTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? TeamTableViewCell  else {
                fatalError("The dequeued cell is not an instance of TeamTableViewCell.")
            }
        let sche = sches[indexPath.row]
        cell.nameA.text = sche.nameA
        cell.nameB.text = sche.nameB
        cell.imgA.image = UIImage(named: sche.imageA)
        cell.imgB.image = UIImage(named: sche.imageB)
        cell.ymd.text = sche.ymd
        cell.hm.text = sche.hm
        if sche.status=="1" {
            cell.status.text = "未开始"
            cell.scoreA.text = ""
            cell.scoreB.text = ""
//            cell.vsButton.isEnabled = false
        }
        else {
            cell.scoreA.text = sche.scoreA
            cell.scoreB.text = sche.scoreB
            if sche.status=="2" {
//                cell.vsButton.setTitle("进行中", for: UIControl.State.normal)
                cell.status.text = "进行中"
                cell.vsButton.isEnabled = true
            }
            else if sche.status=="3" {
//                cell.vsButton.setTitle("观看回放", for: UIControl.State.normal)
                cell.status.text = "已结束"
//                cell.vsButton.isEnabled = false
            }
        }
        cell.linkUrl = sche.url
        return cell
    }
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}
extension Date {
    func getMonth() ->Int {

        let calendar = NSCalendar.current

        //这里注意 swift要用[,]这样方式写

        let com = calendar.dateComponents([.year,.month,.day], from:self)

        return com.month!

    }
    
    func currentDateIntoString(format: String)->String {

        let dateFormatter = DateFormatter()

//        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.dateFormat = format

        let timeString = dateFormatter.string(from: self)

        return timeString

    }
    
    func compare(other: Stride)->String {

        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "yyyy-MM-ddHH:mm:ss"

        let timeString = dateFormatter.string(from: self)

        return timeString

    }
    
    static func stringToTimeStamp(_ stringTime:String)->String {

        let dfmatter = DateFormatter()

        dfmatter.dateFormat = "yyyy-MM-dd HH:mm"

        dfmatter.locale = Locale.current

        let date = dfmatter.date(from: stringTime)

        let dateStamp:TimeInterval = date!.timeIntervalSince1970

        let dateSt:Int = Int(dateStamp)

        return String(dateStamp)

    }
    
    static func timeStampToString(_ timeStamp:String, _ format: String)->String {

        let string = NSString(string: timeStamp)

        let timeSta:TimeInterval = string.doubleValue

        let dfmatter = DateFormatter()

        dfmatter.dateFormat = format

        let date = Date(timeIntervalSince1970: timeSta)

        return dfmatter.string(from: date)

    }
    
    var milliStamp : Int {
            let timeInterval: TimeInterval = self.timeIntervalSince1970
            let millisecond = CLongLong(round(timeInterval*1000))
            return Int(millisecond)
    }
}

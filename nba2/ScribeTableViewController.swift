//
//  ScribeTableViewController.swift
//  nba2
//
//  Created by 刘少冬 on 2021/1/9.
//

import UIKit
import Alamofire

class ScribeTableViewController: UITableViewController {
    
    var  teams = [TeamInfo]()
    var selectTeam : Set<String> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem?.title = "返回"
        tableView.separatorInset = .zero
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemGray6
        
        let userDe = UserDefaults(suiteName: "group.liu.nba")
        selectTeam = Set(userDe?.stringArray(forKey: "TEAMS") ?? [])
        print(selectTeam)
        loadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return teams.count
    }
    
    
    @IBAction func saveData(_ sender: Any) {
        print(selectTeam)
        var urls = [String]()
        for team in selectTeam {
            urls.append("https://china.nba.com/static/data/team/schedule_" + team + ".json")
        }
        let userDe = UserDefaults(suiteName: "group.liu.nba")
        userDe?.set(urls, forKey: "URLS")
        userDe?.set(Array(selectTeam), forKey: "TEAMS")
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func subTeam(_ sender: UISwitch) {
        if(sender.isOn){
            print("ON")
            let code = teams[sender.tag].teamCode
            self.selectTeam.insert(code)
        }
        else {
            print("OFF")
            let code = teams[sender.tag].teamCode
            self.selectTeam.remove(code)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "ScribeTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ScribeTableViewCell  else {
                fatalError("The dequeued cell is not an instance of ScribeTableViewCell.")
            }
        let team = teams[indexPath.row]
        cell.logo.image = UIImage(named: team.teamCode)
        cell.teamName.text = team.teamName
        cell.swich.tag = indexPath.row
        if self.selectTeam.contains(team.teamCode) {
            cell.swich.isOn = true
        }
        else {
            cell.swich.isOn = false
        }
        return cell
    }
    
    private func loadData() {
        self.teams.removeAll()
        AF.request("https://china.nba.com/static/data/league/conferenceteamlist.json").responseJSON { response in
            switch response.result {
            case .success(let JSON):
                print("Success with JSON")
                self.dealDate(dict: JSON as! Dictionary<String,AnyObject>)
                self.tableView.reloadData()
            case .failure(let error):
                print("Request failed with error: \(error)")
            }
        }

    }
    
    func dealDate(dict: Dictionary<String,AnyObject>){
        let payload = dict["payload"] as! Dictionary<String,AnyObject>
         let listGroups = payload["listGroups"] as! NSArray
         for item  in listGroups {
             let group = item as! Dictionary<String,AnyObject>
            let teams = group["teams"] as! NSArray
            for item in teams {
                let team = item as! Dictionary<String,AnyObject>
                let profile = team["profile"] as! Dictionary<String,AnyObject>
                let teamName = profile["name"] as! String
                let  teamCode = profile["code"] as! String
                self.teams += [TeamInfo(teamName: teamName, teamCode: teamCode)]
            }
         }
    }
    
//    func getSche(game: Dictionary<String,AnyObject>, utc: Int) -> Sche {
//        let homeTeam = game["homeTeam"] as! Dictionary<String,AnyObject>
//        let homePro = homeTeam["profile"] as! Dictionary<String,AnyObject>
//        let codeA = homePro["code"] as! String
//        let nameA = homePro["displayAbbr"] as! String
//        
//        let awayTeam = game["awayTeam"] as! Dictionary<String,AnyObject>
//        let awayPro = awayTeam["profile"] as! Dictionary<String,AnyObject>
//        let codeB = awayPro["code"] as! String
//        let nameB = awayPro["displayAbbr"] as! String
//        
//        let boxscore = game["boxscore"] as! Dictionary<String,AnyObject>
//        let scoreA = boxscore["homeScore"] as! Int
//        let scoreB = boxscore["awayScore"] as! Int
//        let status = boxscore["status"] as! String
//        
//        
//        let ymd = Date.timeStampToString(String(utc), "yyyy-MM-dd")
//        let hm = Date.timeStampToString(String(utc), "HH:mm")
//        
//        return Sche(nameA: nameA, nameB: nameB, imageA: codeA, imageB: codeB, scoreA: String(scoreA), scoreB: String(scoreB), status: status, ymd: ymd, hm: hm)
//    }
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

struct TeamInfo {
    let teamName: String
    let teamCode: String
}

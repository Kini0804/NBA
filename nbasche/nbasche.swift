//
//  nbasche.swift
//  nbasche
//
//  Created by 刘少冬 on 2021/1/8.
//

import WidgetKit
import SwiftUI
import Intents
import Alamofire

var urls:[String] = ["https://china.nba.com/static/data/team/schedule_hawks.json", "https://china.nba.com/static/data/team/schedule_nets.json", "https://china.nba.com/static/data/team/schedule_celtics.json"]
var  sches = [Sche]()
var scheDict =  [Int : Sche]()
var lock = NSLock()

struct Provider: IntentTimelineProvider {
    
    
    func placeholder(in context: Context) -> SimpleEntry {
        return SimpleEntry(date: Date(), configuration: ConfigurationIntent(),sches: getData())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration,sches: getData())
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        scheDict.removeAll()
        urls.removeAll()
        let currentDate = Date()
        let currentYMD = currentDate.currentDateIntoString(format: "yyyy-MM-dd")
//        let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
        print(currentDate.currentDateIntoString(format: "yyyy-MM-dd HH:mm"))
        var index = 0;
        let userDe = UserDefaults(suiteName: "group.liu.nba")
        print("group")
        urls = userDe?.stringArray(forKey: "URLS") ?? []
//        print(urls)
        if urls.count == 0 {
            sches.removeAll()
            let entry = SimpleEntry(date: currentDate, configuration: configuration, sches: sches)
            entries.append(entry)
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        }
        for url in urls {
            AF.request(url).responseJSON { response in
                switch response.result {
                case .success(let JSON):
                    print("Success with JSON")
                    scheDict = scheDict.merging(dealDate(dict: JSON as! Dictionary<String,AnyObject>, index: index)) { (first, _) -> Sche in return first }
                    lock.lock()
                    index += 1
                    if index==urls.count {
                        let ds = scheDict.sorted(by: {$0.0 < $1.0})
                        sches.removeAll()
                        for d in ds {
                            if currentYMD==d.value.ymd && !judgeEquale(sches: sches, obj: d.value){
                                sches.append(d.value)
                                if sches.count>=5 {
                                    break
                                }
                            }
                        }
                        print(sches)
                        let entry = SimpleEntry(date: currentDate, configuration: configuration, sches: sches)
                        entries.append(entry)
                        let timeline = Timeline(entries: entries, policy: .atEnd)
                        completion(timeline)
                    }
                    lock.unlock()
                case .failure(let error):
                    print("Request failed with error: \(error)")
                    let timeline = Timeline(entries: entries, policy: .atEnd)
                    completion(timeline)
                }
            }
        }
//        print("PPPPPP")
//        let timeline = Timeline(entries: entries, policy: .atEnd)
//        completion(timeline)
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
    let current = Date().milliStamp - 86400000
    let month = Date().getMonth()
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
    
    
    let ymd = Date.timeStampToString(String(utc), "yyyy-MM-dd")
    let hm = Date.timeStampToString(String(utc), "HH:mm")
    
    return Sche(nameA: nameA, nameB: nameB, imageA: codeA, imageB: codeB, scoreA: String(scoreA), scoreB: String(scoreB), status: status, ymd: ymd, hm: hm)
}


struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let sches: [Sche]
}

class Sche{
    static func == (lhs: Sche, rhs: Sche) -> Bool {
        if(lhs.nameA == rhs.nameA && lhs.nameB == rhs.nameB && lhs.ymd == rhs.ymd && lhs.hm == rhs.hm){
            return true
        }
        else {
            return false
        }
    }
    
    let nameA: String
    let nameB: String
    let imageA: String
    let imageB: String
    let scoreA: String
    let scoreB: String
    let status: String
    let ymd: String
    let hm: String
    
    
    init(nameA: String, nameB: String, imageA: String, imageB: String, scoreA: String, scoreB: String, status: String, ymd: String, hm: String) {
        self.nameA = nameA
        self.nameB = nameB
        self.imageA = imageA
        self.imageB = imageB
        self.scoreA = scoreA
        self.scoreB = scoreB
        self.status = status
        self.ymd = ymd
        self.hm = hm
    }
}

struct nbascheEntryView : View {
    var entry: Provider.Entry
    var body: some View {
        VStack {
            Text(entry.date.currentDateIntoString(format: "yyyy-MM-dd"))
                .padding(.top)
            Divider()
            if entry.sches.count==0 {
                Text("今日没有你关注的比赛")
                    .multilineTextAlignment(.center)
            }
            else {
                ForEach(
                    0..<entry.sches.count,
                    id: \.self
                ) {
                    ScheRow(sche: entry.sches[$0], date: entry.date)
                        .frame(height: 45.0)
                    Divider()
                }
            }
           
            Spacer()
        }
    }
}

struct ScheRow: View {
    let sche: Sche
    let date: Date
    var body: some View {
        HStack(alignment: .center, spacing: 26.0){
            Image(sche.imageA)
                .resizable()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .shadow(radius: 30)
                
                VStack {
                        Text(sche.nameA)
                        .font(.system(size: 17))
                        .fontWeight(.none)
                        .foregroundColor(Color.black)
                                .frame(width: 55, alignment: .leading)
                    if sche.status=="2" || sche.status=="3" {
                        Text(sche.scoreA).fontWeight(.heavy).frame(width: 55, alignment: .leading)
                    }
                }
            
                VStack {
                        Text(sche.hm).font(.system(size: 12)).frame( alignment: .center)
                        Text("VS")
                                .font(.system(size: 22))
                                .frame( alignment: .center)
                        
                    if sche.status=="1" {
                        Text("未开始").font(.system(size: 9)).frame( alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    }
                    else if sche.status=="2" {
                        Text("进行中").font(.system(size: 9)).frame( alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    }
                    else if sche.status=="3" {
                        Text("已结束").font(.system(size: 9)).frame( alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    }
                }
                VStack {
                        Text(sche.nameB)
                        .font(.system(size: 17))
                        .fontWeight(.none)
                        .foregroundColor(Color.black)
                                .frame(width: 55, alignment: .trailing)
                    if sche.status=="2" || sche.status=="3" {
                        Text(sche.scoreB).fontWeight(.heavy).frame(width: 55, alignment: .trailing)
                    }
                }
                Image(sche.imageB)
                        .resizable()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .shadow(radius: 30)
            
        }
    }
}

@main
struct nbasche: Widget {
    let kind: String = "nbasche"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            nbascheEntryView(entry: entry)
        }
        .configurationDisplayName("NBA赛程")
        .description("This is an example widget.")
        .supportedFamilies([.systemLarge])
    }
}

func getCurrentDatePoint(now: Date) -> String {
    let dformatter = DateFormatter()
    dformatter.dateFormat = "yyyy-MM-dd"
    return dformatter.string(from: now)
}

struct nbasche_Previews: PreviewProvider {
    static var previews: some View {
        nbascheEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(),sches: getData()))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}

func getData() -> [Sche] {
    let sches1 = [Sche(nameA: "步行者", nameB: "步行者", imageA: "logo", imageB: "logo", scoreA: "122", scoreB: "100", status: "3", ymd: "2020-10-2", hm: "08:00")]
    return sches1
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


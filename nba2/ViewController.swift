//
//  ViewController.swift
//  nba2
//
//  Created by 刘少冬 on 2021/1/7.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate{

    @IBOutlet weak var upp: UILabel!
    @IBOutlet weak var inputText: UITextField!
    @IBOutlet weak var pic: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        inputText.delegate = self;
        let url = URL(string: "http://mat1.gtimg.com/sports/nba/logo/1602/2.png")!
        downloadImage(from: url)
    }
    
    
    public func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    public func downloadImage(from url: URL) {
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() { [weak self] in
                self?.pic.image = UIImage(data: data)
            }
        }
    }
    
    @IBAction func setImage(_ sender: UITapGestureRecognizer) {
        let url = URL(string: "http://mat1.gtimg.com/sports/nba/logo/1602/3.png")!
        downloadImage(from: url)
        print("SADASD")
    }

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        inputText.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        upp.text = inputText.text
    }

    @IBAction func setInput(_ sender: Any) {
        upp.text = "gggggg"
        inputText.text = "ooooooo"
        let a = inputText.text;
        print(a!)
    }
}


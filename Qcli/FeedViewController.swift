//
//  FeedViewController.swift
//  Qcli
//
//  Created by 吉田周平 on 2020/11/13.
//

import UIKit
import SwiftyJSON
import Alamofire

struct ArticleData {
    var imgURL: String
    var titleText: String
    var discriptionText: String
    var likeNumber: Int
    var articleURL: String
}

class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var searchTxextField: UITextField!
    @IBOutlet weak var articleTableView: UITableView!
    let cornerRadiusValue: CGFloat = 8
    var dataList: [ArticleData] = []
    let tableViewCellHeight: CGFloat = 50
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
        //ログインした状態ならユーザー情報呼び出し
        if self.isLogined() {
            let token = callUserInfo()
            print("トークン読み込みました\(token)")
        }
        articleTableView.dataSource = self
        articleTableView.delegate = self
        getData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = articleTableView.dequeueReusableCell(withIdentifier: "ArticleCell", for: indexPath) as! ArticleTableViewCell
        cell.titleLabel?.text = dataList[indexPath.row].titleText
        cell.discriptionLabel?.text = dataList[indexPath.row].discriptionText
        cell.likeLabel?.text = "\(dataList[indexPath.row].likeNumber)like"
        let url = URL(string: dataList[indexPath.row].imgURL)
        do {
            let imageData = try Data(contentsOf: url!)
            cell.articleIconImage?.image = UIImage(data: imageData)
        } catch {
            cell.articleIconImage?.image = UIImage(named: "no-coupon-image.png")
        }
        cell.cellSetLayout()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableViewCellHeight
    }
    
    //userInfo呼び出し
    func callUserInfo() -> qiitaUserInfo {
        var value = qiitaUserInfo(token: "")
        if let data = UserDefaults.standard.value(forKey:"userInfo") as? Data {
            let userInfo = try? PropertyListDecoder().decode(Array<qiitaUserInfo>.self, from: data)
            if let userInfo = userInfo {
                value = userInfo[0]
            }
        }
        return value
    }
    
    //ログイン判定
    func isLogined() -> Bool {
        var value = false
        value = UserDefaults.standard.bool(forKey: "isLogined")
        return value
    }
    
    func setLayout() {
        searchTxextField.layer.cornerRadius = cornerRadiusValue
    }
    
    func getData() {
        let url = "https://qiita.com/api/v2/items?page=1&per_page=20"
        AF.request(url, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                json.forEach {(_, json) in
                    if let titleData = json["title"].string,
                       let discriptionData = json["body"].string,
                       let likeData = json["likes_count"].int,
                       let imageURL = json["user"]["profile_image_url"].string,
                       let articleURL = json["url"].string {
                        let oneData = ArticleData(imgURL: imageURL, titleText: titleData, discriptionText: discriptionData, likeNumber: likeData, articleURL: articleURL)
                        self.dataList.append(oneData)
                    }
                    
                }
                self.articleTableView.reloadData()
                print("tableリロード")
            case .failure(let error):
                print(error)
            }
        }
    }
}

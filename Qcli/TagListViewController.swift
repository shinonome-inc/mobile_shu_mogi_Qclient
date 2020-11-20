//
//  TagListViewController.swift
//  Qcli
//
//  Created by 吉田周平 on 2020/11/16.
//

import UIKit
import Alamofire
import SwiftyJSON

struct tagData {
    var tagTitle: String
    var imageURL: String
    var itemCount: Int
}

class TagListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var tagListTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    let cornerRadiusValue: CGFloat = 8
    //cellの高さ設定
    let tableViewCellHeight: CGFloat = 50
    //最初に取得する記事欄のデータ
    var initializedItems = [tagData]()
    //検索後記事欄のデータ
    var searchItems = [tagData]()
    var searching = false
    //画面遷移時のデータ受け渡し用
    var sendData = tagData(tagTitle: "", imageURL: "", itemCount: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tagListTableView.dataSource = self
        tagListTableView.delegate = self
        searchBar.delegate = self
        //テーブルビューをスクロールさせたらキーボードを閉じる
        tagListTableView.keyboardDismissMode = .onDrag
        getTagListData()
        // Do any additional setup after loading the view.
    }
    
    //検索のアルゴリズムを変えたいならここをいじる
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchItems = initializedItems.filter({$0.tagTitle.lowercased().prefix(searchText.count) == searchText.lowercased()})
        searching = true
        tagListTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return searchItems.count
        } else {
            return initializedItems.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if searching {
            return setCell(items: searchItems, indexPath: indexPath)
        } else {
            return setCell(items: initializedItems, indexPath: indexPath)
        }
    }
    
    //tableviewcellの高さ設定
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableViewCellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searching {
            sendData = searchItems[indexPath.row]
        } else {
            sendData = initializedItems[indexPath.row]
        }
        //tableviewcell選択解除
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "GoToArticlePage", sender: nil)
    }
    
    //apiを叩きデータを保存する
    func getTagListData() {
        let url = "https://qiita.com/api/v2/tags?page=1&per_page=20&sort=count"
        AF.request(url, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                json.forEach {(_, json) in
                    if let titleData = json["id"].string,
                       let itemsCount = json["items_count"].int,
                       let imageURL = json["icon_url"].string {
                        let oneData = tagData(tagTitle: titleData, imageURL: imageURL, itemCount: itemsCount)
                        self.initializedItems.append(oneData)
                        print(oneData.tagTitle)
                    }
                    
                }
                self.tagListTableView.reloadData()
                self.searchItems = self.initializedItems
            case .failure(let error):
                print(error)
            }
        }
    }
    
    //tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)で呼ばれる関数
    func setCell(items: [tagData], indexPath: IndexPath) -> TagListTableViewCell {
        let cell = tagListTableView.dequeueReusableCell(withIdentifier: "tagCell", for: indexPath) as! TagListTableViewCell
        cell.tagTitle?.text = items[indexPath.row].tagTitle
        cell.tagCount?.text = "\(items[indexPath.row].itemCount)件"
        let url = URL(string: items[indexPath.row].imageURL)
        do {
            let imageData = try Data(contentsOf: url!)
            cell.tagIconImage?.image = UIImage(data: imageData)
        } catch {
            cell.tagIconImage?.image = UIImage(named: "no-coupon-image.png")
        }
        cell.cellSetLayout()
        return cell
    }
}

//
//  TagListViewController.swift
//  Qcli
//
//  Created by 吉田周平 on 2020/11/16.
//

import UIKit
import Alamofire

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
    var dataItems = [tagData]()
    //画面遷移時のデータ受け渡し用
    var sendData = tagData(tagTitle: "", imageURL: "", itemCount: 0)
    //データリクエストの宣言
    var tagListDataRequest: RequestData!
    //スクロールデータ更新用のページカウント
    var pageCount = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tagListTableView.dataSource = self
        tagListTableView.delegate = self
        searchBar.delegate = self
        //テーブルビューをスクロールさせたらキーボードを閉じる
        tagListTableView.keyboardDismissMode = .onDrag
        //タグデータ取得
        //userInfoがあるならuserInfoも追加する
        if self.isLogined() {
            let userInfo = callUserInfo()
            print("Your Token 🔑: \(userInfo.token)")
            self.tagListDataRequest = RequestData(userInfo: userInfo, dataType: .tag, pageNumber: pageCount, perPageNumber: 20, sortdict: [QueryOption.sort:SortOption.count])
        } else {
            self.tagListDataRequest = RequestData(dataType: .tag, pageNumber: pageCount, perPageNumber: 20, sortdict: [QueryOption.sort:SortOption.count])
        }
        getTagListData(requestTagListData: self.tagListDataRequest)
        // Do any additional setup after loading the view.
    }
    
    //検索のアルゴリズムを変えたいならここをいじる
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        searchItems = dataItems.filter({$0.tagTitle.lowercased().prefix(searchText.count) == searchText.lowercased()})
//        searching = true
//        tagListTableView.reloadData()
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return dataItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return setCell(items: dataItems, indexPath: indexPath)
    }
    
    //tableviewcellの高さ設定
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableViewCellHeight
    }
    //tableviewcell選択時の処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //tableviewcell選択解除
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    //tableviewをスクロールしたら最下のcellにたどり着く前にデータ更新を行う
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffsetY = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.height
        let distanceToBottom = maximumOffset - currentOffsetY
        
        if distanceToBottom < 500 {
            self.pageCount += 1
            self.tagListDataRequest.pageNumber = self.pageCount
            getTagListData(requestTagListData: self.tagListDataRequest)
        }
    }
    //apiを叩きデータを保存する
    func getTagListData(requestTagListData: RequestData) {
        requestTagListData.fetchTagData(success: { (tagListData) in
            tagListData?.forEach{ (oneTagData) in
                if let title = oneTagData.id,
                   let imageUrl = oneTagData.iconUrl,
                   let itemCount = oneTagData.itemsCount {
                    let oneData = tagData(tagTitle: title, imageURL: imageUrl, itemCount: itemCount)
                    self.dataItems.append(oneData)
                } else {
                    print("ERROR: This data ↓ allocation failed.")
                    print(oneTagData)
                }
            }
            self.tagListTableView.reloadData()
            print("👍 Reload the \(requestTagListData.dataType.rawValue) data")
        }, failure: { error in
            print("Failed to get the article list data.")
            if let error = error {
                print(error)
            }
        })
//        let url = "https://qiita.com/api/v2/tags?page=1&per_page=20&sort=count"
//        AF.request(url, method: .get).validate().responseJSON { response in
//            switch response.result {
//            case .success(let value):
//                let json = JSON(value)
//                json.forEach {(_, json) in
//                    if let titleData = json["id"].string,
//                       let itemsCount = json["items_count"].int,
//                       let imageURL = json["icon_url"].string {
//                        let oneData = tagData(tagTitle: titleData, imageURL: imageURL, itemCount: itemsCount)
//                        self.dataItems.append(oneData)
//                        print(oneData.tagTitle)
//                    }
//                    
//                }
//                self.tagListTableView.reloadData()
//                self.searchItems = self.dataItems
//            case .failure(let error):
//                print(error)
//            }
//        }
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
    //ログイン判定
    func isLogined() -> Bool {
        var value = false
        value = UserDefaults.standard.bool(forKey: "isLogined")
        return value
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
}

//
//  TagListViewController.swift
//  Qcli
//
//  Created by 吉田周平 on 2020/11/16.
//

import UIKit

struct TagData {
    var tagTitle: String
    var imageURL: String
    var itemCount: Int
}

class TagListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tagListTableView: UITableView!
    let cornerRadiusValue: CGFloat = 8
    //cellの高さ設定
    let tableViewCellHeight: CGFloat = 50
    //最初に取得する記事欄のデータ
    var dataItems = [TagData]()
    //画面遷移時のデータ受け渡し用
    var sendData = TagData(tagTitle: "", imageURL: "", itemCount: 0)
    //スクロールデータ更新用のページカウント
    var pageCount = 1
    //データリクエストの宣言
    var tagListDataRequest: TagDataNetworkService!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tagListTableView.dataSource = self
        tagListTableView.delegate = self

        //テーブルビューをスクロールさせたらキーボードを閉じる
        tagListTableView.keyboardDismissMode = .onDrag
        // Do any additional setup after loading the view.
       
        self.tagListDataRequest = TagDataNetworkService(sortDict: [QueryOption.sort:SortOption.count])
        getTagListData(requestTagListData: self.tagListDataRequest)
    }
    
    
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
    func getTagListData(requestTagListData: TagDataNetworkService) {
        requestTagListData.fetch(success: { (tagListData) in
            tagListData?.forEach{ (oneTagData) in
                if let title = oneTagData.id,
                   let imageUrl = oneTagData.iconUrl,
                   let itemCount = oneTagData.itemsCount {
                    let oneData = TagData(tagTitle: title, imageURL: imageUrl, itemCount: itemCount)
                    self.dataItems.append(oneData)
                } else {
                    print("ERROR: This data ↓ allocation failed.")
                    print(oneTagData)
                }
            }
            self.tagListTableView.reloadData()
            print("👍 Reload the tag data")
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
//                        let oneData = TagData(tagTitle: titleData, imageURL: imageURL, itemCount: itemsCount)
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
    func setCell(items: [TagData], indexPath: IndexPath) -> TagListTableViewCell {
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
    
}

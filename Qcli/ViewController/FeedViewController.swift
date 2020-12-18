//
//  FeedViewController.swift
//  Qcli
//
//  Created by 吉田周平 on 2020/11/13.
//

import UIKit

struct ArticleData {
    var imgURL: String
    var titleText: String
    var discriptionText: String
    var likeNumber: Int
    var articleURL: String
}

class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmentedControll: UISegmentedControl!
    @IBOutlet weak var articleTableView: UITableView!
    let cornerRadiusValue: CGFloat = 8
    //cellの高さ設定
    let tableViewCellHeight: CGFloat = 50
    //最初に取得する記事欄のデータ
    var dataItems = [ArticleData]()
    //画面遷移時のデータ受け渡し用
    var sendData: ArticleData?
    //segmented controllの選択肢
    let segmentedItems = SearchOption.allCases
    //データリクエストの宣言
    var articleListDataRequest: AirticleDataNetworkService!
    //segmented controlの選択インデックス
    var segmentedSelectedIndex = 0
    //スクロールデータ更新用のページカウント
    var pageCount = 1
    //リクエストできる状態か判定
    var isNotLoading = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        articleTableView.dataSource = self
        articleTableView.delegate = self
        searchBar.delegate = self
        //テーブルビューをスクロールさせたらキーボードを閉じる
        articleTableView.keyboardDismissMode = .onDrag
        //記事データ取得
        self.articleListDataRequest = AirticleDataNetworkService(searchDict: nil)
        getData(requestAirticleData: self.articleListDataRequest)
        //segmented control 設定
        setSegmentedControl()
    }
    
    //テキストを入力してから、リクエストを送る方法
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = self.searchBar.text {
            self.dataItems.removeAll()
            //ページカウント初期化
            self.pageCount = 1
            
            self.articleListDataRequest = AirticleDataNetworkService(
                searchDict: [self.segmentedItems[self.segmentedSelectedIndex]:searchText])
            getData(requestAirticleData: self.articleListDataRequest)
        }
    }
    
    @IBAction func actionSegmentedControl(_ sender: UISegmentedControl) {
        self.segmentedSelectedIndex = sender.selectedSegmentIndex
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
        sendData = dataItems[indexPath.row]
        //tableviewcell選択解除
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "GoToArticlePage", sender: nil)
    }
    //tableviewをスクロールしたら最下のcellにたどり着く前にデータ更新を行う
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffsetY = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.height
        let distanceToBottom = maximumOffset - currentOffsetY
        
        if distanceToBottom < 150 && self.isNotLoading {
            self.isNotLoading = false
            self.pageCount += 1
            self.articleListDataRequest.pageNumber = self.pageCount
            self.getData(requestAirticleData: self.articleListDataRequest)
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "GoToArticlePage") {
            let articlePageVC = segue.destination as! ArticlePageViewController
            if let sendData = self.sendData {
                articlePageVC.articleData = sendData
            }
        }
    }
        
    //ログイン判定
    func isLogined() -> Bool {
        var value = false
        value = UserDefaults.standard.bool(forKey: "isLogined")
        return value
    }
    
    //apiを叩きデータを保存する
    func getData(requestAirticleData: AirticleDataNetworkService) {
        requestAirticleData.fetch(success: { (dataArray) in
            dataArray?.forEach { (oneAirticleData) in
                if let title = oneAirticleData.title,
                   let description = oneAirticleData.body,
                   let like = oneAirticleData.likesCount,
                   let imageURL = oneAirticleData.user.profileImageUrl,
                   let articleURL = oneAirticleData.url {
                    let oneData = ArticleData(imgURL: imageURL, titleText: title, discriptionText: description, likeNumber: like, articleURL: articleURL)
                    self.dataItems.append(oneData)
                } else {
                    print("ERROR: This data ↓ allocation failed.")
                    print(oneAirticleData)
                }
            }
            self.articleTableView.reloadData()
            print("👍 Reload the article data")
            self.isNotLoading = true
            
        }, failure: { error in
            print("Failed to get the article list data.")
            if let error = error {
                print(error)
            }
            self.isNotLoading = true
        })
    }
    
    //tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)で呼ばれる関数
    func setCell(items: [ArticleData], indexPath: IndexPath) -> ArticleTableViewCell {
        let cell = articleTableView.dequeueReusableCell(withIdentifier: "ArticleCell", for: indexPath) as! ArticleTableViewCell
        cell.titleLabel?.text = items[indexPath.row].titleText
        cell.discriptionLabel?.text = items[indexPath.row].discriptionText
        cell.likeLabel?.text = "\(items[indexPath.row].likeNumber)like"
        let url = URL(string: items[indexPath.row].imgURL)
        do {
            if let url = url {
                let imageData = try Data(contentsOf: url)
                cell.articleIconImage?.image = UIImage(data: imageData)
            }
            
        } catch {
            cell.articleIconImage?.image = UIImage(named: "no-coupon-image.png")
        }
        cell.cellSetLayout()
        return cell
    }
    
    func setSegmentedControl() {
        self.segmentedControll.removeAllSegments()
        for (i,x) in self.segmentedItems.enumerated() {
            self.segmentedControll.insertSegment(withTitle: x.rawValue, at: i, animated: true)
        }
    }
}

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
    var sendData = ArticleData(imgURL: "", titleText: "", discriptionText: "", likeNumber: 0, articleURL: "")
    //segmented controllの選択肢
    let segmentedItems = SearchOption.allCases
    //初期のクエリアイテム
    let initQueryItems = [
        URLQueryItem(name: "page", value: "1"),
        URLQueryItem(name: "per_page", value: "20")
    ]
    //segmented controlの選択インデックス
    var segmentedSelectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //ログインした状態ならユーザー情報呼び出し
        if self.isLogined() {
            let token = callUserInfo().token
            print("Your Token 🔑: \(token)")
        }
        articleTableView.dataSource = self
        articleTableView.delegate = self
        searchBar.delegate = self
        //テーブルビューをスクロールさせたらキーボードを閉じる
        articleTableView.keyboardDismissMode = .onDrag
        //記事データ取得
        let articleListDataRequest = RequestData(dataType: .article, queryItems: initQueryItems)
        getData(requestAirticleData: articleListDataRequest)
        //segmented control 設定
        setSegmentedControl()
    }
    
    //検索のアルゴリズムを変えたいならここをいじる
    //↓テキストが変わるごとにリクエストを送ると処理落ちする
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        self.dataItems.removeAll()
//        let articleListDataRequest = RequestData(dataType: .article, queryItems: initQueryItems, searchDict: [.tag:searchText])
//        getData(requestAirticleData: articleListDataRequest)
//    }
    
    //テキストを入力してから、リクエストを送る方法
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = self.searchBar.text {
            self.dataItems.removeAll()
            let articleListDataRequest = RequestData(dataType: .article, queryItems: initQueryItems, searchDict: [self.segmentedItems[self.segmentedSelectedIndex]:searchText])
            getData(requestAirticleData: articleListDataRequest)
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
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "GoToArticlePage") {
            let articlePageVC = segue.destination as! ArticlePageViewController
            articlePageVC.articleData = sendData
        }
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
    
    //apiを叩きデータを保存する
    func getData(requestAirticleData: RequestData) {
        requestAirticleData.fetchAirtcleData(success: { (dataArray) in
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
            print("👍 All the \(requestAirticleData.dataType.rawValue) data is displayed in the table view.")
        }, failure: { error in
            print("Failed to get the article list data.")
            if let error = error {
                print(error)
            }
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
            let imageData = try Data(contentsOf: url!)
            cell.articleIconImage?.image = UIImage(data: imageData)
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

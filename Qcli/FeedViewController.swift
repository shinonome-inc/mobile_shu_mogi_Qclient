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
    @IBOutlet weak var articleTableView: UITableView!
    let cornerRadiusValue: CGFloat = 8
    //cellの高さ設定
    let tableViewCellHeight: CGFloat = 50
    //最初に取得する記事欄のデータ
    var initializedItems = [ArticleData]()
    //検索後記事欄のデータ
    var searchItems = [ArticleData]()
    var searching = false
    //画面遷移時のデータ受け渡し用
    var sendData = ArticleData(imgURL: "", titleText: "", discriptionText: "", likeNumber: 0, articleURL: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //ログインした状態ならユーザー情報呼び出し
        if self.isLogined() {
            let token = callUserInfo().token
            print("Your Token: \(token)")
        }
        articleTableView.dataSource = self
        articleTableView.delegate = self
        searchBar.delegate = self
        //テーブルビューをスクロールさせたらキーボードを閉じる
        articleTableView.keyboardDismissMode = .onDrag
        
        let initialQueryItems = [
            URLQueryItem(name: "page", value: "1"),
            URLQueryItem(name: "per_page", value: "20")
        ]
        getData(queryItems: initialQueryItems)
    }
    
    //検索のアルゴリズムを変えたいならここをいじる
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchItems = initializedItems.filter({$0.titleText.lowercased().prefix(searchText.count) == searchText.lowercased()})
        searching = true
        articleTableView.reloadData()
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
    
    //tableviewcell選択時の処理
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
    func getData(queryItems: [URLQueryItem]) {
        
        let requestAirticleData = RequestData(dataType: .article, queryItems: queryItems)
        requestAirticleData.fetchAirtcleData(success: { (dataArray) in
            dataArray?.forEach { (oneAirticleData) in
                if let title = oneAirticleData.title,
                   let description = oneAirticleData.body,
                   let like = oneAirticleData.likesCount,
                   let imageURL = oneAirticleData.user.profileImageUrl,
                   let articleURL = oneAirticleData.url {
                    let oneData = ArticleData(imgURL: imageURL, titleText: title, discriptionText: description, likeNumber: like, articleURL: articleURL)
                    self.initializedItems.append(oneData)
                } else {
                    print("ERROR: This data ↓ allocation failed.")
                    print(oneAirticleData)
                }
            }
            self.searchItems = self.initializedItems
            self.articleTableView.reloadData()
            print("All the data is displayed in the table view.")
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
}

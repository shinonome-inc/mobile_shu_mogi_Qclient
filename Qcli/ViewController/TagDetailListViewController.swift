//
//  TagDetailListViewController.swift
//  Qcli
//
//  Created by 吉田周平 on 2020/12/20.
//

import UIKit
class TagDetailListViewController: UIViewController {
    
    @IBOutlet weak var articleTableView: UITableView!
    //TagListViewControllerからの受け取りのデータ
    var receiveData: TagData?
    //データリクエストの宣言
    var articleListDataRequest: AirticleDataNetworkService!
    //最初に取得する記事欄のデータ
    var dataItems = [ArticleData]()
    //画面遷移時のデータ受け渡し用
    var sendData: ArticleData?
    //スクロールデータ更新用のページカウント
    var pageCount = 1
    //リクエストできる状態か判定
    var isNotLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        articleTableView.dataSource = self
        articleTableView.delegate = self
        if let receiveData = receiveData {
            articleListDataRequest = AirticleDataNetworkService(searchDict: [SearchOption.tag:receiveData.tagTitle])
            getData(requestAirticleData: articleListDataRequest)
            navigationItem.title = receiveData.tagTitle
        }
    }
    //apiを叩きデータを保存する
    func getData(requestAirticleData: AirticleDataNetworkService) {
        requestAirticleData.fetch(success: { (dataArray) in
            dataArray?.forEach { (oneAirticleData) in
                if let title = oneAirticleData.title,
                   let createdAt = oneAirticleData.createdAt,
                   let like = oneAirticleData.likesCount,
                   let imageURL = oneAirticleData.user.profileImageUrl,
                   let articleURL = oneAirticleData.url {
                    let oneData = ArticleData(imgURL: imageURL, titleText: title, createdAt: createdAt, likeNumber: like, articleURL: articleURL)
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
            //TODO: エラー画面を作成し、遷移させる
        })
    }
    
    //tableviewをスクロールしたら最下のcellにたどり着く前にデータ更新を行う
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffsetY = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.height
        let distanceToBottom = maximumOffset - currentOffsetY
        
        if distanceToBottom < 150 && isNotLoading {
            isNotLoading = false
            pageCount += 1
            articleListDataRequest.pageNumber = pageCount
            getData(requestAirticleData: articleListDataRequest)
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == SegueId.fromTagDetailToArticlePage.rawValue) {
            let articlePageVC = segue.destination as! ArticlePageViewController
            if let sendData = sendData {
                articlePageVC.articleData = sendData
            }
        }
    }
}

extension TagDetailListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = articleTableView.dequeueReusableCell(withIdentifier: "ArticleCell", for: indexPath) as? ArticleTableViewCell else {
            abort()
        }
        let model = dataItems[indexPath.row]
        cell.setModel(model: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sendData = dataItems[indexPath.row]
        //tableviewcell選択解除
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: SegueId.fromTagDetailToArticlePage.rawValue, sender: nil)
    }
}

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
    //set refreshControl
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let navigationController = navigationController as? MyNavigationController {
            navigationController.setConfig()
        }
        if let receiveData = receiveData {
            articleListDataRequest = AirticleDataNetworkService(searchDict: [SearchOption.tag:receiveData.tagTitle])
            articleListDataRequest.errorDelegate = self
            getData(requestAirticleData: articleListDataRequest)
            navigationItem.title = receiveData.tagTitle
        }
        //set refresh control
        articleTableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    //apiを叩きデータを保存する
    func getData(requestAirticleData: AirticleDataNetworkService, isRefresh: Bool = false) {
        requestAirticleData.fetch(success: { (dataArray) in
            self.refreshControl.endRefreshing()
            guard let dataArray = dataArray else { return }
            let convertedModels = self.storingData(dataArray: dataArray)
            if isRefresh {
                self.dataItems = convertedModels
            } else {
                self.dataItems += convertedModels
            }
            self.articleTableView.reloadData()
            print("👍 Reload the article data")
            self.isNotLoading = true
        }, failure: { error in
            self.refreshControl.endRefreshing()
            print("Failed to get the article list data.")
            if let error = error {
                print(error)
            }
            self.isNotLoading = true
            //TODO: エラー画面を作成し、遷移させる
        })
    }
    
    func storingData(dataArray: [AirticleModel]) -> [ArticleData] {
        var models: [ArticleData] = []
        dataArray.forEach { (oneAirticleData) in
            if let title = oneAirticleData.title,
               let createdAt = oneAirticleData.createdAt,
               let like = oneAirticleData.likesCount,
               let imageURL = oneAirticleData.user.profileImageUrl,
               let articleURL = oneAirticleData.url,
               let id = oneAirticleData.user.id {
                let oneData = ArticleData(id: id, imgURL: imageURL, titleText: title, createdAt: createdAt, likeNumber: like, articleURL: articleURL)
                models.append(oneData)
            } else {
                print("ERROR: This data ↓ allocation failed.")
                print(oneAirticleData)
            }
        }
        return models
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
            if let navigationController = segue.destination as? UINavigationController,
               let articlePageViewController = navigationController.topViewController as? ArticlePageViewController,
               let sendData = sendData {
                articlePageViewController.articleData = sendData
            }
        }
    }
    
    @objc func refresh() {
        pageCount = 1
        articleListDataRequest.pageNumber = pageCount
        getData(requestAirticleData: articleListDataRequest, isRefresh: true)
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

extension TagDetailListViewController: ErrorDelegate {
    func backToLoginViewController() {
        let identifier = ViewControllerIdentifier.login.rawValue
        if let storyboard = self.storyboard,
           let navigationController = self.navigationController {
            let loginViewController = storyboard.instantiateViewController(identifier: identifier) as! LoginViewController
            navigationController.pushViewController(loginViewController, animated: true)
        }
    }
    
    func segueErrorViewController(qiitaError: QiitaError) {
        let errorView = ErrorView.make()
        errorView.checkSafeArea(viewController: self)
        errorView.errorDelegate = self
        errorView.qiitaError = qiitaError
        errorView.setConfig()
        view.addSubview(errorView)
    }
    
    func reload() {
        getData(requestAirticleData: articleListDataRequest)
    }
    
}

//
//  FeedViewController.swift
//  Qcli
//
//  Created by 吉田周平 on 2020/11/13.
//

import UIKit

class FeedViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var segmentedControll: UISegmentedControl!
    @IBOutlet weak var articleTableView: UITableView!
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
    var isNotLoading = false
    //set refreshControl
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //記事データ取得
        articleListDataRequest = AirticleDataNetworkService(searchDict: nil)
        articleListDataRequest.errorDelegate = self
        getData(requestAirticleData: articleListDataRequest)
        //segmented control 設定
        setSegmentedControl()
        //set refresh control
        articleTableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    //テキストを入力してから、リクエストを送る方法
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text {
            dataItems.removeAll()
            //ページカウント初期化
            pageCount = 1
            
            articleListDataRequest = AirticleDataNetworkService(
                searchDict: [segmentedItems[segmentedSelectedIndex]:searchText])
            getData(requestAirticleData: articleListDataRequest)
        }
    }
    
    @IBAction func actionSegmentedControl(_ sender: UISegmentedControl) {
        segmentedSelectedIndex = sender.selectedSegmentIndex
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == SegueId.fromFeedToArticle.rawValue) {
            if let navigationController = segue.destination as? UINavigationController,
               let articlePageViewController = navigationController.topViewController as? ArticlePageViewController,
               let sendData = sendData {
                articlePageViewController.articleData = sendData
            }
        }
    }
        
    //apiを叩きデータを保存する
    func getData(requestAirticleData: AirticleDataNetworkService, isRefresh: Bool = false) {
        let beforeFetchDataCount = dataItems.count
        requestAirticleData.fetch(success: { (dataArray) in
            guard let dataArray = dataArray else { return }
            self.storingData(dataArray: dataArray,
                             completion: {
                                if isRefresh {
                                    self.dataItems.removeSubrange(0...beforeFetchDataCount-1)
                                }
                                self.articleTableView.reloadData()
                                print("👍 Reload the article data")
                                self.isNotLoading = true
                             })
        }, failure: { error in
            print("Failed to get the article list data.")
            if let error = error {
                print(error)
            }
            self.isNotLoading = true
            //TODO: エラー画面を作成し、遷移させる
        })
    }
    
    func storingData(dataArray: [AirticleModel], completion: () -> Void) {
        dataArray.forEach { (oneAirticleData) in
            if let title = oneAirticleData.title,
               let createdAt = oneAirticleData.createdAt,
               let like = oneAirticleData.likesCount,
               let imageURL = oneAirticleData.user.profileImageUrl,
               let articleURL = oneAirticleData.url,
               let id = oneAirticleData.user.id {
                let oneData = ArticleData(id: id, imgURL: imageURL, titleText: title, createdAt: createdAt, likeNumber: like, articleURL: articleURL)
                self.dataItems.append(oneData)
            } else {
                print("ERROR: This data ↓ allocation failed.")
                print(oneAirticleData)
            }
        }
        completion()
    }
    
    func setSegmentedControl() {
        segmentedControll.removeAllSegments()
        for (i,x) in segmentedItems.enumerated() {
            segmentedControll.insertSegment(withTitle: x.rawValue, at: i, animated: true)
        }
    }
    
    @objc func refresh() {
        pageCount = 1
        articleListDataRequest.pageNumber = pageCount
        getData(requestAirticleData: articleListDataRequest, isRefresh: true)
        refreshControl.endRefreshing()
    }
}

extension FeedViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = articleTableView.dequeueReusableCell(withIdentifier: "ArticleCell", for: indexPath) as? ArticleTableViewCell else {
            abort()
        }
        print("test: \(indexPath.row)/\(dataItems.count)")
        let model = dataItems[indexPath.row]
        cell.setModel(model: model)
        return cell
    }
    
    //tableviewcell選択時の処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sendData = dataItems[indexPath.row]
        //tableviewcell選択解除
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: SegueId.fromFeedToArticle.rawValue, sender: nil)
    }
    //tableviewをスクロールしたら最下のcellにたどり着く前にデータ更新を行う
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let currentOffsetY = scrollView.contentOffset.y
//        let maximumOffset = scrollView.contentSize.height - scrollView.frame.height
//        let distanceToBottom = maximumOffset - currentOffsetY
//
//        if distanceToBottom < 150 && isNotLoading {
//            isNotLoading = false
//            pageCount += 1
//            articleListDataRequest.pageNumber = pageCount
//            getData(requestAirticleData: articleListDataRequest)
//
//        }
//    }
}

extension FeedViewController: ErrorDelegate {
    func backToLoginViewController() {
        let identifier = ViewControllerIdentifier.login.rawValue
        if let storyboard = self.storyboard,
           let navigationController = self.navigationController {
            let loginViewController = storyboard.instantiateViewController(identifier: identifier) as! LoginViewController
            navigationController.pushViewController(loginViewController, animated: true)
        }
    }
    
    func segueErrorViewController(qiitaError: QiitaError) {
        //↓ErrorViewを使う
        //guard let nib = Bundle.main.loadNibNamed("ErrorView", owner: self, options: nil) else { return }
        //let errorView = nib.first as! ErrorView
        let errorView = ErrorView.make()
        errorView.checkSafeArea(viewController: self)
        errorView.errorDelegate = self
        errorView.qiitaError = qiitaError
        errorView.setConfig()
        view.addSubview(errorView)
        //↓Error VCを使う
        //guard let storyboard = self.storyboard else { abort() }
        //let identifier = ViewControllerIdentifier.error.rawValue
        //let errorViewController = storyboard.instantiateViewController(identifier: identifier) as! ErrorViewController
        //errorViewController.errorDelegate = self
        //errorViewController.qiitaError = qiitaError
        //errorViewController.checkSafeArea(viewController: self)
        //addChild(errorViewController)
        //view.addSubview(errorViewController.view)
    }
    
    func reload() {
        getData(requestAirticleData: articleListDataRequest)
    }
        
}

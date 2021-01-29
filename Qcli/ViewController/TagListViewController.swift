//
//  TagListViewController.swift
//  Qcli
//
//  Created by 吉田周平 on 2020/11/16.
//

import UIKit



class TagListViewController: UIViewController {
    
    @IBOutlet weak var tagListTableView: UITableView!
    //最初に取得する記事欄のデータ
    var dataItems = [TagData]() {
        didSet {
            tagListTableView.reloadData()
        }
    }
    //画面遷移時のデータ受け渡し用
    var sendData: TagData?
    //スクロールデータ更新用のページカウント
    var pageCount = 1
    //データリクエストの宣言
    var tagListDataRequest: TagDataNetworkService!
    //リクエストできる状態か判定
    var isNotLoading = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tagListDataRequest = TagDataNetworkService(sortDict: [QueryOption.sort:SortOption.count])
        tagListDataRequest.errorDelegate = self
        getTagListData(requestTagListData: tagListDataRequest)
        
        //set refresh control
        tagListTableView.refreshControl = UIRefreshControl()
        guard let refreshControl = tagListTableView.refreshControl else { return }
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
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
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == SegueId.fromTagListToTagDetailList.rawValue) {
            let destinationVC = segue.destination as! TagDetailListViewController
            if let sendData = sendData {
                destinationVC.receiveData = sendData
            }
        }
    }
    
    @objc func refresh() {
        dataItems.removeAll()
        pageCount = 1
        tagListDataRequest.pageNumber = pageCount
        getTagListData(requestTagListData: tagListDataRequest)
        guard let refreshControl = tagListTableView.refreshControl else { return }
        refreshControl.endRefreshing()
    }
}
extension TagListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tagListTableView.dequeueReusableCell(withIdentifier: "tagCell", for: indexPath) as? TagListTableViewCell else {
            abort()
        }
        let model = dataItems[indexPath.row]
        cell.setModel(model: model)
        return cell
        //return setCell(items: dataItems, indexPath: indexPath)
    }
    
    //tableviewcell選択時の処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sendData = dataItems[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: SegueId.fromTagListToTagDetailList.rawValue, sender: nil)
    }
    //tableviewをスクロールしたら最下のcellにたどり着く前にデータ更新を行う
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
                
        if distanceFromBottom < height && isNotLoading {
            isNotLoading = false
            pageCount += 1
            tagListDataRequest.pageNumber = pageCount
            getTagListData(requestTagListData: tagListDataRequest)
        }
    }
}

extension TagListViewController: ErrorDelegate {
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
        guard let nib = Bundle.main.loadNibNamed("ErrorView", owner: self, options: nil) else { return }
        let errorView = nib.first as! ErrorView
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
        getTagListData(requestTagListData: tagListDataRequest)
    }
        
}

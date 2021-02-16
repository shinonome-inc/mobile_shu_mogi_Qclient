//
//  TagListViewController.swift
//  Qcli
//
//  Created by 吉田周平 on 2020/11/16.
//

import UIKit



class TagListViewController: UIViewController {
    
    @IBOutlet weak var tagListCollectionView: UICollectionView!
    //最初に取得する記事欄のデータ
    var dataItems = [TagData]() {
        didSet {
            tagListCollectionView.reloadData()
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
    //set refreshControl
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tagListDataRequest = TagDataNetworkService(sortDict: [QueryOption.sort:SortOption.count])
        tagListDataRequest.errorDelegate = self
        getTagListData(requestTagListData: tagListDataRequest)
        
        //set refresh control
        tagListCollectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
       
    //apiを叩きデータを保存する
    func getTagListData(requestTagListData: TagDataNetworkService) {
        requestTagListData.fetch(success: { (tagListData) in
            tagListData?.forEach{ (oneTagData) in
                if let title = oneTagData.id,
                   let imageUrl = oneTagData.iconUrl,
                   let itemCount = oneTagData.itemsCount,
                   let followersCount = oneTagData.followersCount {
                    let oneData = TagData(tagTitle: title, imageURL: imageUrl, itemCount: itemCount, followersCount: followersCount)
                    self.dataItems.append(oneData)
                } else {
                    print("ERROR: This data ↓ allocation failed.")
                    print(oneTagData)
                }
            }
            self.tagListCollectionView.reloadData()
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
        refreshControl.endRefreshing()
    }
}
extension TagListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = tagListCollectionView.dequeueReusableCell(withReuseIdentifier: "tagCell", for: indexPath) as? TagListCollectionViewCell else {
            abort()
        }
        let model = dataItems[indexPath.row]
        cell.setModel(model: model)
        return cell
        //return setCell(items: dataItems, indexPath: indexPath)
    }
    
    //collectionViewcell選択時の処理
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        sendData = dataItems[indexPath.row]
        collectionView.deselectItem(at: indexPath, animated: true)
        performSegue(withIdentifier: SegueId.fromTagListToTagDetailList.rawValue, sender: nil)
    }
    //collectionViewをスクロールしたら最下のcellにたどり着く前にデータ更新を行う
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
        getTagListData(requestTagListData: tagListDataRequest)
    }
        
}

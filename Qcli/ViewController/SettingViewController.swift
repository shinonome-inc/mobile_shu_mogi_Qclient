//
//  SettingViewController.swift
//  Qcli
//
//  Created by 吉田周平 on 2021/02/07.
//

import UIKit

class SettingViewController: UIViewController {
    @IBOutlet weak var settingTableView: UITableView!
    let sectionList = ["アプリ情報", "その他"]
    let appInfoList = AppInfoCellType.allCases
    let otherList = OtherCellType.allCases
    let userInfoKeychain = KeyChain()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingTableView.reloadData()
        //delete tableview footter sepalator
        settingTableView.tableFooterView = UIView()
    }
    
    func tappedPPCell() {
        performSegue(withIdentifier: SegueId.fromSettingToPrivacyPolicy.rawValue, sender: nil)
    }
    
    func tappedTOSCell() {
        performSegue(withIdentifier: SegueId.fromSettingToTermsOfService.rawValue, sender: nil)
    }
    
    func tappedLogout() {
        userInfoKeychain.remove()
        let webViewData = WebViewData()
        webViewData.deleteCache()
        let identifier = ViewControllerIdentifier.login.rawValue
        if let storyboard = self.storyboard,
           let navigationController = self.navigationController {
            let loginViewController = storyboard.instantiateViewController(identifier: identifier) as! LoginViewController
            navigationController.pushViewController(loginViewController, animated: true)
        }
    }
}

extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionList.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionList[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return appInfoList.count
        } else if section == 1 {
            return otherList.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let appInfoCellType = AppInfoCellType(rawValue: indexPath.row) else { abort() }
            switch appInfoCellType {
            case .pp:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "SegueTableViewCell", for: indexPath) as? SegueTableViewCell else {
                    fatalError()
                }
                cell.titleLabel.text = appInfoCellType.titleMessage
                return cell
            case .tos:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "SegueTableViewCell", for: indexPath) as? SegueTableViewCell else {
                    fatalError()
                }
                cell.titleLabel.text = appInfoCellType.titleMessage
                return cell
            case .ver:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "RightDetailTableViewCell", for: indexPath) as? RightDetailTableViewCell else {
                    fatalError()
                }
                cell.titleLabel.text = appInfoCellType.titleMessage
                let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
                cell.versionLabel.text = "v\(version)"
                return cell
            }
        } else if indexPath.section == 1 {
            guard let otherCellType = OtherCellType(rawValue: indexPath.row) else { abort() }
            switch otherCellType {
            case .logout:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "SimpleTitleTableViewCell", for: indexPath) as? SimpleTitileTableViewCell else {
                    fatalError()
                }
                cell.titleLabel.text = otherCellType.titleMessage
                return cell
            }
        }
        fatalError("Unexpected inconsistency in \(#function)")
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let myLabel = UILabel()
        myLabel.frame = CGRect(x: 16, y: 32, width: 320, height: 20)
        myLabel.font = UIFont.boldSystemFont(ofSize: 12)
        myLabel.textColor = .gray
        myLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        
        let headerView = UIView()
        headerView.frame = CGRect(x: 0, y: 0, width: 320, height: 60)
        headerView.backgroundColor = Palette.settingBackgroundColor
        headerView.addSubview(myLabel)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            switch AppInfoCellType(rawValue: indexPath.row) {
            case .pp:
                tappedPPCell()
            case .tos:
                tappedTOSCell()
            case .ver:
                break
            default:
                break
            }
        } else if indexPath.section == 1 {
            switch OtherCellType(rawValue: indexPath.row) {
            case .logout:
                tappedLogout()
            default:
                break
            }
        }
    }
}

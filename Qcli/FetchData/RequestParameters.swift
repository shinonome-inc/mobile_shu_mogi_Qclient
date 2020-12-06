//
//  RequestParameters.swift
//  Qcli
//
//  Created by 吉田周平 on 2020/12/05.
//

import Foundation

class RequestParameters {
    var dataType: DataType!
    private let baseUrl = "https://qiita.com/api/v2/"
    var url = ""
    var pageNumber: Int?
    var perPageNumber: Int?
    var searchDict: [SearchOption:String]?
    var sortdict: [QueryOption:SortOption]?
    var userInfo: qiitaUserInfo?
    init(dataType: DataType,
         pageNumber: Int?,
         perPageNumber: Int?,
         searchDict: [SearchOption:String]?,
         sortdict: [QueryOption:SortOption]?,
         userInfo: qiitaUserInfo?) {
        self.dataType = dataType
        self.pageNumber = pageNumber
        self.perPageNumber = perPageNumber
        self.searchDict = searchDict
        self.sortdict = sortdict
        self.userInfo = userInfo
        self.url = baseUrl + self.dataType.rawValue
    }
}

//
//  QueryItem.swift
//  Qcli
//
//  Created by 吉田周平 on 2020/11/25.
//

import Foundation

enum QueryOption: String {
    case page = "page"
    case perPage = "per_page"
    case query = "query"
}

class QItem {
    func setPage(pageValue: String) -> URLQueryItem {
        return URLQueryItem(name: QueryOption.page.rawValue, value: pageValue)
    }

    func setPerPage(perPageValue: String) -> URLQueryItem {
        return URLQueryItem(name: QueryOption.perPage.rawValue, value: perPageValue)
    }

    func setQuery(queryValue: String) -> URLQueryItem {
        return URLQueryItem(name: QueryOption.query.rawValue, value: queryValue)
    }

    func initQuery() -> [URLQueryItem] {
        let export = [
            setPage(pageValue: "1"),
            setPerPage(perPageValue: "20")
        ]
        return export
    }

    func searchQuery(cOption: QueryOption, queryValue: String) -> [URLQueryItem] {
        let export = [
            setPage(pageValue: "1"),
            setPerPage(perPageValue: "20"),
            setQuery(queryValue: queryValue)
        ]
        return export
    }

}

//urlのエンコードを簡単に行う
extension String {
    
    var urlEncoded: String {
        // 半角英数字 + "/?-._~" のキャラクタセットを定義
        let charset = CharacterSet.alphanumerics.union(.init(charactersIn: "/?-._~"))
        // 一度すべてのパーセントエンコードを除去(URLデコード)
        let removed = removingPercentEncoding ?? self
        // あらためてパーセントエンコードして返す
        return removed.addingPercentEncoding(withAllowedCharacters: charset) ?? removed
    }
}

//struct QItem {
//    
//    func setPage(pageValue: String) -> URLQueryItem {
//        return URLQueryItem(name: QueryOption.page.rawValue, value: pageValue)
//    }
//    
//    func setPerPage(perPageValue: String) -> URLQueryItem {
//        return URLQueryItem(name: QueryOption.perPage.rawValue, value: perPageValue)
//    }
//    
//    func setQuery(option: QueryOption, optionValue: String) -> URLQueryItem {
//        return URLQueryItem(name: option.rawValue, value: optionValue)
//    }
//    
//    mutating func initQuery() -> [URLQueryItem] {
//        let export = [
//            setPage(pageValue: "1"),
//            setPerPage(perPageValue: "20")
//        ]
//        return export
//    }
//    
//    mutating func searchQuery(cOption: QueryOption, cOptionValue: String) -> [URLQueryItem] {
//        let export = [
//            setPage(pageValue: "1"),
//            setPerPage(perPageValue: "20"),
//            setQuery(option: cOption, optionValue: cOptionValue)
//        ]
//        return export
//    }
//    
//    mutating func customQuery(cPage: String, cPerPage: String, cOption: QueryOption, cOptionValue: String) -> [URLQueryItem] {
//        let export = [
//            setPage(pageValue: cPage),
//            setPerPage(perPageValue: cPerPage),
//            setQuery(option: cOption, optionValue: cOptionValue)
//        ]
//        return export
//    }
//}

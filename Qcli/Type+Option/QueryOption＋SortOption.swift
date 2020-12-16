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
    case sort = "sort"
}

enum SortOption: String {
    case count = "count"
    case name = "name"
}

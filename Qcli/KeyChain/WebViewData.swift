//
//  WebViewData.swift
//  Qcli
//
//  Created by 吉田周平 on 2021/02/11.
//

import WebKit

class WebViewData {
    func deleteCache() {
        print("🚮 Delete Webview Data Cache")
        WKWebsiteDataStore.default().removeData(
            ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
            modifiedSince: Date(timeIntervalSince1970: 0),
            completionHandler: {})
    }
}

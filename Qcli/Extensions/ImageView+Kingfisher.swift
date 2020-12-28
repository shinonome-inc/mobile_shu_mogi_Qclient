//
//  ImageView+Kingfisher.swift
//  Qcli
//
//  Created by 吉田周平 on 2020/12/28.
//

import Kingfisher
import UIKit

extension UIImageView {
    
    public func setImage(
        with resource: Resource?,
        placeholder: Placeholder? = nil,
        options: KingfisherOptionsInfo? = nil,
        progressBlock: DownloadProgressBlock? = nil,
        completionHandler: ((Result<RetrieveImageResult, KingfisherError>) -> Void)? = nil) {
        
        kf.setImage(
            with: resource,
            placeholder: placeholder,
            options: options,
            progressBlock: progressBlock,
            completionHandler: completionHandler)
    }
}

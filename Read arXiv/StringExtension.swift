//
//  StringExtension.swift
//  Read arXiv
//
//  Created by Frederick Morlock on 8/16/19.
//  Copyright © 2019 Frederick Morlock. All rights reserved.
//

import Foundation

extension String {
    func truncate(length: Int, trailing: String = "…") -> String {
        if self.count > length {
            return String(self.prefix(length)) + trailing
        } else {
            return self
        }
    }
}

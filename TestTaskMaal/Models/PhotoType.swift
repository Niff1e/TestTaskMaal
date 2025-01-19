//
//  PhotoType.swift
//  TestTaskMaal
//
//  Created by Pavel Maal on 16.01.25.
//

import Foundation

class PhotoType: Codable {
    let content: [PhotoTypeContent]
    let page: Int
    let pageSize: Int
    let totalElements: Int
    let totalPages: Int
}

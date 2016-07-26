//
//  SearchableRecord.swift
//  Timeline
//
//  Created by Brad on 7/26/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation

@objc protocol SearchableRecord {
    func matchesSearchTerm(searchTerm: String) -> Bool
}
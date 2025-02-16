//
//  Item.swift
//  Sparkle
//
//  Created by Philip Brembeck on 16.02.25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}

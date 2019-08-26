//
//  File.swift
//  TO-DO-List
//
//  Created by Ivan on 03/07/2019.
//  Copyright © 2019 Ivan. All rights reserved.
//

import Foundation

class Task {
    var descriptionText: String
    var titleText: String
    
    init(title:String, description:String) {
        self.titleText = title
        self.descriptionText = description
    }
}

//class TaskRealm: Object {
//    @objc dynamic var description = ""
//    @objc dynamic var title = ""
//}

//
//  News.swift
//  MyUnimol
//
//  Created by Giovanni Grano on 19/03/16.
//  Copyright © 2016 Giovanni Grano. All rights reserved.
//

import Gloss

public struct News: Decodable {
    
    let date: String?
    let title: String?
    let text: String?
    let link: String?
    
    public init(json: JSON) {
        self.date = "date" <~~ json
        self.title = "title" <~~ json
        self.text = "text" <~~ json
        self.link = "link" <~~ json
    }
}

public struct NewsList {
    
    var newsList = [News]()
    
    init(json: JSON) {
        self.newsList = [News].fromJSONArray(("newsList" <~~ json)!)
    }
}

public class NewsClass {
    
    public static let sharedInstance = NewsClass()
    
    public var news: NewsList?
    
    private init() { }
}

//
//  MemeModel.swift
//  MemeMe
//
//  Created by felix on 8/7/16.
//  Copyright © 2016 Felix Chen. All rights reserved.
//

import Foundation

class MemeModel {
    var memeList = [Meme]()
    
    func append(meme: Meme) {
        memeList.append(meme)
    }
    
    func remove(index: Int) {
        memeList.removeAtIndex(index)
    }
    
    func count() -> Int {
        return memeList.count
    }
    
    func getItemAt(index: Int) -> Meme? {
        return index >= 0 && index < memeList.count ? memeList[index] : nil
    }
}

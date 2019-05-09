//
//  MADPlayerManager.swift
//  Madpac
//
//  Created by Kevin van den Hoek on 29/07/2018.
//  Copyright © 2018 Kevin van den Hoek. All rights reserved.
//

import AVFoundation

class MADPlayerManager {
    
    static var shared: MADPlayerManager = { return MADPlayerManager() }()
    
    private var players: [MADPost: MADPlayer] = [:]
    
    init() {
        
    }
    
    func getPlayer(for post: MADPost) -> MADPlayer {
        if let player = players[post] {
            return player
        } else {
            let newPlayer = MADPlayer(from: post)
            players[post] = newPlayer
            return newPlayer
        }
    }
    
}

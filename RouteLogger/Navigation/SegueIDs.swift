//
//  SegueIDs.swift
//  RouteLogger
//
//  Created by Vladyslav Bugrym on 02.11.2020.
//  Quality Assurance by Kateryna Galushka
//

import UIKit

enum SegueIdentifier {
    
    enum MapViewScreen:String {
        case userProfile = "toUserProfileScreen", routeHistory = "toRouteHistoryScreen"
    }
    
    enum UserProfileScreen:String {
        case pop
    }
    
    enum RouteHistoryScreen:String {
        case routeMap = "toRouteMapScreen", pop
    }
}

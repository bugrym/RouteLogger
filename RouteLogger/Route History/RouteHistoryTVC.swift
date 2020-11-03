//
//  RouteHistoryTVC.swift
//  RouteLogger
//
//  Created by Vladyslav Bugrym on 02.11.2020.
//

import UIKit
import RealmSwift

class RouteHistoryTVC:UITableViewController {
    
    private var dataSource:[LocationModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createDataSource()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = UITableViewCell()
//        cell.description = self.dataSource[indexPath.row].dates.first
//    }
    
    private func createDataSource() {
        let realm = try! Realm()
        try! realm.write {
            let routes = realm.objects(LocationModel.self)
            self.dataSource.append(contentsOf: routes)
        }
    }
    
}

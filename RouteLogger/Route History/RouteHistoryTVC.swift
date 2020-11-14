//
//  RouteHistoryTVC.swift
//  RouteLogger
//
//  Created by Vladyslav Bugrym on 02.11.2020.
//

import UIKit
import RealmSwift

final class RouteHistoryTVC:UITableViewController {
    
    private var dataSource:[LocationModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorStyle = .none
        self.createDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.backButtonTitle = "History"
        let rightItem = UIBarButtonItem(image: UIImage(named: "trash"), style: .plain, target: self, action: #selector(deleteAllTapped(_:)))
        navigationItem.rightBarButtonItem = rightItem
    }
    
    @objc private func deleteAllTapped(_ sender:UIBarButtonItem) {
        DispatchQueue.main.async { [weak self] in
            guard let strSelf = self else { return }
            strSelf.present(AlertFactory.deleteAllRoutes {
                strSelf.deleteAllRecordInDB()
                strSelf.tableView.reloadData()
            }, animated: true, completion: nil)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss"
        cell.textLabel?.text = dateFormatter.string(from: self.dataSource[indexPath.row].dates.first!)
        cell.imageView?.image = UIImage(named: "route")
        
        
        //Returns route time in seconds
        /*
         print(self.dataSource[indexPath.row].dates.last!.timeIntervalSince(self.dataSource[indexPath.row].dates.first!))*/
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: SegueIdentifier.RouteHistoryScreen.routeMap.rawValue, sender: self)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: "") { [weak self] (_, _, _) in
            guard let strSelf = self else { return }
            strSelf.deleteRecordInDB(with: indexPath)
            strSelf.dataSource.remove(at: indexPath.row)
            strSelf.tableView.beginUpdates()
            strSelf.tableView.deleteRows(at: [indexPath], with: .fade)
            strSelf.tableView.endUpdates()
        }
        
        let likeAction = UIContextualAction(style: .normal, title: "") { [weak self] (view, _, _) in
            guard let strSelf = self else { return }
            let realm = try! Realm()
            try! realm.write {
                let objects = realm.objects(LocationModel.self)
                let currentObject = objects[indexPath.row]
                
                if !currentObject.isFavorite {
                    currentObject.isFavorite = true
                    view.image = UIImage(named: "like")
                    print("now is favorite")
                } else {
                    currentObject.isFavorite = false
                    view.image = UIImage(named: "unlike")
                    print("now is not favorite")
                }
            }
        }
        
        deleteAction.image = UIImage(named: "trash-cell")
        deleteAction.backgroundColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
        likeAction.image = UIImage(named: "unlike")
        likeAction.backgroundColor = .white
        
        let swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction, likeAction])
        return swipeConfig
    }
    
    private func createDataSource() {
        let realm = try! Realm()
        try! realm.write { [weak self] in
            guard let strSelf = self else { return }
            let routes = realm.objects(LocationModel.self)
            strSelf.dataSource.append(contentsOf: routes)
        }
    }
    
    private func createFavoriteDataSource() {
        let realm = try! Realm()
        try! realm.write { [weak self] in
            guard let strSelf = self else { return }
            let routes = realm.objects(LocationModel.self)
            for route in routes.filter("isFavorite == true") {
                strSelf.dataSource.append(route)
            }
        }
    }
    
    private func deleteRecordInDB(with index:IndexPath) {
        let realm = try! Realm()
        try! realm.write { [weak self] in
            guard let strSelf = self else { return }
            realm.delete(strSelf.dataSource[index.row])
        }
    }
    
    private func deleteAllRecordInDB() {
        let realm = try! Realm()
        try! realm.write { [weak self] in
            guard let strSelf = self else { return }
            realm.deleteAll()
            strSelf.dataSource = []
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifier.RouteHistoryScreen.routeMap.rawValue {
            if let destination = segue.destination as? RouteMapVC, let indexPath = self.tableView.indexPathForSelectedRow {
                destination.locationModel = self.dataSource[indexPath.row]
            }
        }
    }
}

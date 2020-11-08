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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.backButtonTitle = "History"
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
        cell.textLabel?.text = dateFormatter.string(from: self.dataSource[indexPath.row].dates.first ?? Date())
        cell.imageView?.image = UIImage(named: "mainLogo")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: SegueIdentifier.RouteHistoryScreen.routeMap.rawValue, sender: self)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.deleteRecordInDB(with: indexPath)
            self.dataSource.remove(at: indexPath.row)
            self.tableView.beginUpdates()
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            self.tableView.endUpdates()
        }
    }
    
    private func createDataSource() {
        let realm = try! Realm()
        try! realm.write { [weak self] in
            guard let strSelf = self else { return }
            let routes = realm.objects(LocationModel.self)
            strSelf.dataSource.append(contentsOf: routes)
        }
    }
    
    private func deleteRecordInDB(with index:IndexPath) {
        let realm = try! Realm()
        try! realm.write { [weak self] in
            guard let strSelf = self else { return }
            realm.delete(strSelf.dataSource[index.row])
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

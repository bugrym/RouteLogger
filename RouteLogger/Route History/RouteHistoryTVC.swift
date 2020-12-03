//
//  RouteHistoryTVC.swift
//  RouteLogger
//
//  Created by Vladyslav Bugrym on 02.11.2020.
//  Quality Assurance by Kateryna Galushka
//

import UIKit
import RealmSwift

final class RouteHistoryTVC:UIViewController {
    
    @IBOutlet weak var segmentedControl:UISegmentedControl!
    @IBOutlet weak var tableView:UITableView!
    
    private var dataSource:[LocationModel] = []
    private var favoriteDataSource:[LocationModel] = []
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorStyle = .none
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.rowHeight = 70
        self.segmentedControl.addTarget(self, action: #selector(toggleSegment(_:)), for: .valueChanged)
        self.toggleStates()
        
        if #available(iOS 10.0, *) {
            self.tableView.refreshControl = refreshControl
            self.refreshControl.tintColor = #colorLiteral(red: 0.4666666667, green: 0.7647058824, blue: 0.2666666667, alpha: 1)
            self.refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        } else {
            self.tableView.addSubview(refreshControl)
            self.refreshControl.tintColor = #colorLiteral(red: 0.4666666667, green: 0.7647058824, blue: 0.2666666667, alpha: 1)
            self.refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        }
        
    }
    
    @objc private func refresh() {
        self.refreshControl.beginRefreshing()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        self.refreshControl.endRefreshing()
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
    
    @objc private func toggleSegment(_ sender:UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 1:
            self.favoriteDataSource = []
            self.createFavoriteDataSource()
            DispatchQueue.main.async { [weak self] in
                guard let strSelf = self else { return }
                strSelf.tableView.reloadData()
            }
        default:
            self.dataSource = []
            self.createDataSource()
            DispatchQueue.main.async { [weak self] in
                guard let strSelf = self else { return }
                strSelf.tableView.reloadData()
            }
        }
    }
    
    private func toggleStates() {
        switch self.segmentedControl.selectedSegmentIndex {
        case 1:
            self.favoriteDataSource = []
            self.createFavoriteDataSource()
            DispatchQueue.main.async { [weak self] in
                guard let strSelf = self else { return }
                strSelf.tableView.reloadData()
            }
        default:
            self.dataSource = []
            self.createDataSource()
            DispatchQueue.main.async { [weak self] in
                guard let strSelf = self else { return }
                strSelf.tableView.reloadData()
            }
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
    
    private func createFavoriteDataSource() {
        let realm = try! Realm()
        try! realm.write { [weak self] in
            guard let strSelf = self else { return }
            let routes = realm.objects(LocationModel.self)
            for route in routes.filter("isFavorite == true") {
//                strSelf.dataSource.append(route)
                strSelf.favoriteDataSource.append(route)
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

extension RouteHistoryTVC:UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.segmentedControl.selectedSegmentIndex {
        case 1:
            return self.favoriteDataSource.count
        default:
            return self.dataSource.count
        }
//        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        let cell = UITableViewCell()
        //        let dateFormatter = DateFormatter()
        //        dateFormatter.dateFormat = "E, d MMM HH:mm:ss"
        //        cell.textLabel?.text = dateFormatter.string(from: self.dataSource[indexPath.row].dates.first!)
        //        cell.imageView?.image = UIImage(named: "route")
        
        //        cell.textLabel?.text = "Route time interval: \(self.dataSource[indexPath.row].timerInterval)"
        
        //Returns route time in seconds
        /*
         print(self.dataSource[indexPath.row].dates.last!.timeIntervalSince(self.dataSource[indexPath.row].dates.first!))*/
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM HH:mm:ss"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: RouteCell.reuseIdentifier, for: indexPath) as! RouteCell
        cell.iconImageView.image = UIImage(named: "route")
//        cell.iconImageView.image = UIImage(named: "route-pin")
//        cell.iconImageView.image = UIImage(named: "tracking")
        cell.dateTitle.text = dateFormatter.string(from: self.dataSource[indexPath.row].dates.first!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: SegueIdentifier.RouteHistoryScreen.routeMap.rawValue, sender: self)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
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
        deleteAction.backgroundColor = .red
        likeAction.image = UIImage(named: "unlike")
        likeAction.backgroundColor = .white
        
        let swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction, likeAction])
        return swipeConfig
    }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        DispatchQueue.main.async {
            guard let indexPath = indexPath else { return }
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}

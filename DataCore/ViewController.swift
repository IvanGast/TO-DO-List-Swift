//
//  ViewController.swift
//  TO-DO-List
//
//  Created by Ivan on 02/07/2019.
//  Copyright © 2019 Ivan. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var toDoList:[Task] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveData()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ToDoTableViewCell
        if toDoList[indexPath.row].titleText == "" {
            toDoList[indexPath.row].titleText = "Task \(indexPath.row + 1)"
            cell.titleLabel.text = "Task \(indexPath.row + 1)"
        } else {
            cell.titleLabel.text = toDoList[indexPath.row].titleText
        }
        cell.descriptionLabel.text = toDoList[indexPath.row].descriptionText
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteData(taskToDelete: toDoList[indexPath.row])
            toDoList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "submit", sender: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func retrieveData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Tasked")
        do {
            let result = try context.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                toDoList.append(Task(title: data.value(forKey: "titleText") as! String,
                                     description: data.value(forKey: "descriptionText") as! String))
            }
        } catch {
            print("Retrieving data failed")
        }
    }
    
    func deleteData(taskToDelete: Task) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Tasked")
        fetchRequest.predicate = NSPredicate(format: "descriptionText = %@", taskToDelete.descriptionText)
        do {
            let test = try context.fetch(fetchRequest)
            let objectToDelete = test[0] as! NSManagedObject
            context.delete(objectToDelete)
            do {
                try context.save()
            } catch {
                print(error)
            }
        } catch {
            print(error)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let submitViewController = segue.destination as! SubmitViewController
        submitViewController.listViewController = self
        if sender is Int {
            submitViewController.submiting = false
            submitViewController.index = sender as? Int
        } else {
            submitViewController.submiting = true
        }
    }
}

//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var itemArray = [Item]()
    var selectedCategory:Category? {
        didSet{
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //loadItems()
    }
    
    //MARK:- TableViewDataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        
        cell.textLabel?.text = itemArray[indexPath.row].title
        cell.accessoryType = itemArray[indexPath.row].done ? .checkmark : .none
        
        return cell
    }
    
    //MARK:- TableViewDelegateMethods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        tableView.deselectRow(at: indexPath, animated: true)
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        do{
            try context.save()
        }catch{
            print("Error updating tick")
        }
        loadItems()
        tableView.reloadData()
        
    }
    
    //MARK:- IBActions
    @IBAction func AddItem(_ sender: UIBarButtonItem) {
        var textField1 = UITextField()
        let alert = UIAlertController(title: "Add", message: "Add new item", preferredStyle:.alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: { action in
            self.saveItems(itemTitle: textField1.text,itemDone: false)
        })
        alert.addAction(action)
        alert.addTextField { (textField) in
            textField.placeholder = "Create New Item"
            textField1 = textField
        }
        present(alert, animated: true, completion: nil)
    }
    
    func saveItems(itemTitle:String?, itemDone:Bool){
        let newItem = Item(context: self.context)
        newItem.title = itemTitle
        newItem.done = false
        newItem.parentCategory = self.selectedCategory
        do{
            try self.context.save()
            print("Data saved Successfully")
        }
        catch{
            print("Error Saving Data")
        }
        loadItems()
        tableView.reloadData()
    }
    
    
    
    func loadItems(with request:NSFetchRequest<Item> = Item.fetchRequest(), predicate:NSPredicate? = nil){
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let searchPredicate = predicate{
            let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate,searchPredicate])
            request.predicate = compoundPredicate
        }else{
            request.predicate = categoryPredicate
        }
        do{
            itemArray = try context.fetch(request)
        }catch{
            print("Error Fetching Data")
        }
        tableView.reloadData()
    }

}
//MARK:- SearchBarMethods
extension TodoListViewController:UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request:NSFetchRequest<Item> = Item.fetchRequest()
        let predecate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        loadItems(with: request,predicate:predecate)
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText.count == 0) {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
    }
}


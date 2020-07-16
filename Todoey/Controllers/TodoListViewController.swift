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
    var itemArray = [Item] ()
    var selectedCategory: Category? {
        didSet {
            // это специальная структура, которая будет вызвана как только эта переменная получит значение
            loadItems()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
         //self.loadItems()
        //  Do any additional setup after loading the view.
        /*
        if let items = defaults.array(forKey: "todoList") as? [Item] {
             itemArray = items
            // method to get destination of db file .plist
            
         print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last! as String)
        }
 */
        
        
        print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last! as String)
        // way how to create files proggramaticaly in Swift
        
    }
//MARK: - TableDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        
        cell.textLabel?.text = itemArray[indexPath.row].title
        cell.accessoryType = itemArray[indexPath.row].done ? .checkmark : .none // тернарник в свифте такой жке как и в js
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Animated flashing effect when clicked
        tableView.deselectRow(at: indexPath, animated: true)
        //Example how to delete:
        /*
        context.delete(itemArray[indexPath.row]) // remove from array, then from DB:
        itemArray.remove(at: indexPath.row)
         */
        // но просто удалить с контекста не достаточно, так как это временная переменная и ее изменения неотобразятся в БД, для этого нам надо вызвать метод для сохравнения текущего контекста в БД:
        self.saveItems()
        //Example how to update:
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        //Update meyhod - same as save method use it self.saveItems()
        tableView.reloadData()
    }
   
    @IBAction func AddNewItemButtonPressed(_ sender: UIBarButtonItem) {
        var textInput = UITextField()
        let alert = UIAlertController.init(title: "Add new item to the list", message: "", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "add new", style: .default) { (action) in
            //code, what happen when user clicks "add button"
            //CoreData using:
            
            
            // то как мы получаем доступ к appdelegate (UIApplication.shared.delegate as! AppDelegate) как к объекту
            let newItem = Item(context: self.context)// Core data class
            newItem.title = textInput.text!
            newItem.parentCategory = self.selectedCategory
            self.itemArray.append(newItem)
            self.saveItems()
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Name of new item"
            textInput = textField
        }
        alert.addAction(alertAction)
        present(alert, animated: true, completion: nil)
    }
    func saveItems() {
         do {
            // при любых вносимых изменениях в бд, следует пересохранять контекст.
            try context.save()
         } catch {
             print("Error: \(error)")
         }
        
         self.tableView.reloadData()
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil)  {
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        if let additionalPredicate = predicate {
            //по скольку у нас так же используется предикейт для поиска, то нам надо скомпоновать оба, для того чтоб вывести те которые относятся к категории и те которые мы ищем

            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [additionalPredicate, categoryPredicate])
            print(request.predicate)
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
            itemArray = try context.fetch(request)
        }catch {
            print("Error: \(error)")
        }
        self.tableView.reloadData()
    }
    
}
//MARK: - UISearchBarDelegate

extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        //request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        // все что касается поля формат можно почтитать тут https://academy.realm.io/posts/nspredicate-cheatsheet/
        // в данном случае это говорит о поле в котором содержится значение аргумента(%@  вместо этих символов подставится значение  аргумента)
        // сортировка результатов
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        // присвоение  массиву с данными для последующего вывода в списке
        loadItems(with: request, predicate: predicate)
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                //после очистки поля убираем клавиатуры и снимаем выделение с серчбара
                searchBar.resignFirstResponder()
            }
            
        }
    }
}


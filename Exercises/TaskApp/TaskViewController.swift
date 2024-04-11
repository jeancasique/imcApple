//
//  TaskViewController.swift
//  Exercises
//
//  Created by Mañanas on 11/4/24.
//

import UIKit

class TaskViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    

    @IBOutlet weak var taskTableView: UITableView!
    
    
    var tasks: [Task] = [
            Task(title: "Tarea de ejemplo 1", isCompleted: false),
            Task(title: "Tarea de ejemplo 2", isCompleted: true)
        ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        taskTableView.dataSource = self
        taskTableView.delegate = self
    }
    
    // DataSource methods
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            // Aquí retornarás el número de tareas
            return tasks.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            // Aquí configurarás y retornarás cada celda de la lista
            let cell = taskTableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)
            cell.textLabel?.text = tasks[indexPath.row].title
            return cell
        }
    
}

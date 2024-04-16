import UIKit

class TaskViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    // OUTLETS
    @IBOutlet weak var taskTableView: UITableView!
    @IBOutlet weak var searchNota: UISearchBar!
    
    // PROPERTIES
    var tasks: [String] = []
    var filteredTasks: [String] = []
    var isFiltering: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        taskTableView.dataSource = self
        taskTableView.delegate = self
        searchNota.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(loadTasks), name: NSNotification.Name("TaskUpdated"), object: nil)
        loadTasks()
    }
    //METODOS 
    @objc func loadTasks() {
        tasks = UserDefaults.standard.array(forKey: "tasks") as? [String] ?? []
        taskTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isFiltering ? filteredTasks.count : tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)
        let taskText = isFiltering ? filteredTasks[indexPath.row] : tasks[indexPath.row]
        let firstWord = taskText.components(separatedBy: " ").first ?? "New Task"
        cell.textLabel?.text = firstWord
        cell.textLabel?.textColor = .white
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tasks.remove(at: indexPath.row)
            UserDefaults.standard.set(tasks, forKey: "tasks")
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Tareas"
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "crearNota", sender: indexPath)
    }
    
    @IBAction func addTaskButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "crearNota", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "crearNota",
           let destinationVC = segue.destination as? NotaViewController,
           let indexPath = sender as? IndexPath {
            // Verifica si la lista está siendo filtrada y obtiene la tarea correcta
            let selectedTask = isFiltering ? filteredTasks[indexPath.row] : tasks[indexPath.row]
            destinationVC.temporalTaskText = selectedTask
            destinationVC.isNewTask = false
            destinationVC.taskIndex = isFiltering ? tasks.firstIndex(of: selectedTask) : indexPath.row
        } else if segue.identifier == "crearNota" {
            let destinationVC = segue.destination as? NotaViewController
            destinationVC?.isNewTask = true
        }
    }
    
    // Search Bar Delegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isFiltering = false
        } else {
            filteredTasks = tasks.filter { $0.lowercased().contains(searchText.lowercased()) }
            isFiltering = true
        }
        taskTableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isFiltering = false
        searchBar.text = ""
        taskTableView.reloadData()
    }
}


import UIKit

class IMCTableViewController: UITableViewController {
    
    
    var historialIMC: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let guardadoHistorialIMC = UserDefaults.standard.array(forKey: "historialIMC") as? [String] {
            historialIMC = guardadoHistorialIMC
        }
        tableView.allowsMultipleSelectionDuringEditing = false
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historialIMC.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistorialCell", for: indexPath)

        cell.textLabel?.text = historialIMC[indexPath.row]

        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Eliminar el IMC del historial
            historialIMC.remove(at: indexPath.row)
            
            // Actualizar UserDefaults
            UserDefaults.standard.set(historialIMC, forKey: "historialIMC")
            
            // Eliminar la celda de la tabla
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    
}


import UIKit

class NotaViewController: UIViewController, UITextViewDelegate {
    
    // OUTLETS
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var buttonCheck: UIBarButtonItem!

    
    // PROPERTIES
    
    var isNewTask = true
    var temporalTaskText: String?
    var taskIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.delegate = self
        textView.becomeFirstResponder()
        
        if let text = temporalTaskText {
            textView.text = text
        }
        
        self.navigationController?.navigationBar.tintColor = UIColor.systemYellow
    }
    
    //METODOS
    
    @IBAction func insertDot(_ sender: UIBarButtonItem) {
        // Inserta un punto "· " en la posición actual del cursor en el textView
        if let selectedRange = textView.selectedTextRange {
            textView.replace(selectedRange, withText: "· ")
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        // Guarda el texto cada vez que cambia para mantener una "versión en progreso"
        UserDefaults.standard.set(textView.text, forKey: "currentTask")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Asegura guardar o actualizar la tarea solo si hay contenido en el textView
        guard !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        saveOrUpdateTask()
        
        // Notifica al viewController principal que las tareas han sido actualizadas
        NotificationCenter.default.post(name: NSNotification.Name("TaskUpdated"), object: nil)
    }
    
    // Guarda o actualiza la tarea dependiendo si es nueva o una edición
    func saveOrUpdateTask() {
        var currentTasks = UserDefaults.standard.array(forKey: "tasks") as? [String] ?? []
        
        if isNewTask {
            currentTasks.append(textView.text)
        } else if let index = taskIndex {
            currentTasks[index] = textView.text
        }
        
        UserDefaults.standard.set(currentTasks, forKey: "tasks")
    }

}


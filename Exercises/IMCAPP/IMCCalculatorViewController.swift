import UIKit

class IMCCalculatorViewController: UIViewController {

    @IBOutlet weak var pesoTextField: UITextField!
    @IBOutlet weak var alturaTextField: UITextField!
    @IBOutlet weak var resultadoLabel: UILabel!
    var lastCalculatedIMC: Double?
  
    @IBOutlet weak var pesoStepper: UIStepper!
    
    @IBOutlet weak var alturaStepper: UIStepper!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Asegura que los steppers estén conectados antes de configurarlos.
        if pesoStepper != nil && alturaStepper != nil {
            configureSteppers()
        } else {
            print("Uno o ambos steppers son nil. Verifica tus conexiones de IBOutlet.")
        }
    }
    
    private func configureSteppers() {
        // Configura el stepper de peso con los valores iniciales y rangos.
        pesoStepper.minimumValue = 1
        pesoStepper.maximumValue = 200
        pesoStepper.stepValue = 1
        pesoStepper.value = 75
        pesoTextField.text = "\(Int(pesoStepper.value)) kg"

        // Configura el stepper de altura con los valores iniciales y rangos.
        alturaStepper.minimumValue = 100 // 1.00 m en cm
        alturaStepper.maximumValue = 300 // 3.00 m en cm
        alturaStepper.stepValue = 1
        alturaStepper.value = 150 // Valor inicial de 1.50 m en cm
        alturaTextField.text = "\(alturaStepper.value) cm"
    }
    
    @IBAction func pesoStepperChanged(_ sender: UIStepper) {
        pesoTextField.text = "\(Int(sender.value)) kg"
    }

    @IBAction func alturaStepperChanged(_ sender: UIStepper) {
        alturaTextField.text = "\(sender.value) cm"
    }

    @IBAction func calcularIMC(_ sender: UIButton) {
        guard let pesoText = pesoTextField.text?.filter("0123456789.".contains),
                 let alturaText = alturaTextField.text?.filter("0123456789.".contains),
                 let peso = Double(pesoText),
                 let altura = Double(alturaText) else {
               resultadoLabel.text = "Por favor, ingresa valores válidos."
               return
           }
           
           let imc = peso / (pow(altura / 100, 2))
           lastCalculatedIMC = imc
           resultadoLabel.text = "Tu IMC es \(String(format: "%.2f", imc))"
           
           // Cambia el color del texto basado en el valor del IMC
           switch imc {
           case 0..<19:
               resultadoLabel.backgroundColor = UIColor.systemTeal // Celeste
           case 19..<25:
               
               resultadoLabel.backgroundColor = UIColor.systemGreen// Verde
           case 25..<30:
               
               resultadoLabel.backgroundColor = UIColor.systemYellow // Amarillo
           case 30...:
               
               resultadoLabel.backgroundColor = UIColor.systemOrange// Naranja
           default:
               resultadoLabel.textColor = UIColor.black // Color por defecto
           }
        
    }
    @IBAction func changeThemePressed(_ sender: UIButton) {
            if #available(iOS 13.0, *) {
                    let newStyle: UIUserInterfaceStyle = self.view.overrideUserInterfaceStyle == .dark ? .light : .dark
                    self.view.overrideUserInterfaceStyle = newStyle
                    UserDefaults.standard.set(newStyle.rawValue, forKey: "userInterfaceStyle")
                    UserDefaults.standard.synchronize() // Esto fuerza a guardar la preferencia inmediatamente.
                
            }
        }
    
    
    @IBAction func HistorialButton(_ sender: Any) {
    }
    
    @IBAction func shareButtonPressed(_ sender: UIButton) {
        shareIMCResult()
    }
    func shareIMCResult() {
        // Asegúrate de que esta cadena refleje el último resultado del IMC calculado.
        let imcResult = "Tu IMC es \(String(format: "%.2f", lastCalculatedIMC!))"
        let activityController = UIActivityViewController(activityItems: [imcResult], applicationActivities: nil)
        
        // Importante para iPads, define el origen del popover.
        if let popoverController = activityController.popoverPresentationController {
            popoverController.sourceView = self.view // o `sender` si estás pasando el UIButton como el sender
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        // Presenta el controlador de actividad.
        self.present(activityController, animated: true, completion: nil)
    }

}

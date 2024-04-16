import UIKit

class IMCCalculatorViewController: UIViewController {

    @IBOutlet weak var pesoTextField: UITextField!
    @IBOutlet weak var alturaTextField: UITextField!
    @IBOutlet weak var resultadoLabel: UILabel!
    var lastCalculatedIMC: Double?
    var historialIMC: [String] = []

    @IBOutlet weak var pesoStepper: UIStepper!
    
    @IBOutlet weak var alturaStepper: UIStepper!

    override func viewDidLoad() {
        super.viewDidLoad()

        if pesoStepper != nil && alturaStepper != nil {
            configureSteppers()
        } else {
            print("Uno o ambos steppers son nil. Verifica tus conexiones de IBOutlet.")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "MostrarHistorialSegue" {
                if let destinoVC = segue.destination as? IMCTableViewController {
                    destinoVC.historialIMC = self.historialIMC
                }
            }
        }
    private func configureSteppers() {
        // Configura el stepper de peso con los valores iniciales y rangos.
        //Peso
        pesoStepper.minimumValue = 1
        pesoStepper.maximumValue = 200
        pesoStepper.stepValue = 1
        pesoStepper.value = 75
        pesoTextField.text = "\(Int(pesoStepper.value)) kg"
        //Altura
        alturaStepper.minimumValue = 100
        alturaStepper.maximumValue = 300
        alturaStepper.stepValue = 1
        alturaStepper.value = 150
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
           
           // Asegúrate de que esta parte se encuentra después de la declaración y asignación de 'imc'
           let resultadoIMC = "IMC: \(String(format: "%.2f", imc)) - \(Date())"
           historialIMC.append(resultadoIMC)
        
           UserDefaults.standard.set(historialIMC, forKey: "historialIMC")
           
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
    
    @IBAction func changeThemePressed(_ sender: UIBarButtonItem) {
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
        guard let imc = lastCalculatedIMC else {
               print("IMC no calculado aún.")
               // Muestra un mensaje al usuario indicando que necesita calcular el IMC primero en modo Alert
               
               let alert = UIAlertController(title: "IMC no calculado", message: "Por favor, calcula tu IMC antes de compartirlo.", preferredStyle: .alert)
               alert.addAction(UIAlertAction(title: "OK", style: .default))
               self.present(alert, animated: true, completion: nil)
               return
           }
           
           let imcResult = "Tu IMC es \(String(format: "%.2f", imc))"
           let activityController = UIActivityViewController(activityItems: [imcResult], applicationActivities: nil)
           
           // Presenta el controlador de actividad.
           self.present(activityController, animated: true, completion: nil)}

}

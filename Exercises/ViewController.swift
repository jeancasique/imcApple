//
//  ViewController.swift
//  Exercises
//
//  Created by Jean Casique on 2/4/24.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var welcomeLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Establece el color del botón de regreso en la barra de navegación
        self.navigationController?.navigationBar.tintColor = UIColor.systemYellow
        }
   
    @IBAction func MoviesButton(_ sender: UIButton) {
    }
    
    @IBAction func calculadoraIMC(_ sender: UIButton) {
    }
    
    @IBAction func TareasButton(_ sender: UIButton) {
        }
    
    @IBAction func Login(_ sender: UIButton) {
    }
}



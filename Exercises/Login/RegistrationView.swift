import SwiftUI
import FirebaseAuth
import Firebase
import FirebaseFirestore

struct RegistrationView: View {
    @State private var name = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var birthDate = Date()
    @State private var gender = ""
    @State private var formErrors = [String: String]()

    @State private var alertMessage = ""
    @State private var showAlert = false
    @State private var shouldNavigateToLogin = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Información Personal")) {
                    TextField("Nombre", text: $name)
                    if let error = formErrors["name"] {
                        Text(error).foregroundColor(.red).font(.caption)
                    }

                    TextField("Apellidos", text: $lastName)
                    if let error = formErrors["lastName"] {
                        Text(error).foregroundColor(.red).font(.caption)
                    }

                    DatePicker("Fecha de Nacimiento", selection: $birthDate, displayedComponents: .date)

                    Picker("Sexo", selection: $gender) {
                        Text("Masculino").tag("Masculino")
                        Text("Femenino").tag("Femenino")
                    }.pickerStyle(SegmentedPickerStyle())
                    if let error = formErrors["gender"] {
                        Text(error).foregroundColor(.red).font(.caption)
                    }
                }

                Section(header: Text("Credenciales de Acceso")) {
                    TextField("Correo Electrónico", text: $email)
                    if let error = formErrors["email"] {
                        Text(error).foregroundColor(.red).font(.caption)
                    }

                    SecureField("Contraseña", text: $password)
                    if let error = formErrors["password"] {
                        Text(error).foregroundColor(.red).font(.caption)
                    }

                    SecureField("Confirmar Contraseña", text: $confirmPassword)
                    if let error = formErrors["confirmPassword"] {
                        Text(error).foregroundColor(.red).font(.caption)
                    }
                }

                Button("Crear Usuario") {
                    validateAndCreateUser()
                }
            }
            .navigationTitle("Registro")
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Registro"), message: Text(alertMessage), dismissButton: .default(Text("OK"), action: {
                    if shouldNavigateToLogin {
                        self.shouldNavigateToLogin = false
                    }
                }))
            }
            .background(NavigationLink("", destination: LoginView(), isActive: $shouldNavigateToLogin))
        }
    }

    private func validateAndCreateUser() {
        formErrors.removeAll()
        validateField("name", value: name, errorMessage: "El nombre es obligatorio.")
        validateField("lastName", value: lastName, errorMessage: "Los apellidos son obligatorios.")
        validateField("gender", value: gender, errorMessage: "El sexo es obligatorio.")
        validateField("email", value: email, errorMessage: "El correo electrónico es obligatorio.", validation: isValidEmail)
        validateField("password", value: password, errorMessage: "La contraseña es obligatoria.", validation: isValidPassword)
        if password != confirmPassword {
            formErrors["confirmPassword"] = "Las contraseñas no coinciden."
        }

        if formErrors.isEmpty {
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let user = authResult?.user, error == nil {
                    saveUserData(user)
                } else {
                    alertMessage = "Error al crear el usuario: \(error?.localizedDescription ?? "")"
                    showAlert = true
                }
            }
        }
    }
    private func validateField(_ field: String, value: String, errorMessage: String, validation: ((String) -> Bool)? = nil) {
        if value.isEmpty {
            formErrors[field] = errorMessage
        } else if let validation = validation, !validation(value) {
            formErrors[field] = errorMessage
        } else {
            formErrors[field] = nil
        }
    }

    private func saveUserData(_ user: User) {
        let db = Firestore.firestore()
        let userData = [
            "firstName": name,
            "lastName": lastName,
            "birthDate": "\(birthDate)", // ISO 8601 format
            "gender": gender
        ]
        db.collection("users").document(user.uid).setData(userData) { error in
            if let error = error {
                alertMessage = "Error saving user data: \(error.localizedDescription)"
                showAlert = true
            } else {
                alertMessage = "Registro exitoso. Por favor inicia sesión con tus nuevas credenciales."
                showAlert = true
                shouldNavigateToLogin = true
            }
        }
    }

    func isValidEmail(_ email: String) -> Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: email)
    }

    func isValidPassword(_ password: String) -> Bool {
        let passwordFormat = "^(?=.*[A-Z])(?=.*\\d)[A-Za-z\\d]{5,}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordFormat)
        return passwordPredicate.evaluate(with: password)
    }
}

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView()
    }
}


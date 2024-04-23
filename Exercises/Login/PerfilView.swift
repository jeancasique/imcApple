import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class UserData: ObservableObject {
    @Published var email: String = ""
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var birthDate: Date = Date()
    @Published var gender: String = ""
    @Published var profileImage: UIImage?
}

struct PerfilView: View {
    @StateObject private var userData = UserData()
    @State private var editingField: String?
    @State private var showImagePicker = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .center, spacing: 20) {
                    Text(userData.firstName)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top, 10)

                    profileImageSection

                    HStack {
                        Text("Correo Electrónico")
                            .padding()
                            .font(.body)
                            .foregroundColor(.primary)
                        Spacer()
                        Text(userData.email)
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                    .padding(.vertical)

                    userInfoField(label: "Nombre", value: $userData.firstName, editing: $editingField, fieldKey: "firstName", editable: true)
                    userInfoField(label: "Apellidos", value: $userData.lastName, editing: $editingField, fieldKey: "lastName", editable: true)
                    datePickerField(label: "Fecha de Nacimiento", date: $userData.birthDate, editing: $editingField, fieldKey: "birthDate")
                    userInfoField(label: "Género", value: $userData.gender, editing: $editingField, fieldKey: "gender", editable: true)

                    Button("Guardar Cambios", action: saveData)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(10)

                    Spacer()
                }
                .padding()
            }
            .onAppear(perform: loadUserData)
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $userData.profileImage)
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Datos Guardados"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    var profileImageSection: some View {
        ZStack {
            Circle()
                .fill(Color.gray.opacity(0.5))
                .frame(width: 140, height: 140)
                .shadow(radius: 10)

            if let image = userData.profileImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .clipShape(Circle())
                    .frame(width: 130, height: 130)
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 130, height: 130)
                    .clipShape(Circle())
                    .foregroundColor(.white)
            }
        }
        .onTapGesture {
            self.showImagePicker = true
        }
        .padding(.bottom, 20)
    }

    func userInfoField(label: String, value: Binding<String>, editing: Binding<String?>, fieldKey: String, editable: Bool) -> some View {
        HStack {
            if editing.wrappedValue == fieldKey {
                TextField(label, text: value)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: { editing.wrappedValue = nil }) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            } else {
                Text(label)
                Spacer()
                Text(value.wrappedValue)
                if editable {
                    Button(action: { editing.wrappedValue = fieldKey }) {
                        Image(systemName: "pencil.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
    }

    func datePickerField(label: String, date: Binding<Date>, editing: Binding<String?>, fieldKey: String) -> some View {
        DatePicker(label, selection: date, displayedComponents: .date)
            .padding()
            .onChange(of: date) { _ in
                editing.wrappedValue = nil
            }
    }

    func saveData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let storageRef = Storage.storage().reference().child("profileImages/\(uid).jpg")

        if let imageData = userData.profileImage?.jpegData(compressionQuality: 0.4) {
            storageRef.putData(imageData, metadata: nil) { metadata, error in
                guard let metadata = metadata else {
                    alertMessage = "Error uploading image: \(error?.localizedDescription ?? "Unknown error")"
                    showAlert = true
                    return
                }

                storageRef.downloadURL { url, error in
                    guard let downloadURL = url else {
                        alertMessage = "Error getting download URL: \(error?.localizedDescription ?? "Unknown error")"
                        showAlert = true
                        return
                    }

                    let userDataToUpdate: [String: Any] = [
                        "firstName": userData.firstName,
                        "lastName": userData.lastName,
                        "email": userData.email,
                        "birthDate": Timestamp(date: userData.birthDate),
                        "gender": userData.gender,
                        "profileImageUrl": downloadURL.absoluteString
                    ]

                    db.collection("users").document(uid).setData(userDataToUpdate) { error in
                        if let error = error {
                            alertMessage = "Error saving user data: \(error.localizedDescription)"
                        } else {
                            alertMessage = "Data saved successfully!"
                        }
                        showAlert = true
                    }
                }
            }
        } else {
            // Save without image change
            let userDataToUpdate: [String: Any] = [
                "firstName": userData.firstName,
                "lastName": userData.lastName,
                "email": userData.email,
                "birthDate": Timestamp(date: userData.birthDate),
                "gender": userData.gender
            ]

            db.collection("users").document(uid).setData(userDataToUpdate) { error in
                if let error = error {
                    alertMessage = "Error saving user data: \(error.localizedDescription)"
                } else {
                    alertMessage = "Data saved successfully!"
                }
                showAlert = true
            }
        }
    }

    func loadUserData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()

        db.collection("users").document(uid).getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                userData.firstName = data?["firstName"] as? String ?? ""
                userData.lastName = data?["lastName"] as? String ?? ""
                userData.email = data?["email"] as? String ?? ""
                userData.gender = data?["gender"] as? String ?? ""
                userData.birthDate = (data?["birthDate"] as? Timestamp)?.dateValue() ?? Date()

                if let profileImageUrl = data?["profileImageUrl"] as? String {
                    loadImageFromURL(profileImageUrl)
                }
            } else {
                alertMessage = "Document does not exist"
                showAlert = true
            }
        }
    }

    func loadImageFromURL(_ urlString: String) {
        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        userData.profileImage = image
                    }
                }
            }.resume()
        }
    }
}


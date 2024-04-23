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
                    datePickerField(label: "Fecha de Nacimiento", date: $userData.birthDate, editingField: $editingField, fieldKey: "birthDate")
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

    func datePickerField(label: String, date: Binding<Date>, editingField: Binding<String?>, fieldKey: String) -> some View {
        DatePicker(label, selection: date, displayedComponents: .date)
            .padding()
            .onChange(of: date) { _ in
                editingField.wrappedValue = nil
            }
    }

    // [The rest of the PerfilView code remains unchanged]
}


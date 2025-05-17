import SwiftUI

struct TextFieldsView: View {
    
    @EnvironmentObject private var registrationViewModel: RegistrationViewModel
    @Binding var name: String
    @Binding var email: String
    @Binding var phone: String
    @Binding var photo: Data
    @FocusState private var isFocused: Field?
    
    var body: some View {
        Group {
            buildTextField(title: "Your name", text: $name, field: .name)
            buildTextField(title: "Email", text: $email, field: .email)
            buildTextField(title: "Phone", text: $phone, field: .phone)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isFocused = .name
            }
        }
    }
    
    @ViewBuilder
    private func buildTextField(title: String, text: Binding<String>, field: Field) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            ZStack(alignment: .leading) {
                Text(title)
                    .padding()
                    .foregroundColor(labelColor(for: field, text: text.wrappedValue))
                    .offset(y: text.wrappedValue.isEmpty ? 0 : -25)
                    .scaleEffect(text.wrappedValue.isEmpty ? 1 : 0.8, anchor: .leading)

                TextField("", text: text)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.horizontal)
                    .frame(height: 56)
                    .background(RoundedRectangle(cornerRadius: 5).stroke(borderColor(for: field), lineWidth: 2))
                    .focused($isFocused, equals: field)
                    .onChange(of: text.wrappedValue) { value in
                        let trimmed = value.trimmingCharacters(in: .whitespaces)
                        text.wrappedValue = trimmed.lowercased()
                        let key = fieldKey(for: field)
                        if !trimmed.isEmpty,
                           registrationViewModel.validationErrors[key] != nil {
                            registrationViewModel.validationErrors[key] = nil
                        }
                    }
            }
            .padding(.top, 12)
            .animation(.default)
           
            if field == .phone,
               (!registrationViewModel.didSubmit ||
                registrationViewModel.validationErrors[fieldKey(for: field)] == nil) {
                Text("+38 (XXX) XXX-XX-XX")
                    .font(.caption)
                    .foregroundColor(Color.textForTextFields)
                    .padding(.horizontal, 4)
            }

            if registrationViewModel.didSubmit,
               let errorMessage = registrationViewModel.validationErrors[fieldKey(for: field)]?.first {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal, 4)
            }
            
        }
        .padding(.horizontal)
        .padding(.bottom, 12)
    }
    private func borderColor(for field: Field) -> Color {
        
        let key = fieldKey(for: field)
        let value: String
        
        switch field {
        case .name: value = name
        case .email: value = email
        case .phone: value = phone
        }

        if isFocused == field {
            return .secondaryApp
        }

        if registrationViewModel.didSubmit,
           let error = registrationViewModel.validationErrors[key],
           !error.isEmpty {
            return .red
        }
        return Color.uploadViewGray
    }
    private func fieldKey(for field: Field) -> String {
        switch field {
        case .name: return "name"
        case .email: return "email"
        case .phone: return "phone"
        }
    }
    private func labelColor(for field: Field, text: String) -> Color {
        let key = fieldKey(for: field)

        if registrationViewModel.didSubmit,
           let error = registrationViewModel.validationErrors[key],
           !error.isEmpty {
            return .red
        }
        if isFocused == field {
            return .secondaryApp
        }
        if !text.isEmpty {
            return .purple
        }
        return Color(.placeholderText)
    }
    enum Field {
        case name
        case email
        case phone
    }
}

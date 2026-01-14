import Vapor

extension String {
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }
    
    var isValidPhoneNumber: Bool {
        let phoneRegex = "^[+]?[0-9]{10,15}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: self)
    }
}

extension RegisterRequest: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("fullName", as: String.self, is: !.empty && .count(2...100))
        validations.add("email", as: String.self, is: .email)
        validations.add("phoneNumber", as: String.self, is: !.empty)
        validations.add("password", as: String.self, is: .count(6...))
    }
}

extension LoginRequest: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("email", as: String.self, is: .email)
        validations.add("password", as: String.self, is: !.empty)
    }
}

extension CreateTransactionDTO: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("category", as: String.self, is: !.empty)
        validations.add("amount", as: Double.self, is: .range(0.01...))
    }
}

extension CreateBudgetDTO: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("budgetName", as: String.self, is: !.empty && .count(2...100))
        validations.add("allocatedAmount", as: Double.self, is: .range(0.01...))
        validations.add("relatedCategory", as: String.self, is: !.empty)
    }
}

extension UpdateTransactionDTO: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("type", as: String?.self)
        validations.add("category", as: String?.self)
        validations.add("amount", as: Double?.self)
        validations.add("date", as: Date?.self)
    }
}

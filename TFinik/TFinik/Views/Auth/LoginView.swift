import SwiftUI

//Окно входа заглушка, работат вывод в консоль того, что ввели в поля ввода
//Проверка для гитхаба
struct LoginView: View {
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        VStack(spacing:20) {
            Text("T‑Finik").font(.largeTitle).bold()
            TextField("Email", text: $email)
              .autocapitalization(.none)
              .textContentType(.emailAddress)
              .padding().background(Color(white:0.1)).cornerRadius(8)
            SecureField("Пароль", text: $password)
              .padding().background(Color(white:0.1)).cornerRadius(8)
            Button("Войти") {
              print("Login:", email, password)
            }
            .frame(maxWidth:.infinity).padding()
            .background(Color.accentColor).foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
    }
}

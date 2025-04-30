import SwiftUI
import UniformTypeIdentifiers

struct BankWrapper: Identifiable {
    var id: String { bankName }
    let bankName: String
}

struct BankStatementUploadView: View {
    @EnvironmentObject var transactionStore: TransactionStore
    @State private var selectedFiles: [String: URL] = [:]
    @State private var showingDocumentPickerForBank: BankWrapper? = nil
    @State private var showAlert = false
    @State private var showPreview = false

    @AppStorage("hasOnboarded") private var hasOnboarded = false
    @AppStorage("hasUploadedStatement") private var hasUploadedStatement = false

    var body: some View {
        ZStack {
            BackgroundView()

            ScrollView {
                VStack(spacing: 24) {
                    Text("🗒")
                        .font(.system(size: 60))
                        .padding(.top, 60)

                    Text("Загрузите выписку")
                        .font(.title2.bold())
                        .foregroundColor(.white)

                    Text("⏳ Мы просим Вас загрузить выписку за весь период пользования картой — с самого первого дня и до текущей даты")
                        .font(.body)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    VStack(spacing: 4) {
                        Text("Банки-партнеры")
                            .font(.headline)
                            .foregroundColor(.white)

                        Text("(нажмите на иконку банка для загрузки)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }

                    LazyVGrid(columns: [GridItem(), GridItem()], spacing: 20) {
                        ForEach(["Tinkoff", "Sber", "Alfa", "VTB"], id: \.self) { bank in
                            ZStack(alignment: .topTrailing) {
                                Button {
                                    showingDocumentPickerForBank = BankWrapper(bankName: bank)
                                } label: {
                                    Image(bankIconName(for: bank))
                                        .resizable()
                                        .frame(width: 64, height: 64)
                                        .cornerRadius(14)
                                }

                                Image(systemName: selectedFiles[bank] != nil ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundColor(selectedFiles[bank] != nil ? .green : .red)
                                    .offset(x: 6, y: -6)
                            }
                        }
                    }

                    Button("Далее →") {
                        if selectedFiles.isEmpty {
                            showAlert = true
                            return
                        }

                        transactionStore.clear() // очищаем старые транзакции до начала
                        var completed = 0
                        let total = selectedFiles.count
                        var allTransactions: [Transaction] = []

                        for (bank, fileURL) in selectedFiles {
                            uploadPDF(fileURL: fileURL, bank: bank) { result in
                                DispatchQueue.main.async {
                                    completed += 1
                                    switch result {
                                    case .success(let txs):
                                        allTransactions.append(contentsOf: txs)
                                    case .failure(let error):
                                        print("❌ Ошибка при загрузке \(bank): \(error)")
                                    }

                                    if completed == total {
                                        transactionStore.transactions = allTransactions
                                        if !allTransactions.isEmpty {
                                            showPreview = true
                                        } else {
                                            print("⚠️ Выписка загружена, но транзакции пусты")
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal)

                    Spacer(minLength: 40)
                }
                .padding(.horizontal)
            }

            NavigationLink(
                destination: TransactionPreviewView()
                    .environmentObject(transactionStore),
                isActive: $showPreview
            ) {
                EmptyView()
            }


        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Загрузка не завершена"),
                message: Text("Пожалуйста, загрузите хотя бы одну выписку, прежде чем продолжить."),
                dismissButton: .default(Text("OK"))
            )
        }
        .sheet(item: $showingDocumentPickerForBank) { wrapper in
            DocumentPicker { url in
                if let url {
                    selectedFiles[wrapper.bankName] = url
                }
                showingDocumentPickerForBank = nil
            }
        }
        .navigationTitle(" ")
        .navigationBarTitleDisplayMode(.inline)
    }

    func uploadPDF(fileURL: URL, bank: String, completion: @escaping (Result<[Transaction], Error>) -> Void) {
        let boundary = UUID().uuidString
        guard let accessToken = KeychainHelper.shared.readAccessToken() else {
            completion(.failure(NSError(domain: "Token not found", code: 401)))
            return
        }

        var request = URLRequest(url: URL(string: "http://169.254.218.217:8000/transactions/upload")!)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        var data = Data()
        let filename = fileURL.lastPathComponent
        let mimeType = "application/pdf"
        let fileData = try? Data(contentsOf: fileURL)

        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"bank\"\r\n\r\n".data(using: .utf8)!)
        data.append("\(bank)\r\n".data(using: .utf8)!)
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        data.append(fileData ?? Data())
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        URLSession.shared.uploadTask(with: request, from: data) { responseData, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let responseData = responseData else {
                completion(.failure(NSError(domain: "Empty response", code: -1)))
                return
            }

            do {
                let decoded = try JSONDecoder().decode(UploadResponse.self, from: responseData)
                let transactions = decoded.transactions.map { tx in
                    Transaction(
                        id: tx.id,
                        date: tx.date,
                        time: tx.time,
                        amount: tx.amount,
                        isIncome: tx.isIncome,
                        description: tx.description,
                        category: tx.category,
                        bank: tx.bank
                    )
                }
                completion(.success(transactions))
            } catch {
                print("❌ Ошибка декодирования JSON: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }

    private func bankIconName(for bank: String) -> String {
        switch bank {
        case "Tinkoff": return "tinkoff_icon"
        case "Sber": return "sber_icon"
        case "Alfa": return "alfa_icon"
        case "VTB": return "vtb_icon"
        default: return "questionmark"
        }
    }
}

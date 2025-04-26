import SwiftUI
import Foundation
import UniformTypeIdentifiers

struct BankWrapper: Identifiable {
    var id: String { bankName }
    let bankName: String
}

struct BankStatementUploadView: View {
    @EnvironmentObject var transactionStore: TransactionStore
    @State private var selectedBanks: [String: Bool] = [
        "Tinkoff": false,
        "Sber": true,
        "Alfa": true,
        "VTB": true
    ]
    
    @State private var showingDocumentPickerForBank: BankWrapper? = nil
    @State private var showAlert = false
    @State private var navigateToPreview = false

    var body: some View {
        NavigationView {
            ZStack {
                BackgroundView()

                VStack(spacing: 24) {
                    HStack {
                        Button(action: {
                            // Назад
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                                .font(.title2)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)

                    Text("🗒")
                        .font(.system(size: 60))
                        .padding(.top, 20)

                    Text("Загрузите выписку")
                        .font(.title2.bold())
                        .foregroundColor(.white)

                    Text("Сделайте выписку из нужных Вам банков по карте, на которой хранятся Ваши средства")
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
                        ForEach(selectedBanks.sorted(by: { $0.key < $1.key }), id: \.key) { bank, isSelected in
                            ZStack(alignment: .topTrailing) {
                                Button(action: {
                                    simulatePDFSelection(for: bank)
                                }) {
                                    Image(bankIconName(for: bank))
                                        .resizable()
                                        .frame(width: 64, height: 64)
                                        .cornerRadius(14)
                                }

                                Image(systemName: isSelected ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundColor(isSelected ? .green : .red)
                                    .offset(x: 6, y: -6)
                            }
                        }
                    }

                    Spacer()

                    NavigationLink(
                        destination: TransactionPreviewView(transactions: transactionStore.transactions),
                        isActive: $navigateToPreview
                    ) {
                        EmptyView()
                    }

                    Button(action: {
                        if selectedBanks.values.contains(true) {
                            if let url = Bundle.main.url(forResource: "spravka_o_dvizhenii_denegnyh_sredstv", withExtension: "pdf") {
                                uploadPDF(fileURL: url) { result in
                                    DispatchQueue.main.async {
                                        switch result {
                                        case .success(let transactions):
                                            transactionStore.transactions = transactions
                                            navigateToPreview = true
                                        case .failure(let error):
                                            print("Ошибка загрузки PDF: \(error)")
                                        }
                                    }
                                }
                            } else {
                                print("PDF-файл не найден")
                            }

                        } else {
                            showAlert = true
                        }
                    })
 {
                        Text("Далее →")
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }
                    .alert(isPresented: $showAlert) {
                        Alert(
                            title: Text("Загрузка не завершена"),
                            message: Text("Пожалуйста, загрузите хотя бы одну выписку, прежде чем продолжить."),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                }
                .padding(.top)
            }
            .sheet(item: $showingDocumentPickerForBank) { wrapper in
                DocumentPicker { url in
                    if url != nil {
                        selectedBanks[wrapper.bankName] = true
                    }
                    showingDocumentPickerForBank = nil
                }
            }
        }
    }


    func uploadPDF(fileURL: URL, completion: @escaping (Result<[Transaction], Error>) -> Void) {
        let boundary = UUID().uuidString
        var request = URLRequest(url: URL(string: "http://127.0.0.1:8000/transactions/upload")!)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Если есть токен, передаем его
        if let accessToken = KeychainHelper.shared.readAccessToken() {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }

        var data = Data()

        // Добавляем файл
        let filename = fileURL.lastPathComponent
        let mimeType = "application/pdf"
        let fileData = try? Data(contentsOf: fileURL)

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
                        id: tx.id,                     // <--- обязательно UUID
                        date: tx.date,
                        time: tx.time,                   // <--- обязательно time
                        amount: tx.amount,
                        isIncome: tx.isIncome,
                        description: tx.description,
                        category: tx.category,
                        bank: tx.bank
                    )
                }
                completion(.success(transactions))

            } catch {
                completion(.failure(error))
            }
        }.resume()
    }


    
    private func simulatePDFSelection(for bank: String) {
        if let path = Bundle.main.path(forResource: "spravka_o_dvizhenii_denegnyh_sredstv", ofType: "pdf") {
            let url = URL(fileURLWithPath: path)
            print("Загружен PDF из бандла: \(url)")
            selectedBanks[bank] = true
        } else {
            print("Файл не найден в бандле.")
        }
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

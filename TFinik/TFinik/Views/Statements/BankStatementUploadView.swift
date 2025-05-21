import SwiftUI
import UniformTypeIdentifiers

struct BankWrapper: Identifiable {
    var id: String { bankName }
    let bankName: String
}

struct BankStatementUploadView: View {
    @EnvironmentObject var transactionStore: TransactionStore
    @AppStorage("hasOnboarded") private var hasOnboarded = false
    @AppStorage("hasUploadedStatement") private var hasUploadedStatement = false

    @State private var selectedFiles: [String: URL] = [:]
    @State private var showingDocumentPickerForBank: BankWrapper? = nil
    @State private var showAlert = false
    @State private var showPreview = false
    @State private var isUploading = false


    private let supportedBanks = ["Tinkoff", "Sber"]

    var body: some View {
        ZStack {
            BackgroundView()
            content
            navigationLink
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Загрузка не завершена"),
                message: Text("Пожалуйста, загрузите хотя бы одну выписку."),
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
        .navigationBarTitleDisplayMode(.inline)
    }

    private var content: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("🗒").font(.system(size: 60)).padding(.top, 60)

                Text("Загрузите выписку")
                    .font(.title2.bold())
                    .foregroundColor(.white)

                Text("⏳ Мы просим Вас загрузить выписку за весь период пользования картой — с самого первого дня и до текущей даты.")
                    .font(.body)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                bankGridView()
                nextButtonView()
                Spacer(minLength: 40)
            }
            .padding(.horizontal)
        }
    }

    private func bankGridView() -> some View {
        VStack(spacing: 4) {
            Text("Банки-партнеры")
                .font(.headline)
                .foregroundColor(.white)

            Text("(нажмите на иконку для загрузки)")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.bottom, 12) // ✅ Добавлен отступ вниз

            LazyVGrid(columns: [GridItem(), GridItem()], spacing: 20) {
                ForEach(supportedBanks, id: \.self) { bank in
                    ZStack(alignment: .topTrailing) {
                        Button {
                            showingDocumentPickerForBank = BankWrapper(bankName: bank)
                        } label: {
                            Image(bankIconName(for: bank))
                                .resizable()
                                .frame(width: 64, height: 64)
                                .cornerRadius(14)
                        }

                        let isUploaded = selectedFiles[bank] != nil
                        Image(systemName: isUploaded ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(isUploaded ? .green : .red)
                            .offset(x: 6, y: -6)
                    }
                }
            }
        }
    }


    private func nextButtonView() -> some View {
        Button("Далее →") {
            handleUpload()
        }
        .font(.headline)
        .foregroundColor(.black)
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }

    private var navigationLink: some View {
        NavigationLink(
            destination: TransactionPreviewView()
                .environmentObject(transactionStore),
            isActive: $showPreview
        ) {
            EmptyView()
        }
    }

    private func handleUpload() {
        guard !isUploading else { return } // защита от повторов
        guard !selectedFiles.isEmpty else {
            showAlert = true
            return
        }

        isUploading = true // старт блокировки

        transactionStore.clear()
        var completed = 0
        var allTransactions: [Transaction] = []
        let total = selectedFiles.count

        for (bank, fileURL) in selectedFiles {
            let token = KeychainHelper.shared.readAccessToken() ?? ""
            TransactionService.shared.uploadStatement(fileURL: fileURL, bank: bank, token: token) { result in
                DispatchQueue.main.async {
                    completed += 1
                    switch result {
                    case .success(let txs):
                        allTransactions.append(contentsOf: txs)
                    case .failure(let error):
                        print("❌ Ошибка при загрузке \(bank): \(error.localizedDescription)")
                        // (опционально) можно показать алерт
                    }

                    if completed == total {
                        isUploading = false // ✅ сбрасываем после всех запросов
                        transactionStore.transactions = allTransactions
                        if !allTransactions.isEmpty {
                            showPreview = true
                        }
                    }
                }
            }
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

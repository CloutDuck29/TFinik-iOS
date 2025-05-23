// MARK: - Окно первичной загрузки выписки

import SwiftUI
import UniformTypeIdentifiers

struct BankWrapper: Identifiable {
    var id: String { bankName }
    let bankName: String
}

struct BankStatementUploadView: View {
    @EnvironmentObject var transactionStore: TransactionStore
    @EnvironmentObject var auth: AuthService

    @AppStorage("hasOnboarded") private var hasOnboarded = false
    @AppStorage("hasUploadedStatement") private var hasUploadedStatement = false

    @State private var selectedFiles: [String: URL] = [:]
    @State private var showingDocumentPickerForBank: BankWrapper? = nil
    @State private var showAlert = false
    @State private var showPreview = false
    @State private var isUploading = false
    @State private var showFormatAlert = false

    private let supportedBanks = ["Tinkoff", "Sber"]

    var body: some View {
        ZStack {
            BackgroundView()
            content
            navigationLink

            if isUploading {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    ProgressView("Загрузка выписки...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .foregroundColor(.white)
                        .font(.headline)
                }
                .padding()
                .background(Color.black.opacity(0.7))
                .cornerRadius(16)
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Загрузка не завершена"),
                message: Text("Пожалуйста, загрузите хотя бы одну выписку."),
                dismissButton: .default(Text("OK"))
            )
        }
        .alert("❌ Вы загружаете выписку другого банка", isPresented: $showFormatAlert) {
            Button("Понял", role: .cancel) { }
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
    // MARK: - контентная часть
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
    // MARK: - Отображение банков
    private func bankGridView() -> some View {
        VStack(spacing: 4) {
            Text("Банки-партнеры")
                .font(.headline)
                .foregroundColor(.white)

            Text("(нажмите на иконку для загрузки)")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.bottom, 12)

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
    // MARK: - Кнопка далее
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
            destination: TransactionPreviewView(isInitialUpload: true)
                .environmentObject(auth)
                .environmentObject(transactionStore),
            isActive: $showPreview
        ) {
            EmptyView()
        }
    }
    // MARK: - Загрузка и ошибки
    private func handleUpload() {
        guard !isUploading else { return }
        guard !selectedFiles.isEmpty else {
            showAlert = true
            return
        }

        isUploading = true
        transactionStore.clear()

        var completed = 0
        var allTransactions: [Transaction] = []
        let total = selectedFiles.count

        for (bank, fileURL) in selectedFiles {
            let token = KeychainHelper.shared.readAccessToken() ?? ""
            TransactionService.shared.uploadStatement(fileURL: fileURL, bank: bank, token: token) { result in
                completed += 1

                switch result {
                case .success(let txs):
                    allTransactions.append(contentsOf: txs)
                case .failure(let error):
                    print("❌ Ошибка при загрузке \(bank): \(error.localizedDescription)")
                    let msg = error.localizedDescription.lowercased()
                    if msg.contains("не является выпиской") || msg.contains("unsupported") {
                        DispatchQueue.main.async {
                            showFormatAlert = true
                        }
                    }
                }

                if completed == total {
                    DispatchQueue.main.async {
                        isUploading = false
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
        default: return "questionmark"
        }
    }
}

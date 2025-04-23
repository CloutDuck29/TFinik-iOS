import SwiftUI

struct BankWrapper: Identifiable {
    var id: String { bankName }
    let bankName: String
}

struct BankStatementUploadView: View {
    @State private var selectedBanks: [String: Bool] = [
        "Tinkoff": false,
        "Sber": true,
        "Alfa": true,
        "VTB": true
    ]
    
    @State private var showingDocumentPickerForBank: BankWrapper? = nil
    @State private var showAlert = false

    var body: some View {
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
                    ForEach(selectedBanks.sorted(by: { $0.key < $1.key }), id: \ .key) { bank, isSelected in
                        ZStack(alignment: .topTrailing) {
                            Button(action: {
                                // Для симуляции выбора PDF из ассетов:
                                simulatePDFSelection(for: bank)
                                
                                // Для реального выбора через DocumentPicker — раскомментировать ниже:
                                // showingDocumentPickerForBank = BankWrapper(bankName: bank)
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

                Button(action: {
                    if selectedBanks.values.contains(true) {
                        // Переход на следующий экран (TransactionPreviewView)
                        print("Продолжить: есть загруженные банки")
                    } else {
                        showAlert = true
                    }
                }) {
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

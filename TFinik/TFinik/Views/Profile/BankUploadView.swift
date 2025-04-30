import SwiftUI
import UniformTypeIdentifiers

struct BankUploadView: View {
    @State private var banks: [Bank] = Bank.sampleBanks
    @State private var selectedBankID: UUID?
    @State private var selectedYear: Int?
    @State private var isFileImporterPresented = false

    var body: some View {
        ZStack {
            BackgroundView()

            ScrollView {
                VStack(spacing: 24) {
                    ForEach(banks) { bank in
                        BankCardView(bank: bank, onUpload: { year in
                            selectedBankID = bank.id
                            selectedYear = year
                            isFileImporterPresented = true
                        })
                    }
                }
                .padding()
            }
            .navigationTitle("Загрузки выписок")
            .fileImporter(
                isPresented: $isFileImporterPresented,
                allowedContentTypes: [.pdf],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first,
                       let bankIndex = banks.firstIndex(where: { $0.id == selectedBankID }),
                       let year = selectedYear {
                        print("Загружен файл для банка: \(banks[bankIndex].name), год: \(year), путь: \(url.path)")
                        banks[bankIndex].uploadedYears.insert(year)
                    }
                case .failure(let error):
                    print("Ошибка загрузки файла: \(error.localizedDescription)")
                }
            }
        }
        .onAppear {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.backgroundColor = .clear
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]

            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

struct BankCardView: View {
    var bank: Bank
    var onUpload: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(bank.logoName)
                    .resizable()
                    .frame(width: 36, height: 36)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                Text(bank.name)
                    .font(.title3.bold())
                    .foregroundColor(.white)
            }

            ForEach(bank.availableYears, id: \.self) { year in
                Button(action: {
                    onUpload(year)
                }) {
                    HStack {
                        Text("\(year)")
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: bank.isYearUploaded(year) ? "checkmark.circle.fill" : "folder.fill")
                            .foregroundColor(bank.isYearUploaded(year) ? .green : .blue)
                            .transition(.scale)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.12))
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 3)
    }
}

struct Bank: Identifiable {
    var id = UUID()
    var name: String
    var logoName: String
    var availableYears: [Int]
    var uploadedYears: Set<Int>

    func isYearUploaded(_ year: Int) -> Bool {
        uploadedYears.contains(year)
    }
}

extension Bank {
    static let sampleBanks: [Bank] = [
        Bank(name: "Тинькофф", logoName: "tinkoff_icon", availableYears: [2022, 2023, 2024], uploadedYears: []),
        Bank(name: "Альфа-Банк", logoName: "alfa_icon", availableYears: [2022, 2023, 2024], uploadedYears: []),
        Bank(name: "Сбербанк", logoName: "sber_icon", availableYears: [2022, 2023, 2024], uploadedYears: []),
        Bank(name: "ВТБ", logoName: "vtb_icon", availableYears: [2022, 2023, 2024], uploadedYears: [])
    ]
}

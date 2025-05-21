// MARK: Дозагрузка последующих выписок

import SwiftUI
import UniformTypeIdentifiers
import Foundation

struct BankUploadEntry: Identifiable {
    var id = UUID()
    let bankName: String
    let logoName: String
    let years: [YearChunk]
}

struct BankUploadView: View {
    @EnvironmentObject var auth: AuthService
    @State private var entries: [BankUploadEntry] = []
    @State private var selectedBank: String?
    @State private var isFileImporterPresented = false
    @State private var showDuplicateAlert = false
    @State private var isLoading = false
    @State private var showSuccessAlert = false
    @State private var showFormatAlert = false  // ✅ Новый алерт

    let supportedBanks = ["Тинькофф", "Сбер"]

    var body: some View {
        ZStack {
            BackgroundView()

            VStack(spacing: 16) {
                HStack {
                    Text("📥")
                        .font(.system(size: 32))
                    Text("Загрузки выписок")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                }
                .padding(.top, 40)

                if isLoading {
                    Spacer()
                    ProgressView("Загрузка...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .foregroundColor(.white)
                    Spacer()
                } else if entries.isEmpty {
                    Spacer()
                    Text("Нет загруженных выписок")
                        .foregroundColor(.gray)
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Кнопки для загрузки недостающих банков
                            ForEach(supportedBanks, id: \.self) { bank in
                                Button(action: {
                                    selectedBank = bank
                                    isFileImporterPresented = true
                                }) {
                                    HStack {
                                        Image(systemName: "plus.circle")
                                        Text("Загрузить выписку для \(bank)")
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(12)
                                }
                            }

                            ForEach(entries) { entry in
                                BankUploadCard(entry: entry, onUpload: {
                                    selectedBank = entry.bankName
                                    isFileImporterPresented = true
                                })
                            }
                        }
                        .padding(.bottom, 24)
                    }
                }
            }
            .padding(.horizontal)
            .fileImporter(
                isPresented: $isFileImporterPresented,
                allowedContentTypes: [.pdf],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first, let bank = selectedBank {
                        let normalizedBank = bank.lowercased() == "тинькофф" ? "tinkoff" :
                                             bank.lowercased() == "сбер" ? "sber" : bank.lowercased()

                        isLoading = true
                        TransactionService.shared.uploadStatementSimple(fileURL: url, bank: normalizedBank, token: auth.accessToken ?? "") { result in
                            DispatchQueue.main.async {
                                isLoading = false
                                switch result {
                                case .success:
                                    showSuccessAlert = true

                                    if !entries.contains(where: { $0.bankName == bank }) {
                                        entries.append(
                                            BankUploadEntry(
                                                bankName: bank,
                                                logoName: "\(bank.lowercased())_icon",
                                                years: []
                                            )
                                        )
                                    }

                                    fetchStatements()
                                case .failure(let error):
                                    let message = error.localizedDescription.lowercased()
                                    if message.contains("не является выпиской") || message.contains("unsupported") {
                                        showFormatAlert = true
                                    } else if message.contains("уже загружена") || message.contains("duplicate") {
                                        showDuplicateAlert = true
                                    } else {
                                        print("❌ Необработанная ошибка: \(message)")
                                    }
                                    print("❌ Ошибка при загрузке: \(error.localizedDescription)")
                                }
                            }
                        }
                    }
                case .failure(let error):
                    print("Ошибка загрузки файла: \(error.localizedDescription)")
                }
            }
        }
        .alert("⚠️ Такая выписка уже загружена", isPresented: $showDuplicateAlert) {
            Button("Ок", role: .cancel) { }
        }
        .alert("✅ Выписка успешно загружена", isPresented: $showSuccessAlert) {
            Button("Ок", role: .cancel) { }
        }
        .alert("❌ Вы загружаете выписку другого банка", isPresented: $showFormatAlert) {
            Button("Понял", role: .cancel) { }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                fetchStatements()
            }
        }
    }

    func fetchStatements() {
        isLoading = true
        TransactionService.shared.fetchStatements(token: auth.accessToken ?? "") { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let statements):
                    self.entries = processStatements(statements)
                case .failure(let error):
                    print("❌ Ошибка получения выписок: \(error.localizedDescription)")
                }
            }
        }
    }

    func processStatements(_ statements: [Statement]) -> [BankUploadEntry] {
        let grouped = Dictionary(grouping: statements, by: { $0.bank.lowercased() }) // 🔁 нормализуем ключ
        var result: [BankUploadEntry] = []

        for (bank, stmts) in grouped {
            var yearMap: [Int: [Int: Bool]] = [:]
            let calendar = Calendar.current

            for stmt in stmts {
                guard let start = stmt.dateStartAsDate, let end = stmt.dateEndAsDate else { continue }
                var current = start
                while current <= end {
                    let year = calendar.component(.year, from: current)
                    let month = calendar.component(.month, from: current)
                    yearMap[year, default: [:]][month] = true
                    current = calendar.date(byAdding: .month, value: 1, to: current)!
                }
            }

            // Красивое отображение
            let displayBank = bank == "tinkoff" ? "Tinkoff" :
                              bank == "sber" ? "Сбер" : bank.capitalized

            result.append(
                BankUploadEntry(
                    bankName: displayBank,
                    logoName: "\(bank.lowercased())_icon",
                    years: yearMap.map { YearChunk(year: $0.key, months: $0.value) }.sorted { $0.year < $1.year }
                )
            )
        }

        return result
    }

}

struct BankUploadCard: View {
    let entry: BankUploadEntry
    let onUpload: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(entry.logoName)
                    .resizable()
                    .frame(width: 36, height: 36)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                Text(entry.bankName)
                    .font(.title3.bold())
                    .foregroundColor(.white)
            }

            ForEach(entry.years) { chunk in
                VStack(alignment: .leading, spacing: 6) {
                    Text(String(chunk.year))
                        .font(.subheadline.bold())
                        .foregroundColor(.white)

                    LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 6), spacing: 8) {
                        ForEach(1...12, id: \.self) { month in
                            let isUploaded = chunk.months[month] ?? false
                            Text(threeLetterMonthName(month))
                                .font(.caption2)
                                .frame(maxWidth: .infinity)
                                .padding(6)
                                .background(isUploaded ? Color.green.opacity(0.8) : Color.gray.opacity(0.4))
                                .cornerRadius(6)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.12))
        .cornerRadius(24)
    }

    func threeLetterMonthName(_ month: Int) -> String {
        let shortNames = [
            "янв", "фев", "мар", "апр", "май", "июн",
            "июл", "авг", "сен", "окт", "ноя", "дек"
        ]
        return shortNames[month - 1]
    }
}

import SwiftUI
import UniformTypeIdentifiers

struct Statement: Identifiable, Decodable {
    var id: Int
    var bank: String
    var date_start: String
    var date_end: String

    var dateStartAsDate: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.date(from: date_start)
    }

    var dateEndAsDate: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.date(from: date_end)
    }
}

struct YearChunk: Identifiable {
    var id = UUID()
    var year: Int
    var months: [Int: Bool] // месяц: true = загружен
}

struct BankUploadEntry: Identifiable {
    var id = UUID()
    let bankName: String
    let logoName: String
    let years: [YearChunk]
}

struct BankUploadView: View {
    @EnvironmentObject var auth: AuthService // ✅ правильно
    @State private var entries: [BankUploadEntry] = []
    @State private var selectedBank: String?
    @State private var isFileImporterPresented = false
    

    var body: some View {
        ZStack {
            BackgroundView()

            VStack(spacing: 16) {
                Text("Загрузки выписок")
                    .font(.title.bold())
                    .foregroundColor(.white)
                    .padding(.top, 32)

                if entries.isEmpty {
                    Spacer()
                    Text("Нет загруженных выписок")
                        .foregroundColor(.gray)
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
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
                        print("Загружен файл для банка: \(bank), путь: \(url.path)")
                        // TODO: отправка файла на сервер
                    }
                case .failure(let error):
                    print("Ошибка загрузки файла: \(error.localizedDescription)")
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                print("👀 auth.accessToken = \(auth.accessToken ?? "nil")") // <-- вот сюда смотри
                fetchStatements()
            }
        }

    }

    func fetchStatements() {
        guard let token = KeychainHelper.shared.readAccessToken() else {
            print("❌ Токен не найден в Keychain")
            return
        }


        print("✅ Найден токен: \(token)")

        var request = URLRequest(url: URL(string: "http://169.254.202.90:8000/statements")!)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Ошибка запроса: \(error.localizedDescription)")
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                print("ℹ️ Код ответа: \(httpResponse.statusCode)")
            }

            guard let data = data else {
                print("❌ Нет данных")
                return
            }

            do {
                let decoded = try JSONDecoder().decode([Statement].self, from: data)
                print("✅ Получено \(decoded.count) выписок")
                DispatchQueue.main.async {
                    self.entries = processStatements(decoded)
                }
            } catch {
                print("❌ Ошибка декодирования: \(error)")
            }
        }.resume()
    }

    func processStatements(_ statements: [Statement]) -> [BankUploadEntry] {
        let grouped = Dictionary(grouping: statements, by: { $0.bank })
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

            let years = yearMap.map { YearChunk(year: $0.key, months: $0.value) }.sorted { $0.year < $1.year }
            result.append(BankUploadEntry(bankName: bank, logoName: "\(bank.lowercased())_icon", years: years))
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
                    Text("\(chunk.year)")
                        .font(.subheadline.bold())
                        .foregroundColor(.white)

                    LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 6), spacing: 8) {
                        ForEach(1...12, id: \ .self) { month in
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

            Button("➕ Загрузить выписку", action: onUpload)
                .padding(.top, 8)
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

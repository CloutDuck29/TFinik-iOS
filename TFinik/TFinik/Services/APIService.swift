import Foundation
import UniformTypeIdentifiers

func uploadPDF(fileURL: URL, completion: @escaping (Result<[Transaction], Error>) -> Void) {
    let boundary = UUID().uuidString
    var request = URLRequest(url: URL(string: "http://127.0.0.1:8000/transactions/upload")!)
    request.httpMethod = "POST"
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

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
            let decoded = try JSONDecoder().decode(TransactionUploadResponse.self, from: responseData)
            let transactions = decoded.transactions.map { tx in
                Transaction(
                    bank: tx.bank,
                    date: tx.date,
                    description: tx.description,
                    amount: tx.amount,
                    isIncome: tx.isIncome,
                    category: tx.category
                )
            }
            completion(.success(transactions))
        } catch {
            completion(.failure(error))
        }
    }.resume()
}

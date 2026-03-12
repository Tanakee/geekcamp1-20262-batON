import Foundation

// MARK: - API エラー
enum APIError: Error, LocalizedError {
    case graphqlError(String)
    case networkError(Error)
    case decodingError
    case noData

    var errorDescription: String? {
        switch self {
        case .graphqlError(let msg): return msg
        case .networkError(let err): return err.localizedDescription
        case .decodingError: return "データの解析に失敗しました"
        case .noData: return "データが取得できませんでした"
        }
    }
}

// MARK: - GraphQL レスポンス
struct GraphQLResponse<T: Decodable>: Decodable {
    let data: T?
    let errors: [GraphQLError]?
}

struct GraphQLError: Decodable {
    let message: String
}

// MARK: - API サービス
class APIService {
    static let shared = APIService()

    // シミュレータ: localhost / 実機: MacのIPアドレスに変更
    private let endpoint = URL(string: "http://localhost:3000/graphql")!

    var authToken: String? {
        get { UserDefaults.standard.string(forKey: "bat_auth_token") }
        set { UserDefaults.standard.set(newValue, forKey: "bat_auth_token") }
    }

    var savedUserId: String? {
        get { UserDefaults.standard.string(forKey: "bat_user_id") }
        set { UserDefaults.standard.set(newValue, forKey: "bat_user_id") }
    }

    func clearSession() {
        authToken = nil
        savedUserId = nil
    }

    func execute<T: Decodable>(
        query: String,
        variables: [String: Any] = [:],
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 10

        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let body: [String: Any] = ["query": query, "variables": variables]
        guard let bodyData = try? JSONSerialization.data(withJSONObject: body) else {
            completion(.failure(APIError.decodingError))
            return
        }
        request.httpBody = bodyData

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(APIError.networkError(error))) }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async { completion(.failure(APIError.noData)) }
                return
            }
            do {
                let response = try JSONDecoder().decode(GraphQLResponse<T>.self, from: data)
                if let errors = response.errors, let first = errors.first {
                    DispatchQueue.main.async { completion(.failure(APIError.graphqlError(first.message))) }
                    return
                }
                guard let result = response.data else {
                    DispatchQueue.main.async { completion(.failure(APIError.noData)) }
                    return
                }
                DispatchQueue.main.async { completion(.success(result)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(APIError.decodingError)) }
            }
        }.resume()
    }
}

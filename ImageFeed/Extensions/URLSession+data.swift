import Foundation

// MARK: - Network Errors

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case invalidRequest
    case decodingError(Error)
}

// MARK: - Data Task

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillOnMain: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }

        let task = dataTask(with: request) { data, response, error in
            if let error = error {
                print("‼️[URLSession/data]: URL request error: \(error.localizedDescription)")
                fulfillOnMain(.failure(NetworkError.urlRequestError(error)))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  let data = data else {
                print("‼️[URLSession/data]: URL session error — missing response or data.")
                fulfillOnMain(.failure(NetworkError.urlSessionError))
                return
            }

            let statusCode = httpResponse.statusCode
            if (200..<300).contains(statusCode) {
                fulfillOnMain(.success(data))
            } else {
                print("⚠️[URLSession/data]: HTTP error — status code: \(statusCode)")
                fulfillOnMain(.failure(NetworkError.httpStatusCode(statusCode)))
            }
        }

        return task
    }
}

// MARK: - Object Task (Decoding)

extension URLSession {
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return data(for: request) { result in
            switch result {
            case .success(let data):
                // Debug print raw JSON string
                if let json = String(data: data, encoding: .utf8) {
                    print("✅[URLSession/objectTask]: Received data:\n\(json)")
                }

                do {
                    let decoded = try decoder.decode(T.self, from: data)
                    completion(.success(decoded))
                } catch let decodingError as DecodingError {
                    print("‼️[URLSession/objectTask]: Decoding error: \(decodingError)")
                    print("📝 Raw data: \(String(data: data, encoding: .utf8) ?? "nil")")
                    completion(.failure(NetworkError.decodingError(decodingError)))
                } catch {
                    print("‼️[URLSession/objectTask]: Unknown decoding error: \(error)")
                    completion(.failure(NetworkError.decodingError(error)))
                }

            case .failure(let error):
                print("‼️[URLSession/objectTask]: Request failed with error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
}

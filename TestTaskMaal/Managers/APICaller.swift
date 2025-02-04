//
//  APICaller.swift
//  TestTaskMaal
//
//  Created by Pavel Maal on 16.01.25.
//

import Foundation

class APICaller {
    static let shared = APICaller()

    struct Constants {
        static let baseURL = "https://junior.balinasoft.com"
    }

    enum APIError: Error, LocalizedError {
        case invalidURL
        case failedToGetData
        case failedEncodingJSON
        case badGateway
        case inpredictableError

        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Некорректный URL. Проверьте адрес."
            case .failedToGetData:
                return "Не удалось получить данные. Проверьте соединение с интернетом."
            case .failedEncodingJSON:
                return "Ошибка кодирования JSON. Проверьте данные."
            case .badGateway:
                return "Ошибка 502. Сервер временно недоступен. Попробуйте позже."
            case .inpredictableError:
                return "Непредвиденная ошибка. Попробуйте позже."
            }
        }
    }

    // MARK: - Variable of State of Download

    private var currentPage = 0
    private(set) var isLoading = false
    private var totalPages = 0

    // MARK: - Swagger calls

    func getPhotoTypes(completion: @escaping (Result<[PhotoTypeContent], APIError>) -> Void) {
        guard let url = URL(string: Constants.baseURL + "/api/v2/photo/type") else {
            completion(.failure(APIError.invalidURL))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, statusCode, error in
            guard let data, error == nil else {
                completion(.failure(APIError.failedToGetData))
                return
            }

            if let code = statusCode as? HTTPURLResponse, code.statusCode == 502 {
                completion(.failure(APIError.badGateway))
                return
            }

            do {
                let result = try JSONDecoder().decode(PhotoType.self, from: data)
                self?.currentPage = result.page
                self?.totalPages = result.totalPages
                completion(.success(result.content))
            } catch {
                completion(.failure(APIError.inpredictableError))
            }
        }
        task.resume()
    }

    func getMorePhotoTypes(completion: @escaping (Result<[PhotoTypeContent], Error>) -> Void) {
        guard !isLoading, currentPage <= totalPages else { return }
        isLoading = true
        guard let url = URL(string: Constants.baseURL + "/api/v2/photo/type?page=\(currentPage + 1)") else {
            completion(.failure(APIError.invalidURL))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data, error == nil else {
                completion(.failure(APIError.failedToGetData))
                return
            }

            do {
                let result = try JSONDecoder().decode(PhotoType.self, from: data)
                self?.currentPage = result.page
                self?.totalPages = result.totalPages
                completion(.success(result.content))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }

    func updateInfoInServer(
        with photoContent: PhotoTypeContentViewModel,
        completion: @escaping (Result<PhotoResponse, Error>) -> Void
    ) {
        guard let url = URL(string: Constants.baseURL + "/api/v2/photo") else {
            completion(.failure(APIError.invalidURL))
            return
        }

        guard let imageData = photoContent.image.jpegData(compressionQuality: 0.8) else { return }

        // Формирование запроса

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        let filename = "photo_\(boundary).jpg"

        // Добавление текстового поля для name

        body.append(Data("--\(boundary)\r\n".utf8))
        body.append(Data("Content-Disposition: form-data; name=\"name\"\r\n\r\n".utf8))
        body.append(Data("\(photoContent.name)\r\n".utf8))

        // Добавление текстового поля для typeId

        body.append(Data("--\(boundary)\r\n".utf8))
        body.append(Data("Content-Disposition: form-data; name=\"typeId\"\r\n\r\n".utf8))
        body.append(Data("\(photoContent.id)\r\n".utf8))

        // Добавление текстового поля для photo

        body.append(Data("--\(boundary)\r\n".utf8))
        body.append(Data("Content-Disposition: form-data; name=\"photo\"; filename=\"\(filename)\"\r\n".utf8))
        body.append(Data("Content-Type: image/jpeg\r\n\r\n".utf8))

        body.append(imageData)

        body.append(Data("\r\n--\(boundary)--\r\n".utf8))

        request.httpBody = body

        // Создание задачи

        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data, error == nil else {
                completion(.failure(APIError.failedToGetData))
                return
            }

            do {
                let result = try JSONDecoder().decode(PhotoResponse.self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }

    // MARK: - Changing State of Downloading

    func setIsLoading(_ isLoading: Bool) {
        self.isLoading = isLoading
    }
}

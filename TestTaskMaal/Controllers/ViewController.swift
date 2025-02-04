//
//  ViewController.swift
//  TestTaskMaal
//
//  Created by Pavel Maal on 16.01.25.
//

import UIKit

class ViewController: UIViewController {

    private var models: [PhotoTypeContent] = []

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(PhotoTableViewCell.self, forCellReuseIdentifier: PhotoTableViewCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.estimatedRowHeight = (UIScreen.main.bounds.width/5) + 20
        return tableView
    }()

    // MARK: - Lifecycle of VC

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self

        positionOfSubviews()

        APICaller.shared.getPhotoTypes { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let models):
                    self?.models = models
                    self?.tableView.reloadData()
                case .failure(let error):
                    print(error.errorDescription ?? "")
                }
            }
        }
    }

    // MARK: - Subviews

    private func positionOfSubviews() {
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: - Table View Delegate and Data Source

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: PhotoTableViewCell.identifier,
            for: indexPath
        ) as? PhotoTableViewCell else {
            return UITableViewCell()
        }
        let model = models[indexPath.row]
        cell.configure(with: model)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastIndex = models.count - 1
        if indexPath.row == lastIndex {
            APICaller.shared.getMorePhotoTypes { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let moreModels):
                        self.models += moreModels
                        APICaller.shared.setIsLoading(false)
                        tableView.reloadData()
                    case .failure(let error):
                        print(error.localizedDescription)
                        APICaller.shared.setIsLoading(false)
                    }
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if APICaller.shared.isLoading {
            let spinner = UIActivityIndicatorView(style: .medium)
            spinner.startAnimating()
            return spinner
        }
        return nil
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return APICaller.shared.isLoading ? 50 : 0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let cameraVC = CameraViewController()
        let model = models[indexPath.row]
        cameraVC.onImageCaptured = { image in
            let photoTypeContent = PhotoTypeContentViewModel(id: model.id, name: "Мааль Павел Викторович", image: image)
            APICaller.shared.updateInfoInServer(with: photoTypeContent) { result in
                switch result {
                case .success(let response):
                    print("Данные загружены на сервер, ID - \(response.id)")
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        present(cameraVC, animated: true)
    }
}

//
//  PhotoTableViewCell.swift
//  TestTaskMaal
//
//  Created by Pavel Maal on 16.01.25.
//

import UIKit
import SDWebImage

class PhotoTableViewCell: UITableViewCell {

    static let identifier = "PhotoTableViewCell"

    private let idLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .lightGray
        label.text = "ID"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .black
        label.numberOfLines = 0
        label.text = "Name"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupPositionOfSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - TableViewCell Methods

    override func prepareForReuse() {
        idLabel.text = nil
        nameLabel.text = nil
        imageView?.image = nil
    }

    // MARK: - Subviews

    private func setupPositionOfSubviews() {
        self.addSubview(idLabel)
        self.addSubview(nameLabel)
        self.addSubview(photoImageView)

        let imageSize = UIScreen.main.bounds.width / 5

        let constraint = photoImageView.heightAnchor.constraint(equalToConstant: imageSize)
        constraint.priority = .defaultHigh

        NSLayoutConstraint.activate([
            photoImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10.0),
            photoImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10.0),
            photoImageView.widthAnchor.constraint(equalToConstant: imageSize),
            constraint,
            photoImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10.0),

            idLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10.0),
            idLabel.leadingAnchor.constraint(equalTo: photoImageView.trailingAnchor, constant: 10.0),
            idLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10.0),

            nameLabel.topAnchor.constraint(equalTo: idLabel.bottomAnchor, constant: 10.0),
            nameLabel.leadingAnchor.constraint(equalTo: photoImageView.trailingAnchor, constant: 10.0),
            nameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10.0),
            nameLabel.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor, constant: -10.0)
        ])
    }

    // MARK: - Model and Data

    func configure(with model: PhotoTypeContent) {
        idLabel.text = "\(model.id)"
        nameLabel.text = "\(model.name)"
        photoImageView.sd_setImage(with: URL(string: model.image ?? ""), completed: nil)
    }
}

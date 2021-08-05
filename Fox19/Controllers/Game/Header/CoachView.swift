//
//  CoachView.swift
//  Fox19
//
//  Created by Mykhailo Romanovskyi on 25.04.2021.
//

import UIKit
class CoachView: UIView {
    
    private let label = UILabel(text: "Организатор:",
                                font: UIFont(name: "Inter-Regular", size: 15),
                                textColor: UIColor(red: 97/255, green: 97/255, blue: 97/255, alpha: 1))
    
    private let nameLabel = UILabel(text: "Matthew McConaughey",
                                font: UIFont(name: "Inter-Regular", size: 15),
                                textColor: UIColor(red: 28/255, green: 44/255, blue: 78/255, alpha: 1))
    private let photoImageView = UIImageView()
    private let button = UIButton(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViewWithData(creatorImage: UIImage?, creatoreName: String?) {
        photoImageView.image = creatorImage
        nameLabel.text = creatoreName
    }
}

extension CoachView {
    private func configure() {
      //  backgroundColor = UIColor(red: 232/255, green: 242/255, blue: 252/255, alpha: 1)
        photoImageView.backgroundColor = .blue
        photoImageView.layer.cornerRadius = 32
        photoImageView.clipsToBounds = true
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(photoImageView)
        
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(nameLabel)
        
        button.setTitle("НАПИСАТЬ", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 14
        button.backgroundColor = UIColor(red: 33/255, green: 114/255, blue: 212/255, alpha: 1)
        button.titleLabel?.font = UIFont(name: "Inter-Regular", size: 12)
        button.translatesAutoresizingMaskIntoConstraints = false
        addSubview(button)
        
        NSLayoutConstraint.activate([
            photoImageView.widthAnchor.constraint(equalToConstant: 64),
            photoImageView.heightAnchor.constraint(equalToConstant: 64),
            photoImageView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            photoImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            button.widthAnchor.constraint(equalToConstant: 89),
            button.heightAnchor.constraint(equalToConstant: 28),
            button.centerYAnchor.constraint(equalTo: photoImageView.centerYAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            label.centerYAnchor.constraint(equalTo: photoImageView.centerYAnchor, constant: -10),
            label.leadingAnchor.constraint(equalTo: photoImageView.trailingAnchor, constant: 16),
            nameLabel.centerYAnchor.constraint(equalTo: photoImageView.centerYAnchor, constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: photoImageView.trailingAnchor, constant: 16),
            
        ])
    }
}

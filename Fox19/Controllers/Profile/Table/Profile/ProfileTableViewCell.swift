//
//  ProfileTableViewCell.swift
//  Fox19
//
//  Created by Артём Скрипкин on 08.11.2020.
//

import UIKit

protocol ManageUpdatedUserProtocol: class {
    /// - Returns: кортеж, где первое значение - обновленные данные, второе - indexPath ячейки(от него зависит тип данных)
    func manageText() -> (String?, IndexPath?)
}

protocol FillProfileCellProtocol: class {
    /// - Returns: пользователь, информацию о котором нужно изменить
    func getDataForCell() -> User?
    func showMyClubsViewController()
}

class ProfileTableViewCell: UITableViewCell {
    
    static let reusedId = "ProfileTableViewCell"
    
    //MARK: - Delegates
    weak var delegate: FillProfileCellProtocol?
    
    ///Показывает в каком контроллере используется ячейка
    private var isEditStyle: Bool = false
    
    ///В зависимости от расположения ячейки(и тип контроллера в котором она используется) выставляются ее данные
    private var indexPath: IndexPath?
    
    private var likes = ""
    
    //MARK: - UI Elements
    private lazy var label: UILabel = {
        let view = UILabel()
        view.backgroundColor = .white
        view.font = UIFont(name: "Avenir-Book", size: 17)
        view.textColor = .lightGray
        view.adjustsFontSizeToFitWidth = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    public lazy var textField: UITextField = {
        let view = UITextField()
        view.autocorrectionType = .no
        view.spellCheckingType = .no
        view.backgroundColor = .white
        view.font = UIFont(name: "Avenir-Black", size: 17)
        view.adjustsFontSizeToFitWidth = true
        let bar = UIToolbar()
        let done = UIBarButtonItem(title: "Готово", style: .done, target: self, action: #selector(hideKeyboard))
        bar.setItems([done], animated: true)
        bar.sizeToFit()
        view.inputAccessoryView = bar
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var separator: UIImageView = {
        let view = UIImageView(image: UIImage(named: "ProfileSeparator"))
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var insetView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        return view
    }()
    
    //MARK: - Methods
    private func setupConstraints() {
        contentView.addSubview(label)
        contentView.addSubview(textField)
        contentView.addSubview(separator)
        contentView.addSubview(insetView)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 50),
            label.topAnchor.constraint(equalTo: contentView.topAnchor),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -50),
            
            textField.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 6),
            textField.leadingAnchor.constraint(equalTo: label.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: label.trailingAnchor),
            
            separator.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 15),
            separator.leadingAnchor.constraint(equalTo: label.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: label.trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 2),
            
            insetView.heightAnchor.constraint(equalToConstant: 20),
            insetView.leadingAnchor.constraint(equalTo: label.leadingAnchor),
            insetView.trailingAnchor.constraint(equalTo: label.trailingAnchor),
            insetView.topAnchor.constraint(equalTo: separator.bottomAnchor),
            insetView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    @objc private func showMyClubsVC() {
        delegate?.showMyClubsViewController()
    }
    
    //MARK: - Configuring Cell
    func setData() {
        guard let int = indexPath?.row else { return }
        guard let data = delegate?.getDataForCell() else { return }
        if isEditStyle {
            switch int {
            case 0:
                label.text = "Имя"
                guard let name = data.name else { return }
                textField.textContentType = .givenName
                textField.placeholder = "Иван"
                textField.text = name
            case 1:
                label.text = "Идентификатор в реестре гольфистов"
                guard let golfId = data.golfRegistryIdRU else { return }
                textField.placeholder = "RUXXXXXX"
                textField.text = golfId
            case 2:
                label.text = "Обо мне"
                guard let aboutMe = data.about else { return }
                textField.text = aboutMe
            case 3:
                label.text = "Email"
                guard let email = data.email else { return }
                textField.textContentType = .emailAddress
                textField.keyboardType = .emailAddress
                textField.placeholder = "email@email.com"
                textField.clearsOnInsertion = true
                textField.autocapitalizationType = .none
                textField.text = email
            default:
                return
            }
        } else {
            isUserInteractionEnabled = false
            switch int {
            case 0:
                label.text = "Имя"
                guard let name = data.name else { return }
                textField.textContentType = .givenName
                textField.placeholder = "Иван"
                textField.text = name
            case 1:
                label.text = "Гандикап"
                guard let handicap = data.handicap else { return }
                textField.placeholder = "dd.d"
                textField.text = "\(handicap)"
            case 2:
                label.text = "Обо мне"
                guard let aboutMe = data.about else { return }
                textField.text = aboutMe
            case 3:
                isUserInteractionEnabled = true
                label.text = "Избранные клубы"
                textField.text = likes
                textField.isUserInteractionEnabled = false
                let tap = UITapGestureRecognizer(target: self,
                                                 action: #selector(showMyClubsVC))
                addGestureRecognizer(tap)
            case 4:
                label.text = "Email"
                guard let email = data.email else { return }
                textField.text = email
                textField.autocorrectionType = .no
                textField.textContentType = .emailAddress
                textField.placeholder = "email@email.com"
            case 5:
                label.text = "Статус"
                var status = ""
                if let admin = data.isAdmin,
                   let gamer = data.isGamer,
                   let referee = data.isReferee,
                   let trainer = data.isTrainer  {
                    if admin {
                        textField.text = "Админ"
                        break
                    }
                    var statusArray: [String] = []
                    if gamer { statusArray.append("Игрок") }
                    if trainer { statusArray.append("Тренер") }
                    if referee { statusArray.append("Судья") }
                    status = statusArray.joined(separator: ", ")
                }
                textField.text = status
            case 6:
                label.text = "Номер телефона"
                guard let phone = data.phone else { return }
                textField.textContentType = .telephoneNumber
                textField.text = phone
            case 7:
                label.text = "Идентификатор в реестре гольфистов"
                guard let golfId = data.golfRegistryIdRU else { return }
                textField.placeholder = "RUXXXXXX"
                textField.text = golfId
            default:
                return
            }
        }
    }
    
    public func setIndexPath(indexPath: IndexPath, isEditingVC: Bool, likes: String? = nil) {
        self.indexPath = indexPath
        self.isEditStyle = isEditingVC
        if let likes = likes {
            self.likes = likes
        }
        setData()
    }
    
    @objc private func hideKeyboard() {
        endEditing(true)
    }
    
    //MARK: - Inits
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - ManageUpdatedUserProtocol
extension ProfileTableViewCell: ManageUpdatedUserProtocol {
    func manageText() -> (String?, IndexPath?) {
        guard let indexPath = indexPath else { return (nil, nil) }
        guard let text = textField.text else { return (nil, nil) }
        return (text, indexPath)
    }
}

import UIKit

class ChatListCell: UICollectionViewCell {
    
    static let identifire = "ChatListCell"
    private var mainImageView = UIImageView(imageName: nil,
                                            playerGandicap: nil,
                                            image: UIImage(),
                                            fogLayer: false)
    
    private let messageImage = UIImageView(image: UIImage(named: "blueMessageIcon"))
    private let myLabel = UILabel(text: "Можно присоединиться",
                                  font: .avenir(fontSize: 12),
                                  textColor: #colorLiteral(red: 0.8274509804, green: 0.831372549, blue: 0.9294117647, alpha: 1))
    private let gandicap = UILabel(text: "0",
                                   font: .avenir(fontSize: 13),
                                   textColor: .white)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
      //  backgroundColor = .lightGray
        addSubview(mainImageView)
        addSubview(myLabel)
        addSubview(messageImage)
        addSubview(gandicap)
        
        mainImageView.translatesAutoresizingMaskIntoConstraints = false
        myLabel.translatesAutoresizingMaskIntoConstraints = false
        messageImage.translatesAutoresizingMaskIntoConstraints = false
        gandicap.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mainImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            mainImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainImageView.widthAnchor.constraint(equalToConstant: 41),
            mainImageView.heightAnchor.constraint(equalToConstant: 41),
            
            myLabel.centerYAnchor.constraint(equalTo: mainImageView.centerYAnchor),
            myLabel.leadingAnchor.constraint(equalTo: mainImageView.trailingAnchor, constant: 11),
            
            messageImage.centerYAnchor.constraint(equalTo: mainImageView.centerYAnchor),
            messageImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -11),
            
            gandicap.centerXAnchor.constraint(equalTo: mainImageView.centerXAnchor),
            gandicap.centerYAnchor.constraint(equalTo: mainImageView.centerYAnchor)
        ])
    }
    
    override func prepareForReuse() {
        mainImageView.image = UIImage(named: "user")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCell(user: User?) {
        if user?.avatar != nil {
            downloadImageForAvatar(user: user)
          //  print("\(user?.avatar)")
        } else {
            mainImageView.image = UIImage(named: "user")
        }
        
        gandicap.text = "\(user?.handicap ?? 0)"
        myLabel.text = user?.name
        myLabel.font = .avenir(fontSize: 15)
        myLabel.textColor = #colorLiteral(red: 0.1764705882, green: 0.2470588235, blue: 0.4, alpha: 1)
    }
    
    private func downloadImageForAvatar(user: User?) {
        guard let account = UserDefaults.standard.string(forKey: "number") else { return }
        ClubsNetworkManager.shared.downloadImageForCover(from: user?.avatar?.url ?? "", account: account) { (result) in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self.mainImageView.image = UIImage(data: data)
                    print("\(user?.name)")
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

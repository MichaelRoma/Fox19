import UIKit

class SmsVareficationViewController: UIViewController {
    
    private let topLabel = UILabel()
    private let middleLabel = UILabel()
    private let bottomLabel = UILabel()
    
    private lazy var codeTextField: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.textAlignment = .center
        view.textColor = .black
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor(named: "backgroundBlue")?.cgColor
        view.textContentType = .oneTimeCode
        view.keyboardType = .numberPad
        view.delegate = self
        return view
    }()
    
    private var data: AuthenticationModel!
    private var backgroundImageView: UIImageView!
    private var timer = Timer()
    private var seconds = 90
    
    func setupData(data: AuthenticationModel) {
        self.data = data
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupElements()
        switchKeyBoard()
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        runTimer()
        setNeedsStatusBarAppearanceUpdate()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundImageView.frame = view.bounds
    }
    
    private func setupElements() {
        backgroundImageView = UIImageView(image: UIImage(named: "LoginWithPhoneNumber"))
        backgroundImageView.contentMode = .scaleToFill
        view.insertSubview(backgroundImageView, at: 0)
        setupTopLabel()
        setCodeTextField()
        setPhoneNumber()
        setBottomLabel()
        handleTapToHideKeyboard()
    }
    
    private func setupTopLabel() {
        topLabel.text = "Введите код подтверждения"
        topLabel.textColor = .white
        topLabel.font = UIFont(name: "Avenir-Book", size: 17)
        topLabel.textAlignment = .center
        topLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topLabel)
        NSLayoutConstraint.activate([
            topLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
            topLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setPhoneNumber() {
        middleLabel.text = "Код выслан на \(data.phone)"
        middleLabel.textColor = .white
        middleLabel.font = UIFont(name: "SFProText-Regular", size: 16)
        middleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(middleLabel)
        NSLayoutConstraint.activate([
            middleLabel.topAnchor.constraint(equalTo: codeTextField.bottomAnchor, constant: 15),
            middleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setCodeTextField() {
        view.addSubview(codeTextField)
        NSLayoutConstraint.activate([
            codeTextField.topAnchor.constraint(equalTo: topLabel.bottomAnchor, constant: 17),
            codeTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            codeTextField.leadingAnchor.constraint(equalTo: topLabel.leadingAnchor),
            codeTextField.trailingAnchor.constraint(equalTo: topLabel.trailingAnchor),
            codeTextField.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    //Label Новый полученный код
    private func setBottomLabel() {
        bottomLabel.text = "Новый код можно получить \n через 00:\(seconds)"
        bottomLabel.numberOfLines = 2
        bottomLabel.textAlignment = .center
        bottomLabel.textColor = .white
        bottomLabel.font = UIFont(name: "SFProText-Regular", size: 16)
        bottomLabel.translatesAutoresizingMaskIntoConstraints = false
        bottomLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(getNewCode)))
        
        view.addSubview(bottomLabel)
        
        NSLayoutConstraint.activate([
            bottomLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bottomLabel.topAnchor.constraint(equalTo: middleLabel.bottomAnchor, constant: 19)
        ])
    }
    
    //Устанавливаем таймер
    private func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        seconds -= 1
        bottomLabel.text = "Новый код можно получить \n через 00:\(seconds)"
        if seconds < 10 {
            bottomLabel.text = "Новый код можно получить \n через 00:0\(seconds)"
        }
        if seconds < 1 {
            timer.invalidate()
            bottomLabel.isUserInteractionEnabled = true
            bottomLabel.text = "Получить новый код"
            
        }
    }
    
    @objc private func getNewCode() {
        middleLabel.text = "Подождите..."
        codeTextField.text = ""
        NetworkManager.shared.getCodeForVarification(witn: data.phone) {[weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                self.seconds = 10
                self.runTimer()
                self.data = data
            case .failure(let error):
                self.middleLabel.text = "Произошла ошибка"
                self.showAlert(title: "Возникла ошибка", message: "\(error)")
            }
        }
    }
    
    //Устанавливаем поднимание и опускание кейборда
    private func switchKeyBoard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height / 1.5
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    
    //Добавляет GestureRecognizer для нажатия на экран
    private func handleTapToHideKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    //Скрывает клавиатуру по тапу
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
}

extension SmsVareficationViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if let code = textField.text, code.count == 4 {
            hideKeyboard()
            NetworkManager.shared.sendSmsCode(with: data, smscode: code) {[weak self] (result) in
                guard let self = self else { return }
                switch result {
                case .success(let user):
                    DispatchQueue.main.async {
                        let vc = WelkomeViewController()
                        vc.setupData(data: user.user.id)
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                case .failure(let error):
                    self.showAlert(title: "Возникла ошибка", message: "\(error)")
                    textField.text = ""
                }
            }
        }
    }
}

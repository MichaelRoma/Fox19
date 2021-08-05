//
//  NewTournamentsViewController.swift
//  Fox19
//
//  Created by Артём Скрипкин on 14.05.2021.
//

import UIKit

class NewTournamentsViewController: UIViewController {
    
    private let segmentedCon: UISegmentedControl = {
        let items = ["Текущие","Прошедшие"]
       let control = UISegmentedControl(items: items)
        control.backgroundColor = UIColor(red: 176/255, green: 201/255, blue: 237/255, alpha: 1)
        control.selectedSegmentIndex = 0
        control.setTitleTextAttributes([
            .foregroundColor: UIColor.black,
            .font: UIFont(name: "Inter-Regular", size: 15) ?? UIFont.systemFont(ofSize: 15, weight: .medium)
        ], for: .normal)
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    
    private var tournaments: [Tournament] = [] {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.tableView.reloadData()
                print("""
                    updated
                    \(self.tournaments)
                    """
                    )
            }
        }
    }
    
    private lazy var tableView: UITableView = {
       // let view = UITableView(frame: self.view.frame, style: .grouped)
        let view = UITableView(frame: .zero, style: .plain)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.separatorStyle = .none
        view.register(NewTournamentTableViewCell.self, forCellReuseIdentifier: NewTournamentTableViewCell.reusedId)
        view.dataSource = self
        view.delegate = self
        view.backgroundColor = .white
        return view
    }()
    
    private func getAllTournaments() {
        guard let number = UserDefaults.standard.string(forKey: "number") else { return }
        TournamentsNetworkManager.shared.getAllChampionships(for: number) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                guard let tournaments = response.results else { return }
                self.tournaments = tournaments
            case .failure(let error):
                self.showAlert(title: "\(error)")
            }
        }
    }
    
    private func settingUpNavigationBar() {
        navigationItem.title = "Турниры"
        navigationController?.navigationBar.prefersLargeTitles = true
        let largeTitleAppearance = UINavigationBarAppearance()
        
        largeTitleAppearance.configureWithOpaqueBackground()
        largeTitleAppearance.backgroundImage = UIImage(named: "Rectangle")
        largeTitleAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        largeTitleAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont(name: "Inter-Regular", size: 33) ?? UIFont.systemFont(ofSize: 30, weight: .light)
        ]
        navigationController?.navigationBar.standardAppearance = largeTitleAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = largeTitleAppearance
        
        let imageMenuButton = UIImage(named: "TournamentsButton")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: imageMenuButton, style: .plain, target: self, action: #selector(navButton))
        navigationController?.navigationBar.tintColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getAllTournaments()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(segmentedCon)
        view.addSubview(tableView)
        settingUpNavigationBar()
        
        view.backgroundColor = .white
        
        NSLayoutConstraint.activate([
            segmentedCon.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            segmentedCon.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedCon.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: segmentedCon.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
        ])
    }
    
    @objc func navButton() {
        print(#function)
    }

}

//MARK: UITableViewDataSource
extension NewTournamentsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tournaments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewTournamentTableViewCell.reusedId) as? NewTournamentTableViewCell else { fatalError() }
        guard let tournament = tournaments.getElement(index: indexPath.row), let name = tournament.name, let isoDate = tournament.date?.value else {
            print("another error")
            return cell }
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-DD'T'HH:mm:ssZ"
        let text = "20 апреля 2021 в 10.00"
        cell.setup(tournament: .init(name: name, date: text))
        return cell
    }
}

//MARK: UITableViewDelegate
extension NewTournamentsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        88
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = NewDetailTournamentsViewController(tournament: tournaments[indexPath.row])
        navigationController?.pushViewController(vc, animated: true)
    }
}

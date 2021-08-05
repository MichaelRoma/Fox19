//
//  GamesViewController.swift
//  Fox19
//
//  Created by Mykhailo Romanovskyi on 14.01.2021.
//

import UIKit

class GamesViewControllerTest: UIViewController {
    private let titleColor = UIColor(red: 28/255, green: 44/255, blue: 78/255, alpha: 1)
    private let orangeColor = UIColor(red: 242/255, green: 122/255, blue: 42/255, alpha: 1)
    enum Section: Int, CaseIterable {
        case main
    }
    
    var games: [GamesModel.Game] = []
    
    private var currentUser: User?
    
    var collectionView: UICollectionView! = nil
    var dataSource: UICollectionViewDiffableDataSource<Section, GamesModel.Game>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        getGamesData()
     //   setupNavigationController()
        setupCollectionView()
        createDataSource()
        reloadData()
      //  getGamesData()
  //      createGameButton()
        getCurrentUser()
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       // getGamesData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       // setupNavigationController()
     //   getGamesData()
        setupNavigationController()
    }
}

//MARK: - Network
extension GamesViewControllerTest {
    func getGamesData() {
        guard let number = UserDefaults.standard.string(forKey: "number") else { return }
        guard let token = Keychainmanager.shared.getToken(account: number) else { return }
        
        GamesNetworkManager.shared.getGamesTest(token: token) { (result) in
            switch result {
            case .success(let result):
                DispatchQueue.main.async {
                    self.games = result.results
                    self.collectionView.reloadData()
                    self.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func getCurrentUser() {
        guard let number = UserDefaults.standard.string(forKey: "number") else { return }
        guard let token = Keychainmanager.shared.getToken(account: number) else { return }
        UserNetworkManager.shared.getUser(id: nil, token: token) { (result) in
            switch result {
            case .success(let user):
                self.currentUser = user
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

//MARK: - Setup CreateGameButton
extension GamesViewControllerTest {
    @objc private func createGameButtonAction() {
        print("Создать игру")
        let vc = GameCreateViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - Setup Navigation Controller
extension GamesViewControllerTest: UISearchBarDelegate {
    private func setupNavigationController() {
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = .white
        
        navigationController?.navigationBar.prefersLargeTitles = true

        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundImage = UIImage(named: "Rectangle")
        navBarAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont(name: "Merriweather-Regular", size: 30) ?? UIFont.systemFont(ofSize: 30, weight: .medium)
        ]
        navBarAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        setupSearchBar()
        navigationItem.title = "Игры"

        let imageSearchButton = UIImage(named: "SearchNav")
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: imageSearchButton, style: .plain, target: self, action: #selector(searchInGames))
        
        let imageSettingButton = UIImage(named: "Games")
       // let imageCreateGameButton = UIImage(named: "acceptButton")
        let imageCreateGameButton = UIImage(systemName: "plus.circle")
        let settingItem = UIBarButtonItem(image: imageSettingButton, style: .plain, target: self, action: #selector(filtrersInGames))
        let createGameItem = UIBarButtonItem(image: imageCreateGameButton, style: .plain, target: self, action: #selector(createGameButtonAction))
        
        navigationItem.rightBarButtonItems = [settingItem, createGameItem]
    }
    
    private func setupSearchBar() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "ПОИСК"
  //      searchController.searchBar.searchTextField.leftView?.tintColor = .white
        searchController.searchBar.showsCancelButton = false
        searchController.searchBar.delegate = self
        searchController.searchBar.searchTextField.backgroundColor = .white
        navigationItem.searchController = searchController
    }
    
    @objc private func searchInGames() {
        print("Seraching")
    }
    
    @objc private func filtrersInGames() {
        print("filtrersInGames")
    }
}

//MARK: Setup CollectionView
extension GamesViewControllerTest {
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: .zero,
                                          collectionViewLayout: createCompositionLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
       // collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
        collectionView.register(GameCollectionCell.self, forCellWithReuseIdentifier: GameCollectionCell.reuseid)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
    }
    
    private func createCompositionLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .absolute(178))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize,
                                                     subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 20
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 17, bottom: 0, trailing: 17)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    private func createDataSource() {
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: {
            (collectionview, indexPath, game) -> UICollectionViewCell? in
            guard let section = Section(rawValue: indexPath.section) else {
                fatalError("Unknown sectionKind")
            }
            switch section {
            case .main:
                let cell = collectionview.dequeueReusableCell(withReuseIdentifier: GameCollectionCell.reuseid, for: indexPath) as? GameCollectionCell
                cell?.cellConfigurator(game: game)
                return cell
            }
           
        })
    }
    
    private func reloadData() {
        var snapShot = NSDiffableDataSourceSnapshot<Section, GamesModel.Game>()
        snapShot.appendSections([.main])
        snapShot.appendItems(games, toSection: .main)
        dataSource?.apply(snapShot, animatingDifferences: true)
    }
}

//MARK: CollectionView Delegate
extension GamesViewControllerTest: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? GameCollectionCell
        
        guard let currentUser = currentUser else { return }
        let detail = DetailGameViewController(user: currentUser)
        
//        detail.setupData(image: cell?.clubImageView.image, game: games[indexPath.item], avatarImage: cell?.imageView)
        detail.setupData(image: cell?.clubImageView.image, game: games[indexPath.item], avatarImage: cell?.imageView.image)
        navigationController?.pushViewController(detail, animated: true)
    }
}

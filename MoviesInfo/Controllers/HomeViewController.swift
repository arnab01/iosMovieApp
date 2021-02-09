//
//  HomeViewController.swift
//  MoviesInfo
//
//  Created by Tobias Ruano on 21/07/2020.
//  Copyright © 2020 Tobias Ruano. All rights reserved.
//

import UIKit
import SwiftUI
class HomeViewController: UITableViewController {
    
    private var movies: [Movie] = []
    private var watchlist: [Movie] = []
    
    private var movieEndpoint: MovieInfoEndPoint!
    
    private let network = NetworkManager.shared
    private var pageNumber: Int = 1
    private var isLoadingMovies = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        //navigationController?.navigationBar.prefersLargeTitles = true
        configureTableView()
        //configureNavigationBar()
        movieRequest(of: .nowPlaying)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       // getWatchlist()
    }
    
    /*private func configureNavigationBar() {
        let image = UIImage(systemName: "ellipsis.circle")
        let action = #selector(changeEndPoint(sender:))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: action)
    }
    
    private func getWatchlist() {
        if let data = UserDefaults.standard.value(forKey: "watchlist") as? Data {
            let copy = try? PropertyListDecoder().decode([Movie].self, from: data)
            watchlist = copy!
        }
    }*/
    
    /*@objc private func changeEndPoint(sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Choose an option:", message: "", preferredStyle: .actionSheet)
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.barButtonItem = sender as UIBarButtonItem
        }
        
        alert.addAction(UIAlertAction(title: "Movies", style: .default, handler: { (UIAlertAction) in
            self.movieRequest(of: .nowPlaying)
        }))
        alert.addAction(UIAlertAction(title: "Upcoming", style: .default, handler: { (UIAlertAction) in
            self.movieRequest(of: .upcoming)
        }))
        alert.addAction(UIAlertAction(title: "Top Rated", style: .default, handler: { (UIAlertAction) in
            self.movieRequest(of: .topRated)
        }))
        alert.addAction(UIAlertAction(title: "Popular", style: .default, handler: { (UIAlertAction) in
            self.movieRequest(of: .popular)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true)
    }*/
    
    private func movieRequest(of type: MovieInfoEndPoint) {
        self.movieEndpoint = type
        self.movies.removeAll()
        self.pageNumber = 1
        self.requestMovies(page: self.pageNumber)
        switch type {
        case .nowPlaying:
            self.title = "Movies"
        case .popular:
            self.title = "Popular"
        case .topRated:
            self.title = "Top Rated"
        case .upcoming:
            self.title = "Upcoming"
        }
    }
    
    private func configureTableView() {
        tableView.register(MoviesCell.self, forCellReuseIdentifier: MoviesCell.reuseID)
        tableView.backgroundColor = .secondarySystemBackground
        tableView.rowHeight = 150
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MoviesCell.reuseID, for: indexPath) as! MoviesCell
        cell.setCell(with: movies[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movieInfo = movies[indexPath.row]
        let destVC = MovieInfoViewController()
        destVC.movie = movieInfo
        self.navigationController?.pushViewController(destVC, animated: true)
    }
    
//    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
//        for indexPath in indexPaths {
//            guard let _ = loadingOperations[indexPath] else { return }
//            if let dataLoader = dataStore.loadPhoto(at: indexPath.row) {
//                loadingQueue.addOperation(dataLoader)
//                loadingOperations[indexPath] = dataLoader
//            }
//        }
//    }
//    
//    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
//        for indexPath in indexPaths {
//            if let dataLoader = loadingOperations[indexPath] {
//                dataLoader.cancel()
//                loadingOperations.removeValue(forKey: indexPath)
//            }
//        }
//    }
    
    /*override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let AddAction = UIContextualAction(style: .normal, title:  "Add to Watchlist", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            self.addToWatchlist(movie: self.movies[indexPath.row])
            success(true)
        })
        AddAction.backgroundColor = .systemBlue
        return UISwipeActionsConfiguration(actions: [AddAction])
    }
    
    private func addToWatchlist(movie: Movie) {
        if !self.watchlist.contains(movie) {
            saveMovie(movie: movie)
            presentStatusAlert(icon: "text.badge.plus", message: "Movie Added to Watchlist")
            TapticEffectsService.performFeedbackNotification(type: .success)
        } else {
            removeFromWatchlist(movie: movie)
        }
    }
    
    private func saveMovie(movie: Movie) {
        self.watchlist.append(movie)
        UserDefaults.standard.set(try? PropertyListEncoder().encode(self.watchlist), forKey: "watchlist")
    }
    
    private func removeFromWatchlist(movie: Movie) {
        if let index = watchlist.firstIndex(of: movie) {
            watchlist.remove(at: index)
            UserDefaults.standard.set(try? PropertyListEncoder().encode(self.watchlist), forKey: "watchlist")
        }
        presentStatusAlert(icon: "text.badge.minus", message: "Movie Removed from Watchlist")
    }*/
    
    private func presentStatusAlert(icon: String, message: String) {
        let statusAlert = StatusAlert()
        statusAlert.image = UIImage(systemName: icon)
        statusAlert.title = "Done"
        statusAlert.message = message
        statusAlert.canBePickedOrDismissed = true
        statusAlert.showInKeyWindow()
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height / 2
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height {
            guard !isLoadingMovies else { return }
            isLoadingMovies = true
            pageNumber += 1
            requestMovies(page: pageNumber)
        }
    }
    
    func requestMovies(page: Int) {
        let requestURL = network.getMoviesURL(endpoint: movieEndpoint, page: page)
        network.fetchMovies(type: requestURL) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let movies):
                self.updateUI(with: movies)
            case .failure(let error):
                print("\(error): \(error.rawValue)")
            }
            self.isLoadingMovies = false
        }
    }
    
    private func updateUI(with movies: [Movie]) {
        self.movies.append(contentsOf: movies)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

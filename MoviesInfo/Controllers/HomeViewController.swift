

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

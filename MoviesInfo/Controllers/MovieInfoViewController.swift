
import UIKit

class MovieInfoViewController: UIViewController {
    
    private var similarMoviesView: UIView!
    private var castView: UIView!
    private var movieView: MovieCardView!
    private var backdropImage: MIHeaderImageView!
    private var backdropContainerView: UIView!
    private var scrollView: UIScrollView!
    private var contentView: UIView!
    
    var movie: Movie!
    private var watchlist: [Movie] = []
    private let network = NetworkManager.shared
    private let genre = GenreManager.shared
    private let imageCache = NSCache<AnyObject, AnyObject>()
    
    var constraint: NSLayoutConstraint!
    
    override public func viewDidLoad()  {
        super.viewDidLoad()
        //getWatchlist()
        configureStyle()
        configureScrollView()
        configureBackdropContainerView()
        configureBackdropImageView()
        configureContentView()
        backdropContainerViewBottomConstraint()
        configureMovieView()

    }
    
    override func viewDidLayoutSubviews() {
        updateMovieViewHeightConstraint()
    }
    
    private func configureStyle() {
        navigationItem.largeTitleDisplayMode = .never
        self.title = movie.title
        view.backgroundColor = .systemBackground
    }

    
    private func presentStatusAlert(icon: String, message: String) {
        let statusAlert = StatusAlert()
        statusAlert.image = UIImage(systemName: icon)
        statusAlert.title = "Done"
        statusAlert.message = message
        statusAlert.canBePickedOrDismissed = true
        
        statusAlert.showInKeyWindow()
    }
    
    private func configureScrollView() {
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
            scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func configureContentView() {
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 200),
            contentView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
    }
    
    private func configureBackdropContainerView() {
        backdropContainerView = UIView()
        scrollView.addSubview(backdropContainerView)
        backdropContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            backdropContainerView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            backdropContainerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            backdropContainerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
    }
    
    private func backdropContainerViewBottomConstraint() {
        let backdropContainerViewBottom : NSLayoutConstraint!
        backdropContainerViewBottom = self.backdropContainerView.bottomAnchor.constraint(equalTo: self.contentView.topAnchor)
        backdropContainerViewBottom.priority = UILayoutPriority(rawValue: 900)
        backdropContainerViewBottom.isActive = true
    }
    
    private func configureBackdropImageView() {
        backdropImage = MIHeaderImageView(frame: .zero)
        if let path = movie.backdropPath {
            backdropImage.downloadImage(fromPath: path)
        }
        backdropImage.contentMode = .scaleAspectFill
        backdropContainerView.addSubview(backdropImage)
        
        backdropImage.translatesAutoresizingMaskIntoConstraints = false
        
        let constraint = backdropImage.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor)
        constraint.priority = UILayoutPriority(900)
        constraint.isActive = true
        
        NSLayoutConstraint.activate([
            backdropImage.leadingAnchor.constraint(equalTo: backdropContainerView.leadingAnchor),
            backdropImage.trailingAnchor.constraint(equalTo: backdropContainerView.trailingAnchor),
            backdropImage.bottomAnchor.constraint(equalTo: backdropContainerView.bottomAnchor)
        ])
    }
    
    private func configureMovieView() {
        var genres: [String] = []
        if let genresIDs = movie.genreIds {
            genres = genre.getGenres(ids: genresIDs)
        }
        let date = movie.releaseDate?.convertToDisplayFormat() ?? "N/A"
        movieView = MovieCardView(title: movie.title, rating: movie.voteAverage, summary: movie.overview, info: date, genres: genres, runtime: movie.runtime)
        if let path = movie.posterPath {
            movieView.setMovieImage(from: path)
        } else {
            movieView.setMovieImage(from: "path")
        }
        contentView.addSubview(movieView)
        
        constraint = movieView.heightAnchor.constraint(equalToConstant: movieView.getMovieViewHeight())
        constraint.isActive = true
        
        NSLayoutConstraint.activate([
            movieView.topAnchor.constraint(equalTo: contentView.topAnchor),
            movieView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            movieView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
        ])
    }
    
    private func updateMovieViewHeightConstraint() {
        let height = movieView.getMovieViewHeight()
        constraint.constant = height
        self.view.layoutIfNeeded()
    }
    

}

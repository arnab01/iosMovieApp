
import UIKit

class MILoginButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        setLogin()
        layer.cornerRadius = 25
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setLogin() {
        setTitle("Login", for: .normal)
        backgroundColor = .systemBlue
    }
    
    func setLogout() {
        setTitle("Logout", for: .normal)
        UIView.animate(withDuration: 0.3) {
            self.backgroundColor = .systemRed
        }
    }
}

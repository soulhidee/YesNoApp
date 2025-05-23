import Foundation

final class MainPresenter {
    
    // MARK: - Properties
    private weak var view: MainViewProtocol?
    private let gifLoader: GifLoading
    private var currentAnswer: String?
    private let alertPresenter: AlertPresenterProtocol
    
    // MARK: - Initializer
    init(
        view: MainViewProtocol,
        gifLoader: GifLoading = GifLoader(),
        alertPresenter: AlertPresenterProtocol
    ) {
        self.view = view
        self.gifLoader = gifLoader
        self.alertPresenter = alertPresenter
    }
    
    // MARK: - Actions
    func actionButtonTapped() {
        view?.changeButtonTextColor()
        view?.animateElementsOut()
        view?.enableButton(false)
        loadGif()
    }
    
    func loadGifIfNeeded() {
        loadGif()
    }

    // MARK: - Helpers
    func getFormattedAnswer() -> String? {
        return currentAnswer?.capitalized
    }
    
    func getNormalizedAnswer() -> String? {
        return currentAnswer?.lowercased()
    }
    
    // MARK: - Private Methods
    private func loadGif() {
        view?.setActivityIndicator(visible: true)
        gifLoader.loadGif { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let gifResponse):
                    self?.currentAnswer = gifResponse.answer
                    self?.view?.loadGifInWebView(from: gifResponse.gif)
                    self?.view?.setActivityIndicator(visible: false)
                case .failure(let error):
                    self?.view?.setActivityIndicator(visible: false)
                    self?.handleError(error)
                }
            }
        }
    }
    
    private func handleError(_ error: Error) {
        let appError = error.toAppError()
        let alert = AlertFactory.createAlert(
            for: appError,
            onDismiss: { [weak self] in
                self?.loadGif()
            }
        )
        alertPresenter.show(alert: alert)
    }

    // MARK: - DEBUG
    #if DEBUG
    func setTestAnswer(_ answer: String?) {
        self.currentAnswer = answer
    }
    #endif
}

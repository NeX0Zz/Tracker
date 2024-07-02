import YandexMobileMetrica

final class Analytics {
    
    static let shared = Analytics()
    
    static func activate() {
        guard let configuration = YMMYandexMetricaConfiguration(apiKey: "d7f1adfe-0d2f-45e4-8ed5-488c882b2f8d") else { return }
        YMMYandexMetrica.activate(with: configuration)
    }
    
    func report(_ event: String, params : [AnyHashable : Any]) {
        YMMYandexMetrica.reportEvent(event, parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
}

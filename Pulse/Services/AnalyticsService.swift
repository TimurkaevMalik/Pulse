//
//  AnalyticsService.swift
//  Pulse
//
//  Created by Malik Timurkaev on 03.06.2024.
//

import Foundation
import YandexMobileMetrica

struct AnalyticsService {
    static func activate() {
        guard let configuration = YMMYandexMetricaConfiguration(apiKey: "068699ac-1bbd-4921-8ae5-b0799af4f23b") else { return }
        
        YMMYandexMetrica.activate(with: configuration)
    }
    
    static func report(event: String, params: [AnyHashable: Any]) {
        
        YMMYandexMetrica.reportEvent(event, parameters: params) { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        }
    }
}

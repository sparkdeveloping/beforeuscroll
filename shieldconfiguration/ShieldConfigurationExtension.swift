//
//  ShieldConfigurationExtension.swift
//  shieldconfiguration
//
//  Created by Denzel Nyatsanza on 5/20/26.
//

import ManagedSettings
import ManagedSettingsUI
import UIKit

class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    nonisolated override init() {
        super.init()
    }

    nonisolated override func configuration(shielding application: Application) -> ShieldConfiguration {
        makeConfiguration()
    }

    nonisolated override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        makeConfiguration()
    }

    nonisolated override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        makeConfiguration()
    }

    nonisolated override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        makeConfiguration()
    }

    private nonisolated func makeConfiguration() -> ShieldConfiguration {
        ShieldConfiguration(
            backgroundBlurStyle: .systemUltraThinMaterialDark,
            backgroundColor: Self.backgroundColor,
            icon: Self.pauseBadgeIcon(),
            title: ShieldConfiguration.Label(
                text: "Before you scroll…",
                color: .white
            ),
            subtitle: ShieldConfiguration.Label(
                text: "Prepare your pause, then open BeforeUScroll.",
                color: Self.subtitleColor
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "Prepare Pause",
                color: Self.primaryTextColor
            ),
            primaryButtonBackgroundColor: Self.goldColor,
            secondaryButtonLabel: ShieldConfiguration.Label(
                text: "Stay Locked",
                color: Self.secondaryTextColor
            )
        )
    }

    private nonisolated static var backgroundColor: UIColor {
        UIColor(red: 0.09, green: 0.10, blue: 0.12, alpha: 0.98)
    }

    private nonisolated static var surfaceColor: UIColor {
        UIColor(red: 0.14, green: 0.15, blue: 0.18, alpha: 1.0)
    }

    private nonisolated static var goldColor: UIColor {
        UIColor(red: 0.95, green: 0.76, blue: 0.38, alpha: 1.0)
    }

    private nonisolated static var goldShadowColor: UIColor {
        UIColor(red: 0.95, green: 0.72, blue: 0.32, alpha: 0.28)
    }

    private nonisolated static var primaryTextColor: UIColor {
        UIColor(red: 0.08, green: 0.07, blue: 0.04, alpha: 1.0)
    }

    private nonisolated static var subtitleColor: UIColor {
        UIColor.white.withAlphaComponent(0.78)
    }

    private nonisolated static var secondaryTextColor: UIColor {
        UIColor.white.withAlphaComponent(0.92)
    }

    private nonisolated static func pauseBadgeIcon() -> UIImage? {
        let size = CGSize(width: 96, height: 96)
        let renderer = UIGraphicsImageRenderer(size: size)

        let image = renderer.image { context in
            let rect = CGRect(origin: .zero, size: size)
            let cgContext = context.cgContext

            cgContext.setShadow(offset: CGSize(width: 0, height: 8), blur: 18, color: goldShadowColor.cgColor)
            goldShadowColor.setFill()
            UIBezierPath(ovalIn: rect.insetBy(dx: 10, dy: 10)).fill()
            cgContext.setShadow(offset: .zero, blur: 0, color: nil)

            surfaceColor.setFill()
            UIBezierPath(ovalIn: rect.insetBy(dx: 12, dy: 12)).fill()

            UIColor.white.withAlphaComponent(0.10).setStroke()
            let outerStroke = UIBezierPath(ovalIn: rect.insetBy(dx: 12.5, dy: 12.5))
            outerStroke.lineWidth = 1.5
            outerStroke.stroke()

            goldColor.setFill()
            UIBezierPath(ovalIn: rect.insetBy(dx: 24, dy: 24)).fill()

            primaryTextColor.setFill()
            let barWidth: CGFloat = 8
            let barHeight: CGFloat = 30
            let barY = (size.height - barHeight) / 2
            let leftBar = CGRect(x: 38, y: barY, width: barWidth, height: barHeight)
            let rightBar = CGRect(x: 50, y: barY, width: barWidth, height: barHeight)
            UIBezierPath(roundedRect: leftBar, cornerRadius: 3).fill()
            UIBezierPath(roundedRect: rightBar, cornerRadius: 3).fill()
        }

        return image.withRenderingMode(.alwaysOriginal)
    }
}

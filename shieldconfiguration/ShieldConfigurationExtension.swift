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
            icon: UIImage(named: "Icon") ?? Self.pauseBadgeIcon(),
            title: ShieldConfiguration.Label(
                text: "Your Flame is out.",
                color: .white
            ),
            subtitle: ShieldConfiguration.Label(
                text: "Open BeforeUScroll to recharge before the scroll gets you.",
                color: Self.subtitleColor
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "Prepare Recharge",
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
            // Draw a simple flame silhouette
            let flamePath = UIBezierPath()
            let centerX = size.width / 2
            let centerY = size.height / 2 + 5
            flamePath.move(to: CGPoint(x: centerX, y: centerY - 15))
            flamePath.addCurve(to: CGPoint(x: centerX + 10, y: centerY + 5), controlPoint1: CGPoint(x: centerX + 5, y: centerY - 10), controlPoint2: CGPoint(x: centerX + 12, y: centerY - 5))
            flamePath.addCurve(to: CGPoint(x: centerX, y: centerY + 15), controlPoint1: CGPoint(x: centerX + 8, y: centerY + 12), controlPoint2: CGPoint(x: centerX + 5, y: centerY + 15))
            flamePath.addCurve(to: CGPoint(x: centerX - 10, y: centerY + 5), controlPoint1: CGPoint(x: centerX - 5, y: centerY + 15), controlPoint2: CGPoint(x: centerX - 8, y: centerY + 12))
            flamePath.addCurve(to: CGPoint(x: centerX, y: centerY - 15), controlPoint1: CGPoint(x: centerX - 12, y: centerY - 5), controlPoint2: CGPoint(x: centerX - 5, y: centerY - 10))
            flamePath.fill()
        }

        return image.withRenderingMode(.alwaysOriginal)
    }
}

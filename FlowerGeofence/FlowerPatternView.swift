//
//  FlowerPatternView.swift
//  FlowerGeofence
//
//  Created by Dinesh Kumar A on 24/10/24.
//
import UIKit
import CoreLocation

class FlowerPatternView: UIView {
    
    private var innerRadius: CLLocationDistance = 35
    private var petalRadius: CLLocationDistance = 40
    private var outerRadius: CLLocationDistance = 80
    private var petalOffset: CLLocationDistance = 32
    private var outerOffset: CLLocationDistance = 10
    var numberOfPetals: Int = 6
    var centerLocation: CGPoint {
        return CGPoint(x: bounds.midX, y: bounds.midY) // Center based on the view's bounds
    }
    
    func updateFlowerPattern(innerRadius: CLLocationDistance, petalRadius: CLLocationDistance, outerRadius: CLLocationDistance, petalOffset: CLLocationDistance, outerOffset: CLLocationDistance) {
        self.innerRadius = innerRadius
        self.petalRadius = petalRadius
        self.outerRadius = outerRadius
        self.petalOffset = petalOffset
        self.outerOffset = outerOffset
        setNeedsDisplay()
    }
    
    // Override the draw method to perform custom drawing
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // Clear the context
        context.clear(rect)
        // Draw a white background for the view
        context.setFillColor(UIColor.gray.cgColor)
        context.fill(rect) // Fill the entire view with white
        
        // Draw Inner Circle
        // Set the stroke color and line width
        context.setStrokeColor(UIColor.yellow.cgColor)
        context.setLineWidth(2)
        context.setFillColor(UIColor.yellow.withAlphaComponent(0.1).cgColor)
        drawCircle(context: context, center: centerLocation, radius: innerRadius, fill: true)
        drawCircle(context: context, center: centerLocation, radius: innerRadius, fill: false)
        
        // Draw Petal Geofences
        context.setStrokeColor(UIColor.systemPink.cgColor) // Color for petals
        context.setLineWidth(2)
        context.setFillColor(UIColor.systemPink.withAlphaComponent(0.1).cgColor)
        let angleStep = 360.0 / Double(numberOfPetals)
        for i in 0..<numberOfPetals {
            let angle = angleStep * Double(i) * .pi / 180.0
            let petalCenter = calculatePetalCenter(from: centerLocation, radius: innerRadius + petalOffset, angle: angle)
            drawCircle(context: context, center: petalCenter, radius: petalRadius, fill: false)
            drawCircle(context: context, center: petalCenter, radius: petalRadius, fill: true)
        }
        
        // Draw Outer Circle
        context.setStrokeColor(UIColor.green.cgColor)
        context.setLineWidth(2)
        context.setFillColor(UIColor.green.withAlphaComponent(0.1).cgColor)
        let outerGeofenceRadius = innerRadius + petalOffset + petalRadius + outerOffset
        drawCircle(context: context, center: centerLocation, radius: outerGeofenceRadius, fill: false)
        drawCircle(context: context, center: centerLocation, radius: outerGeofenceRadius, fill: true)
        
        // Draw MasterExit Circle
        context.setStrokeColor(UIColor.blue.cgColor)
        context.setLineWidth(2)
        context.setFillColor(UIColor.green.withAlphaComponent(0.1).cgColor)
        let masterOuterGeofenceRadius = outerGeofenceRadius * 1.2
        drawCircle(context: context, center: centerLocation, radius: masterOuterGeofenceRadius, fill: false)
        drawCircle(context: context, center: centerLocation, radius: masterOuterGeofenceRadius, fill: true)
    }
    
    private func drawCircle(context: CGContext, center: CGPoint, radius: CGFloat, fill: Bool) {
        context.addEllipse(in: CGRect(x: center.x - radius, y: center.y - radius, width: 2 * radius, height: 2 * radius))
        if fill {
            context.fillPath()
        } else {
            context.strokePath()
        }
    }
    
    private func calculatePetalCenter(from center: CGPoint, radius: CGFloat, angle: Double) -> CGPoint {
        let xOffset = radius * CGFloat(cos(angle))
        let yOffset = radius * CGFloat(sin(angle))
        return CGPoint(x: center.x + xOffset, y: center.y + yOffset)
    }
}

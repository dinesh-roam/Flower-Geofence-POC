//
//  FlowerPatternViewController.swift
//  FlowerGeofence
//
//  Created by Dinesh Kumar A on 24/10/24.
//
import UIKit
import CoreLocation

class FlowerPatternViewController: UIViewController {
    
    // Sliders and Labels for parameters
    private let innerRadiusLabel = UILabel()
    private let innerRadiusSlider = UISlider()
    private let innerRadiusValueLabel = UILabel()
    
//    private let petalRadiusLabel = UILabel()
//    private let petalRadiusSlider = UISlider()
//    private let petalRadiusValueLabel = UILabel()
//    
//    private let petalOffsetLabel = UILabel()
//    private let petalOffsetSlider = UISlider()
//    private let petalOffsetValueLabel = UILabel()
//    
//    private let outerOffsetLabel = UILabel()
//    private let outerOffsetSlider = UISlider()
//    private let outerOffsetValueLabel = UILabel()
    
    
    private let valuesLabel = UILabel()
    
    private var flowerPatternView = FlowerPatternView()
    
    
    
    var petalRadiusValue: Double = 0.0
    var petalOffsetValue: Double = 0.0
    var outerRadiusValue: Double = 0.0
    var outerOffsetValue: Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupUI()
        setupConstraints()
    }
    
    private func setupUI() {
        // Set up the sliders and labels
        setupSlider(innerRadiusSlider, minValue: 25, maxValue: 250, value: 35)
//        setupSlider(petalRadiusSlider, minValue: 30, maxValue: 250, value: 40)
//        setupSlider(petalOffsetSlider, minValue: 0, maxValue: 150, value: 32)
//        setupSlider(outerOffsetSlider, minValue: 10, maxValue: 50, value: 20)
        
        // Labels
        innerRadiusLabel.text = "Inner Radius"
//        petalRadiusLabel.text = "Petal Radius"
//        petalOffsetLabel.text = "Petal Offset"
//        outerOffsetLabel.text = "Outer Offset"
        
        // Adding target for slider changes
        innerRadiusSlider.addTarget(self, action: #selector(innerRadiusChanged), for: .valueChanged)
//        petalRadiusSlider.addTarget(self, action: #selector(petalRadiusChanged), for: .valueChanged)
//        petalOffsetSlider.addTarget(self, action: #selector(petalOffsetChanged), for: .valueChanged)
//        outerOffsetSlider.addTarget(self, action: #selector(outerOffsetChanged), for: .valueChanged)
        
        // Add all elements to the view
        [innerRadiusLabel, innerRadiusSlider, innerRadiusValueLabel,
//         petalRadiusLabel, petalRadiusSlider, petalRadiusValueLabel,
//         petalOffsetLabel, petalOffsetSlider, petalOffsetValueLabel,
         ].forEach {
            view.addSubview($0)
        }
        view.addSubview(valuesLabel)
        valuesLabel.numberOfLines = 3
        // Setup Flower Pattern View
//        flowerPatternView = FlowerPatternView(frame: CGRect(x: 0, y: 400, width: view.frame.width, height: 500))
//        flowerPatternView.backgroundColor = .white
//        view.addSubview(flowerPatternView)
        
        // Initial values display
        loadFlowerPatternValues()
        updateSliderValues()
    }
    
    private func setupSlider(_ slider: UISlider, minValue: Float, maxValue: Float, value: Float) {
        slider.minimumValue = minValue
        slider.maximumValue = maxValue
        slider.value = value
    }
    
    private func setupConstraints() {
        // This example uses auto-layout programmatically for vertical stack-like alignment
        
        // Disable autoresizing mask translation
        [innerRadiusLabel, innerRadiusSlider, innerRadiusValueLabel,
//         petalRadiusLabel, petalRadiusSlider, petalRadiusValueLabel,
//         petalOffsetLabel, petalOffsetSlider, petalOffsetValueLabel,
//         outerOffsetLabel, outerOffsetSlider, outerOffsetValueLabel
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        valuesLabel.translatesAutoresizingMaskIntoConstraints = false
        flowerPatternView.backgroundColor = .white
        flowerPatternView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(flowerPatternView)
        
        // Constraints for the Inner Radius row
        NSLayoutConstraint.activate([
            innerRadiusLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            innerRadiusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            innerRadiusSlider.centerYAnchor.constraint(equalTo: innerRadiusLabel.centerYAnchor),
            innerRadiusSlider.leadingAnchor.constraint(equalTo: innerRadiusLabel.trailingAnchor, constant: 20),
            innerRadiusSlider.trailingAnchor.constraint(equalTo: innerRadiusValueLabel.leadingAnchor, constant: -10),
            
            innerRadiusValueLabel.centerYAnchor.constraint(equalTo: innerRadiusSlider.centerYAnchor),
            innerRadiusValueLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        // Constraints for the Petal Radius row
//        NSLayoutConstraint.activate([
//            petalRadiusLabel.topAnchor.constraint(equalTo: innerRadiusSlider.bottomAnchor, constant: 20),
//            petalRadiusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            
//            petalRadiusSlider.centerYAnchor.constraint(equalTo: petalRadiusLabel.centerYAnchor),
//            petalRadiusSlider.leadingAnchor.constraint(equalTo: petalRadiusLabel.trailingAnchor, constant: 20),
//            petalRadiusSlider.trailingAnchor.constraint(equalTo: petalRadiusValueLabel.leadingAnchor, constant: -10),
//            
//            petalRadiusValueLabel.centerYAnchor.constraint(equalTo: petalRadiusSlider.centerYAnchor),
//            petalRadiusValueLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
//        ])
        
        // Constraints for the Petal Offset row
        NSLayoutConstraint.activate([
//            petalOffsetLabel.topAnchor.constraint(equalTo: petalRadiusSlider.bottomAnchor, constant: 20),
//            petalOffsetLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            
//            petalOffsetSlider.centerYAnchor.constraint(equalTo: petalOffsetLabel.centerYAnchor),
//            petalOffsetSlider.leadingAnchor.constraint(equalTo: petalOffsetLabel.trailingAnchor, constant: 20),
//            petalOffsetSlider.trailingAnchor.constraint(equalTo: petalOffsetValueLabel.leadingAnchor, constant: -10),
//            
//            petalOffsetValueLabel.centerYAnchor.constraint(equalTo: petalOffsetSlider.centerYAnchor),
//            petalOffsetValueLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            valuesLabel.topAnchor.constraint(equalTo: innerRadiusValueLabel.bottomAnchor, constant: 40),
            valuesLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            valuesLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            valuesLabel.heightAnchor.constraint(equalToConstant: 80),
//            valuesLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            
            flowerPatternView.topAnchor.constraint(equalTo: valuesLabel.bottomAnchor, constant: 50),
            flowerPatternView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            flowerPatternView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            flowerPatternView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            
            
            
            
            
        ])

    }
    
    // Methods to handle slider changes
    @objc private func innerRadiusChanged() {
        updateSliderValues()
        // Logic to update flower pattern based on new inner radius value
    }
    
    @objc private func petalRadiusChanged() {
        updateSliderValues()
        // Logic to update flower pattern based on new petal radius value
    }
    
    @objc private func petalOffsetChanged() {
        updateSliderValues()
        // Logic to update flower pattern based on new petal offset value
    }
    
    @objc private func outerOffsetChanged() {
        updateSliderValues()
        // Logic to update flower pattern based on new outer offset value
    }
    
    // Update the displayed values beside each slider
    private func updateSliderValues() {
        innerRadiusValueLabel.text = String(format: "%.1f", innerRadiusSlider.value)
//        petalRadiusValueLabel.text = String(format: "%.1f", petalRadiusSlider.value)
//        petalOffsetValueLabel.text = String(format: "%.1f", petalOffsetSlider.value)
//        outerOffsetValueLabel.text = String(format: "%.1f", outerOffsetSlider.value)
        
        saveFlowerPatternValues()
        updateFlowerPattern()
    }
    
    private func loadFlowerPatternValues() {
        let defaults = UserDefaults.standard

        if defaults.double(forKey: "innerRadius") != 0 {
            let innerRadius = defaults.double(forKey: "innerRadius")
            innerRadiusSlider.value = Float(innerRadius)  // Sync slider
        }
        if defaults.double(forKey: "petalRadius") != 0 {
           let petalRadius = defaults.double(forKey: "petalRadius")
//            petalRadiusSlider.value = Float(petalRadius)  // Sync slider
        }
        if defaults.double(forKey: "petalOffset") != 0 {
            let petalOffset = defaults.double(forKey: "petalOffset")
//            petalOffsetSlider.value = Float(petalOffset)  // Sync slider
        }

    }
    
    // Save the current flower pattern values to UserDefaults
    private func saveFlowerPatternValues() {
        let innerRadius = CGFloat(innerRadiusSlider.value)
//        let petalRadius = CGFloat(petalRadiusSlider.value)
//        let petalOffset = CGFloat(petalOffsetSlider.value)
        UserDefaults.standard.set(innerRadius, forKey: "innerRadius")
//        UserDefaults.standard.set(petalRadius, forKey: "petalRadius")
//        UserDefaults.standard.set(petalOffset, forKey: "petalOffset")
        //            UserDefaults.standard.set(outerRadius, forKey: "outerRadius")
        //            UserDefaults.standard.set(outerOffset, forKey: "outerOffset")
        //            UserDefaults.standard.set(numberOfPetals, forKey: "numberOfPetals")
    }

    
    // Update Flower Pattern View
    private func updateFlowerPattern() {
        let innerRadius = CGFloat(innerRadiusSlider.value)
        
        // Define dynamic petal offset and radius based on the innerRadius
        let petalOffset = innerRadius * GeofenceConstants.petalOffset     // Offset for petals from the inner geofence (50% of innerRadius)
        let petalRadius = innerRadius * GeofenceConstants.petalRadius        // Radius of each petal geofence (30% of innerRadius)
        let outerOffset = innerRadius * GeofenceConstants.outerOffset        // Offset for outer geofence from the petals (20% of innerRadius)
        let outerRadius = innerRadius + petalOffset + petalRadius + outerOffset
        
        //
        petalOffsetValue = petalOffset
        petalRadiusValue = petalRadius
        outerRadiusValue = outerRadius
        outerOffsetValue = outerOffset
        
        let minimumDistance = calculateMinimumDistanceToPetalEdge(innerRadius: innerRadius, petalOffset: petalOffset, petalRadius: petalRadius)
        
        valuesLabel.text = """
Petal Radius:  \(String(format: "%.1f", petalRadiusValue))    Petal Offset: \(String(format: "%.1f", petalOffsetValue))
Outer Radius: \(String(format: "%.1f", outerRadiusValue))    Outer Offset: \(String(format: "%.1f", outerOffsetValue))
Minimum distance to petal edge: \(String(format: "%.1f", minimumDistance)) meters
"""
        
        

        flowerPatternView.updateFlowerPattern(innerRadius: innerRadius, petalRadius: petalRadius, outerRadius: outerRadius, petalOffset: petalOffset, outerOffset: outerOffset)
    }
    
    
    func calculateMinimumDistanceToPetalEdge(innerRadius: CLLocationDistance, petalOffset: CLLocationDistance, petalRadius: CLLocationDistance) -> CLLocationDistance {
        let centerToPetalCenter = innerRadius + petalOffset
        let minimumDistance = centerToPetalCenter - petalRadius
        return max(0, minimumDistance) // Ensures distance is not negative
    }
}

struct GeofenceConstants {
//    static let petalOffset =  0.95
//    static let petalRadius =  1.2
//    static let outerOffset =  0.6
    
    static let petalOffset =  0.95
    static let petalRadius =  1.2
    static let outerOffset =  0.6
}

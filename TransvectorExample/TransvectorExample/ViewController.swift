//
//  ViewController.swift
//  TransvectorExample
//
//  Created by Wong, Kevin a on 2019/05/14.
//  Copyright © 2019 Kevin Wong. All rights reserved.
//

import UIKit
import Transvector

class ViewController: UIViewController {

    let parser = SVGStrokeParser()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animateVector()
    }
    
    func animateVector() {
        parser.vectorView(filename: "testPath2") { [weak self] view in
            guard let view = view else { return }
            // Apply some position correction based on stroke offsets, since
            // this library only detects path size
            view.setPathVsStrokeCorrection(totalExtraX: 1.22, totalExtraY: 0.61, topStrokeOffset: 0.61)
            self?.view.addSubview(view)
            // Use frames or Autolayout
            //view.frame = CGRect(x: 100, y: 100, width: 200, height: 200)
            if let cView = self?.view {
                view.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    view.topAnchor.constraint(equalTo: cView.topAnchor),
                    view.bottomAnchor.constraint(equalTo: cView.bottomAnchor),
                    view.leftAnchor.constraint(equalTo: cView.leftAnchor),
                    view.rightAnchor.constraint(equalTo: cView.rightAnchor),
                    ])
            }
            view.animate(duration: 1, sequential: false)
        }
    }
}


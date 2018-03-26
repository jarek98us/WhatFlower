//
//  ViewController.swift
//  WhatFlower
//
//  Created by Jarek on 25/03/2018.
//  Copyright © 2018 Jarek. All rights reserved.
//

import UIKit
import CoreML
import Vision
import SDWebImage

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    let imagePicker = UIImagePickerController()
    let wikipediaReader = WikipediaReader()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker.delegate = self
        
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .photoLibrary
        } else {
            imagePicker.sourceType = .camera
        }
        imagePicker.allowsEditing = true
        
        descriptionLabel.text = ""
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func detect(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: FlowerClassifier().model) else {
            fatalError("Loading ML model failed")
        }

        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Error loading classification results")
            }

            if let firstResult = results.first {
                let flowerName = firstResult.identifier.capitalized
                self.navigationItem.title  = flowerName
                
                self.wikipediaReader.readExtract(about: flowerName, completion: { (extract, imageUrl) in
                    print(extract)
                    self.descriptionLabel.text = extract
                    self.photoImageView.sd_setImage(with: URL(string: imageUrl))
                })
            }
        }

        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        } catch {
            print("Error permorming ML request: \(error)")
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let takenPhoto = info[UIImagePickerControllerEditedImage] as? UIImage {
            photoImageView.image = takenPhoto
            guard let ciImage = CIImage(image: takenPhoto) else {
                fatalError("Could not convert photo to CIImage")
            }
            
            descriptionLabel.text = ""
            detect(image: ciImage)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cameraButtonClicked(_ sender: Any) {
         present(imagePicker, animated: true, completion: nil)
    }
}


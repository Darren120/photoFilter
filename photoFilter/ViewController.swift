//
//  ViewController.swift
//  photoFilter
//
//  Created by Darren on 8/25/17.
//  Copyright © 2017 Darren. All rights reserved.
//

import UIKit
import CoreImage
class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var intensityLabel: UILabel!
    @IBOutlet weak var changeFilter: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var intensity: UISlider!
    var currentImage: UIImage!
    // CIContact is a class for rendering images
    var context: CIContext!
    var currentFilter: CIFilter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(importPicture))
        context = CIContext()
        currentFilter = CIFilter(name: "CISepiaTone")
        changeFilter.setTitle("CISepiaTone", for: .normal)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func importPicture(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
        
    }
    // refer to project 10 for notes on image stuff.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else  { return }
        dismiss(animated: true)
        // currentImage is of type UIImage so it's like another check to make sure it takes in only image values i guess..
        currentImage = image
        // CIFilter only takes in CImage so we convert it first
        let beginImage = CIImage(image: currentImage)
        //Sets an image that the filter will affect. Think of it as a dictionary. The kCIInputImageKey means the picture that you wish this filter will work with which we set to beginImage. Now currentFilter will have that image.
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
       
        applyProcessing()
    }
    
    func applyProcessing(){
        //If the filter that we set uses a certain type of key like radius value or just simply intensity value then it will use that so the app won't crash since not all filters use the same type of intensity
        // On
        let inputKeys = currentFilter.inputKeys
        //Using this method, we check each of our four keys to see whether the current filter supports it, and, if so, we set the value. Since we set the filter to a specific type it will find the intensity type that supports it.
        if inputKeys.contains(kCIInputIntensityKey) { currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey)
            intensityLabel.text = "Intensity"
        }
        if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(intensity.value * 200, forKey: kCIInputRadiusKey)
            intensityLabel.text = "Radius level"
        }
        if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(intensity.value * 10, forKey: kCIInputScaleKey)
        intensityLabel.text = "Intensity"
        }
        if inputKeys.contains(kCIInputCenterKey) { currentFilter.setValue(CIVector(x: currentImage.size.width / 2, y: currentImage.size.height / 2), forKey: kCIInputCenterKey)
            intensityLabel.text = "Radius level"
        }

        // first paramater creates a CGImage from the image provided and the second paramater is the size of the image. Basically compiles and sizes it.
        if let cgimg = context.createCGImage(currentFilter.outputImage!, from: currentFilter.outputImage!.extent){
            // converts it back to UI.
            let processedImage = UIImage(cgImage: cgimg)
            imageView.image = processedImage
           
        }
        
    }
 
    @IBAction func changeFilter(_ sender: Any) {
        let ac = UIAlertController(title: "Change Filter", message: "Pick a filter", preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "CIBumpDistortion", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIGaussianBlur", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIPixellate", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CISepiaTone", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CITwirlDistortion", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIUnsharpMask", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIVignette", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac,animated: true)
       
        
    }
    
    func setFilter(action: UIAlertAction!){
        guard currentImage != nil else { return }
        currentFilter = CIFilter(name: action.title!)
        let processedImage = CIImage(image: currentImage)
        currentFilter.setValue(processedImage, forKey: kCIInputImageKey)
        changeFilter.setTitle(action.title!, for: .normal)
        
        
        applyProcessing()
        
        
    }
    @IBAction func save(_ sender: Any) {
        if currentImage == nil {
            let ac = UIAlertController(title: "No Image", message: "Please import a image", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(ac,animated: true)
        } else {
            // The selector method can be written plainly as #selector(image) but this way gives the reader and the coder as to what the selector do.
            //The self part is basicaly saying the selector method will exist in this class.
            UIImageWriteToSavedPhotosAlbum(currentImage, self, #selector(image(image:error:contextInfo:)), nil)
        }
        
    }
 
    @IBAction func intensityChanged(_ sender: Any) {
           applyProcessing()
    }
    
    func image(image: UIImage, error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let ac = UIAlertController(title: "Error", message: "There was an error processing your request", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: nil, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(ac,animated: true)
            
            
        }
    }
    
    
    

}


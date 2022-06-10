//
//  ViewController.swift
//  firebaseImageUpload
//
//  Created by user217360 on 6/7/22.
//

import UIKit
import PhotosUI
import FirebaseStorage

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    private let storage = Storage.storage().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navigationController?.navigationBar.prefersLargeTitles = true
        fetchImageFromCloud()
    }
    
    
    @IBAction func didTapButton(_ sender: UIButton) {
        var config = PHPickerConfiguration()
        //maximum slected photo, zero for unlimited
        config.selectionLimit = 1
        config.filter = PHPickerFilter.images
        let pickerVC = PHPickerViewController(configuration: config)
        pickerVC.delegate = self
        self.present(pickerVC, animated: true, completion: nil)
    }
    
    func uploadImageData(data: Data) {
        storage.child("Uploaded Images/image.png").putData(data) { _, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchImageFromCloud() {
        let storageRef = storage.child("Uploaded Images/image.png")
        storageRef.getData(maxSize: 20 * 1024 * 1024) { [weak self] maybeData, maybeError in
            guard let data = maybeData,
                  maybeError == nil,
                let imageFromCloude = UIImage(data: data) else {
                return
            }
            DispatchQueue.main.async {
                self?.imageView.image = imageFromCloude
            }
        }
    }
}

extension ViewController : PHPickerViewControllerDelegate{
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let provider = results.first?.itemProvider else {
            return
        }
        if provider.canLoadObject(ofClass: UIImage.self) {
            provider.loadObject(ofClass: UIImage.self, completionHandler: { [weak self] maybeImage, maybeError in
                guard let image = maybeImage as? UIImage,
                      maybeError == nil,
                      let imageData = image.pngData() else {
                    return
                }
                DispatchQueue.main.async {
                    self?.imageView.image = image
                }
                //upload image
                self?.uploadImageData(data: imageData)
            })
        }
    }
}


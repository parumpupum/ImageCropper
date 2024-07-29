import UIKit
import Photos

final class ViewController: UIViewController {

    // - UI
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var exportButton: UIButton!
    @IBOutlet weak var filterSwitch: UISwitch!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var viewForImage: UIView!
    private var holeView: HoleView?
    
    // - Data
    private var originalImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewDidLayoutSubviews() {
        holeView?.removeFromSuperview()
        holeView = HoleView(frame: viewForImage.bounds)
        viewForImage.addSubview(holeView!)
    }
    
    //MARK: - ButtonActions
    @IBAction func choosePhotoButtonTouch(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.delegate = self
        present(vc, animated: true)
    }
    
    @IBAction func filterSwitchDidChangeValue(_ sender: Any) {
        switch (sender as! UISwitch).isOn {
        case true:
            guard let originalImage = originalImage else { return }
            
            // Создаем CIImage с учетом ориентации
            let ciImage = CIImage(image: originalImage)
            let filter = CIFilter(name: "CIColorControls")
            filter?.setValue(ciImage, forKey: kCIInputImageKey)
            filter?.setValue(0.0, forKey: kCIInputSaturationKey) // Устанавливаем насыщенность в 0 для черно-белого эффекта
            
            if let outputImage = filter?.outputImage {
                let context = CIContext()
                if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                    // Создаем UIImage с учетом ориентации
                    let filteredImage = UIImage(cgImage: cgImage, scale: originalImage.scale, orientation: originalImage.imageOrientation)
                    imageView.image = filteredImage
                }
            }
            
        case false:
            if let originalImage = originalImage {
                imageView.image = originalImage
            }
        }
    }
    
    @IBAction func saveButtonTouch(_ sender: Any) {
        if let croppedImmage = holeView?.captureImageInHoleArea() {
            if PHPhotoLibrary.authorizationStatus(for: .addOnly) == .notDetermined {
                PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                    DispatchQueue.main.async {
                        self.saveButtonTouch(self)
                    }
                }
                return
            }
            
            switch PHPhotoLibrary.authorizationStatus(for: .addOnly) {
            case .authorized, .limited:
                DispatchQueue.main.async {
                    UIImageWriteToSavedPhotosAlbum(croppedImmage, nil, nil, nil)
                    
                    let alert = UIAlertController(title: "Success", message: "Cropped photo successfully added to your photo library", preferredStyle: .alert)
                    self.present(alert, animated: true)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                        alert.dismiss(animated: true)
                    })
                }
            default:
                let alert = UIAlertController(title: "Error", message: "Open settings and give app access to your photo library", preferredStyle: .alert)
                
                let okButton = UIAlertAction(title: "OK", style: .default) { _ in
                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                        return
                    }
                    
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                            print("Settings opened: \(success)") // Prints true
                        })
                    }
                }
                alert.addAction(okButton)
                
                let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
                alert.addAction(cancelButton)
                
                present(alert, animated: true)
            }
        }
    }
    
    
    func setImage(image: UIImage) {
        originalImage = image
        
        let height = image.size.height
        let width = image.size.width
        
        var viewHeight = 0.0
        var viewWidth = 0.0
        
        viewHeight = viewForImage.bounds.height
        viewWidth = width * viewHeight / height
        
        imageView.heightAnchor.constraint(equalToConstant: viewHeight).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: viewWidth).isActive = true
        
        imageView.image = image
        imageView.layer.masksToBounds = true
        
        UIView.animate(withDuration: 0.3, animations: {
            self.filterSwitch.alpha = 1.0
            self.exportButton.alpha = 1.0
            self.uploadButton.alpha = 0.0
        })
    }
}

// MARK: - UIGestureRecognizerDelegate
extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if (gestureRecognizer is UIPanGestureRecognizer && otherGestureRecognizer is UIRotationGestureRecognizer) ||
            (gestureRecognizer is UIPanGestureRecognizer && otherGestureRecognizer is UIPinchGestureRecognizer) {
            return true
        }
        return false
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if gestureRecognizer is UIRotationGestureRecognizer && (touch.view?.gestureRecognizers?.contains(where: { $0 is UIPinchGestureRecognizer && $0.state == .began }) ?? false) {
            return false
        }
        return true
    }
}

//MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        setImage(image: image)
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

//MARK: - Configure

private extension ViewController {
    func configure() {
        configureUI()
        addGestureRecognizers()
        imageView.isUserInteractionEnabled = true
    }
    
    func configureUI() {
        filterSwitch.alpha = 0.0
        exportButton.alpha = 0.0
    }
    
    func addGestureRecognizers() {
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation(_:)))
        rotationGesture.delegate = self
        imageView.addGestureRecognizer(rotationGesture)

        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        pinchGesture.delegate = self
        imageView.addGestureRecognizer(pinchGesture)

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        imageView.addGestureRecognizer(panGesture)
    }

    @objc func handleRotation(_ gesture: UIRotationGestureRecognizer) {
        guard let view = gesture.view else { return }
        
        if gesture.state == .began || gesture.state == .changed {
            view.transform = view.transform.rotated(by: gesture.rotation)
            gesture.rotation = 0
        }
    }

    @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        guard let view = gesture.view else { return }
        
        if gesture.state == .began || gesture.state == .changed {
            view.transform = view.transform.scaledBy(x: gesture.scale, y: gesture.scale)
            gesture.scale = 1
        }
    }

    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view else { return }
        
        let translation = gesture.translation(in: self.view)
        
        view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
        
        gesture.setTranslation(.zero, in: self.view)
    }
}

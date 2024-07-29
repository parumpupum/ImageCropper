import UIKit

final class HoleView: UIView {
    
    private let holeSize = CGSize(width: 200, height: 300)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        let grayView = UIView(frame: self.bounds)
        grayView.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        self.addSubview(grayView)
        
        let holeSize = CGSize(width: 200, height: 300)
        let holePath = UIBezierPath(rect: CGRect(x: (self.bounds.width - holeSize.width) / 2,
                                                 y: (self.bounds.height - holeSize.height) / 2,
                                                 width: holeSize.width,
                                                 height: holeSize.height))
        
        let fullPath = UIBezierPath(rect: self.bounds)
        fullPath.append(holePath)
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = fullPath.cgPath
        maskLayer.fillRule = .evenOdd
        
        grayView.layer.mask = maskLayer
        
        let borderLayer = CAShapeLayer()
        borderLayer.path = holePath.cgPath
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = UIColor.yellow.cgColor
        borderLayer.lineWidth = 2.0
        
        grayView.layer.addSublayer(borderLayer)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let holeRect = CGRect(x: (self.bounds.width - holeSize.width) / 2,
                              y: (self.bounds.height - holeSize.height) / 2,
                              width: holeSize.width,
                              height: holeSize.height)

        if holeRect.contains(point) {
            return nil
        }

        return super.hitTest(point, with: event)
    }
    
    func captureImageInHoleArea() -> UIImage? {
        let holeRect = CGRect(x: (self.bounds.width - holeSize.width) / 2,
                              y: (self.bounds.height - holeSize.height) / 2,
                              width: holeSize.width,
                              height: holeSize.height)
        
        let convertedHoleRect = self.convert(holeRect, to: self.superview)
        
        UIGraphicsBeginImageContextWithOptions(self.superview?.bounds.size ?? .zero, false, 0.0)
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        self.superview?.layer.render(in: context)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if let image = image {
            if let finalImage = cropImage(centerImage: image, cropSize: holeSize) {
                return finalImage
            }
        }
        
        return nil
    }

    private func cropImage(centerImage: UIImage, cropSize: CGSize) -> UIImage? {
        let cropRect = CGRect(
            x: (centerImage.size.width - cropSize.width) / 2,
            y: (centerImage.size.height - cropSize.height) / 2,
            width: cropSize.width,
            height: cropSize.height
        )

        UIGraphicsBeginImageContextWithOptions(cropSize, false, centerImage.scale)

        centerImage.draw(in: CGRect(x: -cropRect.origin.x, y: -cropRect.origin.y, width: centerImage.size.width, height: centerImage.size.height))

        let croppedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return croppedImage
    }


}

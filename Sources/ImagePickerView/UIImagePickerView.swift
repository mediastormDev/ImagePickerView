//
//  UIImagePickerView.swift
//
//
//  Created by Alex Nagy on 28.02.2021.
//

import SwiftUI
import UIKit

@available(iOS 13.0, *)
public struct UIImagePickerView: UIViewControllerRepresentable {
    
    public typealias UIViewControllerType = UIImagePickerController
    
    /// Image Picker with UIImagePickerController
    /// - Parameters:
    ///   - allowsEditing: does it allow editing
    ///   - sourceType: source
    ///   - delegate: Image Picker Delegate
    public init(
        allowsEditing: Bool = true,
        sourceType: UIImagePickerController.SourceType = .photoLibrary,
        didCancel: @escaping (UIImagePickerController) -> (),
        didSelect: @escaping (UIImagePickerResult) -> ()
    ) {
        self.allowsEditing = allowsEditing
        self.sourceType = sourceType
        self.didCancel = didCancel
        self.didSelect = didSelect
    }

    private let allowsEditing: Bool
    private let sourceType: UIImagePickerController.SourceType
    private let didCancel: (UIImagePickerController) -> ()
    private let didSelect: (UIImagePickerResult) -> ()
    
    public func makeCoordinator() -> Delegate {
        Delegate(didCancel: didCancel, didSelect: didSelect)
    }
    
    public func makeUIViewController(context: UIViewControllerRepresentableContext<UIImagePickerView>) -> UIImagePickerController {
        let controller = UIImagePickerController()
        controller.allowsEditing = allowsEditing
        controller.sourceType = sourceType
        controller.delegate = context.coordinator
        return controller
    }
    
    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<UIImagePickerView>) { }
}

@available(iOS 13.0, *)
extension UIImagePickerView {
    
    public class Delegate: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        public init(didCancel: @escaping (UIImagePickerController) -> (), didSelect: @escaping (UIImagePickerResult) -> ()) {
            self.didCancel = didCancel
            self.didSelect = didSelect
        }
        
        private let didCancel: (UIImagePickerController) -> ()
        private let didSelect: (UIImagePickerResult) -> ()
        
        public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            var image = UIImage()
            if let editedImage = info[.editedImage] as? UIImage {
                image = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                image = originalImage
            }
            didSelect(UIImagePickerResult(picker: picker, image: image))
        }
        
        public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            didCancel(picker)
        }
    }
    
}

public struct UIImagePickerResult {
    public let picker: UIImagePickerController
    public let image: UIImage
}

//
//  ImagePickerView.swift
//  
//
//  Created by Alex Nagy on 19.01.2021.
//

import SwiftUI
import UIKit
import PhotosUI

public struct ImagePickerView: UIViewControllerRepresentable {
    
    public typealias UIViewControllerType = PHPickerViewController
    
    public init(
        filter: PHPickerFilter = .images,
        selectionLimit: Int = 1,
        didCancel: @escaping (PHPickerViewController) -> (),
        didSelect: @escaping (ImagePickerResult) -> (),
        didFail: @escaping (ImagePickerError) -> ()
    ) {
        self.filter = filter
        self.selectionLimit = selectionLimit
        self.didCancel = didCancel
        self.didSelect = didSelect
        self.didFail = didFail
    }
    
    private let filter: PHPickerFilter
    private let selectionLimit: Int
    private let didCancel: (PHPickerViewController) -> ()
    private let didSelect: (ImagePickerResult) -> ()
    private let didFail: (ImagePickerError) -> ()
    
    public func makeCoordinator() -> Delegate {
        Delegate(didCancel: didCancel, didSelect: didSelect, didFail: didFail)
    }
    
    public func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        configuration.filter = filter
        configuration.selectionLimit = selectionLimit
        
        let controller = PHPickerViewController(configuration: configuration)
        controller.delegate = context.coordinator
        return controller
    }
    
    public func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) { }
}

extension ImagePickerView {
    public class Delegate: NSObject, PHPickerViewControllerDelegate {
        
        public init(didCancel: @escaping (PHPickerViewController) -> (), didSelect: @escaping (ImagePickerResult) -> (), didFail: @escaping (ImagePickerError) -> ()) {
            self.didCancel = didCancel
            self.didSelect = didSelect
            self.didFail = didFail
        }
        
        private let didCancel: (PHPickerViewController) -> ()
        private let didSelect: (ImagePickerResult) -> ()
        private let didFail: (ImagePickerError) -> ()
        
        public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            if results.count == 0 {
                self.didCancel(picker)
                return
            }
            var images = [ImagePickerResult.SelectedImage]()
            for i in 0..<results.count {
                let result = results[i]
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    result.itemProvider.loadObject(ofClass: UIImage.self) { newImage, error in
                        if let error = error {
                            self.didFail(ImagePickerError(picker: picker, error: error))
                        } else if let image = newImage as? UIImage {
                            images.append(.init(index: i, image: image))
                        }
                        if images.count == results.count {
                            if images.count != 0 {
                                self.didSelect(ImagePickerResult(picker: picker, images: images))
                            } else {
                                self.didCancel(picker)
                            }
                        }
                    }
                } else {
                    self.didFail(ImagePickerError(picker: picker, error: ImagePickerViewError.cannotLoadObject))
                }
            }
            
            
        }
    }
}

public struct ImagePickerResult {
    public let picker: PHPickerViewController
    public let images: [SelectedImage]

    public struct SelectedImage {
        public let index: Int
        public let image: UIImage
    }
}

public struct ImagePickerError {
    public let picker: PHPickerViewController
    public let error: Error
}

public enum ImagePickerViewError: Error {
    case cannotLoadObject
    case failedToLoadObject
}

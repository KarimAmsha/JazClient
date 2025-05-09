//
//  ImagePicker.swift
//  Khawi
//
//  Created by Karim Amsha on 23.10.2023.
//

import SwiftUI
import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

struct ImagePicker: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIImagePickerController
    typealias SourceType = UIImagePickerController.SourceType

    let sourceType: SourceType
    let completionHandler: (UIImage?, String?) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let viewController = UIImagePickerController()
        viewController.delegate = context.coordinator
        viewController.sourceType = sourceType

        return viewController
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        return Coordinator(completionHandler: completionHandler)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let completionHandler: (UIImage?, String?) -> Void

        init(completionHandler: @escaping (UIImage?, String?) -> Void) {
            self.completionHandler = completionHandler
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            let image: UIImage? = {
                if let image = info[.editedImage] as? UIImage {
                    return image
                }

                return info[.originalImage] as? UIImage
            }()

            let imageUrl: URL? = {
                if let imageUrl = info[.imageURL] as? URL {
                    return imageUrl
                }

                return info[.mediaURL] as? URL
            }()

            let lastPathComponent = imageUrl?.lastPathComponent

            completionHandler(image, lastPathComponent)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            completionHandler(nil, nil)
        }
    }
}

struct MediaPicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode)
    private var presentationMode

    typealias SourceType = UIImagePickerController.SourceType
    typealias MType = MediaType

    let sourceType: SourceType
    let mediaType: MediaType
    let onImagePicked: (UIImage) -> Void
    let onVideoPicked: (URL) -> Void

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        @Binding private var presentationMode: PresentationMode
        private let onImagePicked: (UIImage) -> Void
        private let onVideoPicked: (URL) -> Void

        init(presentationMode: Binding<PresentationMode>, onImagePicked: @escaping (UIImage) -> Void, onVideoPicked: @escaping (URL) -> Void) {
            _presentationMode = presentationMode
            self.onImagePicked = onImagePicked
            self.onVideoPicked = onVideoPicked
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.editedImage] as? UIImage {
                onImagePicked(image)
            } else if let image = info[.originalImage] as? UIImage {
                onImagePicked(image)
            } else if let url = info[.mediaURL] as? URL {
                onVideoPicked(url)
            }
            presentationMode.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            presentationMode.dismiss()
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(presentationMode: presentationMode, onImagePicked: onImagePicked, onVideoPicked: onVideoPicked)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<MediaPicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator

        let mediaTypeStrings = mediaTypeMediaTypes.map { $0.identifier }
        picker.mediaTypes = mediaTypeStrings

        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<MediaPicker>) {
    }

    private var mediaTypeMediaTypes: [UTType] {
        switch mediaType {
        case .multi:
            return [UTType.movie, UTType.image]
        case .video:
            return [UTType.movie]
        case .image:
            return [UTType.image]
        }
    }
}

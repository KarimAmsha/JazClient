//
//  ImagePicker.swift
//  Wishy
//
//  Created by Karim Amsha on 14.06.2024.
//

import SwiftUI
import PhotosUI

struct SelectedImage: Identifiable {
    let id = UUID()
    let image: UIImage
}

struct ImagePicker2: UIViewControllerRepresentable {
    @Binding var selectedImages: [SelectedImage]

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 0 // 0 means no limit

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        private let parent: ImagePicker2

        init(_ parent: ImagePicker2) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.selectedImages.removeAll()
            picker.dismiss(animated: true, completion: nil)

            for result in results {
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (object, error) in
                        if let image = object as? UIImage {
                            DispatchQueue.main.async {
                                self?.parent.selectedImages.append(SelectedImage(image: image))
                            }
                        }
                    }
                }
            }
        }
    }
}

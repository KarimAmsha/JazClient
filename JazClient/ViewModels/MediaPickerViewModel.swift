//
//  MediaPickerViewModel.swift
//  Wishy
//
//  Created by Karim Amsha on 27.04.2024.
//

import SwiftUI

class MediaPickerViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var selectedImageLastPath: String?
    @Published var selectedIDImage: UIImage?
    @Published var selectedIDImageLastPath: String?
    @Published var isPresentingImagePicker = false
    @Published var isPresentingIDImagePicker = false
    private(set) var sourceType: ImagePicker.SourceType = .camera
    
    func choosePhoto() {
        sourceType = .photoLibrary
        isPresentingImagePicker = true
    }
    
    func takePhoto() {
        sourceType = .camera
        isPresentingImagePicker = true
    }
    
    func chooseIDPhoto() {
        sourceType = .photoLibrary
        isPresentingIDImagePicker = true
    }
    
    func takeIDPhoto() {
        sourceType = .camera
        isPresentingIDImagePicker = true
    }
    
    func chooseVideo() {
        sourceType = .photoLibrary
        isPresentingImagePicker = true
    }
    
    func didSelectImage(_ image: UIImage?, _ lastPath: String?) {
        selectedImage = image
        selectedImageLastPath = lastPath
        isPresentingImagePicker = false
        
    }
    
    func didSelectIDImage(_ image: UIImage?, _ lastPath: String?) {
        selectedIDImage = image
        selectedIDImageLastPath = lastPath
        isPresentingIDImagePicker = false
    }
}

class MediaViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var selectedVideoUrl: URL?
    @Published var isPresentingMediaPicker = false
    private(set) var sourceType: MediaPicker.SourceType = .camera
    var mediaType: MediaPicker.MType = .image

    func choosePhoto() {
        sourceType = .photoLibrary
        mediaType = .image
        isPresentingMediaPicker = true
    }
    
    func takePhoto() {
        sourceType = .camera
        mediaType = .image
        isPresentingMediaPicker = true
    }
    
    func chooseVideo() {
        sourceType = .photoLibrary
        mediaType = .video
        isPresentingMediaPicker = true
    }
    
    func didSelectImage(_ image: UIImage?) {
        selectedImage = image
        isPresentingMediaPicker = false
    }
    
    func didSelectVideo(_ url: URL?) {
        selectedVideoUrl = url
        selectedImage = url?.getThumbnailFrom()
        isPresentingMediaPicker = false
    }
}

//
//  ScannerView.swift
//  Sylly
//
//  This view lets users take a photo of their syllabus
//  using the iPhone camera or pick from photo library
//

import SwiftUI

struct ScannerView: View {

    // MARK: - Navigation
    // Single binding to control entire navigation
    @Binding var navigationState: NavigationState

    // MARK: - State Properties
    @State private var showCamera = false           // Shows the camera
    @State private var showPhotoLibrary = false     // Shows photo picker
    @State private var capturedImage: UIImage?      // The photo user took

    // MARK: - Body
    var body: some View {
        ZStack {
            // Black background (like a camera app)
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 0) {

                // MARK: - Top Bar
                HStack {
                    // Close button
                    // Navigate back to home when tapped
                    Button(action: {
                        navigationState = .home
                    }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                    }

                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                // MARK: - Instructions
                Text("Take a photo of your syllabus")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.top, 20)

                Text("Make sure all text is visible and in focus")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.top, 4)

                Spacer()

                // MARK: - Preview Area
                // Shows the captured image or a placeholder
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.1))
                        .frame(maxWidth: .infinity)
                        .frame(height: 500)

                    if let image = capturedImage {
                        // Show the captured photo
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .frame(height: 500)
                            .cornerRadius(12)
                    } else {
                        // Show placeholder
                        VStack(spacing: 12) {
                            Image(systemName: "doc.text.viewfinder")
                                .font(.system(size: 60))
                                .foregroundColor(.white.opacity(0.4))

                            Text("No photo yet")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.4))
                        }
                    }
                }

                Spacer()

                // MARK: - Bottom Buttons
                if capturedImage != nil {
                    // If we have a photo, show "Use Photo" and "Retake" buttons
                    HStack(spacing: 20) {
                        // Retake button
                        Button(action: {
                            capturedImage = nil
                        }) {
                            Text("Retake")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.gray.opacity(0.5))
                                .cornerRadius(25)
                        }

                        // Use Photo button
                        // Navigate to loading state with the captured image
                        Button(action: {
                            navigationState = .loading(capturedImage)
                        }) {
                            Text("Use Photo")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(AppColors.primary)
                                .cornerRadius(25)
                        }
                    }
                    .padding(.bottom, 40)
                    .padding(.horizontal, 20)

                } else {
                    // If no photo yet, show camera and library buttons
                    HStack(spacing: 60) {
                        // Photo library button
                        Button(action: {
                            showPhotoLibrary = true
                        }) {
                            VStack(spacing: 8) {
                                Image(systemName: "photo.on.rectangle")
                                    .font(.title)
                                    .foregroundColor(.white)
                                Text("Library")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .frame(width: 70, height: 70)
                        }

                        // Camera button (big circle)
                        Button(action: {
                            showCamera = true
                        }) {
                            ZStack {
                                Circle()
                                    .stroke(Color.white, lineWidth: 4)
                                    .frame(width: 75, height: 75)

                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 62, height: 62)
                            }
                        }

                        // Empty space for balance
                        Color.clear
                            .frame(width: 70, height: 70)
                    }
                    .padding(.bottom, 40)
                }
            }
        }

        // MARK: - Camera Sheet
        .fullScreenCover(isPresented: $showCamera) {
            ImagePicker(image: $capturedImage, sourceType: .camera)
                .ignoresSafeArea()
        }

        // MARK: - Photo Library Sheet
        .sheet(isPresented: $showPhotoLibrary) {
            ImagePicker(image: $capturedImage, sourceType: .photoLibrary)
        }

    }
}

// MARK: - Image Picker (UIKit Wrapper)
// This wraps Apple's UIImagePickerController so we can use it in SwiftUI
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    let sourceType: UIImagePickerController.SourceType

    @Environment(\.dismiss) private var dismiss

    // Create the UIKit view controller
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    // Update the view controller (not needed but required by protocol)
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    // Create the coordinator that handles callbacks
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // Coordinator handles the "delegate" callbacks from UIKit
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        // Called when user picks/takes a photo
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            // Get the image from the info dictionary
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }

        // Called when user cancels
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - Preview
#Preview {
    ScannerView(navigationState: .constant(.scanning))
}

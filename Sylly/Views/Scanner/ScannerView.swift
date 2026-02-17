//
//  ScannerView.swift
//  Sylly
//
//  This view lets users scan their syllabus using Apple's
//  multi-page document scanner or pick from photo library
//

import SwiftUI
import VisionKit
import PhotosUI
import PDFKit                  // Convert PDF pages → images
import UniformTypeIdentifiers  // UTType.pdf for file picker filter

struct ScannerView: View {

    // MARK: - Navigation
    // Single binding to control entire navigation
    @Binding var navigationState: NavigationState

    // MARK: - State Properties
    @State private var showDocumentScanner = false  // Shows Apple's multi-page scanner
    @State private var showPhotoLibrary = false     // Shows photo picker (multi-select)
    @State private var showFilePicker = false       // Shows Files app picker for PDFs
    @State private var capturedImages: [UIImage] = [] // All scanned/selected/imported pages

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
                Text("Scan your syllabus")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.top, 20)

                Text("Scan multiple pages or pick a photo from your library")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.top, 4)

                Spacer()

                // MARK: - Preview Area
                // Shows scanned pages (swipeable) or a placeholder
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.1))
                        .frame(maxWidth: .infinity)
                        .frame(height: 500)

                    if !capturedImages.isEmpty {
                        VStack(spacing: 8) {
                            // Swipeable carousel of all scanned/selected images
                            TabView {
                                // Loop through each image with its index
                                ForEach(Array(capturedImages.enumerated()), id: \.offset) { index, image in
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFit()       // Fit without stretching
                                        .cornerRadius(12)
                                        .padding(.horizontal, 8)
                                }
                            }
                            // Page style shows swipeable cards with automatic dot indicators
                            .tabViewStyle(.page(indexDisplayMode: .automatic))
                            .frame(height: 460)

                            // Show hint text only when multiple pages exist
                            if capturedImages.count > 1 {
                                Text("\(capturedImages.count) pages — swipe to preview")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                    } else {
                        // Show placeholder
                        VStack(spacing: 12) {
                            Image(systemName: "doc.text.viewfinder")
                                .font(.system(size: 60))
                                .foregroundColor(.white.opacity(0.4))

                            Text("No pages scanned yet")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.4))
                        }
                    }
                }

                Spacer()

                // MARK: - Bottom Buttons
                if !capturedImages.isEmpty {
                    // If we have scanned pages, show "Rescan" and "Continue" buttons
                    HStack(spacing: 20) {
                        // Rescan button — clears all pages
                        Button(action: {
                            capturedImages = []
                        }) {
                            Text("Rescan")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.gray.opacity(0.5))
                                .cornerRadius(25)
                        }

                        // Continue button — sends all images to loading
                        Button(action: {
                            navigationState = .loading(capturedImages)
                        }) {
                            Text("Continue")
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
                    // If no pages yet, show scan and library buttons
                    HStack(spacing: 60) {
                        // Photo library button (single image fallback)
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

                        // Scan button (big circle) — opens Apple's document scanner
                        Button(action: {
                            showDocumentScanner = true
                        }) {
                            ZStack {
                                Circle()
                                    .stroke(Color.white, lineWidth: 4)
                                    .frame(width: 75, height: 75)

                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 62, height: 62)

                                // Small document icon inside the button
                                Image(systemName: "doc.viewfinder")
                                    .font(.title2)
                                    .foregroundColor(.black)
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

        // MARK: - Document Scanner Sheet
        // Apple's built-in multi-page scanner (like in Notes app)
        .fullScreenCover(isPresented: $showDocumentScanner) {
            DocumentScannerView(scannedImages: $capturedImages)
                .ignoresSafeArea()
        }

        // MARK: - Photo Library Sheet
        // Multi-select photo picker for syllabus screenshots
        .sheet(isPresented: $showPhotoLibrary) {
            PhotoLibraryPicker(capturedImages: $capturedImages)
        }

        // MARK: - File Picker Sheet
        // Opens the Files app so users can pick a PDF syllabus
        .sheet(isPresented: $showFilePicker) {
            FilePicker(capturedImages: $capturedImages)
        }

    }
}

// MARK: - Document Scanner (UIKit Wrapper)
// Wraps Apple's VNDocumentCameraViewController for multi-page scanning
// This is the same scanner used in the Notes app
struct DocumentScannerView: UIViewControllerRepresentable {
    // Store all scanned pages
    @Binding var scannedImages: [UIImage]
    // Ability to close the scanner
    @Environment(\.dismiss) private var dismiss

    // Step 1: Create the scanner
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let scanner = VNDocumentCameraViewController()
        // Connect scanner to Coordinator so it can send events back
        scanner.delegate = context.coordinator
        return scanner
    }

    // Step 2: Update scanner (not needed, leave empty)
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}

    // Step 3: Create the event listener
    func makeCoordinator() -> Coordinator {
        // Pass 'self' so Coordinator can talk back to this view
        Coordinator(self)
    }

    // Handles scanner events (like when user scans pages)
    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        // Reference back to SwiftUI view
        let parent: DocumentScannerView

        init(_ parent: DocumentScannerView) {
            self.parent = parent
        }

        // User tapped "Save" - extract all scanned pages
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            var images: [UIImage] = []
            // Get each page from the scan
            for pageIndex in 0..<scan.pageCount {
                images.append(scan.imageOfPage(at: pageIndex))
            }
            // Send all pages back to SwiftUI
            parent.scannedImages = images
            // Close the scanner
            parent.dismiss()
        }

        // Scanning failed - just close
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            print("Document scan failed: \(error.localizedDescription)")
            parent.dismiss()
        }

        // User tapped "Cancel" - close
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            parent.dismiss()
        }
    }
}

// MARK: - Photo Library Picker (Multi-Select)
// Wraps Apple's PHPickerViewController for selecting multiple photos at once
// Great for when students have multiple screenshots of their syllabus
struct PhotoLibraryPicker: UIViewControllerRepresentable {
    // Store all selected photos
    @Binding var capturedImages: [UIImage]
    // Ability to close the picker
    @Environment(\.dismiss) private var dismiss

    // Step 1: Create the photo picker
    func makeUIViewController(context: Context) -> PHPickerViewController {
        // Set up the picker configuration
        var config = PHPickerConfiguration()
        config.filter = .images          // Only show images (no videos)
        config.selectionLimit = 0        // 0 means unlimited selection
        config.preferredAssetRepresentationMode = .current

        let picker = PHPickerViewController(configuration: config)
        // Connect picker to Coordinator so it can send events back
        picker.delegate = context.coordinator
        return picker
    }

    // Step 2: Update picker (not needed, leave empty)
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    // Step 3: Create the event listener
    func makeCoordinator() -> Coordinator {
        // Pass 'self' so Coordinator can talk back to this view
        Coordinator(self)
    }

    // Handles picker events (like when user selects photos)
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        // Reference back to SwiftUI view
        let parent: PhotoLibraryPicker

        init(_ parent: PhotoLibraryPicker) {
            self.parent = parent
        }

        // User tapped "Add" - load all selected photos asynchronously
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            // If user cancelled (no selections), just close
            guard !results.isEmpty else {
                parent.dismiss()
                return
            }

            // Load each selected photo asynchronously
            var images: [UIImage] = []
            // DispatchGroup waits for all image loads to complete before continuing
            let group = DispatchGroup()

            for result in results {
                // Mark the start of an async task
                group.enter()
                result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                    if let image = object as? UIImage {
                        images.append(image)
                    }
                    // Mark the end of this async task
                    group.leave()
                }
            }

            // Once all photos are loaded, send them back to SwiftUI and close
            group.notify(queue: .main) {
                self.parent.capturedImages = images
                self.parent.dismiss()
            }
        }
    }
}

// MARK: - File Picker (PDF Import)
// Wraps Apple's UIDocumentPickerViewController to let users pick a PDF from Files
// After picking, we convert each PDF page into a UIImage using PDFKit
// Those images then go into the same capturedImages array as camera/library
struct FilePicker: UIViewControllerRepresentable {
    // Store all pages as images (same array the other pickers use)
    @Binding var capturedImages: [UIImage]
    // Ability to close the picker
    @Environment(\.dismiss) private var dismiss

    // Step 1: Create the file picker, filtered to PDFs only
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        // UTType.pdf tells the picker "only show PDF files"
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.pdf])
        // Only allow picking one PDF at a time
        picker.allowsMultipleSelection = false
        // Connect picker to Coordinator so it can send events back
        picker.delegate = context.coordinator
        return picker
    }

    // Step 2: Update picker (not needed, leave empty)
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    // Step 3: Create the event listener
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // Handles file picker events (like when user picks a PDF)
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: FilePicker

        init(_ parent: FilePicker) {
            self.parent = parent
        }

        // User picked a PDF — convert each page to an image
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            // Get the first URL (we only allow one file)
            guard let url = urls.first else { return }

            // iOS requires us to ask permission to access the file
            // startAccessingSecurityScopedResource() / stopAccessingSecurityScopedResource()
            // is like saying "I need to read this file now" and "I'm done reading"
            let didStart = url.startAccessingSecurityScopedResource()

            // Make sure we stop accessing when we're done (even if something fails)
            defer {
                if didStart { url.stopAccessingSecurityScopedResource() }
            }

            // Try to open the PDF
            guard let pdfDocument = PDFDocument(url: url) else {
                print("Failed to open PDF: \(url.lastPathComponent)")
                return
            }

            // Convert each PDF page into a UIImage
            var images: [UIImage] = []
            for pageIndex in 0..<pdfDocument.pageCount {
                // Get the page
                guard let page = pdfDocument.page(at: pageIndex) else { continue }

                // Get the page size (in points)
                let pageRect = page.bounds(for: .mediaBox)

                // Render at 2x resolution for crisp OCR results
                // (like taking a retina screenshot of each page)
                let scale: CGFloat = 2.0
                let renderSize = CGSize(
                    width: pageRect.width * scale,
                    height: pageRect.height * scale
                )

                // UIGraphicsImageRenderer draws the PDF page into a UIImage
                let renderer = UIGraphicsImageRenderer(size: renderSize)
                let image = renderer.image { context in
                    // White background (PDFs can have transparent backgrounds)
                    UIColor.white.set()
                    context.fill(CGRect(origin: .zero, size: renderSize))

                    // Scale up and flip the coordinate system
                    // (PDF uses bottom-left origin, UIKit uses top-left)
                    context.cgContext.translateBy(x: 0, y: renderSize.height)
                    context.cgContext.scaleBy(x: scale, y: -scale)

                    // Draw the PDF page
                    page.draw(with: .mediaBox, to: context.cgContext)
                }

                images.append(image)
            }

            // Send all page images back to SwiftUI
            parent.capturedImages = images
        }

        // User tapped "Cancel" — nothing to do, picker closes automatically
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            // Picker dismisses itself
        }
    }
}

// MARK: - Preview
#Preview {
    ScannerView(navigationState: .constant(.scanning))
}

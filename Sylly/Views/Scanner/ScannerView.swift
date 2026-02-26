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
import UIKit                   // For haptic feedback

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
        NavigationStack {
            Group {
                if capturedImages.isEmpty {
                    // No images yet — show the 3 import option cards
                    launchPadView
                } else {
                    // Images captured — show preview with Rescan/Continue
                    previewView
                }
            }
            .navigationTitle("Scanner")
            .background(AppColors.background)
        }

        // MARK: - Reset After Flow Completes
        // When the user finishes the scan pipeline (Success → Home),
        // clear the captured images so the Launch Pad shows again.
        // Check navigationState.isHome instead of the enum directly
        // because NavigationState can't easily conform to Equatable
        // (it carries complex types like [UIImage] and Course).
        .onChange(of: navigationState.isHome) { _, isHome in
            if isHome {
                capturedImages = []
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

    // MARK: - Launch Pad View
    // Three cards that let the user choose how to import their syllabus
    private var launchPadView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // Subtitle explaining what this screen does
                Text("Scan your syllabus or import a file")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)

                // Card 1: Scan Document (opens the camera scanner)
                scannerCard(
                    icon: "doc.viewfinder",
                    color: Color("ICON_Blue"),
                    title: "Scan Document",
                    description: "Use your camera to scan pages"
                ) {
                    showDocumentScanner = true
                }

                // Card 2: Photo Library (pick photos from your library)
                scannerCard(
                    icon: "photo.on.rectangle",
                    color: Color("ICON_Purple"),
                    title: "Photo Library",
                    description: "Select photos from your library"
                ) {
                    showPhotoLibrary = true
                }

                // Card 3: Import PDF (pick a PDF from Files app)
                scannerCard(
                    icon: "doc.richtext",
                    color: .orange,
                    title: "Import PDF",
                    description: "Import a PDF from Files"
                ) {
                    showFilePicker = true
                }
            }
            .padding(.vertical)
        }
        .background(Color(UIColor.systemBackground))
    }

    // MARK: - Scanner Card Helper
    // Builds one vertical card — icon on top, title + description below
    // Reusable helper — called 3 times with different values instead of copy-pasting
    private func scannerCard(
        icon: String,
        color: Color,
        title: String,
        description: String,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            // Haptic feedback — medium impact vibration when pressed
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            action()
        } label: {
            VStack(spacing: 14) {
                // Icon — white on colored card background
                Image(systemName: icon)
                    .font(.system(size: 48))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)

                // Title + description centered below — white text
                VStack(spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.85))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .padding(.horizontal, 16)
            .background(color)
            .cornerRadius(14)
        }
        // Custom style handles the scale + opacity press animation
        .buttonStyle(PressableButtonStyle())
        .padding(.horizontal)
    }

    // MARK: - Preview View
    // Shows captured images in a swipeable carousel with Rescan/Continue buttons
    private var previewView: some View {
        VStack(spacing: 0) {

            // Swipeable carousel of all scanned/selected images
            TabView {
                ForEach(Array(capturedImages.enumerated()), id: \.offset) { index, image in
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(12)
                        .padding(.horizontal, 8)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .automatic))
            .frame(maxHeight: .infinity)

            // Show hint text only when there are multiple pages
            if capturedImages.count > 1 {
                Text("\(capturedImages.count) pages — swipe to preview")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }

            // Rescan + Continue buttons
            HStack(spacing: 16) {
                // Rescan — clears images, goes back to Launch Pad
                Button(action: {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    capturedImages = []
                }) {
                    Text("Rescan")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                }
                .buttonStyle(PressableButtonStyle())

                // Continue — sends images to OCR/Claude pipeline
                Button(action: {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    navigationState = .loading(capturedImages)
                }) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(AppColors.primary)
                        .cornerRadius(12)
                }
                .buttonStyle(PressableButtonStyle())
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            .padding(.top, 12)
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
            // Serial queue so only one photo appends at a time (prevents crash when multiple photos load simultaneously)
            let imageQueue = DispatchQueue(label: "com.sylly.imageload")

            for result in results {
                // Mark the start of an async task
                group.enter()
                result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                    if let image = object as? UIImage {
                        imageQueue.sync { images.append(image) }
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
// After picking, each PDF page is converted into a UIImage using PDFKit
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
            // Get the first URL (only one file allowed)
            guard let url = urls.first else { return }

            // iOS requires permission to access the file from Files app
            // startAccessingSecurityScopedResource() / stopAccessingSecurityScopedResource()
            // is like saying "I need to read this file now" and "I'm done reading"
            let didStart = url.startAccessingSecurityScopedResource()

            // Make sure to stop accessing when done (even if something fails)
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

// MARK: - Pressable Button Style
// Custom ButtonStyle that scales down + dims when pressed, then springs back
// SwiftUI gives "configuration.isPressed" for free — no @State needed
// This is reusable on any Button in the app
struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Preview
#Preview {
    ScannerView(navigationState: .constant(.home))
}

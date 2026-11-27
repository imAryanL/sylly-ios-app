//
//  CanvasConnectView.swift
//  Sylly
//
//  Sheet where the student pastes their Canvas calendar link.
//

import SwiftUI

struct CanvasConnectView: View {

    // MARK: - Environment
    @Environment(\.dismiss) private var dismiss

    // MARK: - State
    @State private var link = ""
    @State private var isChecking = false
    @State private var errorMessage = ""

    // Same saved link ContentView refreshes from
    @AppStorage("canvasFeedLink") private var savedLink = ""

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 6) {

                    // MARK: - Heading
                    Text("Copy your Canvas link")
                        .font(.title2.bold())
                    Text("New assignments and date changes show up in Sylly on their own.")
                        .foregroundColor(.secondary)

                    // MARK: - Steps
                    // Words match the Canvas app and the iOS box exactly
                    VStack(alignment: .leading, spacing: 8) {
                        stepTitle(1, "Open the Canvas app")
                        bulletLine("Tap \(Image(systemName: "line.3.horizontal")) at the top left")
                        bulletLine("Tap **Settings**")
                        bulletLine("Tap **Subscribe to Calendar Feed**")

                        Divider().padding(.vertical, 12)

                        stepTitle(2, "Copy your link")
                        bulletLine("Tap the link in the box that opens")
                        bulletLine("Tap **Select All**, then **Copy**")
                        bulletLine("Tap **✕** to close the box")

                        Divider().padding(.vertical, 12)

                        stepTitle(3, "Come back to Sylly")
                        bulletLine("Tap the box below, then tap it again and choose **Paste**")
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 18)
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    .padding(.top, 20)

                    // MARK: - Link Box
                    Text("PUT YOUR CANVAS LINK HERE")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.top, 20)
                        .padding(.leading, 4)

                    TextField("Paste your link here", text: $link)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding(16)
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(14)

                    // MARK: - Link Feedback
                    // Example while empty, then a check or a warning once something's in
                    if link.isEmpty {
                        // verbatim = plain text, so iOS doesn't turn it into a tappable link
                        Text(verbatim: "It should look something like this:")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                            .padding(.leading, 4)
                        Text(verbatim: "https://yourschool.instructure.com/feeds/calendars/…")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .padding(.leading, 4)
                    } else if !errorMessage.isEmpty {
                        Label(errorMessage, systemImage: "exclamationmark.circle.fill")
                            .font(.footnote)
                            .foregroundColor(.orange)
                            .padding(.top, 4)
                            .padding(.leading, 4)
                    } else if looksLikeCanvasLink {
                        Label("Looks like a Canvas link", systemImage: "checkmark.circle.fill")
                            .font(.footnote)
                            .foregroundColor(.green)
                            .padding(.top, 4)
                            .padding(.leading, 4)
                    } else {
                        Label("That doesn't look like a Canvas calendar link", systemImage: "exclamationmark.circle.fill")
                            .font(.footnote)
                            .foregroundColor(.orange)
                            .padding(.top, 4)
                            .padding(.leading, 4)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top, 12)
            }
            .background(Color(.systemGroupedBackground))
            // MARK: - Connect Button
            // Pinned so it never scrolls off. Faded until a Canvas link is in the box.
            .safeAreaInset(edge: .bottom) {
                Button {
                    Task {
                        await connect()
                    }
                } label: {
                    // Spinner while the link is being tested
                    HStack {
                        if isChecking {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Connect")
                        }
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.primary)
                    .clipShape(Capsule())
                }
                .disabled(!looksLikeCanvasLink || isChecking)
                .opacity(looksLikeCanvasLink ? 1 : 0.4)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(.systemGroupedBackground))
            }
            .navigationTitle("Connect Canvas")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .tint(AppColors.primary)
        // A new paste clears the old error
        .onChange(of: link) {
            errorMessage = ""
        }
    }

    // MARK: - Link Check
    // Shape only. No "instructure.com" check, some schools use their own address.
    private var looksLikeCanvasLink: Bool {
        let cleaned = link.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        let goodStart = cleaned.hasPrefix("https://") || cleaned.hasPrefix("webcal://")
        let hasFeedPath = cleaned.contains("/feeds/calendars/")
        let goodEnd = cleaned.hasSuffix(".ics")

        return goodStart && hasFeedPath && goodEnd
    }

    // MARK: - Connect
    // Downloads the feed once, and only saves the link if that works
    private func connect() async {
        let trimmed = link.trimmingCharacters(in: .whitespacesAndNewlines)

        // Canvas hands out webcal:// links, but the download needs https://
        let httpsLink = trimmed.replacingOccurrences(of: "webcal://", with: "https://", options: .caseInsensitive)

        isChecking = true
        do {
            _ = try await CanvasService().fetchAssignments(from: httpsLink)
            savedLink = httpsLink
            dismiss()
        } catch {
            errorMessage = "Couldn't open that link. Copy it again from Canvas and paste it here."
        }
        isChecking = false
    }

    // MARK: - Step Title
    // Blue number circle + bold title
    private func stepTitle(_ number: Int, _ title: String) -> some View {
        HStack(spacing: 12) {
            Text("\(number)")
                .font(.subheadline.bold())
                .foregroundColor(.white)
                .frame(width: 26, height: 26)
                .background(AppColors.primary)
                .clipShape(Circle())

            Text(title)
                .font(.headline)
        }
    }

    // MARK: - Bullet Line
    // LocalizedStringKey, not String, so the **bold** markers work
    private func bulletLine(_ text: LocalizedStringKey) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text("•")
                .font(.headline)
                .foregroundColor(AppColors.primary)
            Text(text)
                .font(.callout)
        }
        .padding(.leading, 38)
    }
}

#Preview {
    CanvasConnectView()
}

//
//  EmptyScheduleView.swift
//  Sylly
//

import SwiftUI

struct EmptyScheduleView: View {
    // The month grid already fills the screen, so the mascot has no room and nothing to add.
    var showMascot: Bool = true

    // Sits under the calendar when the month is open, instead of floating mid-screen.
    private var topPadding: CGFloat {
        if showMascot {
            return 0
        }
        return 8
    }

    // MARK: - Body
    var body: some View {
        VStack(spacing: 16) {
            if showMascot {
                Spacer()

                Image("SyllyMain")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }

            Text("No assignments due")
                .font(.title2)
                .fontWeight(.semibold)

            // Never claim they are caught up — another day can still be stacked.
            Text("Pick another day to see what's coming.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.top, topPadding)
    }
}

// MARK: - Preview
#Preview {
    EmptyScheduleView()
}

#Preview("Month open") {
    EmptyScheduleView(showMascot: false)
}

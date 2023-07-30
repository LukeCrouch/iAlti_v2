//
//  ShareLinkView.swift
//  iAlti_v2
//
//  Created by Lukas Wheldon (Q465749) on 30.07.23.
//

import SwiftUI

struct ShareLinkView: View {
    let fileURL: URL
    
    @State private var isShareLinkPresented = false // New state variable

    var body: some View {
        VStack {
            Spacer()
            Text("Successfully saved your flight log to: ")
                .font(.custom(
                    "FontNameRound",
                    fixedSize: 34))
                .padding(.bottom)
                .multilineTextAlignment(.center)
            Text(fileURL.absoluteString)
                .font(.custom(
                    "FontNameRound",
                    fixedSize: 17))
                .multilineTextAlignment(.center)
            Spacer()
            Text("Press here to open it with another app or device:")
                .padding(.bottom)
                .multilineTextAlignment(.center)
            ShareLink("Share File", item: fileURL)
            Spacer()
            Button("Cancel") {
                dismissView()
            }
        }
        .padding()
    }

    private func dismissView() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController,
           let presentingViewController = rootViewController.presentedViewController {
            presentingViewController.dismiss(animated: true, completion: nil)
        }
    }
}

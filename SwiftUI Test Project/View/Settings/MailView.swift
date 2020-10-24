//
//  MailView.swift
//  SwiftUI Test Project
//
//  Created by Mike Schoonen on 09/09/2020.
//  Copyright © 2020 Mike Schoonen. All rights reserved.
//

import SwiftUI
import MessageUI

struct MailView: UIViewControllerRepresentable {
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        vc.setToRecipients(["mike.schoonen@hotmail.com"])
        vc.setSubject("New feature request")
        return vc
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {
        
    }
}

struct MailView_Previews: PreviewProvider {
    static var previews: some View {
        MailView()
    }
}

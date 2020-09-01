/// Copyright (c) 2020 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

// import SwiftUI

// struct IMessagesView: View {
//    var body: some View {
//        Text("Hello, iMessage World!")
//    }
// }
//
// struct IMessagesView_Previews: PreviewProvider {
//    static var previews: some View {
//        IMessagesView()
//    }
// }

import MessageUI
import SwiftUI

// typealias AttachmentInfo = (fileURL: URL, mimeType: String)

// public enum MFMailComposeResult : Int {
//    case cancelled = 0
//    case saved = 1
//    case sent = 2
//    case failed = 3
// }

// public enum MessageComposeResult : Int {
//    case cancelled = 0
//    case sent = 1
//    case failed = 2
// }

enum MessageComposeError: Error {
  case unknown
}

// TODO: replace MFMailComposeViewController by MFMessageComposeViewController

struct IMessagesView: UIViewControllerRepresentable {
  @Environment(\.presentationMode) var presentation
  var messageBody: String
  var attachmentInfo: AttachmentInfo?
  @Binding var result: Result<MFMailComposeResult, Error>?

  class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
    @Binding var presentation: PresentationMode
    @Binding var result: Result<MFMailComposeResult, Error>?
    var messageBody: String
    var attachmentInfo: AttachmentInfo?

    init(
      presentation: Binding<PresentationMode>,
      messageBody: String,
      attachmentInfo: AttachmentInfo?,
      result: Binding<Result<MFMailComposeResult, Error>?>
    ) {
      _presentation = presentation
      self.messageBody = messageBody
      self.attachmentInfo = attachmentInfo
      _result = result
    }

//    func mailComposeController(
//      _ controller: MFMailComposeViewController,
//      didFinishWith result: MFMailComposeResult,
//      error: Error?
//    ) {
//      defer {
//        $presentation.wrappedValue.dismiss()
//      }
//      if let error = error {
//        self.result = .failure(error)
//        return
//      }
//      self.result = .success(result)
//    }

    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
      defer {
        $presentation.wrappedValue.dismiss()
      }
      if result == .sent {
        self.result = .success(.sent)
      } else {
        self.result = .failure(MessageComposeError.unknown)
      }
    }
  }

  func makeCoordinator() -> Coordinator {
    return Coordinator(
      presentation: presentation,
      messageBody: messageBody,
      attachmentInfo: attachmentInfo,
      result: $result
    )
  }

  func makeUIViewController(
    context: UIViewControllerRepresentableContext<IMessagesView>
  ) -> MFMessageComposeViewController {
    let viewController = MFMessageComposeViewController()
    viewController.messageComposeDelegate = context.coordinator
    // viewController.setMessageBody(context.coordinator.messageBody, isHTML: false)
    // TODO: ^^^

    if let fileURL = attachmentInfo?.fileURL,
      let mimeType = attachmentInfo?.mimeType,
      let fileData = try? Data(contentsOf: fileURL) {
      viewController.addAttachmentData(
        fileData,
        typeIdentifier: mimeType,
        filename: "ExportData.rwtl"
      )
    }
    return viewController
  }

  func updateUIViewController(
    _ uiViewController: MFMessageComposeViewController,
    context: UIViewControllerRepresentableContext<IMessagesView>
  ) {}
}

// func presentMessageVC(recipientPhoneNumbers: [String]) {
//    guard MFMailComposeViewController.canSendMail() else {
//        // TODO: Show alert informing the user
//        printClassAndFunc(info: "canSendMail: false")
//        return
//    }
//    // EP's Test Doesn't Work
//    if !MFMessageComposeViewController.canSendText() {
//        print("SMS services are not available")
//    }
//
//    let messageVC = MFMessageComposeViewController()
//    MFMessageComposeViewController.canSendAttachments() // EP's Test Doesn't Work
//    messageVC.title = "\(String(describing: SharedUserDefaults.selectedCalendarTitle))'s Club" // EP's Test
//    messageVC.body = ""
//
//    messageVC.recipients = recipientPhoneNumbers
//
//    messageVC.messageComposeDelegate = self
//    messageVC.modalTransitionStyle = .crossDissolve
//    messageVC.modalPresentationStyle = .fullScreen
//
//    present(messageVC, animated: true, completion: nil)
// }
//

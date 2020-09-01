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

import MessageUI
import SwiftUI

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
  case cancelled
  case failed
  case unknown

  init(_ mcres: MessageComposeResult) {
    switch mcres {
    case .cancelled: self = .cancelled
    case .failed: self = .failed
    default: self = .unknown
    }
  }
}

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

    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
      defer {
        $presentation.wrappedValue.dismiss()
      }
      switch result {
      case .sent:
        self.result = .success(.sent)
      default:
        self.result = .failure(MessageComposeError(result))
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
    viewController.body = context.coordinator.messageBody

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

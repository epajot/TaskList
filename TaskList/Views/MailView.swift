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
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import SwiftUI
import MessageUI

typealias AttachmentInfo = (fileURL: URL, mimeType: String)

struct MailView: UIViewControllerRepresentable {
  @Environment(\.presentationMode) var presentation
  var messageBody: String
  var attachmentInfo: AttachmentInfo?
  @Binding var result: Result<MFMailComposeResult, Error>?

  class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
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

    func mailComposeController(
      _ controller: MFMailComposeViewController,
      didFinishWith result: MFMailComposeResult,
      error: Error?
    ) {
      defer {
        $presentation.wrappedValue.dismiss()
      }
      if let error = error {
        self.result = .failure(error)
        return
      }
      self.result = .success(result)
    }
  }

  func makeCoordinator() -> Coordinator {
    return Coordinator(
      presentation: presentation,
      messageBody: messageBody,
      attachmentInfo: attachmentInfo,
      result: $result)
  }

  func makeUIViewController(
    context: UIViewControllerRepresentableContext<MailView>
  ) -> MFMailComposeViewController {
    let viewController = MFMailComposeViewController()
    viewController.mailComposeDelegate = context.coordinator
    viewController.setMessageBody(context.coordinator.messageBody, isHTML: false)

    if let fileURL = attachmentInfo?.fileURL,
      let mimeType = attachmentInfo?.mimeType,
      let fileData = try? Data(contentsOf: fileURL) {
      viewController.addAttachmentData(
        fileData,
        mimeType: mimeType,
        fileName: "ExportData.rwtl")
    }
    return viewController
  }

  func updateUIViewController(
    _ uiViewController: MFMailComposeViewController,
    context: UIViewControllerRepresentableContext<MailView>
  ) { }
}

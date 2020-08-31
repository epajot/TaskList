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

// swiftlint:disable multiple_closures_with_trailing_closure
struct ContentView: View {
  @ObservedObject var taskStore: TaskStore
  @State var result: Result<MFMailComposeResult, Error>?
  @State var modalIsPresented = false
  @State var mailViewIsPresented = false
  @State var shareSheetIsPresented = false

  var body: some View {
    NavigationView {
      List {
        ForEach(taskStore.prioritizedTasks) { index in
          SectionView(prioritizedTasks: self.$taskStore.prioritizedTasks, index: index)
        }
      }
      .listStyle(GroupedListStyle())
      .navigationBarTitle("Tasks")
      .navigationBarItems(
        leading: EditButton(),
        trailing:
        HStack {
          // Add Item Button
          Button(action: { self.modalIsPresented = true }) {
            Image(systemName: "plus")
          }
          .frame(width: 44, height: 44, alignment: .center)
          .sheet(isPresented: $modalIsPresented) {
            NewTaskView(taskStore: self.taskStore)
          }
          // Export Via Email
          Button(action: { self.mailViewIsPresented = true }) {
            Image(systemName: "envelope")
          }
          .frame(width: 44, height: 44, alignment: .center)
          .disabled(!MFMailComposeViewController.canSendMail())
          .sheet(isPresented: $mailViewIsPresented) {
            MailView(
              messageBody: "This is a test email string",
              attachmentInfo: (
                fileURL: TaskStore.shared.tasksDocURL,
                mimeType: "application/xml"),
              result: self.$result)
          }

          // Share Sheet
          Button(action: { self.shareSheetIsPresented = true }) {
            Image(systemName: "square.and.arrow.up")
          }
          .frame(width: 44, height: 44, alignment: .center)
          .sheet(isPresented: $shareSheetIsPresented) {
            ShareSheet(
              activityItems: [TaskStore.shared.tasksDocURL],
              excludedActivityTypes: [.copyToPasteboard])
          }
        }
      )
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView( taskStore: TaskStore.shared )
  }
}

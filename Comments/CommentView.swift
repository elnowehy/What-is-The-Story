//
//  CommentView.swift
//  What is The Story
//
//  Created by Amr El-Nowehy on 2023-01-19.
//
//  This view will show the comments related to the video being viewed
//
//  Access: VideoPlayerView -> CommentView: Users can tap on a button to access the comments
//          related to the video being viewed

import SwiftUI

struct CommentView: View {
    @ObservedObject var commentVM: CommentVM
    @State private var commentText: String = ""
    let contentId: String
    @State private var sortByOldestFirst: Bool = true
    @EnvironmentObject var userVM: UserVM
    
    var body: some View {
        VStack {
            if !userVM.user.id.isEmpty {
                if commentVM.isReplying || commentVM.isEditing {
                    HStack {
                        TextField("\(AppSettings.commentMax) characters max", text: $commentText)
                        Button(action: {
                            if commentVM.isReplying {
                                if commentText.count <= AppSettings.commentMax {
                                    Task {
                                        await commentVM.postReply(comment: commentVM.replyingToComment!, text: commentText, userId: userVM.user.id)
                                        commentText = ""
                                    }
                                } // else, show an error or truncate the text
                            } else if commentVM.isEditing {
                                if commentText.count <= AppSettings.commentMax {
                                    Task {
                                        await commentVM.edit(comment: commentVM.editingComment!, with: commentText)
                                        commentText = ""
                                    }
                                } // else, show an error or truncate the text
                            }
                        }, label: {
                            Image(systemName: "arrow.up.circle.fill")
                        })
                    }
                    .padding(.horizontal)
                } else {
                    HStack {
                        TextField("Write a comment up to \(AppSettings.commentMax) characters", text: $commentText)
                        Button(action: {
                            if commentText.count <= AppSettings.commentMax {
                                Task {
                                    await commentVM.postComment(text: commentText, contentId: contentId, userId: userVM.user.id)
                                    commentText = ""
                                }
                            } // else, show an error or truncate the text
                        }, label: {
                            Image(systemName: "arrow.up.circle.fill")
                        })
                    }
                    .padding(.horizontal)
                }
            }
            
            Picker("Sort By", selection: $sortByOldestFirst) {
                Text("Oldest First").tag(true)
                Text("Newest First").tag(false)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            if commentVM.isLoading {
                ProgressView()
            } else {
                ScrollView {
                    ForEach(commentVM.comments.sorted(by: sortByOldestFirst ? { $0.timestamp > $1.timestamp } : { $0.timestamp < $1.timestamp })) { comment in
                        CommentRowView(comment: comment, onEdit: { text in
                            Task {
                                // commentVM.prepareEdit(for: comment)
                                await commentVM.edit(comment: comment, with: text)
                            }
                        }, onDelete: {
                            Task {
                                await commentVM.delete(comment: comment)
                            }
                        }, onReply: { replyText in
                            Task {
                                // commentVM.prepareReply(to: comment)
                                await commentVM.postReply(comment: comment, text: replyText, userId: userVM.user.id)
                            }
                        })
                    }
                }
            }
        }
        .onAppear {
            Task {
                await commentVM.fetchComments(for: contentId)
            }
        }
    }
}

struct CommentRowView: View {
    let comment: Comment
    let onEdit: (String) -> Void
    let onDelete: () -> Void
    let onReply: (String) -> Void
    @State private var isEditing = false
    @State private var isReplying = false
    @State private var editedText: String = ""
    @State private var replyText: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            if isEditing {
                TextField("Edit comment", text: $editedText)
                Button("Save") {
                    if editedText.count <= AppSettings.commentMax {
                        onEdit(editedText)
                        isEditing = false
                    } // else, show an error or truncate the text
                }
            } else {
                Text(comment.text)
                HStack {
                    Button("Reply") {
                        isReplying.toggle()
                    }
                    Button("Edit") {
                        editedText = comment.text
                        isEditing = true
                    }
                    Button("Delete") {
                        onDelete()
                    }
                }
                
                if isReplying {
                                TextField("Write a reply...", text: $replyText)
                                Button("Post Reply") {
                                    if replyText.count <= AppSettings.commentMax {
                                        onReply(replyText)
                                        replyText = ""
                                        isReplying = false
                                    } // else, show an error or truncate the text
                                }
                            }
            }
        }
        .padding()
    }
}



//struct CommentView_Previews: PreviewProvider {
//    static var previews: some View {
//        CommentView()
//    }
//}

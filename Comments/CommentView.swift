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
    @State private var repliesExpanded: [Comment.ID: Bool] = [:]
    
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
                                } else {
                                    print("Exceeding the \(AppSettings.commentMax) limits")
                                }
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
                    LazyVStack(alignment: .leading) {
                        ForEach(commentVM.comments.sorted(by: sortByOldestFirst ? { $0.timestamp > $1.timestamp } : { $0.timestamp < $1.timestamp })) { comment in
                            VStack {
                                HStack {
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
                                    
                                    Button(action: { repliesExpanded[comment.id, default: false].toggle() }) {
                                        Image(systemName: repliesExpanded[comment.id, default: false] ? "chevron.down.circle" : "chevron.right.circle")
                                    }
                                    .accessibilityLabel(repliesExpanded[comment.id, default: false] ? Text("Hide Replies") : Text("Show Replies"))
                                }

                                
                                if repliesExpanded[comment.id, default: false] {
                                    ForEach(comment.replies.sorted(by: sortByOldestFirst ? { $0.timestamp > $1.timestamp } : { $0.timestamp < $1.timestamp })) { reply in
                                        CommentRowView(comment: reply, onEdit: { text in
                                            Task {
                                                await commentVM.edit(comment: reply, with: text)
                                            }
                                        }, onDelete: {
                                            Task {
                                                await commentVM.delete(comment: reply)
                                            }
                                        }, onReply: nil)
                                        .padding(.leading)
                                    }
                                }
                            }
                        }
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
    let onReply: ((String) -> Void)?
    @State private var isEditing = false
    @State private var isReplying = false
    @State private var editedText: String = ""
    @State private var replyText: String = ""
    @EnvironmentObject var userVM: UserVM
    
    var body: some View {
        VStack(alignment: .leading) {
            if isEditing {
                TextField("Edit comment", text: $editedText)
                Button(action: {
                    if editedText.count <= AppSettings.commentMax {
                        onEdit(editedText)
                        isEditing = false
                    } // else, show an error or truncate the text
                }) {
                    Image(systemName: "checkmark")
                }
            } else {
                HStack {
                    Text("\(comment.userName): ")
                    Text(comment.text)
                }
                HStack {
                    if !userVM.user.id.isEmpty {
                        Button(action: { isReplying.toggle() }) {
                            Image(systemName: "arrowshape.turn.up.left")
                        }
                    }
                    if comment.userId == userVM.user.id {
                        Button(action: {
                            editedText = comment.text
                            isEditing = true
                        }) {
                            Image(systemName: "pencil")
                        }
                        Button(action: { onDelete() }) {
                            Image(systemName: "trash")
                        }
                    }
                }
                
                if isReplying, let onReply = onReply {
                    TextField("Write a reply...", text: $replyText)
                    HStack {
                        Button(action: {
                            if replyText.count <= AppSettings.commentMax {
                                onReply(replyText)
                                replyText = ""
                                isReplying = false
                            } // else, show an error or truncate the text
                        }) {
                            Image(systemName: "arrow.up.circle.fill")
                        }
                        Button(action: {
                            replyText = ""
                            isReplying = false
                        }) {
                            Image(systemName: "xmark")
                            .foregroundColor(.red)
                        }
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

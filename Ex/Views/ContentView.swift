//
//  ContentView.swift
//  Ex
//
//  Created by Sharan Thakur on 22/05/23.
//

import SwiftUI

struct ContentView: View {
    @State private var keys: [String] = []
    @State private var showAlert = false
    @State private var confirmAction = false
    @State private var success = false
    
    var body: some View {
        NavigationStack {
            AllWidgetsView()
                .padding(.horizontal, 10)
                .navigationTitle("All Widgets")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showAlert = true
                        } label: {
                            Label("Clear Keys?", systemImage: "gear.circle.fill")
                        }
                        .alert("Success!", isPresented: $success) {
                            Button("Okay") {
                                self.success = false
                            }
                        }
                        .confirmationDialog("Confirm Delete?", isPresented: $confirmAction) {
                            Button("Yes") {
                                self.deleteAllKeys()
                                self.confirmAction = false
                            }
                            
                            Button("No") {
                                self.confirmAction = false
                            }
                        } message: {
                            Text("This will delete all cache from app.")
                        }
                        .fullScreenCover(isPresented: $showAlert) {
                            List {
                                HStack {
                                    Button("Confirm?", role: .destructive) {
                                        self.showAlert = false
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            self.confirmAction = true
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Button("Cancel") {
                                        showAlert = false
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                                .foregroundColor(.black)
                                
                                ForEach(self.keys, id: \.self) { key in
                                    Text(key)
                                        .foregroundStyle(.black)
                                }
                            }
                            .background(.white)
                            .onAppear {
                                self.keys = appStorage.dictionaryRepresentation().keys.map { $0.description }
                            }
                        }
                    }
                }
        }
    }
    
    private func backGround() -> some View {
        let gradient = LinearGradient(
            colors: [.cyan, .blue],
            startPoint: .top,
            endPoint: .bottom
        )
        
        return Image("Main_BG")
            .resizable()
            .opacity(0.69)
            .scaledToFill()
            .ignoresSafeArea()
            .background(gradient)
    }
    
    private func deleteAllKeys() {
        for (k, _) in appStorage.dictionaryRepresentation() {
            appStorage.removeObject(forKey: k)
        }
        appStorage.synchronize()
        self.keys = appStorage.dictionaryRepresentation().keys.map { $0.description }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.success = true
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

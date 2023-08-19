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
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
                Text("KIDA Entertainment!")
                    .font(.system(.largeTitle, design: .rounded, weight: .heavy))
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                VStack(alignment: .center, spacing: 25.0) {
                    Text("Your One Stop Shop For Widget Entertainment!")
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .foregroundStyle(.black)
                        .padding(.bottom, 55.0)
                        .multilineTextAlignment(.center)
                    
                    NavigationLink {
                        AllWidgetsView()
                            .navigationTitle("All Widgets")
                            .navigationBarBackButtonHidden(true)
                    } label: {
                        Label("All Widgets View", systemImage: "arrow.forward.circle")
                            .foregroundStyle(.black)
                    }
                    .clipShape(Circle())
                    
                    Button("Clear All Keys") {
                        showAlert = true
                        print(appStorage.dictionaryRepresentation().keys.count)
                    }
                    .onAppear {
                        self.keys = appStorage.dictionaryRepresentation().keys.map { $0.description }
                        appStorage.dictionaryRepresentation().keys.map { $0.description }.forEach {
                            print($0)
                        }
                    }
                    .fullScreenCover(isPresented: $showAlert, content: {
                        List {
                            HStack {
                                Button("Confirm?", role: .destructive) {
                                    self.deleteAllKeys()
                                }
                                
                                Spacer()
                                
                                Button("Cancel") {
                                    showAlert = false
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .foregroundColor(.black)
                            
                            ForEach(appStorage.dictionaryRepresentation().keys.map { $0.description }, id: \.self) { key in
                                Text(key)
                                    .foregroundStyle(.black)
                            }
                        }
                    })
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.borderedProminent)
                .foregroundStyle(.bar)
                .tint(.orange)
                
                Spacer()
            }
            .padding(.vertical, 30)
            .padding(.horizontal, 10)
            .background(backGround())
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
            print(k)
            appStorage.removeObject(forKey: k)
        }
        appStorage.synchronize()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

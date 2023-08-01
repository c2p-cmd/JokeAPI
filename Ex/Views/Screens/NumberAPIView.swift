//
//  NumberAPIView.swift
//  Ex
//
//  Created by Sharan Thakur on 26/07/23.
//

import SwiftUI

struct NumberAPIView: View {
    private let categories = [
        "Number",
        "Date",
        "Year"
    ]
    
    @AppStorage("number_fact") private var fact: String = ""
    @State private var savedNumber: String = ""
    @State private var savedYear: String = ""
    @State private var chosenCategory: String = "Number"
    
    @State private var savedDate: Date = .now
    @State private var isBusy = false
    @State private var error: String?
    
    var body: some View {
        VStack(spacing: 50) {
            if let error {
                Text(error)
                    .foregroundStyle(.red)
            }
            
            Picker(selection: self.$chosenCategory) {
                ForEach(self.categories, id: \.self.hashValue) {
                    Text($0)
                        .tag($0)
                }
            } label: {
                Text("Choose category")
                    .font(.system(.title3, design: .rounded, weight: .bold))
            }
            .pickerStyle(.segmented)
            
            Text("Choose a \(self.chosenCategory)")
                .font(.system(size: 21, weight: .semibold, design: .rounded))
            
            switch self.chosenCategory {
            case categories[0]:
                TextField(
                    "Enter a number",
                    text: self.$savedNumber,
                    prompt: Text("Number")
                )
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
            case categories[1], categories[2]:
                DatePicker(
                    selection: self.$savedDate,
                    in: ...Date(),
                    displayedComponents: .date
                ) {
                    Image(systemName: "calendar.badge.clock")
                }
            default:
                TextField(
                    "Enter a number",
                    text: self.$savedYear,
                    prompt: Text("Year")
                )
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
            }
            
            if fact.isNotEmpty {
                Text(fact)
                    .font(.system(size: 22.5, design: .rounded))
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            Button("Submit", action: getNewFact)
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .disabled(isBusy)
        }
        .padding(.horizontal)
        .padding(.vertical, 100)
    }
    
    private func getNewFact() {
        if isBusy {
            return
        }
        
        isBusy = true
        
        switch self.chosenCategory {
        case categories[0]:
            guard let number = Int(savedNumber) else {
                self.error = "Enter a valid number"
                isBusy = false
                return
            }
            
            getFactAboutNumber(number, completion: onComplete(newFact:error:))
            break
        case categories[1]:
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd"
            let formattedDate = formatter.string(from: self.savedDate)
            
            getFactAboutDate(formattedDate: formattedDate, completion: onComplete(newFact:error:))
            break
        case categories[2]:
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy"
            let formattedDate = formatter.string(from: self.savedDate)
            
            print(formattedDate)
            
            guard let year = Int(formattedDate) else {
                self.error = "Invalid year!"
                self.isBusy = false
                return
            }
            
            getFactAboutYear(year: year, completion: onComplete(newFact:error:))
            break
        default:
            break
        }
    }
    
    private func onComplete(newFact: String?, error: Error?) {
        isBusy = false
        
        if let newFact {
            self.fact = newFact
            self.error = nil
        }
        
        if let error {
            self.error = error.localizedDescription
        }
    }
}

//#Preview {
//    NumberAPIView()
//}

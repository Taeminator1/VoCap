//
//  SearchView.swift
//  VoCap
//
//  Created by 윤태민 on 12/2/20.
//

import SwiftUI

struct SearchView: View {
    @State private var word: String = ""
    @State private var meaning: String = ""
    @State private var showingDictionarySheet: Bool = false
    @State private var showingWikipediaSheet: Bool = false
    
//    @EnvironmentObject var queryModle: QueryModel
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass")
                
                TextField("Search", text: $word, onEditingChanged: { _ in testOnEditingChanged() }, onCommit: { testOnCommit() })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                
                Button(action: { self.showingDictionarySheet.toggle() }) {
                    Text("Dict")
                }
                .sheet(isPresented: $showingDictionarySheet, content: {
                    DictionaryView(word: word)
                })
                
                Button(action: {self.showingWikipediaSheet.toggle() }) {
                    Text("Wiki")
                }
                .sheet(isPresented: $showingWikipediaSheet, content: {
                    WikipediaView()
                })
            }
            .padding(.all)
            
            HStack {
                Text("Word")
                Spacer()
                Text("Meaning")
                Spacer()
            }
            .padding([.top, .leading, .trailing])
            
            
            
            HStack {
                TextField("Word", text: $word)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                
                TextField("meaning", text: $meaning)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                
                Button(action: { print("add") }) {
                    Text("Add")
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
    
    func testOnEditingChanged() -> Void {
        print("change")
    }
    
    func testOnCommit() -> Void {
        print("testOnCommit")
//        self.showingDictionarySheet.toggle()
    }
    
//    func testOnCommit() -> Void {
//        let globalEntries = LexicalaFetchData(source: "global", text: word, morph: true)
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
//            if let results = globalEntries.lexicalaEntries!.results {
//                for result in results {
//                    if let headword = result.headword {
//                        if let text = headword.text {
//                            print(text)
//                            let passwordEntries = LexicalaFetchData(source: "password", text: text, analyzed: true)
//
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
//                                if let results = passwordEntries.lexicalaEntries!.results {
//                                    for result in results {
//                                        if let id = result.id {
//                                            print(id)
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                    }
//                    break               // results 중 첫 번째 것만 사용
//                }
//            }
//        }
//    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}


struct DictionaryView: UIViewControllerRepresentable {
    let word: String

    func makeUIViewController(context: UIViewControllerRepresentableContext<DictionaryView>) -> UIReferenceLibraryViewController {
        return UIReferenceLibraryViewController(term: word)
    }

    func updateUIViewController(_ uiViewController: UIReferenceLibraryViewController, context: UIViewControllerRepresentableContext<DictionaryView>) {
    }
}

struct WikipediaView: View {
    var body: some View {
        Text("WikipediaView")
    }
}


class QueryModel: ObservableObject {
    @Published var query: String = ""
}

struct textInputView: View {
    @EnvironmentObject var queryModel: QueryModel
    
    @State var query: String = ""
    
    var body: some View {
        let text = Binding(get: { self.query }, set: {
            self.query = $0; self.queryModel.query = $0;       // transfer query string
        })
        
        return TextField("Search", text: text)
    }
}

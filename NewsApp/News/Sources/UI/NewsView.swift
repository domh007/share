//
//  ContentView.swift
//  News
//
//  Created by Dominic Harrison on 25/06/2022.
//

import SwiftUI
struct NewsView: View {
    @ObservedObject var vm: NewsViewModel
    @State var showPassphrase = false
    
    public init(_ vm: NewsViewModel) {
        self.vm = vm
    }
    
    var body: some View {
        switch vm.loadingState {
        case .loading(let labelText), .error(let labelText):
            Text(labelText).padding()
        case .articlesAvailabe(let articles):
            NavigationView {
                List {
                    ForEach(articles, id: \.self) { article in
                        ArticleRow(article: article).onTapGesture {
                            vm.articleTapped(article: article)
                        }
                    }
                }
                .listStyle(GroupedListStyle())
                .navigationBarTitle(vm.title)
                .refreshable{
                    vm.requestNewData()
                }
            }
        case .undefined:
            Text("").padding()
        }
    }
}

struct ArticleRow: View {
    var article: UIArticle
    
    var body: some View {
        let dateFormatter = DateFormatter()
        let dateString = dateFormatter.string(from: article.date)
        HStack {
            AsyncImage(url: URL(string: article.thumbnail ?? "")) { image in
                image.resizable()
            } placeholder: {
                Color.gray
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .shadow(radius: 2.0)
            VStack(alignment: .leading, spacing: 20) {
                Text(article.title).font(.subheadline).bold()
                HStack {
                    Text(article.byline).font(.subheadline)
                    Text(dateString).font(.subheadline)
                }
            }
        }
    }
}

struct ArticleRow_Previews: PreviewProvider {
    static var previews: some View {
        let article = UIArticle(section: "arts",
                                title: "Preview Title",
                                byline: "Preview byline",
                                url: "http://bbc.co.uk",
                                date: Date.now,
                                thumbnail: "https://static01.nyt.com/images/2022/03/04/arts/04wubbels-2/04wubbels-2-thumbLarge.jpg")
        ArticleRow(article: article)
    }
}

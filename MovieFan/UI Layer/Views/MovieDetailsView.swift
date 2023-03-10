//
//  MovieDetailsView.swift
//  MovieFan
//
//  Created by Cong Huynh on 2023-03-06.
//

import SwiftUI

struct MovieDetailsView: View {
    var movie: Movie
    var body: some View {
        ScrollView {
            VStack {
                let url = URL(string: movie.getLargeImageUrl())
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .frame(width: 350, height: 350, alignment: .center)
                } placeholder: {
                    Image("blue_square")
                        .resizable()
                        .frame(width: 250, height: 250)
                }
                Spacer()
                Text("Released: \(movie.releaseDate)")
                Spacer()
                Text(movie.overview)
                    .font(.body)
                    .foregroundColor(.black)
            }
            // if the user is visually impaired cannot see the app directly
            // she can turn on the voice over by three taps on her iPhone/iPad.
            // Whenever she tap on the element, which is set up with accessibility
            // label, they would hear what it is exactly.
            .accessibilityLabel("Movie Details")
            //.accessibilityAddTraits(<#T##traits: AccessibilityTraits##AccessibilityTraits#>)
        }
        .navigationTitle(movie.title)
        .foregroundColor(.blue)
        .padding()
    }
}

struct MovieDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        MovieDetailsView(movie: Movie(id: 1,
                                      title: "Black Panther: Wakanda Forever",
                                      releaseDate: "2022-11-09",
                                      imageUrlSuffix: "/sv1xJUazXeYqALzczSZ3O6nkH75.jpg",
                                      overview: "Queen Ramonda, Shuri, M’Baku, Okoye and the Dora Milaje fight to protect their nation from intervening world powers in the wake of King T’Challa’s death.  As the Wakandans strive to embrace their next chapter, the heroes must band together with the help of War Dog Nakia and Everett Ross and forge a new path for the kingdom of Wakanda."))
    }
    
    
}

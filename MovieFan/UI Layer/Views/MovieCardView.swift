//
//  MovieCardView.swift
//  MovieFan
//
//  Created by Cong Huynh on 2023-03-06.
//

import SwiftUI

struct MovieCardView: View {
    var movie: Movie
    
    var body: some View {
        VStack {
            HStack {
                Text(movie.title)
                    .font(.headline)
                    .multilineTextAlignment(.leading)
                Spacer()
                let url = URL(string: movie.getThumbnailImageUrl())
                AsyncImage(url: url, scale: 0.9) { img in
                    img.scaledToFit()
                } placeholder: {
                    Image("blue_square")
                        .resizable()
                        .frame(width: 50, height: 50)
                }
                
            }
            HStack {
                Text(movie.releaseDate)
                    .font(.caption)
                    .foregroundColor(.accentColor)
                Spacer()
            }
        }.padding()
    }
}

struct MovieCardView_Previews: PreviewProvider {
    static var previews: some View {
        // Dumb data for preview
        MovieCardView(movie: Movie(id: 1,
                                   title: "Black Panther: Wakanda Forever",
                                   releaseDate: "2022-11-09",
                                   imageUrlSuffix: "/sv1xJUazXeYqALzczSZ3O6nkH75.jpg",
                                   overview: "Queen Ramonda, Shuri, M’Baku, Okoye and the Dora Milaje fight to protect their nation from intervening world powers in the wake of King T’Challa’s death.  As the Wakandans strive to embrace their next chapter, the heroes must band together with the help of War Dog Nakia and Everett Ross and forge a new path for the kingdom of Wakanda."))
    }
}

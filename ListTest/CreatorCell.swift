//
//  CreatorCell.swift
//  ListTest
//
//  Created by Артeмий Шлесберг on 19.10.2021.
//

import SwiftUI

struct CratorCellModel {
    
    var large: Bool = true
    var title: String = "Some new drops"
    var subtitle: String = " goes live tomorrow at 4:00 PM"
    var image: URL?
    var ticket: Bool = false
    var online: Bool = false
}

struct CreatorCellView: View {
    
    var model = CratorCellModel()
    
    var body: some View {
        if model.large {
            LargeCreatorCell(model: model)
        } else {
            SmallCreatorCell(model: model)
        }
    }
}

fileprivate struct SmallCreatorCell: View {
    var model: CratorCellModel
    
    var body: some View {
        VStack {
        ZStack(alignment: .bottomTrailing, content: {
            Color.gray
                .frame(width: 70, height: 70)
                .cornerRadius(20)
                .padding(EdgeInsets(top: 0, leading: 7, bottom: 3, trailing: 7))
            ZStack(alignment: .center) {
                Circle()
                    .strokeBorder(lineWidth: 5, antialiased: true)
                    .foregroundColor(.black)
                    .frame(width: 24, height: 24)
                Circle()
                    .foregroundColor(.green)
                    .frame(width: 14, height: 14)
            }
        })
            // Text Block
            (
                Text(model.title)
                    .foregroundColor(.white)
                +
                Text(model.subtitle)
                    .foregroundColor(.gray)
            )
                .multilineTextAlignment(.center)
                .font(Font.system(size: 18, weight: .semibold, design: .rounded))
            
            if model.ticket {
                Label("40.99$", systemImage: "ticket.fill")
                    .foregroundColor(.yellow)
            } else {
                HStack {
                    Image(systemName: "ticket.fill").foregroundColor(.gray)
                    Image(systemName: "checkmark").foregroundColor(.gray)
                }
            }
        }.frame(maxWidth: 140, maxHeight: 121)
    }
}


fileprivate struct LargeCreatorCell: View {
    var model: CratorCellModel
    
    var body: some View {
        VStack {
            ZStack(alignment: .bottomTrailing, content: {
                Color.gray
                    .frame(width: 90, height: 90)
                    .cornerRadius(30)
                    .padding(EdgeInsets(top: 0, leading: 7, bottom: 0, trailing: 7))
                ZStack(alignment: .center) {
                    Circle()
                        .strokeBorder(lineWidth: 5, antialiased: true)
                        .foregroundColor(.black)
                        .frame(width: 24, height: 24)
                    Circle()
                        .foregroundColor(.green)
                        .frame(width: 14, height: 14)
                }
            })
            // Text Block
            (
                Text(model.title)
                    .foregroundColor(.white)
                +
                Text(model.subtitle)
                    .foregroundColor(.gray)
            )
                .multilineTextAlignment(.center)
                .font(Font.system(size: 18, weight: .semibold, design: .rounded))
            
            if !model.ticket {
                Label("40.99$", systemImage: "ticket.fill")
                    .foregroundColor(.yellow)
            } else {
                HStack {
                    Image(systemName: "ticket.fill").foregroundColor(.gray)
                    Image(systemName: "checkmark").foregroundColor(.gray)
                }
            }
        }.frame(maxWidth: 215, maxHeight: 163)
    }
}


struct CreatorCell_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black
            CreatorCellView()
        }
        ZStack {
            Color.black
            CreatorCellView(model: CratorCellModel(
                large: false,
                title: "Alexa",
                subtitle: " is live",
                image: nil,
                ticket: false,
                online: false))
        }
        
    }
}

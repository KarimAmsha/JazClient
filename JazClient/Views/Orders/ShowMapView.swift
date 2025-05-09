//
//  ShowMapView.swift
//  Wishy
//
//  Created by Karim Amsha on 27.05.2024.
//

import SwiftUI
import MapKit

struct ShowMapView: View {
    @Binding var region: MKCoordinateRegion
    @Binding var locations: [Mark]
    @Binding var isShowingMap: Bool

    var body: some View {
        NavigationView {
            ZStack {
                Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: locations) { location in
                    MapAnnotation(
                        coordinate: location.coordinate,
                        anchorPoint: CGPoint(x: 0.5, y: 0.7)
                    ) {
                        VStack {
                            Image("ic_pin")
                                .resizable()
                                .frame(width: 32, height: 32)
                                .clipShape(Circle())
                        }
                    }
                }
                                                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Image(systemName: "square.arrowtriangle.4.outward")
                            .resizable()
                            .frame(width: 32, height: 32)
                            .foregroundColor(.gray)
                    }
                }
            }

            .edgesIgnoringSafeArea(.bottom)
            .navigationBarItems(trailing: Button(LocalizedStringKey.done) {
                isShowingMap = false
            })
            .foregroundColor(.black)
        }
    }
    
    func moveToUserLocation() {
        withAnimation(.easeInOut(duration: 2.0)) {
            LocationManager.shared.getCurrentLocation { location in
                if let location = location {
                    region.center = location
                    region.span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                }
            }
        }
    }
}


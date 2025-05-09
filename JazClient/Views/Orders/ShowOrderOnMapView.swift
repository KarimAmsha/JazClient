//
//  ShowOrderOnMapView.swift
//  Wishy
//
//  Created by Karim Amsha on 16.06.2024.
//

import SwiftUI
import MapKit

struct ShowOrderOnMapView: View {
    @Binding var region: MKCoordinateRegion
    let latitude: Double
    let longitude: Double
    @Binding var isShowingMap: Bool

    var body: some View {
        NavigationView {
            ZStack {
                Map(coordinateRegion: $region, annotationItems: [Mark(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))]) { location in
                    MapAnnotation(
                        coordinate: location.coordinate,
                        anchorPoint: CGPoint(x: 0.5, y: 0.7)
                    ) {
                        Image("ic_pin")
                            .resizable()
                            .frame(width: 32, height: 32)
                            .clipShape(Circle())
                    }
                }
                .onAppear {
                    setRegion()
                }

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Image(systemName: "square.arrowtriangle.4.outward")
                            .resizable()
                            .frame(width: 32, height: 32)
                            .foregroundColor(.gray)
                            .onTapGesture {
                                isShowingMap = false
                            }
                    }
                    .padding(16)
                }
            }
            .edgesIgnoringSafeArea(.bottom)
            .navigationBarItems(trailing: Button(LocalizedStringKey.done) {
                isShowingMap = false
            })
            .foregroundColor(.black)
        }
    }

    private func setRegion() {
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        
        region = MKCoordinateRegion(center: center, span: span)
    }
}

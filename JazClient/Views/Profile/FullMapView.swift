//
//  FullMapView.swift
//  Wishy
//
//  Created by Karim Amsha on 27.05.2024.
//

import SwiftUI
import MapKit

struct FullMapView: View {
    @Binding var region: MKCoordinateRegion
    @State private var locations: [Mark] = []
    @Binding var isShowingMap: Bool
    @Binding var address: String

    var body: some View {
        NavigationView {
            ZStack {
                Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: locations) { location in
                    MapAnnotation(
                        coordinate: location.coordinate,
                        anchorPoint: CGPoint(x: 0.5, y: 0.7)
                    ) {
                        VStack{
                            if location.show {
                                Text(location.title)
                                    .customFont(weight: .bold, size: 14)
                                    .foregroundColor(.black131313())
                            }
                            
                            Image(location.imageName)
                                .font(.title)
                                .foregroundColor(.red)
                                .onTapGesture {
                                    let index: Int = locations.firstIndex(where: {$0.id == location.id})!
                                    locations[index].show.toggle()
                                }
                        }
                    }
                }
                
                Image("ic_pin")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
                
                VStack {
                    Spacer()
                    Text(address)
                        .customFont(weight: .bold, size: 14)
                        .foregroundColor(.black131313())
                        .padding(10)
                        .background(Color.white.cornerRadius(8))
                        .padding()
                }
            }
            .edgesIgnoringSafeArea(.bottom)
            .navigationBarItems(trailing: Button(LocalizedStringKey.done) {
                isShowingMap = false
            })
            .foregroundColor(.black)
            .onAppear {
                moveToUserLocation()
            }
            .onChange(of: region, perform: { newRegion in
                Utilities.getAddress(for: newRegion.center) { address in
                    self.address = address
                }
            })
        }
    }
    
    func moveToUserLocation() {
        withAnimation(.easeInOut(duration: 2.0)) {
            if let userLocation = LocationManager.shared.userLocation {
                region.center = userLocation
                region.span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            }
        }
    }
}

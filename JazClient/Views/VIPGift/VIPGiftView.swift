//
//  VIPGiftView.swift
//  Wishy
//
//  Created by Karim Amsha on 14.06.2024.
//

import SwiftUI
import Combine
import PopupView
import MapKit

struct VIPGiftView: View {
    @ObservedObject var viewModel: InitialViewModel
    @EnvironmentObject var appRouter: AppRouter
    @State private var gender: Gender = .male
    @State private var latitude = ""
    @State private var longitude = ""
    @State private var address = ""
    @State private var note = ""
    @State private var selectedImages: [SelectedImage] = []
    @State private var showImagePicker = false
    @State private var phone = ""
    @State private var extraNote = ""
    @State private var total = ""
    @State private var isNeedOffer = true
    @State var countryPattern : String = "############"
    @FocusState private var keyIsFocused: Bool
    @State var countryPatternPalceholder : String = "966#########"
    @State private var description: String = LocalizedStringKey.description
    @State var placeholderString = LocalizedStringKey.description
    @State private var isShowingEvents = false
    @State private var selectedEvent: Event?
    @State private var userLocation: CLLocationCoordinate2D? = nil
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: 24.7136,
            longitude: 46.6753
        ),
        span: MKCoordinateSpan(
            latitudeDelta: 5,
            longitudeDelta: 5
        )
    )
    @State private var locations: [Mark] = []
    @State private var isShowingMap = false
    @State private var date: Date = Date()
    @State private var time: Date = Date()
    @State private var dateStr: String = ""
    @State private var timeStr: String = ""
    @State private var isShowingDatePicker = false
    @State private var isShowingTimePicker = false
    let categoryType: CategoryType?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 12) {
                    // Image picker button
                    VStack(alignment: .leading, spacing: 8) {
                        Text(LocalizedStringKey.addPhotos)
                            .customFont(weight: .regular, size: 12)
                            .foregroundColor(.black1F1F1F())
                        
                        Button(action: {
                            showImagePicker = true
                        }) {
                            Text(LocalizedStringKey.selectImages)
                                .foregroundColor(.primary1())
                                .frame(maxWidth: .infinity, maxHeight: 40)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                        }
                        .disabled(viewModel.isLoading)
                        
                        // Selected images
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(selectedImages) { selectedImage in
                                    Image(uiImage: selectedImage.image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .padding(.trailing, 8)
                                }
                            }
                        }
                    }
                    .sheet(isPresented: $showImagePicker) {
                        ImagePicker2(selectedImages: $selectedImages)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text(LocalizedStringKey.events)
                            .customFont(weight: .regular, size: 12)
                            .foregroundColor(.black1F1F1F())
                        ZStack {
                            CustomTextField(text: Binding(
                                get: { selectedEvent?.localizedName ?? "" },
                                set: { newText in
                                    // Implement the set closure if needed
                                }
                            ), placeholder: LocalizedStringKey.selectEvents, textColor: .black4E5556(), placeholderColor: .grayA4ACAD())
                                .disabled(true)
                            HStack {
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.black1F1F1F())
                                    .padding()
                            }
                        }
                        .roundedBackground(cornerRadius: 8, strokeColor: .black121212(), lineWidth: 1)
                    }
                    .onTapGesture {
                        isShowingEvents = true
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(LocalizedStringKey.gender)
                            .customFont(weight: .regular, size: 12)
                            .foregroundColor(.black1F1F1F())
                        GenderPickerView(selectedGender: $gender)
                            .padding(.vertical, 8)
                    }

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
                        .disabled(true)
                        .onChange(of: region, perform: { newRegion in
                            Utilities.getAddress(for: newRegion.center) { address in
                                self.address = address
                            }
                        })
                        .onAppear {
                            moveToUserLocation()
                        }

                        Image("ic_logo")
                            .resizable()
                            .frame(width: 32, height: 32)
                            .clipShape(Circle())
                        
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Image(systemName: "square.arrowtriangle.4.outward")
                                    .resizable()
                                    .frame(width: 32, height: 32)
                                    .foregroundColor(.gray)
                                    .onTapGesture {
                                        isShowingMap = true
                                    }
                            }
                        }
                        .padding(10)
                        .sheet(isPresented: $isShowingMap) {
                            FullMapView(region: $region, isShowingMap: $isShowingMap, address: $address)
                        }
                    }
                    .frame(height: 250)
                    .cornerRadius(8)

                    CustomInputField(title: LocalizedStringKey.address, text: $address, placeholder: LocalizedStringKey.address)
                        .disabled(viewModel.isLoading)

                    VStack {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(LocalizedStringKey.date)
                                    .customFont(weight: .regular, size: 12)
                                    .foregroundColor(.black1F1F1F())
                                CustomTextField(text: $dateStr, placeholder: LocalizedStringKey.date, textColor: .black4E5556(), placeholderColor: .grayA4ACAD())
                                    .disabled(true)
                                    .roundedBackground(cornerRadius: 8, strokeColor: .black121212(), lineWidth: 1)
                            }
                            .onTapGesture {
                                isShowingDatePicker = true
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text(LocalizedStringKey.time)
                                    .customFont(weight: .regular, size: 12)
                                    .foregroundColor(.black1F1F1F())
                                CustomTextField(text: $timeStr, placeholder: LocalizedStringKey.time, textColor: .black4E5556(), placeholderColor: .grayA4ACAD())
                                    .disabled(true)
                                    .roundedBackground(cornerRadius: 8, strokeColor: .black121212(), lineWidth: 1)
                            }
                            .onTapGesture {
                                isShowingTimePicker = true
                            }
                        }
                    }
                    
                    CustomInputField(title: LocalizedStringKey.note, text: $note, placeholder: LocalizedStringKey.note)
                        .disabled(viewModel.isLoading)

                    VStack(alignment: .leading, spacing: 8) {
                        Text(LocalizedStringKey.phoneNumber)
                            .customFont(weight: .regular, size: 12)
                            .foregroundColor(.black1F1F1F())
                        TextField(countryPatternPalceholder, text: $phone)
                            .placeholder(when: phone.isEmpty) {
                                Text(countryPatternPalceholder)
                                    .foregroundColor(.gray999999())
                            }
                            .focused($keyIsFocused)
                            .customFont(weight: .regular, size: 14)
                            .foregroundColor(.black1C2433())
                            .keyboardType(.phonePad)
                            .onReceive(Just(phone)) { _ in
                                applyPatternOnNumbers(&phone, pattern: countryPattern, replacementCharacter: "#")
                            }
                            .accentColor(.primary())
                            .padding(.horizontal, 16)
                            .padding(.vertical, 18)
                            .roundedBackground(cornerRadius: 8, strokeColor: .black121212(), lineWidth: 1)
                    }
                    
                    VStack(alignment: .leading) {
                        Text(LocalizedStringKey.description)
                            .customFont(weight: .regular, size: 12)
                            .foregroundColor(.black1F1F1F())

                        TextEditor(text: self.$description)
                            .customFont(weight: .regular, size: 14)
                            .foregroundColor(self.description == placeholderString ? .gray : .black121212())
                            .frame(height: 100)
                            .onTapGesture {
                                if self.description == placeholderString {
                                    self.description = ""
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 14)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .inset(by: 0.5)
                                    .stroke(Color(red: 0.93, green: 0.93, blue: 0.93), lineWidth: 1)
                            )
                            .roundedBackground(cornerRadius: 8, strokeColor: .black121212(), lineWidth: 1)
                    }

                    CustomInputField(title: LocalizedStringKey.estimatedAmount, text: $total, placeholder: LocalizedStringKey.estimatedAmount, keyboardType: .numberPad)
                        .disabled(viewModel.isLoading)
                        .onChange(of: total) { value in
                            total = value.toInt()?.toEnglish() ?? ""
                        }

//                    Toggle(isOn: $isNeedOffer) {
//                        Text(LocalizedStringKey.needsOffer)
//                            .customFont(weight: .bold, size: 14)
//                            .foregroundColor(.black121212())
//                    }
                }
            }
            
            if viewModel.isLoading {
                LoadingView()
            }

            Button {
                withAnimation {
                    handleImageUploadAndPostRequest()
                }
            } label: {
                Text(LocalizedStringKey.submit)
            }
            .buttonStyle(GradientPrimaryButton(fontSize: 16, fontWeight: .bold, background: Color.primaryGradientColor(), foreground: .white, height: 48, radius: 12))
        }
        .padding(16)
        .navigationBarBackButtonHidden()
        .background(Color.background())
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    Button {
                        appRouter.navigateBack()
                    } label: {
                        Image("ic_back")
                    }
                    
                    Text(categoryType == .eventPreparation ? LocalizedStringKey.eventsPreparing : LocalizedStringKey.VIPGift)
                        .customFont(weight: .bold, size: 20)
                        .foregroundColor(Color.primaryBlack())
                }
            }
        }
        .popup(isPresented: $isShowingEvents) {
            let model = CustomModel(title: LocalizedStringKey.events, content: "", items: viewModel.appconstantsItems?.event ?? [], onSelect: { item in
                self.selectedEvent = item
                self.isShowingEvents = false
            })

            EventListView(customModel: model)
        } customize: {
            $0
                .type(.toast)
                .position(.bottom)
                .animation(.spring())
                .closeOnTapOutside(true)
                .closeOnTap(false)
                .backgroundColor(Color.black.opacity(0.80))
                .isOpaque(true)
                .useKeyboardSafeArea(true)
        }
        .popup(isPresented: $isShowingDatePicker) {
            let dateModel = DateTimeModel(pickerMode: .date) { date in
                self.date = date
                dateStr = date.toString(format: "yyyy-MM-dd")
                isShowingDatePicker = false
            } onCancelAction: {
                isShowingDatePicker = false
            }
            
            DateTimePicker(model: dateModel)
        } customize: {
            $0
                .type(.toast)
                .position(.bottom)
                .animation(.spring())
                .closeOnTapOutside(true)
                .closeOnTap(false)
                .backgroundColor(Color.black.opacity(0.80))
                .isOpaque(true)
                .useKeyboardSafeArea(true)
        }
        
        .popup(isPresented: $isShowingTimePicker) {
            let timeModel = DateTimeModel(pickerMode: .time) { time in
                self.time = time
                timeStr = time.toString(format: "hh: mm a")
                isShowingTimePicker = false
            } onCancelAction: {
                isShowingTimePicker = false
            }
            
            DateTimePicker(model: timeModel)
        } customize: {
            $0
                .type(.toast)
                .position(.bottom)
                .animation(.spring())
                .closeOnTapOutside(true)
                .closeOnTap(false)
                .backgroundColor(Color.black.opacity(0.80))
                .isOpaque(true)
                .useKeyboardSafeArea(true)
        }
        .overlay(
            MessageAlertObserverView(
                message: $viewModel.errorMessage,
                alertType: .constant(.error)
            )
        )
        .onAppear {
            viewModel.fetchAppConstantsItems()
        }
    }
    
    func handleImageUploadAndPostRequest() {
        viewModel.errorMessage = nil
        viewModel.isLoading = true
        let userID = UserSettings.shared.id ?? ""

        // Convert images to [UIImage?] format
        let images: [UIImage?] = selectedImages.map { $0.image }

        FirestoreService.shared.uploadMultipleImages(images: images, id: userID) { imageUrls, success in
            if success, let urls = imageUrls {
                var imagesArray: [String] = []
                for url in urls {
                    imagesArray.append(url)
                }

                let body: [String: Any] = [
                    "event_id": selectedEvent?.id ?? "",
                    "gender": gender.value,
                    "lat": region.center.latitude.toString(),
                    "lng": region.center.longitude.toString(),
                    "address": address,
                    "date": dateStr,
                    "time": timeStr,
                    "note": note,
                    "images": imagesArray,
                    "reciver_phone": phone,
                    "extra_note": description,
                    "total": total,
                    "isNeedOffer": String(isNeedOffer)
                ]
                
                viewModel.addVIP2(params: body) {
                    appRouter.navigateBack()
                }
            } else {
                self.viewModel.isLoading = false
                self.viewModel.errorMessage = "Failed to upload images"
            }
        }
    }
    
    func applyPatternOnNumbers(_ stringvar: inout String, pattern: String, replacementCharacter: Character) {
        var pureNumber = stringvar.replacingOccurrences( of: "[^0-9]", with: "", options: .regularExpression)
        for index in 0 ..< pattern.count {
            guard index < pureNumber.count else {
                stringvar = pureNumber
                return
            }
            let stringIndex = String.Index(utf16Offset: index, in: pattern)
            let patternCharacter = pattern[stringIndex]
            guard patternCharacter != replacementCharacter else { continue }
            pureNumber.insert(patternCharacter, at: stringIndex)
        }
        stringvar = pureNumber
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

struct VIPGiftView_Previews: PreviewProvider {
    static var previews: some View {
        VIPGiftView(viewModel: InitialViewModel(errorHandling: ErrorHandling()), categoryType: nil)
            .environmentObject(AppRouter())
    }
}

struct GenderPickerView: View {
    @Binding var selectedGender: Gender

    var body: some View {
        Picker(LocalizedStringKey.gender, selection: $selectedGender) {
            ForEach(Gender.allCases) { gender in
                Text(gender.localizedValue).tag(gender)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }
}

enum Gender: String, CaseIterable, Identifiable {
    case male
    case female

    var id: String { self.rawValue }
    
    var value : String {
        switch self {
        case .male: return "Male"
        case .female: return "Female"
        }
    }
    
    var localizedValue : String {
        switch self {
        case .male: return LocalizedStringKey.male
        case .female: return LocalizedStringKey.female
        }
    }
}

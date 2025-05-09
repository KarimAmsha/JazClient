//
//  AddServiceView.swift
//  FreelanceApp
//
//  Created by Karim OTHMAN on 7.05.2025.
//

import SwiftUI

import SwiftUI

struct AddServiceView: View {
    @State private var currentStep = 0
    @State private var service = ServiceModel()
    @EnvironmentObject var appRouter: AppRouter

    var body: some View {
        VStack(alignment: .leading) {
            StepperView(currentStep: $currentStep)
                .padding(.top)

            VStack {
                switch currentStep {
                case 0:
                    AddServiceInfoView(service: $service)
                case 1:
                    AddServiceImagesView(service: $service)
                case 2:
                    AddServicePricingView(service: $service)
                default:
                    Text("تم الانتهاء")
                }
            }
            .padding(.vertical)

            Spacer()

            HStack {
                if currentStep > 0 {
                    SecondaryActionButton(title:"رجوع") {
                        currentStep -= 1
                    }
                }

                Spacer()

                if currentStep < 2 {
                    PrimaryActionButton(title:"التالي") {
                        currentStep += 1
                    }
                } else {
                    PrimaryActionButton(title:"حفظ وتفعيل الخدمة") {
                        // Submit Logic
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .padding()
        .background(Color.background())
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                VStack(alignment: .leading) {
                    Text("اضافة خدمة جديد 💻")
                        .customFont(weight: .bold, size: 20)
                    Text("اضافة خدمات جديدة باسرع واسهل طريقة ممكنة!")
                        .customFont(weight: .regular, size: 10)
                }
                .foregroundColor(Color.black222020())
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Image("ic_bell")
                    .onTapGesture {
                        appRouter.navigate(to: .notifications)
                    }
            }
        }
    }
}

#Preview {
    AddServiceView()
}

struct StepperView: View {
    @Binding var currentStep: Int

    let steps = ["المعلومات العامة", "صور الخدمة", "تسعير الخدمة"]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<steps.count, id: \.self) { index in
                VStack {
                    Circle()
                        .fill(index <= currentStep ? Color.primary() : Color.gray.opacity(0.5))
                        .frame(width: 12, height: 12)
                    Text(steps[index])
                        .font(.caption)
                        .foregroundColor(index <= currentStep ? .primary() : .gray)
                }

                if index != steps.count - 1 {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 1)
                        .padding(.horizontal, 4)
                }
            }
        }
    }
}

struct AddServiceInfoView: View {
    @Binding var service: ServiceModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .center, spacing: 4) {
                    Text("•")
                        .font(.title2)
                        .padding(.top, 2)

                    Text("المعلومات العامة")
                        .font(.headline)
                        .bold()
                }

                Text("اختر التخصص الاساسي والفرعي للخدمة")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.bottom, 16)

            TextField("اكتب عنوان واضح للخدمة", text: $service.title)
                .padding()
                .background(Color.white)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3)))

            TextEditor(text: $service.description)
                .frame(height: 100)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
        }
    }
}

struct AddServiceImagesView: View {
    @Binding var service: ServiceModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .center, spacing: 4) {
                    Text("•")
                        .font(.title2)
                        .padding(.top, 2)

                    Text("صور الخدمة")
                        .font(.headline)
                        .bold()
                }

                Text("قم برفع صور توضح جودة عملك لجذب عملاء أكثر!")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.bottom, 16)

            Button(action: {
                // Image picker logic
            }) {
                VStack {
                    Image(systemName: "camera.fill")
                        .font(.largeTitle)
                        .foregroundColor(.yellowF8B22A())
                        .padding()
                    Text("قم بالضغط لرفع صور الخدمة")
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 180)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(style: StrokeStyle(lineWidth: 1, dash: [5])))
            }

            ScrollView(.horizontal) {
                HStack {
                    ForEach(service.images, id: \.self) { img in
                        Image(uiImage: img)
                            .resizable()
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
        }
    }
}

struct AddServicePricingView: View {
    @Binding var service: ServiceModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .center, spacing: 4) {
                    Text("•")
                        .font(.title2)
                        .padding(.top, 2)

                    Text("تسعير الخدمة")
                        .font(.headline)
                        .bold()
                }

                Text("قم بوضع سعر منطقي مقابل الخدمة التي تقدمها!")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.bottom, 16)

            HStack {
                TextField("السعر", value: $service.price, formatter: NumberFormatter())
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)

                Text("دولار")
            }

            Stepper("عدد التعديلات الجانبية: \(service.revisionCount)", value: $service.revisionCount, in: 0...10)

            HStack {
                TextField("سعر التعديل الواحد", value: $service.revisionPrice, formatter: NumberFormatter())
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                Text("دولار")
            }

            Stepper("مدة التنفيذ (أيام): \(service.deliveryTime)", value: $service.deliveryTime, in: 1...30)
        }
    }
}

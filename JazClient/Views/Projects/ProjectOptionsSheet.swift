import SwiftUI

struct ProjectOptionsSheet: View {
    @Binding var isPresented: Bool
    var onRequestEdit: () -> Void
    var onRequestCancel: () -> Void
    var onRequestSpeedUp: () -> Void

    var body: some View {
        ModalTemplate(
            title: "خيارات المشروع",
            content: {
                VStack(alignment: .leading, spacing: 12) {
                    Text("قم بإدارة المشروع الحالي ..")
                        .foregroundColor(.black)
                    Button(action: {
                        isPresented = false
                        onRequestEdit()
                    }) {
                        Label("طلب تعديل على الخدمة", systemImage: "pencil")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            .foregroundColor(.black)
                    }
                    Button(action: {
                        isPresented = false
                        onRequestCancel()
                    }) {
                        Label("طلب إلغاء الخدمة", systemImage: "xmark.circle")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            .foregroundColor(.black)
                    }
                    Button(action: {
                        isPresented = false
                        onRequestSpeedUp()
                    }) {
                        Label("طلب تسريع التسليم", systemImage: "clock.arrow.circlepath")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            .foregroundColor(.black)
                    }
                }
            },
            onClose: {
                isPresented = false
            }
        )
    }
}

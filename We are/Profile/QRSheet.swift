import SwiftUI
import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

struct QRSheet: View {
    var text: String
    var avatar: UIImage?

    @Environment(\.dismiss) private var dismiss

    private let context = CIContext()
    private let filter = CIFilter.qrCodeGenerator()

    var body: some View {
        ZStack {
            Color.black.opacity(0.35).ignoresSafeArea()

            VStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.white)
                        .shadow(color: .black.opacity(0.25), radius: 16, y: 8)
                        .frame(width: 280, height: 280)

                    Image(uiImage: generateQR(from: text))
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 210, height: 210)
                }
                .overlay(alignment: .top) {
                    if let avatar {
                        Image(uiImage: avatar)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 72, height: 72)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                            .offset(y: -36)
                    }
                }

                Text("Отсканируйте и оставьте отзыв\nо компании или о сотруднике")
                    .multilineTextAlignment(.center)
                    .font(.subheadline)
                    .foregroundStyle(.white)
                    .padding(.horizontal)
            }
        }
        .onTapGesture { dismiss() }
    }

    private func generateQR(from string: String) -> UIImage {
        // Сообщение и уровень коррекции
        filter.setValue(Data(string.utf8), forKey: "inputMessage")
        filter.setValue("M", forKey: "inputCorrectionLevel")

        let output = filter.outputImage ?? CIImage()
        // Масштабируем, чтобы картинка была чёткой
        let scaled = output.transformed(by: CGAffineTransform(scaleX: 8, y: 8))

        if let cgimg = context.createCGImage(scaled, from: scaled.extent) {
            return UIImage(cgImage: cgimg)
        } else {
            return UIImage() // пустая картинка как fallback
        }
    }
}

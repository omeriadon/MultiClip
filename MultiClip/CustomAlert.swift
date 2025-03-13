import SwiftUI

struct CustomAlert: View {
    var title: String
    var message: String
    var primaryButtonTitle: String = "OK"
    var primaryButtonAction: () -> Void = {}
    var primaryButtonRole: ButtonRole? = nil
    
    var secondaryButtonTitle: String? = nil
    var secondaryButtonAction: (() -> Void)? = nil
    var secondaryButtonRole: ButtonRole? = nil
    
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.3)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    withAnimation {
                        isPresented = false
                    }
                }
            
            // Alert content
            VStack(spacing: 16) {
                // Title
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                // Message
                Text(message)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 8)
                
                // Buttons
                HStack(spacing: 16) {
                    if let secondaryButtonTitle = secondaryButtonTitle {
                        Button(role: secondaryButtonRole) {
                            isPresented = false
                            secondaryButtonAction?()
                        } label: {
                            Text(secondaryButtonTitle)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    Button(role: primaryButtonRole) {
                        isPresented = false
                        primaryButtonAction()
                    } label: {
                        Text(primaryButtonTitle)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(primaryButtonRole == .destructive ? .borderedProminent : .borderedProminent)
                    .tint(primaryButtonRole == .destructive ? .red : nil)
                }
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
            .cornerRadius(12)
            .shadow(radius: 10)
            .padding(30)
            .frame(maxWidth: 300)
        }
        .transition(.opacity)
    }
}

struct CustomAlertModifier: ViewModifier {
    var title: String
    var message: String
    var primaryButtonTitle: String
    var primaryButtonAction: () -> Void
    var primaryButtonRole: ButtonRole?
    
    var secondaryButtonTitle: String?
    var secondaryButtonAction: (() -> Void)?
    var secondaryButtonRole: ButtonRole?
    
    @Binding var isPresented: Bool
    
    func body(content: Content) -> some View {
        content.overlay {
            if isPresented {
                CustomAlert(
                    title: title,
                    message: message,
                    primaryButtonTitle: primaryButtonTitle,
                    primaryButtonAction: primaryButtonAction,
                    primaryButtonRole: primaryButtonRole,
                    secondaryButtonTitle: secondaryButtonTitle,
                    secondaryButtonAction: secondaryButtonAction,
                    secondaryButtonRole: secondaryButtonRole,
                    isPresented: $isPresented
                )
            }
        }
    }
}

extension View {
    func customAlert(
        title: String,
        message: String,
        isPresented: Binding<Bool>,
        primaryButtonTitle: String = "OK",
        primaryButtonAction: @escaping () -> Void = {},
        primaryButtonRole: ButtonRole? = nil,
        secondaryButtonTitle: String? = nil,
        secondaryButtonAction: (() -> Void)? = nil,
        secondaryButtonRole: ButtonRole? = nil
    ) -> some View {
        self.modifier(
            CustomAlertModifier(
                title: title,
                message: message,
                primaryButtonTitle: primaryButtonTitle,
                primaryButtonAction: primaryButtonAction,
                primaryButtonRole: primaryButtonRole,
                secondaryButtonTitle: secondaryButtonTitle,
                secondaryButtonAction: secondaryButtonAction,
                secondaryButtonRole: secondaryButtonRole,
                isPresented: isPresented
            )
        )
    }
}

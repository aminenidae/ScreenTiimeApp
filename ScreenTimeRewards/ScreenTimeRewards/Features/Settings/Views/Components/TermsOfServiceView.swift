import SwiftUI
import DesignSystem

struct TermsOfServiceView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                termsOfServiceContent
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Terms of Service")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Terms of Service")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Last Updated: September 28, 2025")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var termsOfServiceContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("These Terms of Service govern your use of the Screen Time Rewards application. By using the app, you agree to these terms.")
                .font(.body)
            
            SectionHeader(title: "Acceptance of Terms")
            
            Text("By downloading, installing, or using Screen Time Rewards, you agree to be bound by these Terms of Service and all applicable laws and regulations.")
                .font(.body)
            
            SectionHeader(title: "License")
            
            Text("Screen Time Rewards is licensed, not sold. We grant you a limited, non-exclusive, non-transferable license to use the app for personal, non-commercial use.")
                .font(.body)
            
            SectionHeader(title: "Use of the Service")
            
            Text("You agree to use Screen Time Rewards only for lawful purposes and in accordance with these Terms. You agree not to:")
                .font(.body)
            
            BulletPoint(text: "Use the app in any way that violates applicable laws")
            BulletPoint(text: "Interfere with or disrupt the operation of the service")
            BulletPoint(text: "Attempt to gain unauthorized access to the service")
            BulletPoint(text: "Use the app for any fraudulent or malicious activities")
            
            SectionHeader(title: "Subscription and Payments")
            
            Text("Screen Time Rewards offers subscription-based features. By purchasing a subscription, you agree to pay the applicable fees and taxes.")
                .font(.body)
            
            BulletPoint(text: "Subscriptions automatically renew unless cancelled")
            BulletPoint(text: "You can cancel subscriptions at any time through the App Store")
            BulletPoint(text: "No refunds are provided for partial subscription periods")
            BulletPoint(text: "Prices are subject to change with notice")
            
            SectionHeader(title: "Intellectual Property")
            
            Text("Screen Time Rewards and its content are protected by copyright, trademark, and other intellectual property laws. You may not copy, modify, or distribute any part of the app without our permission.")
                .font(.body)
            
            SectionHeader(title: "Disclaimer of Warranties")
            
            Text("Screen Time Rewards is provided \"as is\" without warranties of any kind. We do not warrant that the app will be uninterrupted or error-free.")
                .font(.body)
            
            SectionHeader(title: "Limitation of Liability")
            
            Text("To the maximum extent permitted by law, we shall not be liable for any indirect, incidental, special, or consequential damages arising out of or in connection with your use of the app.")
                .font(.body)
            
            SectionHeader(title: "Termination")
            
            Text("We may terminate or suspend your access to Screen Time Rewards at any time, without notice, for any reason, including breach of these Terms.")
                .font(.body)
            
            SectionHeader(title: "Governing Law")
            
            Text("These Terms shall be governed by and construed in accordance with the laws of the State of California, without regard to its conflict of law provisions.")
                .font(.body)
            
            SectionHeader(title: "Changes to Terms")
            
            Text("We may update these Terms from time to time. Any changes will be posted on this page with an updated date. Your continued use of the app after changes constitutes acceptance of the new terms.")
                .font(.body)
            
            SectionHeader(title: "Contact Information")
            
            Text("If you have any questions about these Terms of Service, please contact us at:")
                .font(.body)
            
            Text("support@screentimerewards.com")
                .font(.body)
                .foregroundColor(.blue)
            
            Text("https://screentimerewards.com/support")
                .font(.body)
                .foregroundColor(.blue)
        }
    }
}

#Preview {
    NavigationView {
        TermsOfServiceView()
    }
}
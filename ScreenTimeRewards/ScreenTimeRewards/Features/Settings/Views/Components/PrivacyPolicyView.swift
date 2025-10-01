import SwiftUI
import DesignSystem

struct PrivacyPolicyView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                privacyPolicyContent
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Privacy Policy")
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
            Text("Privacy Policy")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Last Updated: September 28, 2025")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var privacyPolicyContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your privacy is important to us. This Privacy Policy explains how Screen Time Rewards collects, uses, and protects your information.")
                .font(.body)
            
            SectionHeader(title: "Information We Collect")
            
            Text("Screen Time Rewards does not collect any personal data. All information is stored locally on your device or within your family's private iCloud account.")
                .font(.body)
            
            SectionHeader(title: "How We Use Information")
            
            Text("We use device-local information to provide the screen time management and rewards features. This includes:")
                .font(.body)
            
            BulletPoint(text: "App usage data to calculate points")
            BulletPoint(text: "Child profile information to personalize the experience")
            BulletPoint(text: "Reward configurations set by parents")
            BulletPoint(text: "Achievement progress and statistics")
            
            SectionHeader(title: "Data Sharing and Disclosure")
            
            Text("We do not share, sell, or transmit any user data to third parties. All data remains within your family's private iCloud account or on your device.")
                .font(.body)
            
            SectionHeader(title: "Children's Privacy")
            
            Text("Screen Time Rewards is designed for families and takes children's privacy seriously. The app complies with the Children's Online Privacy Protection Act (COPPA) by:")
                .font(.body)
            
            BulletPoint(text: "Not collecting personal information from children")
            BulletPoint(text: "Storing all data locally or in family iCloud accounts")
            BulletPoint(text: "Requiring parental consent for child accounts")
            BulletPoint(text: "Providing parental controls for all features")
            
            SectionHeader(title: "Data Security")
            
            Text("We implement appropriate security measures to protect your information, including:")
                .font(.body)
            
            BulletPoint(text: "End-to-end encryption for iCloud data")
            BulletPoint(text: "Secure local storage on your device")
            BulletPoint(text: "No transmission of personal data to external servers")
            
            SectionHeader(title: "Data Retention")
            
            Text("You can delete all data at any time by removing the app or deleting your iCloud data. There are no automatic data retention periods.")
                .font(.body)
            
            SectionHeader(title: "Changes to This Policy")
            
            Text("We may update this Privacy Policy from time to time. Any changes will be posted on this page with an updated date.")
                .font(.body)
            
            SectionHeader(title: "Contact Us")
            
            Text("If you have any questions about this Privacy Policy, please contact us at:")
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

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.headline)
            .fontWeight(.semibold)
            .padding(.top, 8)
    }
}

struct BulletPoint: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .font(.body)
                .foregroundColor(.primary)
            Text(text)
                .font(.body)
                .foregroundColor(.primary)
            Spacer()
        }
    }
}

#Preview {
    NavigationView {
        PrivacyPolicyView()
    }
}
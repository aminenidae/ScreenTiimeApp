import SwiftUI

public enum IconSystem {

    // MARK: - Navigation Icons
    public enum Navigation {
        public static let dashboard = "chart.bar.fill"
        public static let rewards = "gift.fill"
        public static let settings = "gearshape.fill"
        public static let profile = "person.circle.fill"
        public static let back = "chevron.left"
        public static let forward = "chevron.right"
        public static let close = "xmark"
        public static let menu = "line.horizontal.3"
    }

    // MARK: - Action Icons
    public enum Action {
        public static let add = "plus"
        public static let edit = "pencil"
        public static let delete = "trash"
        public static let save = "checkmark"
        public static let cancel = "xmark"
        public static let refresh = "arrow.clockwise"
        public static let share = "square.and.arrow.up"
        public static let search = "magnifyingglass"
        public static let filter = "line.horizontal.3.decrease"
        public static let sort = "arrow.up.arrow.down"
    }

    // MARK: - Status Icons
    public enum Status {
        public static let success = "checkmark.circle.fill"
        public static let warning = "exclamationmark.triangle.fill"
        public static let error = "xmark.circle.fill"
        public static let info = "info.circle.fill"
        public static let loading = "arrow.2.circlepath"
        public static let offline = "wifi.slash"
        public static let online = "wifi"
    }

    // MARK: - Gamification Icons
    public enum Gamification {
        public static let points = "star.fill"
        public static let achievement = "trophy.fill"
        public static let badge = "shield.fill"
        public static let streak = "flame.fill"
        public static let level = "crown.fill"
        public static let progress = "chart.line.uptrend.xyaxis"
        public static let reward = "gift.fill"
        public static let coin = "dollarsign.circle.fill"
        public static let gem = "diamond.fill"
        public static let medal = "medal.fill"
    }

    // MARK: - Screen Time Icons
    public enum ScreenTime {
        public static let clock = "clock.fill"
        public static let timer = "timer"
        public static let hourglass = "hourglass"
        public static let screenTime = "iphone"
        public static let app = "app.fill"
        public static let category = "folder.fill"
        public static let limit = "hand.raised.fill"
        public static let allowance = "checkmark.shield.fill"
    }

    // MARK: - Family Icons
    public enum Family {
        public static let parent = "person.fill"
        public static let child = "figure.child"
        public static let family = "person.3.fill"
        public static let supervision = "eye.fill"
        public static let approval = "hand.thumbsup.fill"
        public static let restriction = "hand.raised.fill"
    }

    // MARK: - App Category Icons
    public enum AppCategory {
        public static let educational = "book.fill"
        public static let creative = "paintbrush.fill"
        public static let reading = "text.book.closed.fill"
        public static let productivity = "briefcase.fill"
        public static let entertainment = "tv.fill"
        public static let games = "gamecontroller.fill"
        public static let social = "message.fill"
        public static let other = "app.dashed"
    }

    // MARK: - Communication Icons
    public enum Communication {
        public static let notification = "bell.fill"
        public static let message = "message.fill"
        public static let email = "envelope.fill"
        public static let phone = "phone.fill"
        public static let video = "video.fill"
        public static let chat = "bubble.left.and.bubble.right.fill"
    }

    // MARK: - Settings Icons
    public enum Settings {
        public static let general = "gearshape.fill"
        public static let privacy = "lock.shield.fill"
        public static let notifications = "bell.badge.fill"
        public static let account = "person.crop.circle.fill"
        public static let security = "key.fill"
        public static let help = "questionmark.circle.fill"
        public static let about = "info.circle.fill"
        public static let logout = "rectangle.portrait.and.arrow.right"
    }

    // MARK: - Utility Functions
    public static func icon(_ name: String, size: CGFloat = 24) -> some View {
        Image(systemName: name)
            .font(.system(size: size))
    }

    public static func iconButton(
        _ name: String,
        size: CGFloat = 24,
        color: Color = ColorTokens.Primary.blue500,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: name)
                .font(.system(size: size))
                .foregroundColor(color)
        }
    }
}
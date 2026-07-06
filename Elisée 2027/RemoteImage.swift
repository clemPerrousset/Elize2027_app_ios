import SwiftUI
#if canImport(UIKit)
import UIKit
typealias PlatformImage = UIImage
#elseif canImport(AppKit)
import AppKit
typealias PlatformImage = NSImage
#endif

// URLSession avec User-Agent requis par Wikimedia Commons
private let wikiSession: URLSession = {
    let config = URLSessionConfiguration.default
    config.httpAdditionalHeaders = ["User-Agent": "Elyze2027App/1.0 (iOS; contact@elyze2027.fr)"]
    return URLSession(configuration: config)
}()

private final class ImageCache: @unchecked Sendable {
    static let shared = ImageCache()
    private let cache = NSCache<NSString, PlatformImage>()
    func get(_ url: URL) -> PlatformImage? { cache.object(forKey: url.absoluteString as NSString) }
    func set(_ img: PlatformImage, for url: URL) { cache.setObject(img, forKey: url.absoluteString as NSString) }
}

struct RemoteImage: View {
    let url: URL
    let initials: String
    let color: Color

    @State private var image: PlatformImage? = nil

    var body: some View {
        Group {
            if let img = image {
                #if canImport(UIKit)
                Image(uiImage: img).resizable().scaledToFill()
                #elseif canImport(AppKit)
                Image(nsImage: img).resizable().scaledToFill()
                #endif
            } else {
                Text(initials)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(color)
            }
        }
        .task(id: url) { await load() }
    }

    private func load() async {
        if let cached = ImageCache.shared.get(url) { image = cached; return }
        guard let (data, _) = try? await wikiSession.data(from: url),
              let img = PlatformImage(data: data) else { return }
        ImageCache.shared.set(img, for: url)
        withAnimation(.easeIn(duration: 0.2)) { image = img }
    }
}

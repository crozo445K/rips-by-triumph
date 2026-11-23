import SwiftUI

@main
struct RipsStyleDemoApp: App {
    var body: some Scene {
        WindowGroup { MainView() }
    }
}

struct DemoCard: Identifiable, Codable, Hashable {
    var id = UUID()
    let player: String
    let team: String
    let rarity: String
    let rating: Int
    let colorHex: String
}

final class DemoStore: ObservableObject {
    @Published var credits = 2500
    @Published var cards: [DemoCard] = []
    @Published var latest: DemoCard?
    @Published var activeTab = 0

    let names = [
        ("J. Carter", "CHICAGO", "COMMON", 84, "477DA8"),
        ("M. Hayes", "NEW YORK", "RARE", 91, "8064B5"),
        ("A. Brooks", "LOS ANGELES", "EPIC", 95, "B77B38"),
        ("D. Morgan", "BOSTON", "LEGENDARY", 99, "B99B48"),
        ("T. Wilson", "MIAMI", "RARE", 89, "3C9B91")
    ]

    func openPack() {
        guard credits >= 250 else { return }
        credits -= 250
        let item = names.randomElement()!
        let card = DemoCard(player: item.0, team: item.1, rarity: item.2,
                            rating: item.3, colorHex: item.4)
        cards.insert(card, at: 0)
        latest = card
    }

    func claimDaily() { credits += 500 }
}

struct MainView: View {
    @StateObject private var store = DemoStore()
    var body: some View {
        ZStack {
            Color(hex: "090D16").ignoresSafeArea()
            Group {
                switch store.activeTab {
                case 0: HomeView()
                case 1: CollectionView()
                case 2: RewardsView()
                default: ProfileView()
                }
            }
            .environmentObject(store)
        }
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: 0) {
                tab("square.grid.2x2.fill", "PACKS", 0)
                tab("rectangle.stack.fill", "COLLECTION", 1)
                tab("gift.fill", "REWARDS", 2)
                tab("person.crop.circle.fill", "ACCOUNT", 3)
            }
            .padding(.top, 12).padding(.bottom, 8)
            .background(Color(hex: "101725"))
            .overlay(alignment: .top) { Rectangle().fill(Color.white.opacity(0.08)).frame(height: 1) }
        }
        .preferredColorScheme(.dark)
        .sheet(item: $store.latest) { card in
            RevealView(card: card).presentationDetents([.medium, .large])
        }
    }
    private func tab(_ icon: String, _ title: String, _ index: Int) -> some View {
        Button { store.activeTab = index } label: {
            VStack(spacing: 5) {
                Image(systemName: icon).font(.system(size: 19, weight: .semibold))
                Text(title).font(.system(size: 9, weight: .bold, design: .rounded))
            }
            .foregroundStyle(store.activeTab == index ? Color(hex: "64B9FF") : .white.opacity(0.48))
            .frame(maxWidth: .infinity)
        }
    }
}

struct Header: View {
    @EnvironmentObject var store: DemoStore
    var title: String
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("RIP • CARD CLUB").font(.system(size: 10, weight: .black, design: .rounded)).tracking(2).foregroundStyle(Color(hex: "69BFFF"))
                Text(title).font(.system(size: 27, weight: .heavy, design: .rounded))
            }
            Spacer()
            HStack(spacing: 7) {
                Image(systemName: "sparkle").foregroundStyle(Color(hex: "77C6FF"))
                Text("\(store.credits.formatted())").font(.system(size: 14, weight: .bold, design: .rounded))
                Image(systemName: "plus.circle.fill").foregroundStyle(Color(hex: "77C6FF"))
            }
            .padding(.horizontal, 12).padding(.vertical, 10)
            .background(Color.white.opacity(0.07), in: Capsule())
        }
        .padding(.horizontal, 20).padding(.top, 12)
    }
}

struct HomeView: View {
    @EnvironmentObject var store: DemoStore
    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                Header(title: "Packs")
                HStack {
                    VStack(alignment: .leading, spacing: 7) {
                        Text("THE NEXT BIG PULL").font(.system(size: 11, weight: .black)).tracking(1.5).foregroundStyle(Color(hex: "7CC8FF"))
                        Text("Your collection\nstarts here.").font(.system(size: 29, weight: .heavy, design: .rounded))
                        Text("Open a free-play pack and reveal a new card.")
                            .font(.system(size: 13)).foregroundStyle(.white.opacity(0.58))
                    }
                    Spacer(minLength: 0)
                    Image(systemName: "sparkles.rectangle.stack.fill")
                        .font(.system(size: 62)).foregroundStyle(Color(hex: "68B9FF"))
                        .shadow(color: .blue.opacity(0.4), radius: 18)
                }
                .padding(20).background(LinearGradient(colors: [Color(hex:"172D49"), Color(hex:"111A2B")], startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: 22))
                .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.white.opacity(0.09)))
                VStack(alignment: .leading, spacing: 12) {
                    sectionTitle("FEATURED PACK", subtitle: "A simulated pack opening")
                    ZStack {
                        RoundedRectangle(cornerRadius: 22).fill(LinearGradient(colors: [Color(hex:"263C5C"), Color(hex:"111827"), Color(hex:"261C3D")], startPoint: .topLeading, endPoint: .bottomTrailing))
                        VStack(spacing: 13) {
                            Image(systemName: "shippingbox.fill").font(.system(size: 58)).foregroundStyle(Color(hex:"9BD7FF"))
                            Text("ALL-STAR DROP").font(.system(size: 21, weight: .black, design: .rounded)).tracking(1)
                            Text("1 RANDOM PLAYER CARD").font(.system(size: 10, weight: .bold)).tracking(2).foregroundStyle(.white.opacity(0.58))
                            Button { store.openPack() } label: {
                                HStack { Text("OPEN PACK"); Spacer(); Text("250 ✦") }
                                    .font(.system(size: 13, weight: .black, design: .rounded))
                                    .padding(.horizontal, 18).padding(.vertical, 15)
                                    .background(Color(hex:"55AFFF"), in: Capsule()).foregroundStyle(Color(hex:"08111F"))
                            }
                            .disabled(store.credits < 250).opacity(store.credits < 250 ? 0.45 : 1)
                        }.padding(25)
                    }.frame(height: 280)
                }
                HStack {
                    stat("CARDS COLLECTED", "\(store.cards.count)", "rectangle.stack.fill")
                    stat("BEST RATING", store.cards.map(\.rating).max().map(String.init) ?? "—", "trophy.fill")
                }
            }.padding(.horizontal, 18).padding(.bottom, 24)
        }
    }
    func sectionTitle(_ a: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(a).font(.system(size: 12, weight: .black)).tracking(1.4)
            Text(subtitle).font(.system(size: 11)).foregroundStyle(.white.opacity(0.48))
        }
    }
    func stat(_ title: String, _ value: String, _ icon: String) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            Image(systemName: icon).foregroundStyle(Color(hex:"70BFFF"))
            Text(value).font(.system(size: 24, weight: .heavy, design: .rounded))
            Text(title).font(.system(size: 9, weight: .bold)).tracking(1).foregroundStyle(.white.opacity(0.5))
        }.frame(maxWidth: .infinity, alignment: .leading).padding(16)
            .background(Color.white.opacity(0.055), in: RoundedRectangle(cornerRadius: 16))
    }
}

struct CollectionView: View {
    @EnvironmentObject var store: DemoStore
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Header(title: "Collection")
                HStack {
                    Text("MY CARDS").font(.system(size: 12, weight: .black)).tracking(1.5)
                    Spacer()
                    Text("\(store.cards.count) ITEMS").font(.system(size: 10, weight: .bold)).foregroundStyle(.white.opacity(0.5))
                }.padding(.horizontal, 20)
                if store.cards.isEmpty {
                    ContentUnavailableView("No cards yet", systemImage: "rectangle.stack", description: Text("Open a pack to add your first card."))
                        .frame(maxWidth: .infinity).padding(.top, 70)
                } else {
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(store.cards) { card in CardTile(card: card) }
                    }.padding(.horizontal, 18)
                }
            }.padding(.bottom, 25)
        }
    }
}

struct CardTile: View {
    let card: DemoCard
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                LinearGradient(colors: [Color(hex: card.colorHex), Color(hex:"101827")], startPoint: .topLeading, endPoint: .bottomTrailing)
                VStack(spacing: 8) {
                    HStack { Text(card.rarity).font(.system(size: 8, weight: .black)).tracking(1); Spacer(); Text("\(card.rating)").font(.system(size: 18, weight: .black)) }
                    Spacer()
                    Image(systemName: "person.crop.square.fill").font(.system(size: 65)).foregroundStyle(.white.opacity(0.8))
                    Text(card.player.uppercased()).font(.system(size: 14, weight: .black, design: .rounded))
                    Text(card.team).font(.system(size: 8, weight: .bold)).tracking(2)
                    Spacer()
                }.padding(12)
            }.frame(height: 205)
            Text("PLAYER CARD").font(.system(size: 9, weight: .bold)).tracking(1).foregroundStyle(.white.opacity(0.55)).padding(10)
        }
        .background(Color(hex:"151D2B"), in: RoundedRectangle(cornerRadius: 15))
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.white.opacity(0.12)))
    }
}

struct RevealView: View {
    let card: DemoCard
    @Environment(\.dismiss) var dismiss
    var body: some View {
        ZStack {
            Color(hex:"090D16").ignoresSafeArea()
            VStack(spacing: 18) {
                Text("NEW CARD UNLOCKED").font(.system(size: 12, weight: .black)).tracking(2).foregroundStyle(Color(hex:"76C7FF"))
                CardTile(card: card).frame(maxWidth: 245)
                Text(card.rarity).font(.system(size: 13, weight: .black)).tracking(2)
                Button("ADD TO COLLECTION") { dismiss() }
                    .font(.system(size: 12, weight: .black)).padding(.horizontal, 26).padding(.vertical, 15)
                    .background(Color(hex:"58B2FF"), in: Capsule()).foregroundStyle(Color(hex:"08111F"))
            }.padding(25)
        }
    }
}

struct RewardsView: View {
    @EnvironmentObject var store: DemoStore
    var body: some View {
        VStack(spacing: 20) {
            Header(title: "Rewards")
            VStack(spacing: 14) {
                Image(systemName: "gift.fill").font(.system(size: 55)).foregroundStyle(Color(hex:"79C8FF"))
                Text("DAILY BONUS").font(.system(size: 21, weight: .black, design: .rounded))
                Text("Collect 500 free-play credits. No purchases or cash value.")
                    .font(.system(size: 13)).foregroundStyle(.white.opacity(0.58)).multilineTextAlignment(.center)
                Button { store.claimDaily() } label: {
                    Text("CLAIM +500 ✦").font(.system(size: 13, weight: .black))
                        .padding(.horizontal, 30).padding(.vertical, 15)
                        .background(Color(hex:"58B2FF"), in: Capsule()).foregroundStyle(Color(hex:"08111F"))
                }
            }.padding(28).frame(maxWidth: .infinity).background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 22)).padding(20)
            Spacer()
        }
    }
}

struct ProfileView: View {
    @EnvironmentObject var store: DemoStore
    var body: some View {
        VStack(spacing: 18) {
            Header(title: "Account")
            Image(systemName: "person.crop.circle.fill").font(.system(size: 78)).foregroundStyle(Color(hex:"70BFFF")).padding(.top, 28)
            Text("DEMO COLLECTOR").font(.system(size: 19, weight: .black, design: .rounded))
            Text("Local profile • No sign-in required").font(.system(size: 12)).foregroundStyle(.white.opacity(0.5))
            HStack {
                Label("\(store.cards.count) cards", systemImage: "rectangle.stack")
                Spacer()
                Label("\(store.credits) credits", systemImage: "sparkle")
            }.padding(18).background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 16)).padding(.horizontal, 20)
            Spacer()
            Text("Independent fan-made demo. Not affiliated with Rips or Triumph.")
                .font(.system(size: 10)).foregroundStyle(.white.opacity(0.35)).multilineTextAlignment(.center).padding()
        }
    }
}

extension Color {
    init(hex: String) {
        let value = Int(hex, radix: 16) ?? 0
        self.init(.sRGB, red: Double((value >> 16) & 255) / 255,
                  green: Double((value >> 8) & 255) / 255,
                  blue: Double(value & 255) / 255, opacity: 1)
    }
}

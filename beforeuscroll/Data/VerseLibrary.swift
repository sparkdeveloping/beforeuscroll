import Foundation

enum VerseLibrary {
    static let verses: [Verse] = [
        Verse(
            id: "ephesians-5-16",
            reference: "Ephesians 5:16",
            text: "Redeeming the time, because the days are evil.",
            category: .redeemingTime,
            quiz: [
                .init(id: "eph-516-q1", prompt: "What is this verse mainly telling us to redeem?", options: ["Time", "Money", "Popularity"], correctIndex: 0),
                .init(id: "eph-516-q2", prompt: "Which word appears in the verse?", options: ["Redeeming", "Scrolling", "Sleeping"], correctIndex: 0),
                .init(id: "eph-516-q3", prompt: "What is the better choice before opening a distracting app?", options: ["Pause and choose intentionally", "Scroll without thinking", "Ignore the warning"], correctIndex: 0)
            ]
        ),
        Verse(
            id: "psalm-101-3",
            reference: "Psalm 101:3",
            text: "I will set no wicked thing before mine eyes.",
            category: .purity,
            quiz: [
                .init(id: "ps-1013-q1", prompt: "What is this verse mainly about guarding?", options: ["What you put before your eyes", "What you eat", "Where you travel"], correctIndex: 0),
                .init(id: "ps-1013-q2", prompt: "Which phrase appears in the verse?", options: ["Before mine eyes", "Before my friends", "Before my plans"], correctIndex: 0),
                .init(id: "ps-1013-q3", prompt: "Before scrolling, what should you consider?", options: ["Whether this helps or harms my heart", "Whether the app is popular", "Whether I have notifications"], correctIndex: 0)
            ]
        ),
        Verse(
            id: "romans-12-2",
            reference: "Romans 12:2",
            text: "Be not conformed to this world: but be ye transformed by the renewing of your mind.",
            category: .renewedMind,
            quiz: [
                .init(id: "rom-122-q1", prompt: "What does the verse say not to be conformed to?", options: ["This world", "A schedule", "A quiet room"], correctIndex: 0),
                .init(id: "rom-122-q2", prompt: "What should be renewed?", options: ["Your mind", "Your phone", "Your feed"], correctIndex: 0),
                .init(id: "rom-122-q3", prompt: "What should happen before you scroll?", options: ["Let your mind be redirected", "Open the feed immediately", "Skip the pause"], correctIndex: 0)
            ]
        ),
        Verse(
            id: "colossians-3-2",
            reference: "Colossians 3:2",
            text: "Set your affection on things above, not on things on the earth.",
            category: .focus,
            quiz: [
                .init(id: "col-32-q1", prompt: "Where does this verse say to set your affection?", options: ["Things above", "The feed", "Other people’s opinions"], correctIndex: 0),
                .init(id: "col-32-q2", prompt: "What should not control your focus?", options: ["Things on the earth", "Prayer", "Scripture"], correctIndex: 0),
                .init(id: "col-32-q3", prompt: "What is the pause helping you do?", options: ["Refocus on better things", "Scroll faster", "Find more entertainment"], correctIndex: 0)
            ]
        ),
        Verse(
            id: "proverbs-4-23",
            reference: "Proverbs 4:23",
            text: "Keep thy heart with all diligence; for out of it are the issues of life.",
            category: .wisdom,
            quiz: [
                .init(id: "prov-423-q1", prompt: "What does this verse say to keep?", options: ["Your heart", "Your battery", "Your image"], correctIndex: 0),
                .init(id: "prov-423-q2", prompt: "How should you keep your heart?", options: ["With diligence", "With laziness", "With distraction"], correctIndex: 0),
                .init(id: "prov-423-q3", prompt: "Why pause before scrolling?", options: ["Because what enters your heart matters", "Because apps need more time", "Because feeds are always harmless"], correctIndex: 0)
            ]
        ),
        Verse(
            id: "2-timothy-1-7",
            reference: "2 Timothy 1:7",
            text: "For God hath not given us the spirit of fear; but of power, and of love, and of a sound mind.",
            category: .anxiety,
            quiz: [
                .init(id: "2tim-17-q1", prompt: "What has God not given us?", options: ["The spirit of fear", "A sound mind", "Love"], correctIndex: 0),
                .init(id: "2tim-17-q2", prompt: "Which phrase appears in the verse?", options: ["A sound mind", "A busy feed", "A restless heart"], correctIndex: 0),
                .init(id: "2tim-17-q3", prompt: "If you are anxious, what is better than scrolling on impulse?", options: ["Pause and return to a sound mind", "Keep refreshing the feed", "Open more apps"], correctIndex: 0)
            ]
        ),
        Verse(
            id: "1-corinthians-6-12",
            reference: "1 Corinthians 6:12",
            text: "All things are lawful unto me, but I will not be brought under the power of any.",
            category: .discipline,
            quiz: [
                .init(id: "1cor-612-q1", prompt: "What does the verse say we should not be brought under?", options: ["The power of any", "Good habits", "Prayer"], correctIndex: 0),
                .init(id: "1cor-612-q2", prompt: "What is the warning behind this verse?", options: ["Something allowed can still control you", "Everything is always helpful", "Scrolling never affects you"], correctIndex: 0),
                .init(id: "1cor-612-q3", prompt: "What should this app help prevent?", options: ["Being controlled by the feed", "Reading Scripture", "Intentional choices"], correctIndex: 0)
            ]
        )
    ]

    static func verse(for goal: ScrollGoal) -> Verse {
        let preferredCategory: VerseCategory

        switch goal {
        case .doomscrolling: preferredCategory = .redeemingTime
        case .lust: preferredCategory = .purity
        case .distraction: preferredCategory = .focus
        case .anxiety: preferredCategory = .anxiety
        case .lateNight: preferredCategory = .discipline
        case .entertainment: preferredCategory = .discipline
        case .comparison: preferredCategory = .contentment
        case .procrastination: preferredCategory = .wisdom
        }

        return verses.first(where: { $0.category == preferredCategory }) ?? verses[0]
    }

    static func random() -> Verse {
        verses.randomElement() ?? verses[0]
    }
}

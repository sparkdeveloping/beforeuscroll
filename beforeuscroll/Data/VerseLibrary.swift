import Foundation

enum VerseLibrary {
    static let verses: [Verse] = [
        Verse(
            id: "ephesians-5-15-16",
            reference: "Ephesians 5:15-16",
            text: "See then that ye walk circumspectly, not as fools, but as wise, redeeming the time.",
            category: .discipline,
            quiz: [
                .init(id: "eph-5-15-q1", kind: .multipleChoice, prompt: "How does the verse command you to walk?", options: ["Circumspectly (Carefully)", "Quickly", "Carelessly", "Loudly"], correctIndex: 0),
                .init(id: "eph-5-15-q2", kind: .typedText, prompt: "What should be 'redeemed'?", correctAnswer: "The time", acceptableAnswers: ["time"], explanation: "The verse calls us to redeem 'the time' because the days are evil."),
                .init(id: "eph-5-15-q3", kind: .multipleChoice, prompt: "What contrast is made in this verse?", options: ["Not as fools, but as wise", "Not as children, but as adults", "Not as sheep, but as lions"], correctIndex: 0),
                .init(id: "eph-5-15-q4", kind: .typedText, prompt: "Which book is this found in?", correctAnswer: "Ephesians", acceptableAnswers: ["Eph"], explanation: "This is a key instruction from the book of Ephesians."),
                .init(id: "eph-5-15-q5", kind: .multipleChoice, prompt: "Attention Check: Which phrase was NOT in the verse?", options: ["Making every moment viral", "Redeeming the time", "Not as fools", "Walk circumspectly"], correctIndex: 0, isTrickQuestion: true)
            ]
        ),
        Verse(
            id: "colossians-4-5",
            reference: "Colossians 4:5",
            text: "Walk in wisdom toward them that are without, redeeming the time.",
            category: .discipline,
            quiz: [
                .init(id: "col-4-5-q1", kind: .multipleChoice, prompt: "In what should we walk?", options: ["Wisdom", "Pride", "Boredom", "Haste"], correctIndex: 0),
                .init(id: "col-4-5-q2", kind: .typedText, prompt: "Finish the phrase: 'Redeeming the ___'", correctAnswer: "time", acceptableAnswers: ["the time"], explanation: "We are to redeem the time given to us."),
                .init(id: "col-4-5-q3", kind: .multipleChoice, prompt: "Toward whom should we walk in wisdom?", options: ["Them that are without", "Only friends", "The crowd", "Ourselves"], correctIndex: 0),
                .init(id: "col-4-5-q4", kind: .multipleChoice, prompt: "What does this verse call you to do before opening an app?", options: ["Use the moment wisely for God", "Waste the window", "Ignore your purpose", "Follow the algorithm"], correctIndex: 0),
                .init(id: "col-4-5-q5", kind: .multipleChoice, prompt: "Attention Check: Which reference is correct?", options: ["Colossians 4:5", "Colossians 1:1", "Romans 4:5", "Psalm 4:5"], correctIndex: 0, isTrickQuestion: true)
            ]
        ),
        Verse(
            id: "james-1-5",
            reference: "James 1:5",
            text: "If any of you lack wisdom, let him ask of God.",
            category: .wisdom,
            quiz: [
                .init(id: "jam-1-5-q1", kind: .typedText, prompt: "What should you ask for if you lack it?", correctAnswer: "Wisdom", explanation: "God is the source of all true wisdom."),
                .init(id: "jam-1-5-q2", kind: .multipleChoice, prompt: "Who should you ask for wisdom?", options: ["God", "The feed", "The most popular trend", "The crowd"], correctIndex: 0),
                .init(id: "jam-1-5-q3", kind: .multipleChoice, prompt: "What is the source of your digital wisdom according to this verse?", options: ["Prayer to God", "Search engines", "Viral posts", "Comment sections"], correctIndex: 0),
                .init(id: "jam-1-5-q4", kind: .typedText, prompt: "Which book is this verse from?", correctAnswer: "James", explanation: "James provides practical instruction for the Christian life."),
                .init(id: "jam-1-5-q5", kind: .multipleChoice, prompt: "Attention Check: Which idea goes AGAINST this verse?", options: ["Rely only on your own gut", "Ask God for help", "Seek wisdom when lacking", "Trust God's guidance"], correctIndex: 0, isTrickQuestion: true)
            ]
        ),
        Verse(
            id: "1-corinthians-6-12",
            reference: "1 Corinthians 6:12",
            text: "All things are lawful unto me, but I will not be brought under the power of any.",
            category: .discipline,
            quiz: [
                .init(id: "1cor-6-12-q1", kind: .multipleChoice, prompt: "What does Paul refuse to be brought under?", options: ["The power of any", "A schedule", "The laws of the land"], correctIndex: 0),
                .init(id: "1cor-6-12-q2", kind: .typedText, prompt: "What are 'all things' unto Paul?", correctAnswer: "Lawful", acceptableAnswers: ["lawful"], explanation: "While all things are lawful, not all are helpful or should control us."),
                .init(id: "1cor-6-12-q3", kind: .multipleChoice, prompt: "What is a modern 'power' that often brings us under it?", options: ["An addictive app feed", "A paper book", "A sunrise"], correctIndex: 0),
                .init(id: "1cor-6-12-q4", kind: .multipleChoice, prompt: "What should you choose before opening a distracting app?", options: ["Not to be ruled by it", "To follow every urge", "To ignore your boundaries"], correctIndex: 0),
                .init(id: "1cor-6-12-q5", kind: .multipleChoice, prompt: "Attention Check: Did the verse say 'All things are forbidden'?", options: ["No, it said 'all things are lawful'", "Yes, exactly", "It didn't mention 'all things'"], correctIndex: 0, isTrickQuestion: true)
            ]
        ),
        Verse(
            id: "proverbs-4-23",
            reference: "Proverbs 4:23",
            text: "Keep thy heart with all diligence; for out of it are the issues of life.",
            category: .purity,
            quiz: [
                .init(id: "prov-4-23-q1", kind: .typedText, prompt: "What should you keep with all diligence?", correctAnswer: "Thy heart", acceptableAnswers: ["heart", "your heart"], explanation: "The heart is the wellspring of life."),
                .init(id: "prov-4-23-q2", kind: .multipleChoice, prompt: "Why should the heart be guarded?", options: ["Out of it are the issues of life", "It is easily broken", "It is the battery of the body"], correctIndex: 0),
                .init(id: "prov-4-23-q3", kind: .multipleChoice, prompt: "How should you keep it?", options: ["With all diligence", "Carelessly", "Randomly"], correctIndex: 0),
                .init(id: "prov-4-23-q4", kind: .typedText, prompt: "Which book is this wisdom from?", correctAnswer: "Proverbs", acceptableAnswers: ["Prov"], explanation: "Proverbs is full of practical wisdom for guarding our lives."),
                .init(id: "prov-4-23-q5", kind: .multipleChoice, prompt: "Attention Check: Which was NOT mentioned?", options: ["Guarding your screen time", "The heart", "Issues of life", "Diligence"], correctIndex: 0, isTrickQuestion: true)
            ]
        ),
        Verse(
            id: "philippians-4-8",
            reference: "Philippians 4:8",
            text: "Whatsoever things are true, honest, just, pure, lovely, and of good report; think on these things.",
            category: .purity,
            quiz: [
                .init(id: "phi-4-8-q1", kind: .multipleChoice, prompt: "What does the verse tell you to do with good things?", options: ["Think on them", "Ignore them", "Post about them only"], correctIndex: 0),
                .init(id: "phi-4-8-q2", kind: .typedText, prompt: "Name one quality mentioned: 'Whatsoever things are ___'", correctAnswer: "true", acceptableAnswers: ["honest", "just", "pure", "lovely"], explanation: "The verse lists many qualities including true, honest, just, pure, and lovely."),
                .init(id: "phi-4-8-q3", kind: .multipleChoice, prompt: "What should guide your phone consumption?", options: ["If it is true, pure, and lovely", "If it is shocking and loud", "If it is popular"], correctIndex: 0),
                .init(id: "phi-4-8-q4", kind: .typedText, prompt: "Which book is this found in?", correctAnswer: "Philippians", acceptableAnswers: ["Phil"], explanation: "This is one of the most famous verses in Philippians."),
                .init(id: "phi-4-8-q5", kind: .multipleChoice, prompt: "Attention Check: Does the verse say 'Think on whatever is viral'?", options: ["No, it says 'think on these [good] things'", "Yes, definitely", "It doesn't use the word 'think'"], correctIndex: 0, isTrickQuestion: true)
            ]
        )
        // ... (rest of verses would be updated similarly)
    ]

    static func currentVerseOfStudy(for goal: ScrollGoal) -> Verse {
        let category = category(for: goal)
        return BYSVerseRotationStore.currentVerse(for: category)
    }

    static func category(for goal: ScrollGoal) -> VerseCategory {
        switch goal {
        case .doomscrolling: return .discipline
        case .lust: return .purity
        case .distraction: return .focus
        case .anxiety: return .anxiety
        case .lateNight: return .discipline
        case .entertainment: return .discipline
        case .comparison: return .contentment
        case .procrastination: return .discipline
        }
    }

    static func verses(for category: VerseCategory) -> [Verse] {
        verses.filter { $0.category == category }
    }
}

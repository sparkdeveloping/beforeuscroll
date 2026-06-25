import Foundation

enum VerseLibrary {
    static let verses: [Verse] = [

        // MARK: - Discipline
        Verse(
            id: "ephesians-5-15-16",
            reference: "Ephesians 5:15-16",
            text: "See then that ye walk circumspectly, not as fools, but as wise, redeeming the time.",
            category: .discipline,
            quiz: [
                .init(id: "eph-5-15-q1", kind: .multipleChoice, type: .keyPhrase, prompt: "How does the verse command you to walk?", options: ["Circumspectly (Carefully)", "Quickly", "Carelessly", "Loudly"], correctIndex: 0),
                .init(id: "eph-5-15-q2", kind: .typedText, type: .keyPhrase, prompt: "What should be 'redeemed'?", correctAnswer: "The time", acceptableAnswers: ["time"], explanation: "The verse calls us to redeem 'the time' because the days are evil."),
                .init(id: "eph-5-15-q3", kind: .multipleChoice, type: .meaning, prompt: "What contrast is made in this verse?", options: ["Not as fools, but as wise", "Not as children, but as adults", "Not as sheep, but as lions"], correctIndex: 0),
                .init(id: "eph-5-15-q4", kind: .typedText, type: .reference, prompt: "Which book is this found in?", correctAnswer: "Ephesians", acceptableAnswers: ["Eph"], explanation: "This is a key instruction from the book of Ephesians."),
                .init(id: "eph-5-15-q5", kind: .multipleChoice, type: .application, prompt: "Attention Check: Which phrase was NOT in the verse?", options: ["Making every moment viral", "Redeeming the time", "Not as fools", "Walk circumspectly"], correctIndex: 0, isTrickQuestion: true)
            ]
        ),
        Verse(
            id: "colossians-4-5",
            reference: "Colossians 4:5",
            text: "Walk in wisdom toward them that are without, redeeming the time.",
            category: .discipline,
            quiz: [
                .init(id: "col-4-5-q1", kind: .multipleChoice, type: .meaning, prompt: "In what should we walk?", options: ["Wisdom", "Pride", "Boredom", "Haste"], correctIndex: 0),
                .init(id: "col-4-5-q2", kind: .typedText, type: .keyPhrase, prompt: "Finish the phrase: 'Redeeming the ___'", correctAnswer: "time", acceptableAnswers: ["the time"], explanation: "We are to redeem the time given to us."),
                .init(id: "col-4-5-q3", kind: .multipleChoice, type: .meaning, prompt: "Toward whom should we walk in wisdom?", options: ["Them that are without", "Only friends", "The crowd", "Ourselves"], correctIndex: 0),
                .init(id: "col-4-5-q4", kind: .multipleChoice, type: .application, prompt: "What does this verse call you to do before opening an app?", options: ["Use the moment wisely for God", "Waste the window", "Ignore your purpose", "Follow the algorithm"], correctIndex: 0),
                .init(id: "col-4-5-q5", kind: .multipleChoice, type: .reference, prompt: "Attention Check: Which reference is correct?", options: ["Colossians 4:5", "Colossians 1:1", "Romans 4:5", "Psalm 4:5"], correctIndex: 0, isTrickQuestion: true)
            ]
        ),
        Verse(
            id: "1-corinthians-6-12",
            reference: "1 Corinthians 6:12",
            text: "All things are lawful unto me, but I will not be brought under the power of any.",
            category: .discipline,
            quiz: [
                .init(id: "1cor-6-12-q1", kind: .multipleChoice, type: .meaning, prompt: "What does Paul refuse to be brought under?", options: ["The power of any", "A schedule", "The laws of the land"], correctIndex: 0),
                .init(id: "1cor-6-12-q2", kind: .typedText, type: .keyPhrase, prompt: "What are 'all things' unto Paul?", correctAnswer: "Lawful", acceptableAnswers: ["lawful"], explanation: "While all things are lawful, not all are helpful or should control us."),
                .init(id: "1cor-6-12-q3", kind: .multipleChoice, type: .application, prompt: "What is a modern 'power' that often brings us under it?", options: ["An addictive app feed", "A paper book", "A sunrise"], correctIndex: 0),
                .init(id: "1cor-6-12-q4", kind: .multipleChoice, type: .application, prompt: "What should you choose before opening a distracting app?", options: ["Not to be ruled by it", "To follow every urge", "To ignore your boundaries"], correctIndex: 0),
                .init(id: "1cor-6-12-q5", kind: .multipleChoice, type: .meaning, prompt: "Attention Check: Did the verse say 'All things are forbidden'?", options: ["No, it said 'all things are lawful'", "Yes, exactly", "It didn't mention 'all things'"], correctIndex: 0, isTrickQuestion: true)
            ]
        ),

        // MARK: - Wisdom
        Verse(
            id: "james-1-5",
            reference: "James 1:5",
            text: "If any of you lack wisdom, let him ask of God.",
            category: .wisdom,
            quiz: [
                .init(id: "jam-1-5-q1", kind: .typedText, type: .keyPhrase, prompt: "What should you ask for if you lack it?", correctAnswer: "Wisdom", explanation: "God is the source of all true wisdom."),
                .init(id: "jam-1-5-q2", kind: .multipleChoice, type: .meaning, prompt: "Who should you ask for wisdom?", options: ["God", "The feed", "The most popular trend", "The crowd"], correctIndex: 0),
                .init(id: "jam-1-5-q3", kind: .multipleChoice, type: .application, prompt: "What is the source of your digital wisdom according to this verse?", options: ["Prayer to God", "Search engines", "Viral posts", "Comment sections"], correctIndex: 0),
                .init(id: "jam-1-5-q4", kind: .typedText, type: .reference, prompt: "Which book is this verse from?", correctAnswer: "James", explanation: "James provides practical instruction for the Christian life."),
                .init(id: "jam-1-5-q5", kind: .multipleChoice, type: .application, prompt: "Attention Check: Which idea goes AGAINST this verse?", options: ["Rely only on your own gut", "Ask God for help", "Seek wisdom when lacking", "Trust God's guidance"], correctIndex: 0, isTrickQuestion: true)
            ]
        ),

        // MARK: - Purity
        Verse(
            id: "proverbs-4-23",
            reference: "Proverbs 4:23",
            text: "Keep thy heart with all diligence; for out of it are the issues of life.",
            category: .purity,
            quiz: [
                .init(id: "prov-4-23-q1", kind: .typedText, type: .keyPhrase, prompt: "What should you keep with all diligence?", correctAnswer: "Thy heart", acceptableAnswers: ["heart", "your heart"], explanation: "The heart is the wellspring of life."),
                .init(id: "prov-4-23-q2", kind: .multipleChoice, type: .meaning, prompt: "Why should the heart be guarded?", options: ["Out of it are the issues of life", "It is easily broken", "It is the battery of the body"], correctIndex: 0),
                .init(id: "prov-4-23-q3", kind: .multipleChoice, type: .meaning, prompt: "How should you keep it?", options: ["With all diligence", "Carelessly", "Randomly"], correctIndex: 0),
                .init(id: "prov-4-23-q4", kind: .typedText, type: .reference, prompt: "Which book is this wisdom from?", correctAnswer: "Proverbs", acceptableAnswers: ["Prov"], explanation: "Proverbs is full of practical wisdom for guarding our lives."),
                .init(id: "prov-4-23-q5", kind: .multipleChoice, type: .application, prompt: "Attention Check: Which was NOT mentioned?", options: ["Guarding your screen time", "The heart", "Issues of life", "Diligence"], correctIndex: 0, isTrickQuestion: true)
            ]
        ),
        Verse(
            id: "philippians-4-8",
            reference: "Philippians 4:8",
            text: "Whatsoever things are true, honest, just, pure, lovely, and of good report; think on these things.",
            category: .purity,
            quiz: [
                .init(id: "phi-4-8-q1", kind: .multipleChoice, type: .meaning, prompt: "What does the verse tell you to do with good things?", options: ["Think on them", "Ignore them", "Post about them only"], correctIndex: 0),
                .init(id: "phi-4-8-q2", kind: .typedText, type: .keyPhrase, prompt: "Name one quality mentioned: 'Whatsoever things are ___'", correctAnswer: "true", acceptableAnswers: ["honest", "just", "pure", "lovely"], explanation: "The verse lists many qualities including true, honest, just, pure, and lovely."),
                .init(id: "phi-4-8-q3", kind: .multipleChoice, type: .application, prompt: "What should guide your phone consumption?", options: ["If it is true, pure, and lovely", "If it is shocking and loud", "If it is popular"], correctIndex: 0),
                .init(id: "phi-4-8-q4", kind: .typedText, type: .reference, prompt: "Which book is this found in?", correctAnswer: "Philippians", acceptableAnswers: ["Phil"], explanation: "This is one of the most famous verses in Philippians."),
                .init(id: "phi-4-8-q5", kind: .multipleChoice, type: .meaning, prompt: "Attention Check: Does the verse say 'Think on whatever is viral'?", options: ["No, it says 'think on these [good] things'", "Yes, definitely", "It doesn't use the word 'think'"], correctIndex: 0, isTrickQuestion: true)
            ]
        ),

        // MARK: - Focus
        Verse(
            id: "matthew-6-33",
            reference: "Matthew 6:33",
            text: "But seek ye first the kingdom of God, and his righteousness; and all these things shall be added unto you.",
            category: .focus,
            quiz: [
                .init(id: "mat-6-33-q1", kind: .multipleChoice, type: .keyPhrase, prompt: "What should you seek first?", options: ["The kingdom of God", "Likes and follows", "A productive morning", "A trending topic"], correctIndex: 0),
                .init(id: "mat-6-33-q2", kind: .typedText, type: .keyPhrase, prompt: "What shall be added when you seek first?", correctAnswer: "All these things", acceptableAnswers: ["all things", "these things"], explanation: "When we prioritize God's kingdom, He provides what we need."),
                .init(id: "mat-6-33-q3", kind: .multipleChoice, type: .meaning, prompt: "What two things should we seek first?", options: ["The kingdom of God and his righteousness", "Success and fame", "Peace and quiet", "Food and shelter"], correctIndex: 0),
                .init(id: "mat-6-33-q4", kind: .typedText, type: .reference, prompt: "Which Gospel is this verse from?", correctAnswer: "Matthew", acceptableAnswers: ["Matt"], explanation: "Jesus spoke these words in the Sermon on the Mount."),
                .init(id: "mat-6-33-q5", kind: .multipleChoice, type: .application, prompt: "Attention Check: Does the verse say 'Seek first your goals'?", options: ["No, it says seek first the kingdom of God", "Yes, that's the point", "It doesn't mention seeking anything"], correctIndex: 0, isTrickQuestion: true)
            ]
        ),
        Verse(
            id: "hebrews-12-1",
            reference: "Hebrews 12:1",
            text: "Let us run with patience the race that is set before us, looking unto Jesus the author and finisher of our faith.",
            category: .focus,
            quiz: [
                .init(id: "heb-12-1-q1", kind: .multipleChoice, type: .keyPhrase, prompt: "What are we called to run with?", options: ["Patience", "Speed", "Ambition", "Distraction"], correctIndex: 0),
                .init(id: "heb-12-1-q2", kind: .typedText, type: .keyPhrase, prompt: "Who is the author and finisher of our faith?", correctAnswer: "Jesus", acceptableAnswers: ["Jesus Christ", "Christ"], explanation: "We run the race by keeping our eyes fixed on Jesus."),
                .init(id: "heb-12-1-q3", kind: .multipleChoice, type: .meaning, prompt: "What must we lay aside to run the race?", options: ["Every weight and sin", "Our plans and goals", "Our comfort and joy", "Rules and schedules"], correctIndex: 0),
                .init(id: "heb-12-1-q4", kind: .typedText, type: .reference, prompt: "Which book contains this verse?", correctAnswer: "Hebrews", acceptableAnswers: ["Heb"], explanation: "Hebrews encourages believers to endure by fixing their eyes on Jesus."),
                .init(id: "heb-12-1-q5", kind: .multipleChoice, type: .application, prompt: "Attention Check: What should your eyes be looking toward?", options: ["Jesus, the author and finisher of our faith", "Your notifications", "Your goals board", "Popular accounts"], correctIndex: 0, isTrickQuestion: true)
            ]
        ),

        // MARK: - Anxiety
        Verse(
            id: "philippians-4-6",
            reference: "Philippians 4:6",
            text: "Be careful for nothing; but in every thing by prayer and supplication with thanksgiving let your requests be made known unto God.",
            category: .anxiety,
            quiz: [
                .init(id: "phi-4-6-q1", kind: .multipleChoice, type: .keyPhrase, prompt: "What does the verse say to be careful for?", options: ["Nothing", "Everything", "Many things", "Your future"], correctIndex: 0),
                .init(id: "phi-4-6-q2", kind: .typedText, type: .keyPhrase, prompt: "How should requests be made known to God?", correctAnswer: "By prayer and supplication", acceptableAnswers: ["prayer", "prayer and supplication", "supplication"], explanation: "Prayer with thanksgiving replaces anxious scrolling."),
                .init(id: "phi-4-6-q3", kind: .multipleChoice, type: .meaning, prompt: "What should accompany prayer according to this verse?", options: ["Thanksgiving", "Fasting only", "Silence only", "A good mood"], correctIndex: 0),
                .init(id: "phi-4-6-q4", kind: .typedText, type: .reference, prompt: "Which book is this verse from?", correctAnswer: "Philippians", acceptableAnswers: ["Phil"], explanation: "Paul wrote Philippians while in prison, showing peace is possible in any situation."),
                .init(id: "phi-4-6-q5", kind: .multipleChoice, type: .application, prompt: "Attention Check: Does 'be careful for nothing' mean ignore your responsibilities?", options: ["No — it means don't be anxious; bring everything to God", "Yes, it means stop caring", "Yes, ignore all your problems"], correctIndex: 0, isTrickQuestion: true)
            ]
        ),
        Verse(
            id: "1-peter-5-7",
            reference: "1 Peter 5:7",
            text: "Casting all your care upon him; for he careth for you.",
            category: .anxiety,
            quiz: [
                .init(id: "1pet-5-7-q1", kind: .multipleChoice, type: .keyPhrase, prompt: "What should you cast upon God?", options: ["All your care", "Your plans only", "Your failures only", "Your schedule"], correctIndex: 0),
                .init(id: "1pet-5-7-q2", kind: .typedText, type: .keyPhrase, prompt: "Why can you cast your cares on God?", correctAnswer: "He careth for you", acceptableAnswers: ["he cares", "he cares for you", "he careth"], explanation: "God's care for us is the foundation for releasing anxiety."),
                .init(id: "1pet-5-7-q3", kind: .multipleChoice, type: .meaning, prompt: "What does this verse teach about God's attitude toward you?", options: ["He cares for you", "He is indifferent", "He is busy with bigger things", "He only cares about the world"], correctIndex: 0),
                .init(id: "1pet-5-7-q4", kind: .typedText, type: .reference, prompt: "Which letter is this verse from?", correctAnswer: "1 Peter", acceptableAnswers: ["peter", "first peter", "1 pet"], explanation: "Peter wrote to encourage believers enduring suffering and anxiety."),
                .init(id: "1pet-5-7-q5", kind: .multipleChoice, type: .application, prompt: "Attention Check: Does 'casting your care' mean scrolling to escape?", options: ["No — it means trusting God, not numbing out", "Yes, distraction is a form of care-casting", "Yes, anything that helps counts"], correctIndex: 0, isTrickQuestion: true)
            ]
        ),

        // MARK: - Contentment
        Verse(
            id: "1-timothy-6-6",
            reference: "1 Timothy 6:6",
            text: "But godliness with contentment is great gain.",
            category: .contentment,
            quiz: [
                .init(id: "1tim-6-6-q1", kind: .multipleChoice, type: .keyPhrase, prompt: "What combination is described as great gain?", options: ["Godliness with contentment", "Wealth with wisdom", "Popularity with purpose", "Hustle with discipline"], correctIndex: 0),
                .init(id: "1tim-6-6-q2", kind: .typedText, type: .keyPhrase, prompt: "What is 'great gain' according to this verse?", correctAnswer: "Godliness with contentment", acceptableAnswers: ["contentment", "godliness and contentment"], explanation: "True wealth is godliness paired with contentment — not more followers or possessions."),
                .init(id: "1tim-6-6-q3", kind: .multipleChoice, type: .meaning, prompt: "What does this verse suggest about comparison and wanting more?", options: ["Contentment is the better path", "Always wanting more is wisdom", "Comparing yourself is healthy", "More is always better"], correctIndex: 0),
                .init(id: "1tim-6-6-q4", kind: .typedText, type: .reference, prompt: "Which letter is this verse from?", correctAnswer: "1 Timothy", acceptableAnswers: ["timothy", "first timothy", "1 tim"], explanation: "Paul wrote 1 Timothy with practical instructions for godly living."),
                .init(id: "1tim-6-6-q5", kind: .multipleChoice, type: .application, prompt: "Attention Check: Does the verse say 'great gain' means getting more followers?", options: ["No — great gain is godliness and contentment, not more", "Yes, influence is great gain", "Yes, if used for God"], correctIndex: 0, isTrickQuestion: true)
            ]
        ),
        Verse(
            id: "hebrews-13-5",
            reference: "Hebrews 13:5",
            text: "Let your conversation be without covetousness; and be content with such things as ye have.",
            category: .contentment,
            quiz: [
                .init(id: "heb-13-5-q1", kind: .multipleChoice, type: .keyPhrase, prompt: "What should your conversation be without?", options: ["Covetousness", "Humor", "Confidence", "Boldness"], correctIndex: 0),
                .init(id: "heb-13-5-q2", kind: .typedText, type: .keyPhrase, prompt: "What does the verse say to be content with?", correctAnswer: "Such things as ye have", acceptableAnswers: ["what you have", "what ye have", "things you have"], explanation: "Contentment means being satisfied with what God has already given."),
                .init(id: "heb-13-5-q3", kind: .multipleChoice, type: .meaning, prompt: "What is covetousness in a digital age?", options: ["Craving what others have, including their lives online", "Being ambitious for good things", "Wanting to improve yourself", "Studying other people's journeys"], correctIndex: 0),
                .init(id: "heb-13-5-q4", kind: .typedText, type: .reference, prompt: "Which book is this verse from?", correctAnswer: "Hebrews", acceptableAnswers: ["Heb"], explanation: "Hebrews calls believers to a life of contentment, trusting God's provision."),
                .init(id: "heb-13-5-q5", kind: .multipleChoice, type: .application, prompt: "Attention Check: Does 'be content' mean you cannot grow or improve?", options: ["No — it means trust God with what you have now", "Yes, never aim higher", "Yes, growth is wrong"], correctIndex: 0, isTrickQuestion: true)
            ]
        )
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

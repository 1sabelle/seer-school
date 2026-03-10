import '../../models/card_guide.dart';

const majorArcanaGuides = <CardGuide>[
  // ── 0 · The Fool ──────────────────────────────────────────────
  CardGuide(
    cardId: 'major_00',
    description:
        'The Fool stands at the edge of a cliff, gazing upward with '
        'complete trust in the journey ahead. A small white dog leaps beside '
        'him — instinct and loyalty — while a single white rose symbolises '
        'purity of intention. He carries only a small knapsack: everything '
        'he needs, nothing he doesn\'t.\n\n'
        'Numbered zero, The Fool exists outside the ordinary sequence. He '
        'is both the beginning and the end of the Major Arcana, the eternal '
        'traveller whose story is the Fool\'s Journey itself. In the '
        'Rider-Waite-Smith tradition, this card is an invitation to leap '
        'before you look — not from recklessness, but from a deep faith '
        'that the universe will catch you.',
    elementMeaning:
        'Air here represents the realm of pure thought and infinite '
        'possibility. Like a breath before the first word, The Fool\'s air '
        'is potential that has not yet been shaped into form.',
    uprightMeaning:
        'New beginnings, spontaneity, and a leap of faith. The Fool '
        'encourages you to trust the process and embrace the unknown with '
        'an open heart. This is a time to start fresh, free from the weight '
        'of past experience or future worry.',
    reversedMeaning:
        'Recklessness, naivety, or hesitation that holds you back. '
        'Reversed, The Fool may warn that you are acting without thought, '
        'or conversely, that fear is stopping you from taking a necessary '
        'risk.',
    reflectionQuestions: [
      'Where in your life are you being called to take a leap of faith?',
      'What would you do if you weren\'t afraid of looking foolish?',
      'Is there something you need to release before you can begin again?',
    ],
  ),

  // ── I · The Magician ──────────────────────────────────────────
  CardGuide(
    cardId: 'major_01',
    description:
        'The Magician stands before a table bearing all four suit symbols '
        '— wand, cup, sword, and pentacle — representing mastery over '
        'every element. One hand points skyward, the other toward the '
        'earth: "as above, so below." An infinity symbol floats above his '
        'head, and a garden of roses and lilies blooms at his feet.\n\n'
        'Card I of the Major Arcana, The Magician is the first conscious '
        'act of creation. Where The Fool carries raw potential, The '
        'Magician channels it. He is the bridge between intention and '
        'manifestation, reminding you that you already have every tool '
        'you need.',
    elementMeaning:
        'Air governs communication and intellect. The Magician\'s air is '
        'focused thought — the mental clarity required to turn an idea '
        'into reality.',
    uprightMeaning:
        'Willpower, resourcefulness, and inspired action. You have the '
        'skills, knowledge, and energy to manifest what you desire. Now is '
        'the time to act with confidence and focus.',
    reversedMeaning:
        'Manipulation, untapped potential, or trickery. Reversed, The '
        'Magician may indicate that you are not using your abilities '
        'honestly, or that you doubt your own power.',
    reflectionQuestions: [
      'What resources do you already have that you\'ve been overlooking?',
      'Where could you channel your energy more intentionally?',
      'Are you communicating your true intentions clearly?',
    ],
  ),

  // ── II · The High Priestess ───────────────────────────────────
  CardGuide(
    cardId: 'major_02',
    description:
        'Seated between two pillars — one black (Boaz, severity) and one '
        'white (Jachin, mercy) — The High Priestess guards the threshold '
        'between the seen and unseen worlds. A crescent moon rests at her '
        'feet, and a veil decorated with pomegranates hangs behind her, '
        'concealing the mysteries that lie beyond conscious reach.\n\n'
        'She holds a scroll labelled TORA, only partially visible: full '
        'knowledge is never given freely but must be earned through '
        'patience and inner listening. The High Priestess is the keeper '
        'of intuition, dreams, and the deep subconscious.',
    elementMeaning:
        'Water is the element of emotion, intuition, and the unseen '
        'currents beneath the surface. Here it represents the deep well '
        'of inner knowing that The High Priestess invites you to draw from.',
    uprightMeaning:
        'Intuition, sacred knowledge, and the subconscious mind. Trust '
        'what you feel rather than what you can prove. Stillness and '
        'receptivity will reveal more than action right now.',
    reversedMeaning:
        'Secrets, disconnection from intuition, or information withheld. '
        'You may be ignoring your inner voice or struggling to access your '
        'deeper knowing.',
    reflectionQuestions: [
      'What is your intuition quietly telling you right now?',
      'Are you making enough space for stillness and reflection?',
      'What hidden knowledge might be waiting just beyond your awareness?',
    ],
  ),

  // ── III · The Empress ─────────────────────────────────────────
  CardGuide(
    cardId: 'major_03',
    description:
        'The Empress reclines on luxurious cushions in a lush, abundant '
        'garden. A field of golden wheat ripens before her, a waterfall '
        'flows nearby, and her robe is patterned with pomegranates — '
        'symbols of fertility. The Venus symbol on her heart-shaped shield '
        'connects her to love, beauty, and the creative force of nature.\n\n'
        'She is the great Mother archetype: sensual, generous, and deeply '
        'connected to the rhythms of the earth. Where The High Priestess '
        'holds hidden knowledge, The Empress brings it into bloom.',
    elementMeaning:
        'Earth grounds The Empress in the physical, sensory world. Her '
        'earth energy is fertile and generative — the soil in which seeds '
        'of intention take root and grow into tangible abundance.',
    uprightMeaning:
        'Abundance, fertility, nurturing, and sensual pleasure. This is a '
        'time of growth and creative fruition. Nourish your body, your '
        'relationships, and your projects with patient, loving care.',
    reversedMeaning:
        'Creative block, dependence, or neglect of self-care. Reversed, '
        'The Empress may suggest smothering love, difficulty receiving, or '
        'disconnection from your body and the natural world.',
    reflectionQuestions: [
      'How are you nurturing your creative projects and relationships?',
      'Where might you need to slow down and enjoy the sensory world?',
      'Are you giving to others at the expense of your own nourishment?',
    ],
  ),

  // ── IV · The Emperor ──────────────────────────────────────────
  CardGuide(
    cardId: 'major_04',
    description:
        'The Emperor sits on a stone throne carved with four rams\' heads, '
        'symbols of Aries and assertive energy. Clad in red robes and '
        'armour, he holds an ankh sceptre in one hand and an orb in the '
        'other — authority over both life and dominion. Behind him rise '
        'barren mountains: his kingdom is built on unyielding rock.\n\n'
        'He is the Father archetype: structured, protective, and decisive. '
        'Where The Empress creates through nurturing, The Emperor creates '
        'through order. He establishes the rules, boundaries, and systems '
        'that allow civilisation to function.',
    elementMeaning:
        'Fire here represents the driving will to build and protect. The '
        'Emperor\'s fire is not wild but controlled — a forge that shapes '
        'raw ambition into lasting structure.',
    uprightMeaning:
        'Authority, structure, stability, and fatherly protection. '
        'Establish clear boundaries, take responsibility, and lead with '
        'discipline. A solid foundation is being built or needed.',
    reversedMeaning:
        'Rigidity, domination, or lack of discipline. Reversed, The '
        'Emperor warns of tyranny, excessive control, or an inability to '
        'adapt when structure becomes a cage.',
    reflectionQuestions: [
      'Where do you need more structure or discipline in your life?',
      'Are your boundaries protecting you or isolating you?',
      'How do you relate to authority — your own and others\'?',
    ],
  ),

  // ── V · The Hierophant ────────────────────────────────────────
  CardGuide(
    cardId: 'major_05',
    description:
        'The Hierophant sits between two grey pillars in a formal '
        'religious setting, wearing a triple crown and robes of red, '
        'white, and blue. He raises his right hand in a gesture of '
        'blessing — two fingers pointing skyward, two toward earth — '
        'while two acolytes kneel before him. At his feet lie two '
        'crossed keys: the keys to heaven and the conscious and '
        'subconscious mind.\n\n'
        'He is the spiritual teacher, the bridge between the divine and '
        'the congregation. The Hierophant represents tradition, shared '
        'beliefs, and the institutions that preserve collective wisdom '
        'across generations.',
    elementMeaning:
        'Earth gives The Hierophant practical rootedness. His spiritual '
        'wisdom is not abstract but embodied in ritual, institution, and '
        'the tangible structures of faith and education.',
    uprightMeaning:
        'Tradition, spiritual guidance, conformity, and shared belief '
        'systems. Seek wisdom through established teachings, mentors, or '
        'institutions. There is value in following a well-worn path.',
    reversedMeaning:
        'Dogma, rebellion against convention, or unconventional '
        'spirituality. Reversed, The Hierophant suggests it may be time '
        'to question traditions that no longer serve you or forge your own '
        'spiritual path.',
    reflectionQuestions: [
      'Which traditions or belief systems still nourish you?',
      'Is there a teacher or mentor whose guidance you need right now?',
      'Where might blind conformity be limiting your growth?',
    ],
  ),

  // ── VI · The Lovers ───────────────────────────────────────────
  CardGuide(
    cardId: 'major_06',
    description:
        'Beneath the radiant angel Raphael, a naked man and woman stand '
        'in a garden reminiscent of Eden. Behind the woman grows the Tree '
        'of Knowledge with a serpent coiled around it; behind the man '
        'stands the Tree of Life bearing twelve flames. The angel\'s '
        'purple cloak represents royalty of spirit, and the sun blazes '
        'overhead.\n\n'
        'Despite its name, The Lovers is fundamentally a card about '
        'choice — the conscious alignment of values that transforms a '
        'relationship from mere attraction into sacred union. It speaks '
        'to every meaningful decision where head and heart must agree.',
    elementMeaning:
        'Air brings the mental clarity needed to make a true choice. Love '
        'alone is not enough; The Lovers asks you to understand what you '
        'value and choose accordingly.',
    uprightMeaning:
        'Love, harmony, deep connection, and values-driven choices. A '
        'meaningful relationship or partnership is forming. Align your '
        'actions with your deepest values and choose with both heart and '
        'mind.',
    reversedMeaning:
        'Disharmony, misalignment, or avoidance of a difficult choice. '
        'Reversed, The Lovers may point to a relationship out of balance, '
        'a values conflict, or self-deception about what you truly want.',
    reflectionQuestions: [
      'What is the most important choice facing you right now?',
      'Are your relationships reflecting your deepest values?',
      'Where might you be avoiding a decision that needs to be made?',
    ],
  ),

  // ── VII · The Chariot ─────────────────────────────────────────
  CardGuide(
    cardId: 'major_07',
    description:
        'A young warrior stands in a stone chariot drawn by two sphinxes '
        '— one black, one white — representing opposing forces that must '
        'be harnessed, not destroyed. He wears a breastplate with a '
        'square (willpower) and carries no reins; he steers by sheer '
        'force of will. Stars crown his canopy, and a city recedes behind '
        'him — he has left the safety of the known world.\n\n'
        'The Chariot marks the moment you take the lessons of cards 0-VI '
        'and ride forth into the world. It is willful triumph through '
        'determination, not brute force.',
    elementMeaning:
        'Water here is surprising — it reveals that The Chariot\'s '
        'victory is emotional as much as physical. True determination '
        'requires mastering your inner tides: fear, doubt, and desire.',
    uprightMeaning:
        'Determination, willpower, victory, and focused ambition. You '
        'have the drive to overcome obstacles. Harness opposing forces '
        'within you and charge forward with confidence.',
    reversedMeaning:
        'Lack of direction, aggression, or loss of control. Reversed, '
        'The Chariot warns that willpower without wisdom becomes '
        'recklessness, or that you\'ve lost your sense of purpose.',
    reflectionQuestions: [
      'What opposing forces within you need to be unified right now?',
      'Are you steering your life with intention or being carried along?',
      'What victory are you working toward, and what will it cost?',
    ],
  ),

  // ── VIII · Strength ───────────────────────────────────────────
  CardGuide(
    cardId: 'major_08',
    description:
        'A woman gently holds open the jaws of a lion — not through '
        'force, but through calm, patient love. An infinity symbol '
        'mirrors The Magician\'s, suggesting a deeper, more mature form '
        'of power. She wears a white robe adorned with flowers, and a '
        'garland of roses drapes both her and the lion.\n\n'
        'Strength is the first card of the subconscious realm in many '
        'numbering systems. It teaches that true power comes not from '
        'dominating our animal nature, but from befriending it. Courage '
        'here is quiet, sustained, and compassionate.',
    elementMeaning:
        'Fire represents the raw passion and primal energy of the lion. '
        'Strength\'s lesson is that fire need not be extinguished — it '
        'can be gently channelled through patience and inner fortitude.',
    uprightMeaning:
        'Inner strength, courage, patience, and compassion. Face your '
        'challenges with grace rather than force. Gentle persistence '
        'will achieve what aggression cannot.',
    reversedMeaning:
        'Self-doubt, weakness, or raw uncontrolled emotion. Reversed, '
        'Strength may indicate that you are either suppressing your '
        'instincts entirely or being overwhelmed by them.',
    reflectionQuestions: [
      'Where do you need to show yourself more compassion?',
      'What "inner lion" are you struggling to tame right now?',
      'How might patience accomplish what force has not?',
    ],
  ),

  // ── IX · The Hermit ───────────────────────────────────────────
  CardGuide(
    cardId: 'major_09',
    description:
        'An old man stands alone on a snowy mountain peak, holding a '
        'lantern containing a six-pointed star — the Seal of Solomon, '
        'symbolising wisdom. He leans on a staff, grounded by experience. '
        'The grey landscape stretches below him, but his gaze is turned '
        'inward.\n\n'
        'The Hermit withdraws from the world not to escape it, but to '
        'find the light within. His solitude is purposeful: only in '
        'silence can certain truths be heard. He is the wise guide who '
        'lights the path for those who seek him — but first, he sought '
        'that light for himself.',
    elementMeaning:
        'Earth gives The Hermit his grounded, practical wisdom. His '
        'spiritual seeking is not airy abstraction but hard-won knowledge '
        'rooted in lived experience and patient self-examination.',
    uprightMeaning:
        'Solitude, introspection, inner guidance, and soul-searching. '
        'Withdraw from noise and distraction to find your own truth. '
        'A period of quiet reflection will illuminate your next steps.',
    reversedMeaning:
        'Isolation, loneliness, or withdrawal taken too far. Reversed, '
        'The Hermit may warn that solitude has become avoidance, or that '
        'you are refusing wisdom that others have to offer.',
    reflectionQuestions: [
      'What truth can only be found in silence?',
      'Are you withdrawing for wisdom or running from connection?',
      'What inner light are you being asked to follow right now?',
    ],
  ),

  // ── X · Wheel of Fortune ──────────────────────────────────────
  CardGuide(
    cardId: 'major_10',
    description:
        'A great wheel turns in the sky, inscribed with the letters '
        'T-A-R-O (and the Hebrew letters of the divine name). Four '
        'winged creatures sit in the corners — the lion, eagle, ox, and '
        'angel — representing the fixed signs of the zodiac and the four '
        'evangelists. A sphinx sits atop the wheel holding a sword of '
        'discernment, while Typhon (the serpent) descends on the left '
        'and Anubis rises on the right.\n\n'
        'The Wheel of Fortune is the great turning point of the Major '
        'Arcana. It reminds us that change is the only constant, and '
        'that fortune — good or ill — is always in motion.',
    elementMeaning:
        'Fire here represents the dynamic, ever-turning energy of fate. '
        'The Wheel\'s fire is not something you control but something you '
        'ride — the spark of destiny that ignites change.',
    uprightMeaning:
        'Cycles, fate, turning points, and good fortune. A significant '
        'change is coming — or has arrived. Trust the cycle. What goes '
        'down must come up, and this may be your moment of ascent.',
    reversedMeaning:
        'Bad luck, resistance to change, or feeling stuck in a negative '
        'cycle. Reversed, the Wheel suggests you are fighting against a '
        'natural turning or repeating patterns that need to be broken.',
    reflectionQuestions: [
      'What cycle in your life is asking to turn right now?',
      'How do you respond when things feel out of your control?',
      'What pattern keeps repeating, and what might break it?',
    ],
  ),

  // ── XI · Justice ──────────────────────────────────────────────
  CardGuide(
    cardId: 'major_11',
    description:
        'Justice sits on a stone throne between two grey pillars, '
        'holding a double-edged sword in her right hand and balanced '
        'scales in her left. Her red robe speaks of passion tempered by '
        'the green cloak of compassion beneath. A small crown with a '
        'square jewel adorns her head — clarity of thought and '
        'impartial judgement.\n\n'
        'Justice is not blind in the tarot; her eyes are open, seeing '
        'all with clarity and fairness. She represents the universal law '
        'of cause and effect — every action has a consequence, and truth '
        'cannot be hidden forever.',
    elementMeaning:
        'Air brings the sharp clarity of thought and impartial reasoning. '
        'Justice\'s air is the clean edge of truth — it cuts through '
        'rationalisation and self-deception to reveal what is fair.',
    uprightMeaning:
        'Fairness, truth, accountability, and karmic balance. Accept '
        'responsibility for your actions and their consequences. A fair '
        'outcome is approaching — it may require honesty you\'d rather '
        'avoid.',
    reversedMeaning:
        'Injustice, dishonesty, or refusal to accept accountability. '
        'Reversed, Justice warns of unfair treatment, legal complications, '
        'or a truth you are hiding from yourself or others.',
    reflectionQuestions: [
      'Where in your life do you need to take honest accountability?',
      'Is there a situation where you\'re not being completely truthful?',
      'What would true fairness look like in your current circumstances?',
    ],
  ),

  // ── XII · The Hanged Man ──────────────────────────────────────
  CardGuide(
    cardId: 'major_12',
    description:
        'A man hangs upside down from a living T-shaped tree, his right '
        'foot bound and his left leg crossed behind, forming a figure-4. '
        'Rather than struggling, his expression is serene — even '
        'illuminated, with a golden halo around his head. His arms are '
        'folded behind his back in quiet acceptance.\n\n'
        'The Hanged Man is one of the most misunderstood cards. He does '
        'not suffer; he surrenders. By voluntarily inverting his '
        'perspective, he sees the world in an entirely new way. '
        'Sacrifice here is not loss but a willing exchange of one '
        'viewpoint for a deeper one.',
    elementMeaning:
        'Water represents the flowing, surrendering quality of this card. '
        'Like water finding its way around obstacles, The Hanged Man '
        'teaches that yielding can be more powerful than resisting.',
    uprightMeaning:
        'Surrender, new perspective, pause, and willing sacrifice. Let '
        'go of control and see the situation from an entirely different '
        'angle. What feels like a delay may be the most productive '
        'thing you can do.',
    reversedMeaning:
        'Stalling, resistance, or martyrdom. Reversed, The Hanged Man '
        'may indicate that you are stuck in a holding pattern without '
        'purpose, or making sacrifices that serve no one.',
    reflectionQuestions: [
      'What might you see differently if you stopped resisting?',
      'Where are you being asked to pause rather than push?',
      'Is there a sacrifice you\'re making that no longer serves you?',
    ],
  ),

  // ── XIII · Death ──────────────────────────────────────────────
  CardGuide(
    cardId: 'major_13',
    description:
        'A skeleton in black armour rides a white horse through a '
        'landscape of fallen figures — a king, a child, a maiden, and a '
        'bishop — showing that transformation spares no one. He carries '
        'a black flag emblazoned with a white mystic rose: the promise '
        'of rebirth. In the distance, the sun rises between two towers, '
        'and a river flows toward the horizon.\n\n'
        'Death is rarely about physical death. It is the necessary '
        'ending that clears the way for new life. The old must fall so '
        'the new can rise. This card asks you to grieve what is passing '
        'and trust what is coming.',
    elementMeaning:
        'Water represents the emotional depth of this transition. '
        'Death\'s water is the river of grief and release — the tears '
        'that cleanse and the current that carries you to a new shore.',
    uprightMeaning:
        'Endings, transformation, transition, and release. Something in '
        'your life is coming to a natural close. Do not cling to what '
        'is dying; honour it, release it, and make room for what wants '
        'to be born.',
    reversedMeaning:
        'Resistance to change, stagnation, or fear of endings. '
        'Reversed, Death suggests you are holding on to something past '
        'its time — a relationship, identity, or belief that no longer '
        'serves your growth.',
    reflectionQuestions: [
      'What in your life has already ended that you haven\'t released?',
      'What needs to die so something new can be born?',
      'How do you typically respond to endings — with grief, denial, or relief?',
    ],
  ),

  // ── XIV · Temperance ──────────────────────────────────────────
  CardGuide(
    cardId: 'major_14',
    description:
        'A great winged angel stands with one foot on land and one in '
        'water, pouring liquid between two cups in a continuous, '
        'impossible flow. A golden triangle enclosed in a square adorns '
        'the angel\'s chest — spirit contained within matter. A winding '
        'path leads to a glowing golden crown on the horizon, promising '
        'a destination reached through patience.\n\n'
        'Temperance is the art of balance and alchemy. It follows Death '
        'as the healing integration that comes after loss. The angel '
        'blends opposites — conscious and unconscious, fire and water — '
        'into a harmonious new whole.',
    elementMeaning:
        'Fire here is transmutative — the alchemical fire that refines '
        'without destroying. Temperance\'s fire gently heats and blends '
        'disparate elements into gold.',
    uprightMeaning:
        'Balance, moderation, patience, and purposeful blending. Find '
        'the middle way. Combine different aspects of your life with '
        'care, and trust that slow, steady integration will lead to a '
        'greater whole.',
    reversedMeaning:
        'Imbalance, excess, or lack of long-term vision. Reversed, '
        'Temperance warns of extremes — overindulgence, burnout, or a '
        'refusal to find compromise in a situation that demands it.',
    reflectionQuestions: [
      'Where in your life is the balance between effort and rest off?',
      'What opposing forces within you are asking to be blended?',
      'Are you patient enough to let the right outcome emerge naturally?',
    ],
  ),

  // ── XV · The Devil ────────────────────────────────────────────
  CardGuide(
    cardId: 'major_15',
    description:
        'A horned, bat-winged figure crouches on a half-cube pedestal, '
        'holding a downward-facing torch. Below him, a naked man and '
        'woman are chained — but look closely: the chains around their '
        'necks are loose enough to lift off. Their tails of fire and '
        'grapes echo The Lovers, now distorted by obsession and excess.\n\n'
        'The Devil is not evil incarnate but rather the shadow we refuse '
        'to face. He represents bondage that is largely self-imposed — '
        'the addictions, attachments, and fears we could release if we '
        'chose to. His gift, paradoxically, is awareness: once you see '
        'the chains, you can remove them.',
    elementMeaning:
        'Earth in its shadow aspect: materialism, sensory excess, and '
        'the gravity of attachment. The Devil\'s earth is the weight '
        'that keeps you bound to patterns that no longer serve you.',
    uprightMeaning:
        'Bondage, materialism, shadow self, and unhealthy attachments. '
        'Examine what holds you captive — addiction, toxic relationships, '
        'limiting beliefs. Acknowledge the shadow to reclaim your freedom.',
    reversedMeaning:
        'Release, breaking free, or reclaiming power. Reversed, The '
        'Devil can be profoundly liberating — it signals that you are '
        'ready to shed the chains and step out of a self-imposed prison.',
    reflectionQuestions: [
      'What pattern or attachment are you pretending you can\'t change?',
      'Where in your life have you traded freedom for comfort?',
      'What would it look like to face your shadow with compassion?',
    ],
  ),

  // ── XVI · The Tower ───────────────────────────────────────────
  CardGuide(
    cardId: 'major_16',
    description:
        'Lightning strikes the crown of a tall stone tower, splitting it '
        'open. Flames pour from the windows as two figures plummet '
        'headfirst toward the rocky ground. Twenty-two sparks of light — '
        'one for each path on the Tree of Life — scatter across the dark '
        'sky.\n\n'
        'The Tower is the most dramatic card in the deck. It shatters '
        'what was built on false foundations. The destruction feels '
        'catastrophic in the moment, but it is ultimately liberating: '
        'truth cannot live in a structure built on lies. After The '
        'Tower falls, only what is real remains.',
    elementMeaning:
        'Fire is the bolt of lightning itself — sudden, illuminating, '
        'and impossible to ignore. The Tower\'s fire is the kind of '
        'truth that burns away everything false.',
    uprightMeaning:
        'Sudden upheaval, revelation, and liberation through '
        'destruction. A false structure in your life is collapsing — and '
        'though it is painful, this clearing is necessary. Truth is '
        'replacing illusion.',
    reversedMeaning:
        'Fear of change, averting disaster, or delayed upheaval. '
        'Reversed, The Tower may mean you are clinging to a crumbling '
        'structure, or that you narrowly avoided a breakdown by making '
        'changes just in time.',
    reflectionQuestions: [
      'What structure in your life is built on a shaky foundation?',
      'How do you typically respond to sudden, unexpected change?',
      'What might be freed if something in your life collapsed?',
    ],
  ),

  // ── XVII · The Star ───────────────────────────────────────────
  CardGuide(
    cardId: 'major_17',
    description:
        'A naked woman kneels at the edge of a pool, pouring water from '
        'two pitchers — one onto the land, one into the water — '
        'nourishing both the conscious and subconscious realms. Above '
        'her shines one great eight-pointed star surrounded by seven '
        'smaller ones. A bird perches in a tree behind her — the ibis '
        'of thought, calm and watchful.\n\n'
        'The Star arrives after The Tower\'s devastation as a balm of '
        'hope and renewal. She is vulnerable, open, and unashamed. With '
        'nothing left to hide behind, she pours herself freely into the '
        'world, trusting that the universe will replenish her.',
    elementMeaning:
        'Air here is expansive and clarifying — the first clear breath '
        'after a storm. The Star\'s air carries hope, vision, and the '
        'quiet certainty that the worst has passed.',
    uprightMeaning:
        'Hope, inspiration, serenity, and spiritual renewal. After '
        'hardship, healing is coming. Trust in the future, reconnect '
        'with your sense of purpose, and allow yourself to be vulnerable.',
    reversedMeaning:
        'Despair, disconnection, or loss of faith. Reversed, The Star '
        'may indicate that you have lost hope or are struggling to see '
        'a way forward after a difficult period.',
    reflectionQuestions: [
      'Where in your life is hope quietly returning?',
      'What inspires you when everything else feels stripped away?',
      'How might vulnerability be a source of strength right now?',
    ],
  ),

  // ── XVIII · The Moon ──────────────────────────────────────────
  CardGuide(
    cardId: 'major_18',
    description:
        'A full moon hangs in the night sky, its face in profile, '
        'radiating droplets of light. Below, a narrow path winds between '
        'two towers and disappears into distant mountains. A dog and a '
        'wolf howl at the moon — the tame and wild aspects of the psyche '
        '— while a crayfish emerges from the pool of the unconscious.\n\n'
        'The Moon illuminates, but only partially; shadows and '
        'reflections can deceive. This card represents the journey '
        'through the dark night of the soul — a necessary passage '
        'through fear, illusion, and uncertainty before the dawn.',
    elementMeaning:
        'Water is at its deepest and most mysterious here. The Moon\'s '
        'water is the ocean of the unconscious — teeming with life, '
        'dreams, and fears that surface only at night.',
    uprightMeaning:
        'Illusion, fear, anxiety, and the subconscious. Things are not '
        'as they seem. Navigate carefully through uncertainty, pay '
        'attention to dreams and intuition, and know that the path '
        'through the darkness does lead somewhere.',
    reversedMeaning:
        'Release of fear, clarity emerging, or repressed emotions '
        'surfacing. Reversed, The Moon suggests that confusion is '
        'lifting, or that fears you\'ve been avoiding are finally '
        'demanding to be faced.',
    reflectionQuestions: [
      'What fears are you projecting onto an uncertain situation?',
      'What messages are your dreams or anxieties trying to send?',
      'Can you trust the path even when you can\'t see where it leads?',
    ],
  ),

  // ── XIX · The Sun ─────────────────────────────────────────────
  CardGuide(
    cardId: 'major_19',
    description:
        'A radiant sun with a human face beams down on a joyful naked '
        'child riding a white horse. Sunflowers bloom over a stone wall '
        'behind them, turning toward the light. A red banner flutters '
        'from the child\'s hand — vitality, life force, and celebration.\n\n'
        'The Sun is the most unambiguously positive card in the Major '
        'Arcana. After the darkness of The Moon, light returns in full '
        'glory. The child\'s nakedness represents innocence regained — '
        'not the naive innocence of The Fool, but the hard-won joy of '
        'someone who has walked through darkness and emerged whole.',
    elementMeaning:
        'Fire is at its most generous and life-giving here. The Sun\'s '
        'fire does not burn — it warms, illuminates, and makes things '
        'grow. It is the creative spark expressed as pure joy.',
    uprightMeaning:
        'Joy, success, vitality, and positivity. Everything is coming '
        'together. Celebrate your wins, bask in clarity, and share your '
        'warmth with others. This is a time of abundance and confidence.',
    reversedMeaning:
        'Temporary setbacks, dampened enthusiasm, or inner child wounds. '
        'Reversed, The Sun\'s light is dimmed but not extinguished — '
        'happiness is still available, but something is blocking your '
        'access to it.',
    reflectionQuestions: [
      'What in your life right now deserves celebration?',
      'Where have you been dimming your own light?',
      'How can you reconnect with simple, childlike joy?',
    ],
  ),

  // ── XX · Judgement ────────────────────────────────────────────
  CardGuide(
    cardId: 'major_20',
    description:
        'The archangel Gabriel blows a great trumpet from the clouds, '
        'bearing a flag with a red cross. Below, grey-skinned figures '
        'rise from their coffins — a man, woman, and child — arms '
        'outstretched toward the call. Mountains of ice frame the '
        'background, suggesting the final frontier before transcendence.\n\n'
        'Judgement is the great awakening: a call to rise above the '
        'person you were and become the person you are meant to be. It '
        'is not judgement as condemnation, but as honest reckoning — a '
        'life reviewed and an inner calling answered.',
    elementMeaning:
        'Fire here is the transformative fire of rebirth — the phoenix '
        'flame that calls the dead to rise. Judgement\'s fire purifies '
        'and renews, burning away the last vestiges of the old self.',
    uprightMeaning:
        'Rebirth, inner calling, reflection, and absolution. You are '
        'being called to a higher version of yourself. Reflect honestly '
        'on your past, forgive what needs forgiving, and answer the call.',
    reversedMeaning:
        'Self-doubt, refusal of the call, or harsh self-judgement. '
        'Reversed, Judgement may indicate that you are ignoring an '
        'important inner calling, or that guilt and regret are preventing '
        'you from moving forward.',
    reflectionQuestions: [
      'What is calling you to rise to a higher version of yourself?',
      'What past actions or choices need honest reflection and release?',
      'Are you judging yourself too harshly to hear your own calling?',
    ],
  ),

  // ── XXI · The World ───────────────────────────────────────────
  CardGuide(
    cardId: 'major_21',
    description:
        'A dancing figure is suspended within a great laurel wreath, '
        'holding two wands — echoing The Magician but now in perfect '
        'balance. The four fixed-sign creatures return from The Wheel '
        'of Fortune: lion, eagle, ox, and angel — all integrated, all '
        'at peace. A red ribbon ties the wreath in the shape of an '
        'infinity symbol at top and bottom.\n\n'
        'The World is the final card of the Major Arcana and the '
        'completion of the Fool\'s Journey. It represents wholeness, '
        'accomplishment, and the integration of every lesson learned '
        'along the way. The dance is not static — it carries the seed '
        'of the next cycle, for The Fool will soon step out again.',
    elementMeaning:
        'Earth brings The World to its fullest expression: the tangible '
        'completion of a long journey. Every lesson has been grounded in '
        'real experience, and the result is a life fully lived.',
    uprightMeaning:
        'Completion, integration, accomplishment, and wholeness. A major '
        'cycle is complete. Celebrate what you have achieved and the '
        'person you have become. You have arrived — and a new journey '
        'awaits.',
    reversedMeaning:
        'Incompletion, shortcuts, or lack of closure. Reversed, The '
        'World suggests that a chapter is not yet truly finished. '
        'Something still needs to be integrated or honoured before you '
        'can move on.',
    reflectionQuestions: [
      'What cycle in your life is reaching its natural completion?',
      'Have you fully integrated the lessons of your recent journey?',
      'What new beginning might be waiting on the other side of this ending?',
    ],
  ),
];

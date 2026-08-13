\---



\# MASTER PRODUCT SPECIFICATION



\## Sinking Fund Mobile Application



\*\*Document:\*\* `MASTER\_PRODUCT\_SPEC.md`

\*\*Version:\*\* 1.0

\*\*Status:\*\* Product/Engineering Master Specification

\*\*Primary platforms:\*\* iOS + Android

\*\*Product category:\*\* Sinking Fund / Savings Goal Planner

\*\*Development model:\*\* AI-assisted, agent-driven development using Google Antigravity

\*\*Canonical purpose:\*\* Authoritative product specification for implementation



\---



\# 0. HOW THIS DOCUMENT MUST BE USED



This document defines the \*\*product-level truth\*\* for the application.



It describes:



\* what the product is;

\* who it serves;

\* which problem it solves;

\* why the product should exist;

\* how it should behave;

\* how it should feel;

\* what features it should contain;

\* what constraints must be respected;

\* what should not be built.



It does \*\*not\*\* mean every proposed idea must immediately be implemented.



Each requirement should be interpreted according to its status:



| Status                | Meaning                                     |

| --------------------- | ------------------------------------------- |

| `REQUIRED`            | Must be implemented                         |

| `RECOMMENDED`         | Strong recommendation                       |

| `PROPOSED`            | Product hypothesis requiring validation     |

| `FUTURE`              | Not part of initial implementation          |

| `VALIDATION REQUIRED` | Do not treat as proven                      |

| `PLATFORM DEPENDENT`  | Behavior may differ between iOS and Android |



\### Source hierarchy



When making decisions:



1\. \*\*Explicit user/product decisions\*\*

2\. This Master Product Specification

3\. Approved Architecture/Design Decision Records

4\. Existing verified implementation

5\. General engineering best practices

6\. Agent assumptions



The agent must \*\*not silently invent product decisions\*\* when the specification is ambiguous.



\---



\# 1. PRODUCT VISION



\## 1.1 Product concept



Build a highly polished, mobile-first application dedicated specifically to helping people plan and manage \*\*sinking funds\*\*.



The application should allow users to transform irregular but predictable future expenses into manageable, visible savings goals.



The product should answer one fundamental question:



> \*\*"How much do I need to set aside, and am I on track to have enough money when I need it?"\*\*



The application should deliberately avoid becoming a traditional full-scale personal budgeting application.



\---



\## 1.2 Core product promise



The product promise is:



> \*\*Know what you need to save, see your progress, and be ready when the expense arrives.\*\*



The user should not need to:



\* categorize every grocery purchase;

\* connect their bank account;

\* build complicated budgets;

\* understand accounting terminology;

\* manually calculate contribution schedules.



\---



\# 2. PSYCHOLOGICAL FOUNDATION



This section is directly derived from the supplied research.



\## 2.1 Mental accounting



The product is based on the behavioral-economic concept of \*\*mental accounting\*\*.



Users naturally divide money psychologically into categories or "buckets," even though money is technically fungible.



The application should therefore represent funds as \*\*distinct psychological containers\*\* rather than merely rows in a financial table. 



\### Product implication



A fund should visually feel like an independent object.



Examples:



\* Vacation

\* Car maintenance

\* Insurance

\* Gifts

\* Annual subscriptions

\* Medical expenses

\* Pet expenses

\* Education

\* Home repairs



\---



\## 2.2 Consumption smoothing



Sinking funds allow users to distribute irregular expenses across time rather than experiencing a large financial shock when the expense arrives.



Therefore:



```text

Large future expense

&#x20;       ↓

small recurring contributions

&#x20;       ↓

prepared fund

&#x20;       ↓

predictable expense

```



The product should make this transformation visually obvious.



\---



\## 2.3 Predictability paradox



A major psychological problem is that predictable annual expenses can nevertheless feel like unexpected emergencies.



The application should convert:



> "I suddenly need $1,200."



into:



> "$100/month gets me ready."



This is one of the product's primary emotional benefits.



\---



\## 2.4 Reduce financial anxiety



The product must not behave like a punitive budgeting system.



If the user falls behind:



\*\*Bad:\*\*



> "You failed to save enough."



\*\*Preferred:\*\*



> "You're $120 behind. Your new weekly contribution is $34."



The system should emphasize \*\*recovery and clarity\*\*, not guilt.



The research explicitly recommends dynamic recalculation rather than punitive warnings. 



\---



\# 3. TARGET USER



\## 3.1 Primary user



The primary user is a person who:



\* has recurring irregular expenses;

\* understands that these expenses are predictable;

\* wants to save gradually;

\* finds traditional budgeting applications excessive;

\* wants a simple visual system;

\* does not necessarily want bank synchronization;

\* wants to know how much to save per week/month/paycheck.



\---



\## 3.2 Primary pain points



The product should address:



\### Pain 1 — Large irregular expenses



"I know this expense is coming, but I never know how much I should put aside."



\### Pain 2 — Mental separation



"I want this money to be for my vacation/car/insurance rather than accidentally spending it."



\### Pain 3 — Calculation



"How much do I need to save every month?"



\### Pain 4 — Schedule changes



"I missed a contribution. What do I need to save now?"



\### Pain 5 — Existing budgeting complexity



"I don't want to manage my entire financial life just to track five future expenses."



\### Pain 6 — Lack of visual motivation



"A spreadsheet tells me numbers but doesn't make progress feel satisfying."



\---



\# 4. COMPETITIVE POSITIONING



\## 4.1 Product category



The application should position itself as:



> \*\*A visual sinking-fund planner.\*\*



Not:



> Full personal finance manager.



Not:



> Bank account replacement.



Not:



> Full zero-based budgeting system.



Not:



> Investment application.



\---



\## 4.2 Competitive problem



The research identifies dissatisfaction with comprehensive budgeting platforms including EveryDollar, YNAB and post-Mint alternatives around the treatment of long-term savings goals and cognitive complexity. 



Users also resort to:



\* spreadsheets;

\* multiple savings accounts;

\* banking "buckets";

\* manual workarounds.







\---



\## 4.3 Competitive wedge



The product's wedge is:



```text

Traditional finance apps

&#x20;       ↓

Everything about your money



This product

&#x20;       ↓

Only the money you are preparing for later

```



That simplicity is a feature.



\---



\# 5. PRODUCT DIFFERENTIATION



The application should differentiate through \*\*five combined advantages\*\*.



\## 5.1 Narrow purpose



Do one thing extremely well.



\## 5.2 Mathematical automation



The user supplies:



```text

Target

\+

Deadline

\+

Current balance

```



The app determines the required contribution trajectory.



\## 5.3 Visual fund ownership



Each fund feels like a distinct object.



The research specifically calls for visual cards/buckets/envelopes instead of spreadsheet-like presentation. 



\## 5.4 Premium interaction design



The transcript's central thesis is that apps competing in crowded markets need to stand out through animation, interaction, illustrations, iconography, widgets and polish. 



\## 5.5 Ambient presence



Widgets and contextual notifications make the product part of the user's daily environment rather than something they open only when they remember to budget.



\---



\# 6. CORE FEATURE SET



\## 6.1 Fund creation



Users can create a fund with:



\### Required



\* Name

\* Target amount

\* Target date



\### Optional



\* Starting balance

\* Contribution frequency

\* Custom icon

\* Custom visual

\* Color/theme

\* Notes



\---



\# 7. FUND MODEL



Each fund represents an independent financial goal.



A fund contains:



```text

Fund

├── Identity

│   ├── Name

│   ├── Icon

│   ├── Visual theme

│   └── Color

│

├── Financial state

│   ├── Target amount

│   ├── Current balance

│   ├── Starting balance

│   └── Remaining amount

│

├── Schedule

│   ├── Target date

│   ├── Contribution frequency

│   └── Required contribution

│

├── Progress

│   ├── Percentage

│   ├── Status

│   ├── Days remaining

│   └── Trajectory

│

└── Ledger

&#x20;   ├── Contributions

&#x20;   └── Withdrawals

```



\---



\# 8. CALCULATION ENGINE



This is a \*\*core domain subsystem\*\* and must be isolated from UI code.



\## 8.1 Basic calculation



Conceptually:



```text

remaining amount =

target amount - current balance

```



Then:



```text

required contribution =

remaining amount / remaining contribution periods

```



The exact algorithm must account for the user's selected contribution frequency and date boundaries.



\---



\## 8.2 Dynamic recalculation



The required contribution must automatically change when:



\* user contributes;

\* user withdraws;

\* date advances;

\* target changes;

\* current balance changes;

\* target date changes.



\---



\## 8.3 Status states



Every fund must be able to determine its state:



```text

NOT\_STARTED

ON\_TRACK

AHEAD

BEHIND

COMPLETE

OVERFUNDED

DEADLINE\_PASSED

```



\---



\# 9. FINANCIAL EDGE CASES



The calculation engine must explicitly handle:



\### Target = 0



Do not divide by zero.



\### Current balance > target



Status:



`OVERFUNDED`



\### Current balance = target



Status:



`COMPLETE`



\### Deadline = today



Remaining contribution period must be handled explicitly.



\### Deadline in the past



Status:



`DEADLINE\_PASSED`



\### Missed contribution



Recalculate rather than treating the fund as permanently failed.



\### Extra contribution



Recalculate and potentially show:



> Ahead of schedule.



\### Withdrawal



Recalculate remaining requirement.



\### Multiple transactions



All transactions must be applied deterministically.



\### Partial contribution



Allowed.



\### Negative contribution



Rejected.



\### Negative withdrawal



Rejected.



\### Withdrawal larger than available balance



Rejected unless an explicit future product decision permits overdraft-style behavior.



\---



\# 10. LEDGER



The app should provide a simple ledger.



Transaction types:



```text

CONTRIBUTION

WITHDRAWAL

ADJUSTMENT

```



Each transaction should include:



\* amount;

\* timestamp/date;

\* type;

\* optional note;

\* associated fund.



The application is a \*\*manual planner and ledger\*\*, not a bank-account replacement. The supplied research explicitly recommends avoiding automated bank integration. 



\---



\# 11. DASHBOARD



The dashboard should immediately answer:



1\. What funds do I have?

2\. How much have I saved?

3\. What do I need to contribute?

4\. Which funds need attention?

5\. What is coming up next?



\---



\## 11.1 Dashboard hierarchy



Recommended hierarchy:



```text

Greeting / contextual header

&#x20;       ↓

Overall savings snapshot

&#x20;       ↓

Priority fund / upcoming goal

&#x20;       ↓

Fund cards

&#x20;       ↓

Recent activity

&#x20;       ↓

Optional insight

```



\---



\# 12. FUND CARD



A fund card should communicate at a glance:



```text

Icon

Fund name



$720 / $1,200



\[████████░░] 60%



$80/month

42 days remaining



ON TRACK

```



The card should not feel like a spreadsheet row.



\---



\# 13. FUND DETAIL SCREEN



The detail screen should contain:



\* large visual fund representation;

\* target;

\* current balance;

\* percentage;

\* remaining amount;

\* days remaining;

\* required contribution;

\* trajectory;

\* transaction history;

\* contribution CTA;

\* withdrawal CTA;

\* edit action.



\---



\# 14. CONTRIBUTION FLOW



Primary flow:



```text

Fund Detail

&#x20;   ↓

Add Money

&#x20;   ↓

Amount

&#x20;   ↓

Optional note

&#x20;   ↓

Confirm

&#x20;   ↓

Animated balance update

&#x20;   ↓

Updated trajectory

```



The confirmation should feel satisfying.



Potential feedback:



\* number animation;

\* progress movement;

\* subtle haptic;

\* contextual mascot response;

\* milestone celebration when appropriate.



\---



\# 15. WITHDRAWAL FLOW



Withdrawal should not feel like a catastrophic event.



After withdrawal:



```text

Balance decreases

&#x20;      ↓

Remaining target increases

&#x20;      ↓

Required contribution recalculates

&#x20;      ↓

User sees new trajectory

```



The system should explain the consequence without judgment.



\---



\# 16. ONBOARDING



The primary onboarding objective is:



> \*\*Reach first value within approximately 60 seconds.\*\*



The supplied research explicitly emphasizes getting the user to create a functioning first goal and see the calculation rapidly. 



\---



\## 16.1 Onboarding sequence



Recommended:



```text

Welcome

&#x20;↓

What are you saving for?

&#x20;↓

Target amount

&#x20;↓

Target date

&#x20;↓

Current savings

&#x20;↓

Required contribution

&#x20;↓

First fund created

&#x20;↓

Dashboard

```



Avoid:



\* long questionnaires;

\* unnecessary account creation;

\* financial education before value;

\* permission requests before necessary.



\---



\# 17. ONBOARDING PSYCHOLOGY



The onboarding should create:



\### Curiosity



"What will my number be?"



\### Immediate competence



"I now know exactly what I need to save."



\### Ownership



"This is my fund."



\### Progress



"I'm already on my way."



\### Emotional reinforcement



"The future expense feels manageable now."



\---



\# 18. DESIGN PHILOSOPHY



The app must \*\*not look like a spreadsheet\*\*.



The research explicitly calls for highly visual independent cards/buckets/envelopes. 



\---



\## 18.1 Design objective



The visual language should communicate:



```text

Calm

Trustworthy

Friendly

Premium

Tactile

Simple

Financially responsible

Slightly playful

```



Avoid:



```text

Generic fintech dashboard

Corporate banking UI

Spreadsheet aesthetic

Overly gamified children's app

Clutter

Visual noise

Template-like AI design

```



\---



\# 19. DESIGN SYSTEM



The project must have centralized design tokens for:



```text

Colors

Typography

Spacing

Radius

Elevation

Borders

Icon sizes

Touch targets

Motion

Opacity

Gradients

Illustration treatment

```



No arbitrary one-off values should be introduced unless there is a documented reason.



\---



\# 20. TYPOGRAPHY



Typography should establish a clear hierarchy:



```text

Display

Heading

Subheading

Body

Caption

Financial number

Metadata

Button

```



Financial values should be visually prominent.



Numbers should be highly legible and preferably use tabular numerals where appropriate.



\---



\# 21. ICONOGRAPHY



The application must use a \*\*single coherent icon family\*\*.



Do not mix:



\* filled icons;

\* thin line icons;

\* rounded line icons;

\* 3D icons;

\* random emoji



without a deliberate system.



Chris specifically identifies inconsistent iconography as one of the details that makes an app feel less professionally designed. 



\---



\# 22. VISUAL CUSTOMIZATION



Funds should support customization.



Potential options:



\* color;

\* gradient;

\* icon;

\* illustration;

\* texture;

\* theme.



The research specifically recommends deep visual customization to reinforce psychological separation between funds. 



Premium customization should not compromise usability or accessibility.



\---



\# 23. ANIMATION SYSTEM



Animation is a \*\*product-quality system\*\*, not decoration.



The transcript identifies animation and interactions as one of the most important ways to make a mobile application feel dynamic and differentiated. 



\---



\## 23.1 Animation principles



Animations should:



1\. communicate state;

2\. provide feedback;

3\. establish spatial continuity;

4\. reward meaningful actions;

5\. reduce perceived waiting;

6\. create personality.



Never animate simply because the framework allows it.



\---



\# 24. REQUIRED MICRO-INTERACTIONS



Potential interactions:



\### Button press



Subtle scale/compression.



\### Contribution



```text

Tap

→ feedback

→ amount confirmation

→ balance animation

→ progress animation

```



\### Fund completion



A stronger celebration.



\### Pull/refresh



Use appropriate platform interaction.



\### Sheet presentation



Smooth spring transition.



\### Number change



Animate numerical transition rather than abruptly replacing it where appropriate.



\---



\# 25. HAPTICS



Haptics should reinforce meaningful events:



\* button confirmation;

\* successful contribution;

\* milestone;

\* goal completion;

\* error/invalid input where appropriate.



Do not use haptics for every interaction.



\---



\# 26. MASCOT SYSTEM



The mascot is a \*\*brand system\*\*, not a random illustration.



The transcript emphasizes that a well-designed mascot can add character to onboarding and make an application feel substantially more alive. 



\---



\## 26.1 Mascot principles



The mascot must have:



\* consistent proportions;

\* consistent face;

\* consistent visual language;

\* consistent lighting;

\* repeatable expressions;

\* reusable poses.



\---



\## 26.2 Mascot states



Initial library should include:



```text

Idle

Happy

Celebrating

Thinking

Searching

Encouraging

Waiting

Concerned

Success

Fund completed

Empty state

Error

```



\---



\## 26.3 Mascot usage



Mascot should appear when it adds emotional or contextual value.



Do not put it on every screen.



\---



\## 26.4 Asset consistency



A master mascot reference asset must be maintained.



New mascot variations must be derived from that reference.



The transcript specifically discusses creating a base mascot and then iterating on that established visual identity. 



\---



\# 27. MASCOT/IP SAFETY



The mascot must be original.



Do not reproduce another company's mascot.



References may communicate broad attributes such as:



```text

playful

fresh

friendly

youthful

premium

```



but should not result in an imitation of another brand.



\---



\# 28. WIDGET SYSTEM



Widgets are a strategic retention feature.



The transcript describes widgets as a mechanism for embedding an application into the user's daily workflow and increasing ambient engagement. 



\---



\## 28.1 iOS widgets



Potential sizes:



\* Small

\* Medium

\* Large



Potential content:



\### Fund progress



```text

Vacation



$720 / $1,200



60%

```



\### Contribution reminder



```text

Vacation

$80 needed this month

```



\### Overall progress



```text

Savings goals

3 on track

1 needs attention

```



\---



\## 28.2 Android widgets



Provide equivalent functionality using the appropriate Android widget architecture.



Do not force identical UI implementation across platforms.



\---



\## 28.3 Widget principles



Widgets must:



\* remain useful without opening the app;

\* deep-link into relevant screens;

\* handle stale data;

\* respect privacy;

\* avoid excessive refresh/battery usage;

\* clearly communicate when data is unavailable.



\---



\# 29. NOTIFICATION SYSTEM



Notifications must be \*\*functional and contextual\*\*.



The research explicitly warns against generic promotional notifications and recommends milestone/payday-specific reminders. 



\---



\## 29.1 Appropriate notifications



Examples:



> "Your Vacation fund is 50% complete."



> "Your next Vacation contribution is $80."



> "You're ahead of schedule."



> "Your Car Repair goal is approaching its target date."



\---



\## 29.2 Avoid



```text

"Come back!"

"Don't forget us!"

"We miss you!"

"Check your app!"

```



unless there is an actual user-relevant reason.



\---



\# 30. NOTIFICATION SETTINGS



Users must control:



\* contribution reminders;

\* milestone notifications;

\* deadline notifications;

\* completion notifications;

\* payday reminders.



Respect OS-level notification permissions.



\---



\# 31. PRIVACY ARCHITECTURE



The supplied research strongly recommends avoiding automated bank aggregation and maintaining a local-first architecture. 



\---



\## 31.1 Initial architecture



Preferred:



```text

Mobile application

&#x20;     ↓

Local persistent storage

&#x20;     ↓

Optional OS-native cloud synchronization

```



No central financial database is required for the core product.



\---



\## 31.2 Explicit non-goal



Do \*\*not\*\* implement:



\* Plaid;

\* MX;

\* Yodlee;

\* Finicity;

\* automated bank transaction ingestion;



unless a future product decision explicitly changes this architecture.



The supplied research specifically argues against bank aggregation due to cost and operational complexity. 



\---



\## 31.3 Privacy language



Do not make unsupported legal claims such as:



> "This architecture guarantees GDPR compliance."



Legal compliance must be separately evaluated.



The engineering requirement is:



> Minimize collection and transmission of financial data.



\---



\# 32. DATA MODEL



Initial conceptual model:



```text

User

&#x20;├── Settings

&#x20;├── Subscription

&#x20;└── Funds

&#x20;      │

&#x20;      ├── Fund Identity

&#x20;      ├── Fund Schedule

&#x20;      ├── Fund State

&#x20;      └── Transactions

&#x20;             ├── Contribution

&#x20;             └── Withdrawal

```



\---



\# 33. DATA OWNERSHIP



The user owns their financial records.



The product must provide mechanisms for:



\* data persistence;

\* backup/synchronization where supported;

\* export;

\* deletion;

\* recovery.



\---



\# 34. CROSS-PLATFORM ARCHITECTURE



The app must share:



```text

Domain logic

Calculation engine

Data models

Business rules

Design tokens

Core UI patterns

Analytics abstractions

Validation logic

```



Platform-specific implementations may exist for:



```text

Widgets

Notifications

Haptics

Cloud synchronization

Secure storage

App Store / Play Store integration

Platform permissions

```



\---



\# 35. PLATFORM QUALITY



The objective is \*\*not\*\*:



> "One UI that happens to run on two platforms."



The objective is:



> \*\*One coherent product with platform-appropriate behavior.\*\*



\---



\# 36. ACCESSIBILITY



Required considerations:



\* VoiceOver;

\* TalkBack;

\* Dynamic Type;

\* Android font scaling;

\* sufficient contrast;

\* semantic labels;

\* minimum touch targets;

\* reduced-motion support;

\* color-independent status communication;

\* screen-reader-friendly financial values.



\---



\# 37. MONETIZATION



The research proposes a freemium subscription model. 



\### Proposed model



\#### Free



Approximately:



\* 2–3 funds;

\* core calculation;

\* basic visualization;

\* basic transaction tracking.



\#### Premium



Potentially:



\* unlimited funds;

\* widgets;

\* advanced customization;

\* premium mascot/visual features;

\* biometric security;

\* advanced insights.



\---



\# 38. PRICING HYPOTHESIS



Research proposal:



```text

Monthly: \~$4.99

Annual: \~$29.99–$34.99

```



These are \*\*not final prices\*\*.



Status:



`VALIDATION REQUIRED`



The research itself frames the price as a proposed model rather than a proven market outcome. 



\---



\# 39. FREE EXPERIENCE PRINCIPLE



Do not make the free version useless.



The user must experience the core value before paying.



The free experience should answer:



> "Does this actually help me?"



Premium should answer:



> "I use this enough that I want the complete experience."



\---



\# 40. LOCALIZATION



The research recommends international expansion and identifies Spanish, German, French and Japanese as potentially valuable languages. 



However:



\### MVP



Start with English.



\### Architecture



Design for localization from the beginning.



Do not hard-code user-facing strings.



\---



\# 41. APP STORE STRATEGY



App Store presentation is a \*\*product acquisition system\*\*, not an afterthought.



The transcript explicitly compares App Store screenshots to YouTube thumbnails: users must first be convinced to download before retention matters. 



\---



\## 41.1 Store assets



Prepare:



\* app icon;

\* screenshots;

\* subtitle;

\* description;

\* preview video where appropriate;

\* keywords;

\* localized metadata.



\---



\# 42. APP STORE POSITIONING



Use user vocabulary.



Important terminology from the supplied research includes:



\* Sinking Fund

\* Fund

\* Bucket

\* Envelope

\* Savings Goal

\* Expense Planner







The exact final name remains:



`PROPOSED / VALIDATION REQUIRED`



\---



\# 43. SUCCESS METRICS



Primary funnel:



```text

Store impression

&#x20;     ↓

Store page view

&#x20;     ↓

Install

&#x20;     ↓

Onboarding started

&#x20;     ↓

First fund created

&#x20;     ↓

First calculation viewed

&#x20;     ↓

First contribution

&#x20;     ↓

Day-1 retention

&#x20;     ↓

Day-7 retention

&#x20;     ↓

Day-30 retention

&#x20;     ↓

Premium conversion

&#x20;     ↓

Subscription retention

```



\---



\# 44. CORE PRODUCT METRICS



Track:



\### Activation



\* first fund created;

\* first calculation viewed;

\* first contribution.



\### Engagement



\* funds/user;

\* contributions/user;

\* sessions;

\* widget adoption;

\* notification interaction.



\### Retention



\* D1;

\* D7;

\* D30;

\* D90.



\### Monetization



\* free → premium conversion;

\* monthly churn;

\* annual conversion;

\* revenue/user;

\* LTV.



\---



\# 45. DEVELOPMENT PHASES



The agent must not attempt to build everything simultaneously.



\---



\## PHASE 0 — Product/Agent Infrastructure



Build:



\* repository;

\* Git;

\* documentation;

\* Rules;

\* Workflows;

\* project-state system.



\*\*No major product UI yet.\*\*



\---



\## PHASE 1 — Technical Foundation



Build:



\* cross-platform project;

\* navigation;

\* environment;

\* storage;

\* domain architecture;

\* testing infrastructure;

\* design token infrastructure.



\---



\## PHASE 2 — Design System



Build:



\* typography;

\* colors;

\* spacing;

\* buttons;

\* cards;

\* inputs;

\* sheets;

\* navigation;

\* icons;

\* motion primitives.



\---



\## PHASE 3 — Financial Engine



Build and extensively test:



\* fund calculations;

\* schedules;

\* contribution calculations;

\* progress;

\* status;

\* transaction handling;

\* edge cases.



This phase must be independently testable.



\---



\## PHASE 4 — Core Fund Management



Build:



\* create fund;

\* edit fund;

\* delete/archive;

\* fund detail;

\* contribution;

\* withdrawal;

\* ledger.



\---



\## PHASE 5 — Onboarding



Build:



\* first-run experience;

\* first fund;

\* first-value flow;

\* contextual visual feedback.



\---



\## PHASE 6 — Dashboard



Build:



\* overview;

\* fund cards;

\* progress;

\* upcoming goals;

\* activity.



\---



\## PHASE 7 — Premium UX



Build:



\* animation system;

\* haptics;

\* micro-interactions;

\* transitions;

\* polished empty/error/success states.



\---



\## PHASE 8 — Mascot



Build:



\* mascot base;

\* expression system;

\* state library;

\* onboarding integration;

\* contextual states.



\---



\## PHASE 9 — Widgets



Build:



\* iOS widgets;

\* Android widgets;

\* deep links;

\* refresh strategy;

\* privacy states.



\---



\## PHASE 10 — Notifications



Build:



\* contextual reminders;

\* milestone notifications;

\* deadline notifications;

\* preferences.



\---



\## PHASE 11 — Monetization



Build:



\* entitlement architecture;

\* free limits;

\* premium;

\* subscription;

\* restore purchases;

\* paywall.



\---



\## PHASE 12 — Accessibility



Full accessibility audit.



\---



\## PHASE 13 — QA



Test:



\* iOS;

\* Android;

\* different screen sizes;

\* offline;

\* date transitions;

\* edge cases;

\* performance;

\* accessibility.



\---



\## PHASE 14 — App Store



Prepare:



\* icon;

\* screenshots;

\* metadata;

\* privacy documentation;

\* store listing;

\* subscription configuration.



\---



\# 46. TESTING REQUIREMENTS



Every feature must have acceptance criteria.



\---



\## 46.1 Financial engine



Minimum requirement:



> Every calculation must be deterministic and independently testable.



Test:



\* normal cases;

\* zero;

\* boundary dates;

\* leap years;

\* month-end;

\* missed contributions;

\* surplus;

\* withdrawals;

\* overfunding;

\* past deadlines.



\---



\## 46.2 UI



Test:



\* loading;

\* empty;

\* populated;

\* error;

\* offline;

\* accessibility;

\* large text;

\* dark/light modes if supported.



\---



\# 47. EDGE-CASE MATRIX



The implementation must explicitly consider:



```text

No funds

One fund

Many funds

Zero balance

Zero target

Completed fund

Overfunded fund

Past deadline

Today deadline

Tomorrow deadline

Very distant deadline

Missed contribution

Extra contribution

Withdrawal

Multiple transactions

Deleted fund

Restored fund

Invalid amount

Decimal amount

Large amount

Currency formatting

Timezone change

Daylight saving transition

Leap year

Month boundary

Year boundary

Offline device

Storage failure

Cloud sync conflict

Notification denied

Widget unavailable

Subscription expired

Purchase restored

App reinstalled

Device migration

Large accessibility font

Screen reader

Reduced motion

```



\---



\# 48. PERFORMANCE



The app should feel immediate.



Particular attention:



\* dashboard rendering;

\* fund calculations;

\* animations;

\* transaction updates;

\* widget generation;

\* storage operations.



Financial calculations must never block the UI unnecessarily.



\---



\# 49. SECURITY



Even with local-first architecture:



\* use secure platform storage where appropriate;

\* protect sensitive local data;

\* support biometric app lock if implemented;

\* avoid logging sensitive financial information;

\* never expose financial data in debug logs;

\* minimize permissions.



\---



\# 50. ANALYTICS \& PRIVACY



Analytics should be privacy-conscious.



Track product behavior such as:



```text

fund\_created

contribution\_added

fund\_completed

widget\_enabled

notification\_enabled

paywall\_viewed

subscription\_started

```



Avoid collecting unnecessary financial values.



Prefer:



```text

"contribution\_added"

```



over:



```text

"user\_added\_$1,237.48\_to\_vacation\_fund"

```



unless there is a clearly justified privacy-safe aggregation strategy.



\---



\# 51. DESIGN QUALITY STANDARD



The application should not be considered complete merely because:



```text

it compiles

\+

buttons work

```



Completion requires:



```text

Functional correctness

\+

Visual consistency

\+

Interaction quality

\+

Animation quality

\+

Accessibility

\+

Error handling

\+

Edge-case handling

\+

Cross-platform verification

```



\---



\# 52. ANTI-"VIBE-CODED" REQUIREMENTS



The transcript's central lesson is that AI makes basic implementation increasingly easy, so basic functionality alone does not differentiate an application. 



Therefore the application must avoid:



\* generic dashboards;

\* default component-library appearance;

\* arbitrary gradients;

\* inconsistent icons;

\* placeholder illustrations;

\* static interactions;

\* generic mascot art;

\* unconsidered empty states;

\* inconsistent spacing;

\* excessive rounded cards;

\* meaningless animation.



\---



\# 53. DESIGN INSPIRATION PROCESS



The team/agent should continuously study high-quality mobile applications.



The transcript specifically recommends exposure to strong app design resources such as Mobbin to study interactions, animations and icon choices. 



However:



> Inspiration ≠ copying.



The goal is to understand interaction patterns and quality standards, then develop an original visual language.



\---



\# 54. PRODUCT PERSONALITY



The product should feel:



> \*\*calm + optimistic + tactile + intelligent + trustworthy\*\*



Not:



> aggressive financial advisor.



Not:



> childish savings game.



Not:



> cold accounting software.



\---



\# 55. EMOTIONAL DESIGN



Important emotional moments:



\### First fund



"Now I know what I need."



\### First contribution



"I'm making progress."



\### 50%



"I'm halfway there."



\### Ahead



"I'm doing better than planned."



\### Completion



"I was ready."



These moments should be deliberately designed.



\---



\# 56. RETENTION LOOP



The primary behavioral loop should be:



```text

Create goal

&#x20;   ↓

See required contribution

&#x20;   ↓

Contribute

&#x20;   ↓

Visual progress

&#x20;   ↓

Receive contextual reinforcement

&#x20;   ↓

Return

&#x20;   ↓

Contribute again

&#x20;   ↓

Reach milestone

&#x20;   ↓

Complete goal

&#x20;   ↓

Create next goal

```



Widgets and notifications should support this loop rather than interrupt it.



\---



\# 57. NON-GOALS



The initial product must NOT attempt to become:



\* a bank;

\* an investment platform;

\* a full accounting system;

\* a tax application;

\* a credit-score application;

\* a debt management platform;

\* a complete monthly budgeting system;

\* an automated bank aggregator;

\* a financial advisor.



\---



\# 58. PRODUCT SCOPE PROTECTION



When considering a feature, ask:



\### Question 1



Does this directly improve sinking-fund planning?



\### Question 2



Does it strengthen the core value proposition?



\### Question 3



Does it increase complexity disproportionately?



\### Question 4



Can the product remain simpler without it?



If the answer to #4 is yes, defer it unless there is compelling evidence.



\---



\# 59. NON-NEGOTIABLE ANTIGRAVITY RULES



This is one of the most important sections.



The Antigravity agent must:



\### 1.



Treat this document as the canonical product specification.



\### 2.



Never rely on conversation memory for important product decisions.



\### 3.



Inspect the repository before modifying existing systems.



\### 4.



Reuse existing components before creating new ones.



\### 5.



Never create duplicate components with overlapping responsibilities.



\### 6.



Never create a new design pattern without checking the design system.



\### 7.



Never introduce inconsistent iconography.



\### 8.



Never modify financial calculations without tests.



\### 9.



Never silently change product requirements.



\### 10.



Never add bank synchronization without explicit authorization.



\### 11.



Never treat financial calculations as UI logic.



\### 12.



Never claim implementation is complete without verification.



\### 13.



Every meaningful feature must handle:



```text

loading

empty

success

error

offline

accessibility

edge cases

```



where applicable.



\### 14.



Animations must have a purpose.



\### 15.



Haptics must be intentional.



\### 16.



Mascot usage must be contextual.



\### 17.



Widgets must be treated as first-class product surfaces.



\### 18.



Notifications must provide user value.



\### 19.



Do not use guilt/shame-based financial messaging.



\### 20.



Do not use fake financial certainty.



\### 21.



Do not expose sensitive financial information through logs or analytics unnecessarily.



\### 22.



Preserve platform-specific conventions where appropriate.



\### 23.



Do not optimize implementation speed at the expense of maintainability.



\### 24.



Do not perform large architectural changes as part of an unrelated feature.



\### 25.



When requirements are ambiguous, inspect existing decisions before asking.



\### 26.



When existing decisions conflict, surface the conflict.



\### 27.



Do not silently overwrite established architecture.



\### 28.



Maintain documentation after meaningful implementation changes.



\### 29.



Maintain deterministic calculation tests.



\### 30.



Maintain a clean Git history.



\---



\# 60. DEFINITION OF DONE



A feature is \*\*not done\*\* merely because code exists.



A feature is done when:



```text

Requirements implemented

&#x20;       +

Existing architecture respected

&#x20;       +

Design system respected

&#x20;       +

Edge cases considered

&#x20;       +

Tests implemented

&#x20;       +

Tests pass

&#x20;       +

Accessibility considered

&#x20;       +

iOS behavior verified

&#x20;       +

Android behavior verified

&#x20;       +

UI visually reviewed

&#x20;       +

Documentation updated

&#x20;       +

Current project state updated

```



\---



\# 61. CHANGE MANAGEMENT



Any significant change to:



\* architecture;

\* financial logic;

\* monetization;

\* data privacy;

\* navigation;

\* design system;

\* product positioning;



requires a documented decision.



Create:



```text

docs/DECISIONS.md

```



with:



```text

Decision

Context

Alternatives

Chosen solution

Reason

Consequences

Date

Status

```



\---



\# 62. PRODUCT HYPOTHESES THAT MUST BE VALIDATED



The following should \*\*not\*\* be treated as guaranteed facts:



\* $4.99/month will convert well;

\* $29.99/year will be optimal;

\* widgets will materially increase retention;

\* mascot will materially increase conversion;

\* specific localization markets will outperform others;

\* 240 subscribers will produce the desired profit;

\* any specific App Store search volume;

\* any specific churn rate.



The supplied research presents these as strategic conclusions/projections, not guarantees. 



\---



\# 63. INITIAL BUSINESS TARGET



The supplied research uses:



> approximately $1,000/month net profit



as an initial financial objective and estimates approximately 240 active subscribers at $4.99 before platform revenue shares and other considerations. 



This should be treated as:



`BUSINESS TARGET / HYPOTHESIS`



not:



`ENGINEERING REQUIREMENT`.



\---



\# 64. MASTER PRODUCT PRINCIPLE



Everything in the application should ultimately reinforce this transformation:



```text

"I have a future expense I am worried about."



&#x20;                   ↓



"I know exactly what I need to save."



&#x20;                   ↓



"I can see my progress."



&#x20;                   ↓



"I know whether I'm on track."



&#x20;                   ↓



"I am prepared when the expense arrives."

```



That is the product.



\---



\# 65. FINAL PRODUCT NORTH STAR



If a feature does not contribute meaningfully to:



> \*\*making future irregular expenses feel predictable, manageable, visible and achievable\*\*



it should be questioned.



If a feature makes the product substantially more complicated without strengthening that experience, it should probably not be part of the MVP.



\---



\# 66. SOURCE-BASED DESIGN STRATEGY



The two supplied sources give us two complementary foundations.



\### Sinking-fund research



Provides:



```text

psychology

\+

market problem

\+

competitive gap

\+

core feature

\+

calculation

\+

manual ledger

\+

privacy/local-first

\+

monetization hypothesis

\+

retention mechanics

```



For example, the research explicitly identifies mental accounting, consumption smoothing and the need for a dedicated visual sinking-fund tool. 



\### Chris Ro transcript



Provides:



```text

competitive design philosophy

\+

animation

\+

interaction

\+

illustration

\+

mascot

\+

iconography

\+

widgets

\+

haptics

\+

visual polish

\+

App Store presentation

```



His core argument is that the ease of producing basic apps increases the importance of differentiation and polish. 



\*\*The combination is what we want.\*\*



Not just:



> "A useful finance calculator."



And not just:



> "A pretty app."



But:



> \*\*A psychologically coherent, mathematically reliable, visually distinctive, tactile sinking-fund product.\*\*






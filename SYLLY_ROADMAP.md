# Sylly Roadmap: Subscription & Spring 2027 Launch

_Last updated: November 23, 2026_

## Where Sylly is today

- **2,000+ downloads** since launch (approved March 5, 2026)
- **4.9★ from 52 ratings.** About 2.6% of people who download leave a rating, which is well above average.
- **Shows up in App Store search for "syllabus"**
- Current version: 1.0.5 (build 10). The app is completely free today.

**Resume line (use it now):** "Built and shipped Sylly, an AI syllabus scanner for iOS (SwiftUI, SwiftData, Vision OCR, Claude API behind a Cloudflare Worker): 2,000+ downloads, 4.9★ from 52 ratings."

---

## Goals

1. **Earn money** with a Pro subscription, without hurting the 4.9 rating.
2. **Get students using Sylly all semester, not just once.** Scanning is the setup. The real product is what happens in weeks 2–15.
3. **Launch before spring semester** (mid-January 2027).
4. **Grow the resume story:** StoreKit 2, WidgetKit, Live Activities, Screen Time APIs, an AI backend, real revenue and retention numbers.

---

## Do today (account setup, no coding)

- [ ] Accept the **Paid Apps Agreement** and fill in **tax and banking info** in App Store Connect. Without this, you can't test or sell any purchases.
- [ ] Join the **App Store Small Business Program**. It lowers Apple's cut from 30% to **15%**.
- [ ] Request the **Family Controls distribution entitlement**, which Deadline Lock needs. Approval can take weeks.
- [ ] Write down your **App Analytics** numbers: downloads per month (how big the August spike was), product page conversion rate, Day 1/7/28 retention, active devices in the last 30 days.

---

## Pricing

| Plan | Price | Notes |
|---|---|---|
| **Free** | $0 | 2 syllabus scans, plus everything that brings users back (reminders, calendar export, widget, weekly preview, check-offs, streaks, garden) |
| **Pro Monthly** | **$4.99/mo** | Mostly there to make the yearly plan look like the better deal |
| **Pro Yearly** | **$19.99/yr**, 7-day free trial | **The main plan.** Highlight it and show it as "$1.67/month" |
| **Pro Lifetime** | **$39.99 one-time** | For students who don't want a subscription. You get the money upfront. |

**Why these prices**
- **One semester of monthly (about $20) costs as much as a full year**, so even students who only need Sylly for one semester should pick yearly.
- **Competitors charge more** (Ahead $9.99/mo or $29.99/yr, Due Gooder $8.99/mo). Sylly costs less and has a higher rating.
- **Lifetime is about 2× yearly.** A lower price would take too many sales away from yearly.
- **Scans cost you about 2¢ each** (Claude Haiku 4.5: $1 per million input tokens, $5 per million output). A heavy user costs about $0.20 a year, so unlimited scans and a lifetime plan are safe. Check this against your real spend in the Anthropic console.
- **No 6-month plan.** More than 3 paid options makes people hesitate. Put the trial on yearly only.
- You can raise prices later. Lowering them upsets people who already paid.

**What's in Pro:** unlimited syllabus scans, scanning any course document, semester overview, exam study reminders, grade tracker, Deadline Lock, AI step breakdown, extra garden themes, alternate app icons.

**How to set it up in App Store Connect**
- Monthly and Yearly go in **one subscription group**. Lifetime is a separate **non-consumable** purchase.
- Someone is Pro if they have an active subscription **or** own lifetime. Check both with `Transaction.currentEntitlements`.
- The paywall must show the price, the renewal period, **Restore Purchases**, and **Terms and Privacy links**, or Apple will reject it.

**Existing users get Pro free, permanently**
- Use `AppTransaction.shared.originalAppVersion` to check when someone first downloaded the app.
- ⚠️ On iOS this value is the **build number** (`CFBundleVersion`), not the version number. Anyone whose original build is **≤ 10** was an existing user.
- ⚠️ In the sandbox it returns `"1.0"`. Test this case on purpose.

---

## Competition

At least 10 other AI syllabus apps exist, most launched in 2025–26: **Ahead, Due Gooder, SyllySync, Semester Flow, CourseLink, Syllabot, Semora, StudyKit, ProPlan Scholar, Syllabus AI.**

- **Features competitors already have, so you need them too:** widgets with check-off, grade weights, daily summaries, reminders.
- **What only Sylly would have:** Deadline Lock, focus sessions with a Lock Screen timer, "What should I do now?", start-by dates, the semester garden, the weekly on-time streak, and **the 4.9★ rating.**
- In a crowded list of similar apps, students pick the one with the best rating. **Protecting the rating is protecting your lead.**

---

## Full feature list, ranked

⭐ = your idea · **Days** = estimate for one person full-time · **Total** = running total of days

### Tier 1: Required to launch
| # | Feature | Days | Total | Plan |
|---|---|---|---|---|
| 1 | Version the SwiftData models (`VersionedSchema` + migration plan) so updates don't wipe users' courses | 0.5 | 0.5 | — |
| 2 | ⭐ StoreKit 2: 3 plans, paywall (`SubscriptionStoreView`), Restore, Terms links | 3 | 3.5 | — |
| 3 | Existing users get Pro free (original build ≤ 10) | 0.5 | 4 | — |
| 4 | Worker: verify purchases, 2 free scans tracked with **DeviceCheck** (survives reinstall), failed scans don't count, daily cap of about 25 scans per device | 2 | 6 | — |
| 5 | Guaranteed JSON from Claude (tool use or structured output in the Worker) | 0.5 | 6.5 | — |
| 6 | Onboarding: 3 screens, notification permission request with an explanation, "2 free scans" | 1.5 | 8 | Free |
| 7 | Analytics (TelemetryDeck): scan → review → paywall → purchase, weeks active | 0.5 | 8.5 | — |
| 8 | Unit tests (Swift Testing) for parsing, dates, reminder timing, who counts as Pro. Remove `TestClaudeView` | 1.5 | 10 | — |
| 9 | App Store page: subtitle and keywords, new screenshots, **"Spring Semester Setup" In-App Event (submit by about Dec 12)** | 1 | 11 | — |

### Tier 2: Reasons to use Sylly all semester ⭐
| # | Feature | Days | Total | Plan |
|---|---|---|---|---|
| 10 | Quick, satisfying check-off: haptics, animation, swipe to complete, bigger celebration for exams and projects | 1 | 12 | Free |
| 11 | Progress rings for each course and the whole semester | 1 | 13 | Free |
| 12 | ⭐ Weekly preview notification (Sunday) | 1 | 14 | Free |
| 13 | ⭐ Semester overview: every week of the term with heavy weeks marked | 2.5 | 16.5 | Pro |
| 14 | ⭐ Widget with a **Mark done** button | 3 | 19.5 | Free |
| 15 | Calendar events and notifications open Sylly (`sylly://assignment/<id>`), Mark done action on notifications | 1 | 20.5 | Free |
| 16 | "Did you finish it?" check-in the morning after a due date | 0.5 | 21 | Free |
| 17 | Exam study reminders, 5 and 2 days before | 1 | 22 | Pro |
| 18 | ⭐ "What should I do now?" button that shows only the most urgent task | 1 | 23 | Free |
| 19 | No-shame overdue handling: "Move to tomorrow?" in one tap, no growing red list | 0.5 | 23.5 | Free |

### Tier 3: Features no competitor has ⭐
| # | Feature | Days | Total | Plan |
|---|---|---|---|---|
| 20 | ⭐ Focus sessions: 15/25/45-minute timer on the Lock Screen and Dynamic Island (Live Activity) | 3.5 | 27 | Free |
| 21 | ⭐ "Start by" dates that estimate how long a task takes (ADHD-friendly) | 1.5 | 28.5 | Free |
| 22 | ⭐ **Deadline Lock:** block distracting apps until the assignment is checked off (Screen Time APIs, custom block screen) | 6 | 34.5 | Pro |
| 23 | Weekly on-time streak. Weeks with nothing due don't break it. | 1.5 | 36 | Free |
| 24 | ⭐ Semester garden: each finished assignment grows a plant in the course's color. It never wilts. | 3.5 | 39.5 | Free, extra themes Pro |
| 25 | ⭐ AI breaks big assignments into steps with mini deadlines | 2.5 | 42 | Pro |
| 26 | Scan any course document (project sheets, rubrics, study guides) into an existing course | 2.5 | 44.5 | Pro |
| 27 | ⭐ Grade tracker: "you need 78% on the final for an A" + prompt change to extract numeric weights | 5 | 49.5 | Pro |

### Tier 4: Nice extras
| # | Feature | Days | Total | Plan |
|---|---|---|---|---|
| 28 | Export to Google Calendar (.ics file) | 1 | 50.5 | Free |
| 29 | Import a syllabus from the Share Sheet (Mail, Files, Canvas PDFs) | 1.5 | 52 | Free |
| 30 | Alternate app icons | 0.5 | 52.5 | Pro |
| 31 | Siri and Shortcuts: "What's due this week?" | 1.5 | 54 | Free |

### Tier 5: Only useful later in the semester (not cut)
| # | Feature | Ships |
|---|---|---|
| 32 | Finals view: every exam and final project in one countdown | April |
| 33 | Semester recap share card ("Sylly Recap", not "Wrapped") | May |
| 34 | "Start new semester" flow: archive old courses | May, ready for August |

### Tier 6: Large projects after launch
| # | Feature | Why later |
|---|---|---|
| 35 | iCloud sync (SwiftData + CloudKit) | Requires every model property to be optional or have a default. Do it after #1. |
| 36 | ⭐ Share a course with classmates | Needs a backend for share links. Keep it **free**, since it's how new users find you. |
| 37 | ⭐ Canvas import | Each school's admin has to approve API access |
| 38 | Rescan to update only what changed | Hard to get right |

---

## Release plan

You have about **25–30 build days** between now and the last safe submission date (around Jan 5), after Thanksgiving, Apple's holiday review slowdown (about Dec 23–27), TestFlight testing, and job applications. Everything above is about **54 days**, so ship in two releases and keep going down the list:

| Release | Submit by | What's in it |
|---|---|---|
| **1.1** | **About Dec 12** | Tier 1 (#1–9) and the core of Tier 2 (#10–14) |
| **1.2** | **About Jan 5** | #15–21, plus #22–24 if they're solid and the entitlement is approved |
| **1.3 "Grades"** | February | #25–27: grade tracker, step breakdown, scanning other documents |
| **1.4 "Midterms Focus"** | Early March | Anything left from Tier 3 and Tier 4 |
| **1.5** | April–May | Tier 5 |

**Rules**
- **1.2 never holds back 1.1.** Anything that isn't ready goes into the next release.
- The order is set so that wherever you stop, what ships is complete.
- The grade tracker loses nothing by shipping in February, because students don't have grades in January.

---

## Daily loop to design around

**Sunday preview → "What should I do now?" → focus session (apps locked, timer on the Lock Screen) → check it off → haptic, ring fills, garden grows, streak continues → apps unlock**

## Engagement rules

- **Reward finishing real work, not opening the app.** No daily-open streaks.
- **No guilt.** No wilting plants, no "you missed 3 assignments 😢", no "your streak is about to break!"
- **No leaderboards or grade comparisons** with friends.
- **Keep the main rewards free** (check-offs, rings, streak, basic garden). Charge only for extras.
- **Checking off has to be quick** (widget, notification, swipe, morning check-in). Every other engagement feature depends on it.
- Describe Sylly as **"ADHD-friendly,"** never as treating or managing ADHD (no medical claims).

---

## Growth & App Store search

Revenue = **downloads × conversion**. Downloads are the bigger lever right now.

- [ ] **Keep "Syllabus Scanner" in the app name.** Changing the name is the fastest way to lose your ranking.
- [ ] Use the subtitle and keyword field for searches you don't rank for yet: *assignment planner, homework tracker, due dates, college planner*. Don't repeat "syllabus" there.
- [ ] **In-App Event "Spring Semester Setup"** running about Jan 5–25. Submit by about Dec 12, since Apple reviews events before they go live.
- [ ] New screenshots: semester overview, widget, focus session, garden.
- [ ] **TikTok and Instagram:** 10-second "scan a syllabus → every deadline appears" videos. Post several in the first 2 weeks of January.
- [ ] Post in r/college and school subreddits ("I built this for myself"), and share in class group chats.
- [ ] Track where you rank for "syllabus" each week (Appfigures or AppTweak free tier).
- [ ] **Push for lots of downloads in the first 2 weeks of January.** A download spike then can lift your ranking for the rest of the semester.

## Protecting the 4.9★ rating

- [ ] Existing users get Pro free
- [ ] Free tier stays useful (2 scans + all reminder and engagement features)
- [ ] Ask for reviews after happy moments (successful scan, a week with everything done, a 4-week streak), **never right after showing the paywall**
- [ ] Reply to every review in App Store Connect, especially negative ones about the paywall

---

## Revenue estimate (rough guesses; update with real data)

- Spring downloads (Jan–May): about **1,500**
- Share who start paying: **3–5%** → about **45–75 paying users**
- Plan mix 60% yearly / 25% lifetime / 15% monthly (about 3 months) → about **$24 per paying user before Apple's cut, about $20.60 after the 15% fee**
- **Spring estimate: about $930–1,550**
- **First full year (spring + fall): about $2,500–5,000**

Doubling downloads roughly doubles these numbers.

## Numbers to track

- **Average weeks per semester a user opens Sylly** (the main number to improve). Target: 10+ weeks with at least one open.
- Share of downloads that start a scan, finish review, and see the paywall
- Paywall → trial → paid conversion rates
- Day 1, 7, and 28 retention
- Rating and number of reviews
- Ranking for "syllabus"

---

## Technical notes

- **Schema first.** `SyllyApp.swift:33` uses a plain `.modelContainer(...)` with no versioning. Freeze the current models as `SchemaV1` before adding anything.
- **Free scan limit:** `identifierForVendor` (`ClaudeService.swift:45`) resets on reinstall. Use DeviceCheck's 2 per-device bits, which Apple stores and the Worker can read and write.
- **JSON parsing:** stop stripping `` ```json `` fences. Use tool use or structured output so the reply always matches `ParsedSyllabus`.
- **Deadline Lock:** `FamilyControls` (`.individual` authorization), `ManagedSettings`, `DeviceActivity`, plus a Shield Configuration extension. The app picker returns hidden tokens, so Sylly never sees which apps were picked, which is good for privacy.
- **Widget:** WidgetKit with App Intents for the interactive Mark done button (iOS 17+).
- **Focus session:** ActivityKit Live Activity (Lock Screen + Dynamic Island).
- **Calendar links:** set `EKEvent.url` to `sylly://assignment/<id>` in `CalendarService`.
- **Share cards:** `ImageRenderer` + `ShareLink`.
- **Garden:** SwiftUI `Canvas`.

---

## Resume lines to aim for

- "Added StoreKit 2 subscriptions with purchases verified on the server (Cloudflare Worker + DeviceCheck), earning $X in the first semester at Y% conversion."
- "Redesigned the app around weekly habits (widgets, Live Activities, streaks), raising average weeks active from A to B."
- "Built a focus mode that blocks distracting apps until assignments are done, using Apple's Screen Time APIs."

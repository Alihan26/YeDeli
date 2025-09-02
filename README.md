# YeDeli

## How to run everything

### Prerequisites
- Xcode 15+ (latest recommended)
- Node.js 18+
- Local PostgreSQL 15+ and Redis 7+

### 1) Run the backend (API)
```
cd backend
cp env.example .env
npm install
# Ensure Postgres and Redis are running locally
# Development mode (mock endpoints, no DB required)
npm run dev
# Or full server (requires DB/Redis running)
npm start
```
- Health check: `http://localhost:3001/health`

### 2) Run the iOS app
1. Open `YeDeli.xcodeproj` in Xcode
2. Pick an iPhone simulator
3. Press Run (⌘+R)

Notes:
- The app currently uses local sample data. API wiring is the next step.
- Default API base URL for local dev: `http://localhost:3001`

---

Vision and positioning
What YeDeli is: A preorder-and-pickup marketplace for homemade and small-batch food by non-restaurant cooks. Hyperlocal, community-first, affordable, culturally authentic.
What YeDeli is not: On-demand delivery, restaurants, ghost kitchens. Start with pickup only; add optional delivery later if it proves necessary.
Core “why”: Give home cooks (especially expats and hobby caterers) flexible income and give eaters authentic, affordable food they can’t get easily elsewhere.
2. Target users and core use cases

Buyers: Students, expats, busy families, foodies looking for authentic or specialty cuisines, people with dietary needs (halal, vegetarian, gluten-free).
Cooks: Home cooks, expat parents, retirees, culinary students, small caterers without a storefront.
Signature scenarios:
Batch drops: “Kimbap on Friday, pickup 17:00–19:00, max 40 rolls, preorder closes Wednesday.”
Weekly menus: “Monday: lasagna; Thursday: biryani; Sunday: dumplings.”
Group order: One buyer coordinates a larger order for friends/classmates with a bulk discount.
Meal plan subscriptions: Preorder 3 meals/week from a favorite cook for a month.
3. Core product experience (MVP)

For buyers
Map + list of upcoming drops near you with filters by cuisine, dietary, pickup day/time, price.
Preorder with clear pickup window, portion size, allergens, reheating/storage instructions.
Pay in-app; receive a pickup code; get reminders.
Ratings/reviews after pickup; tipping optional.
For cooks
Create a dish with photos, story, price, portion size, allergens, lead time, capacity, pickup window.
Batch scheduling and cutoff times; minimum order sizes; automatic “sold out.”
Simple chat with buyers; pickup check-in via QR code; waitlist when sold out.
Cost calculator: ingredient cost, packaging, time; suggested price and margin.
Auto-generated shopping list per batch and label template.
Platform
Payments (Stripe/Apple Pay/Google Pay; in Switzerland, add TWINT).
Notifications, receipts, basic analytics (views, conversion, on-time pickup, rating).
4. Proximity hierarchy: does it make sense?

Why it helps
Hyperlocal trust and convenience; shorter trips; fewer no-shows; easier pickup coordination.
Reduces overwhelmed new cooks and keeps quality high.
Possible drawbacks
Low-density areas may starve new cooks of demand.
Rare cuisines may need a wider reach.
Can feel punitive if a cook is dependable but new.
Recommendation
Default radius for new cooks: 2 km for first 2–3 batches or first 10 fulfilled orders.
Auto-expand rules:
If orders < X after 7–10 days, expand to 5 km automatically.
If rating ≥ 4.7 and ≥ 90% on-time for last 10 orders, expand to 10 km.
Rare cuisine or low local supply triggers wider discovery.
Buyer controls:
Buyers can expand search radius manually anytime.
“I’m willing to travel farther for this cuisine” preference saves across sessions.
Safety/privacy:
Show approximate location (block-level) until purchase. Exact address revealed post-payment.
Alternative to hard locks:
Keep full radius but rank results by distance and reliability; new cooks appear hyperlocally first but are still discoverable farther away via filters.
5. Safety, trust, and compliance

Identity and verification
KYC for cooks (ID + selfie match), minimum age, bank account verification.
Address verification. Option to choose a safe pickup spot near home rather than publishing a home address.
Food safety
Require a short food-hygiene onboarding course and quiz.
Mandate ingredient list, allergen flags, prep date/time, storage and reheating guidance on labels.
Provide printable labels; sample: cook name and address, dish name, ingredients, bold allergens, prep date/time, consumption-by date, storage instructions.
Legal reality check (Switzerland)
Food laws: Swiss Foodstuffs Act (LMG), Foodstuffs and Commodities Ordinance (LGV), Hygiene Ordinance (HyV), allergen disclosure rules. Requirements may vary by canton; many home-based sellers must register with the cantonal food authority and follow hygiene and labeling standards.
Immigration/work status: Some dependents and students may be restricted from gainful employment. Selling food is typically gainful employment. Include a permit check in onboarding and clear guidance; do not onboard cooks who cannot legally work.
Taxes and VAT: Income is taxable; provide annual earnings statements. VAT registration may be required at higher turnover (e.g., > CHF 100k).
Insurance: Offer or require product liability insurance per order or as a monthly micro-policy.
Data privacy: Comply with Swiss FADP and GDPR where applicable.
Include clear Terms: You are a marketplace; cooks are independent sellers responsible for compliance.
Community safety
Fraud prevention, dispute resolution, refunds on safety issues, no cash-only transactions, no on-site dining.
Pickup codes; no entry into private homes; recommended public handover points.
6. Pricing and business model

Revenue streams
Commission per order (e.g., 12–18%).
Buyer service fee (small, transparent).
Optional subscription for cooks (reduced commission, analytics, discovery boosts).
Packaging store/partners, ingredient marketplace affiliates.
Insurance pass-through fee.
Incentives
Referral credits for both sides.
Early-bird discounts; group-buy discounts for bulk orders.
7. Policies and operations

Cancellations/refunds
Buyer can cancel free until cook’s shopping cutoff; after that, partial refund only unless safety issue.
No-show policy: order forfeited after window; repeated no-shows may trigger account flags.
SLA for cooks
On-time readiness rate tracked; late penalties reduce search ranking temporarily.
Content and moderation
Disallow risky items (e.g., raw or undercooked items without warning), alcohol, tobacco, or anything illegal.
8. Growth and go-to-market

Start small, hyperlocal pilots around universities and expat hubs (ETH/UZH, EPFL/UNIL, Geneva/Lausanne).
Community ambassadors within diaspora groups (Korean, Indian, Turkish, Chinese, Middle Eastern, etc.).
“Taste drops” events: coordinated platform-wide cuisine weeks with featured cooks.
Partnerships: ethnic grocery stores for ingredient discounts; packaging suppliers; student associations.
Social proof: creator-style profiles, stories behind dishes, high-quality photos.
9. Product differentiation ideas

Group order and pickup consolidation: one person grabs multiple friends’ orders.
Ingredient pre-buy assist: cooks set a minimum threshold; order only proceeds if threshold is met by cutoff.
Reusable container deposit wallet; discounts for BYO containers if local rules allow.
Dietary certifications: halal/kosher/vegan—self-attestation plus optional third-party verification badge.
Translation layer: automatic translation for menus and messages between cook/buyer languages.
Subscriptions: weekly “chef’s choice” boxes; pause/skip anytime.
Followers and notifications: follow favorite cooks; get alerts for new drops.
Meetup-safe handover points: map of recommended public pickup spots.
10. Analytics and KPIs

Supply: new cooks activated/week, time to first batch, batches per cook/month.
Demand: views-to-order conversion, orders per buyer/month, repeat rate.
Reliability: on-time readiness, pickup success rate, cancellations/no-shows.
Quality: average rating, complaint rate, food safety incidents (target zero).
Unit economics: take rate, payment fees, insurance cost, CAC vs LTV.
11. MVP scope to build first

Roles: buyer and cook accounts; KYC for cooks.
Listings: dish + batch scheduling + capacity + cutoff.
Discovery: map/list with filters, default 2 km radius and manual override.
Checkout: prepayment, pickup code, receipts; integrate Stripe/Apple/Google Pay; TWINT for Switzerland.
Messaging and notifications.
Ratings/reviews.
Basic dashboards for cooks (sales, upcoming pickups) and buyers (orders, pickups).
Legal/compliance: cook onboarding checklist, allergen labeling requirement, terms, privacy.
12. Roadmap after MVP

Radius expansion algorithm and ranking improvements.
Insurance integration and “YeDeli Verified” training badge.
Group orders, waitlists, and subscription plans.
Packaging deposit wallet and reusable options.
Delivery experiments via third-party couriers once pickup works reliably.
Advanced analytics for cooks (profit, repeat customers, cohort retention).
Ingredient marketplace partnerships and bulk-buy tools.
13. Quick validation plan (pre-code)

Concierge test in one neighborhood:
Recruit 10 cooks via expat groups and student orgs; collect drops via a form.
Publish a simple landing page and WhatsApp/Telegram channel.
Take orders via Typeform + Stripe/TWINT links; distribute pickup instructions manually.
Measure demand, no-shows, prep issues, pricing fit, and feedback.
Use learnings to refine policies, pricing, and the proximity model before coding.
Final word on the proximity hierarchy

It makes sense as a default to seed trust and convenience. Avoid a hard gate that starves supply; combine it with:
Auto-expansion when demand is low.
Buyer-controlled radius filters.
Ranking that prioritizes distance and reliability over strict exclusion.







What about the Levels:
Core value of levels

Trust: Levels signal reliability (on-time, safe, well-rated). Buyers feel safer trying someone new.
Market shaping: New cooks start hyperlocal to avoid overwhelm and reduce no-shows; proven cooks earn wider reach.
Incentives: Clear, fair milestones nudge good behaviors (prep on time, label allergens, avoid cancellations).
Operations: Levels cap complexity (orders, concurrent batches) until the cook demonstrates they can handle more.
How leveling up helps cooks (tangible benefits)

More demand
Larger discovery radius and ranking boosts.
Higher caps: more portions per week and more simultaneous “drops.”
Access to group orders, subscriptions, and corporate/campus bulk orders.
Better economics
Lower commission at higher levels.
Faster payouts (T+3 days → next day → instant for a small fee at top tiers).
Packaging discounts or credits; optional liability insurance included/discounted at higher tiers.
Better tools and support
Advanced scheduling (recurring drops), waitlists, pre-order thresholds (only cook if X orders).
Analytics (repeat rate, dish performance, margin calculator).
Dedicated support and “spotlight” promotions at top tiers.
Stronger brand
Badges (Verified Hygiene, Community Favorite).
Followers get alerts for new drops; featured in cuisine collections.
Example level ladder (simple MVP version)

L0 Setup (not listed)
Do: KYC + address verify, bank details, short hygiene tutorial + allergen checklist.
L1 Local Cook
Default when approved.
Discovery radius: ~2 km.
Capacity: 1 live batch at a time; up to ~30 portions/week.
Features: basic listing, prepayment, pickup codes.
Commission: base (e.g., 16–18%).
L2 Neighborhood Cook
Requirements: ≥10 completed orders, rating ≥4.6, on-time readiness ≥90%, 0–1 seller cancellations in last 10; allergen labels on 100% of items.
Discovery radius: up to 5 km.
Capacity: 3 simultaneous batches; ~80 portions/week.
Features: group orders, basic analytics, ranking boost in local results.
Commission: -1–2% vs base; faster payouts (e.g., T+2/T+1).
L3 City Cook
Requirements: ≥50 completed orders, rating ≥4.7, on-time ≥94%, cancellation ≤2% (rolling 30 orders); completes “Food Safety Lite” quiz; verified pickup spot set.
Discovery radius: 10–15 km or citywide.
Capacity: 5 simultaneous batches; ~200 portions/week.
Features: subscriptions, pre-order thresholds, waitlists, reusable container wallet option.
Perks: packaging discount, included micro-liability coverage (where available), bigger ranking boost.
Commission: -2–4% vs base; next-day or instant payout option.
L4 Pro / Verified
Requirements: ≥200 completed orders (or canton registration/inspection where required), rating ≥4.8, zero safety incidents, cancellation ≤1% (rolling 90 orders).
Discovery: citywide + cuisine spotlight; eligible for campus/corporate drops.
Capacity: ~400 portions/week; pop-up event slots.
Perks: lowest commission, instant payouts, dedicated support, promo features, partner deals.
Badge: “YeDeli Pro” + “Verified Hygiene” (docs/training).
Key metrics to drive leveling (keep it transparent)

Reliability Score (rolling window, e.g., last 30–50 orders):
On-time readiness rate.
Seller cancellation rate (heavy penalty).
Average rating and complaint rate (1–2 star).
Allergen/label compliance.
Volume: completed orders or distinct buyers (prevents gaming with tiny orders).
Compliance: training completed, documentation (where required).
Fairness, flexibility, and edge cases

Buyer control: Buyers can always expand search radius manually; rare cuisines surface beyond default radius.
Auto-expansion safety valve: If a cook gets <X views or <Y orders in 10 days, temporarily widen their radius to test demand.
Fast-track: If a cook uploads canton registration/food handler proof or references from another platform, start at L2.
Rolling windows and forgiveness: Levels adjust based on recent performance; occasional issues don’t nuke a level.
Anti-gaming: Block self-orders, detect duplicate cards/phones, rate-weight only verified pickups.
UX guidance for cooks

Always-on progress panel: “You’re 3 orders and a 4.7+ average away from L2. Keep on-time rate above 90% this week.”
Clear benefits preview: “Unlock 5 km radius and group orders at L2.”
Playbooks: In-app tips to improve on-time rate, labeling templates, batch planning calculator.
What to implement first (MVP)

Start with 3 levels (L1/L2/L3) to keep complexity down.
Benefits to ship first: radius expansion, capacity limits, ranking boosts, basic analytics, small fee reduction and faster payout at L2/L3.
Metrics: on-time, cancellations, ratings (simple, auditable).
Progress UI + clear policy docs.
Bottom line
Levels matter because they turn trust into concrete growth: more visibility, more orders, better tools, and better margins. For buyers, they reduce risk. For YeDeli, they keep quality high while scaling supply.
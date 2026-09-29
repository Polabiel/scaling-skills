---
name: hm-conversion
description: Conversion-focused product and UX design guidance for hm-designer. Use when designing, reviewing, or modifying interfaces that influence acquisition, activation, signup, trial, upgrade, checkout, lead capture, onboarding, pricing, CTAs, forms, modals, or other customer conversion paths. Treat unnecessary interaction friction as a conversion risk and require explicit justification for friction that affects the primary action.
---

# HM Conversion

## Purpose

Make conversion a first-class design constraint without reducing design to aggressive growth tactics.

This skill complements `hm-designer`:
- `hm-designer` protects visual quality, hierarchy, consistency, responsiveness, and implementation fidelity.
- `hm-conversion` evaluates whether the design makes the intended customer action easy to understand and execute.
- `hm-ux-flow` evaluates the broader cognitive and interaction flow.

When a change affects a conversion path, apply all three lenses.

## Core principle

**Do not add friction at the moment of intent without a clear reason.**

A UI can be visually polished and technically correct while still creating conversion friction. The job is to identify that friction before shipping.

Think in this sequence:

`attention → comprehension → confidence → action`

Every unnecessary interaction between these stages is a potential abandonment point.

## Hard rules

### 1. Primary action must be reachable without unnecessary scrolling

For high-intent surfaces such as:
- signup
- checkout
- upgrade
- purchase
- trial activation
- lead capture
- pricing selection
- confirmation of a commercial action

the primary CTA and the information required to make the decision should be visible or immediately reachable.

**Do not make the user scroll inside a modal merely because the content does not fit the viewport.**

Bad pattern:
- modal opens
- important content extends below the viewport
- user must scroll inside the modal to discover the CTA
- the CTA is not available at first glance

Preferred patterns:
- reduce non-essential content
- restructure the hierarchy
- use progressive disclosure
- move secondary information elsewhere
- make the modal responsive to the viewport
- keep the CTA in a persistent footer when appropriate
- split a genuinely complex task into explicit steps

Exception:
Internal scrolling can be appropriate when the content itself is necessary and cannot reasonably be condensed, such as legal terms, long lists, advanced configuration, or genuinely complex workflows. Even then, keep the primary action and navigation model obvious.

### 2. Never confuse visual completeness with conversion quality

A design is not better merely because it contains more information.

Before adding UI, ask:
- Does this help the user decide?
- Does this reduce uncertainty?
- Does this increase trust?
- Does this help the user complete the intended action?

If not, consider removing it, collapsing it, or moving it out of the critical path.

### 3. Minimize interaction cost

For conversion-critical actions, inspect:
- number of clicks/taps
- amount of typing
- scrolling required
- context switching
- repeated information
- unnecessary confirmations
- hidden CTAs
- disabled states with unclear causes
- fields that are not required for the immediate goal

Do not optimize for the theoretical minimum number of interactions at the expense of clarity or trust. The goal is **low unnecessary friction**, not blindly fewer steps.

### 4. Preserve decision context

The user should understand:
- what they are doing
- why they are doing it
- what happens next
- what the primary action will cause

Avoid interfaces where the user must close a modal, remember information, navigate elsewhere, and return to complete the decision.

### 5. Mobile is a conversion surface, not a smaller desktop

For mobile:
- assume less vertical space
- test modal height
- check whether the CTA remains accessible
- avoid nested scrolling where possible
- ensure keyboard interaction does not hide the action
- verify sticky/fixed CTAs do not obscure content
- check tap target sizes
- test the complete flow, not only the initial viewport

## Conversion friction checklist

When reviewing a design, explicitly check:

### Visibility
- Is the primary CTA visible?
- Is the value proposition visible?
- Is the next action obvious?
- Is important pricing or commitment information visible before action?

### Friction
- Does the user need to scroll to act?
- Does the user need to open another element to understand the decision?
- Are there unnecessary fields?
- Are there unnecessary steps?
- Is there a nested scroll container?
- Is there a modal inside another modal?
- Is the user forced to repeat information?

### Trust
- Is the action understandable?
- Are important costs, commitments, limitations, or consequences clear?
- Are errors recoverable?
- Does the UI feel predictable?

### Hierarchy
- Is one action clearly primary?
- Are secondary actions visually subordinate?
- Does decorative content compete with the CTA?
- Is important information buried below low-value content?

## How to report a conversion issue

Do not merely say "this UX is bad."

State:

1. **Observation** — what the interface currently does.
2. **Friction** — what extra effort the user must perform.
3. **Conversion risk** — how that friction can interrupt the intended action.
4. **Recommendation** — the smallest design change that removes or reduces the friction.
5. **Validation** — how to verify the change in the actual viewport/device.

Example:

> **Observation:** The upgrade modal is taller than the viewport and the CTA is below the fold.
>
> **Friction:** The user must scroll inside the modal before they can continue.
>
> **Conversion risk:** The primary action is separated from the initial decision context, creating an unnecessary interaction at a high-intent point.
>
> **Recommendation:** Reduce secondary content and keep the CTA visible in a persistent modal footer. If all content is mandatory, split the flow into explicit steps.
>
> **Validation:** Test at the target desktop and mobile viewport sizes and verify that the user can understand the offer and reach the primary CTA without accidental nested scrolling.

## Severity

Use these labels descriptively, not as scores:

- **Blocker:** The primary conversion action is inaccessible, broken, obscured, or effectively hidden.
- **High:** Significant unnecessary friction exists directly before the intended conversion action.
- **Medium:** Friction or hierarchy problems may slow comprehension or action but do not prevent completion.
- **Low:** Minor polish opportunities with limited effect on the critical path.

## Required review behavior for hm-designer

When `hm-designer` reviews a conversion-related screen:

1. Identify the intended user action.
2. Identify the primary CTA.
3. Determine whether the CTA and decision-critical information are accessible at the initial viewport.
4. Inspect every scroll container, especially modal and drawer scroll areas.
5. Check mobile separately.
6. Identify unnecessary friction.
7. Recommend the smallest change that preserves visual quality while reducing friction.
8. Do not claim that a change will increase conversion unless supported by measured evidence. Use language such as "conversion risk", "friction", or "hypothesis" when evidence is unavailable.

## Anti-patterns

Flag these when relevant:

- CTA hidden below modal scroll
- nested scrolling in conversion-critical dialogs
- excessive form fields before the value is established
- low-contrast or ambiguous primary CTA
- multiple competing primary CTAs
- important price/commitment information hidden behind interaction
- unnecessary confirmation screens
- destructive or commercial actions with unclear labels
- required information mixed with optional information without distinction
- promotional copy that overwhelms the actual action
- desktop layout that becomes unusable on mobile
- sticky UI that covers the CTA or form fields
- loading states that provide no feedback during a high-intent action

## Evidence discipline

Conversion advice must distinguish between:
- established usability constraints
- design heuristics
- product assumptions
- measured analytics
- A/B test evidence

Never invent a conversion uplift percentage.

If analytics are available, ask for or inspect:
- modal open → CTA click rate
- CTA click → completion rate
- form start → completion rate
- step-by-step drop-off
- mobile vs desktop conversion
- error rate
- time to completion

Use measured product data to validate hypotheses whenever possible.


## Evidence-backed conversion principles

Use these as **evidence-backed heuristics**, not universal laws. Effects depend on product, audience, device, intent, traffic source, and implementation. Validate consequential recommendations with the product's own analytics or experiments.

### 1. Reduce unnecessary checkout complexity

Baymard's 2026 checkout research reports that 17% of US online shoppers said they had abandoned an order in the previous quarter because the checkout was too long or complicated. Its benchmark found an average of 23.48 form elements displayed by default, while its usability research found many checkouts can be reduced to roughly 12–14 elements (7–8 actual fields).

**Design implication:** minimize fields and decision points that are not necessary to complete the immediate action. Do not optimize merely for fewer "steps"; the amount of information the user must process and enter matters more.

**Source:** Baymard Institute — "Reasons for Cart Abandonment" and "Checkout Optimization: Minimize Form Fields".

### 2. Treat unnecessary scrolling as friction in high-intent surfaces

The evidence does **not** establish that every scrollable modal lowers conversion. The defensible rule is narrower:

> When the primary action or decision-critical information is hidden behind unnecessary scrolling, the interface introduces additional interaction cost at a high-intent moment.

NN/G reports that users allocate less attention to content below the fold and documents excessive scrolling problems on mobile.

**Design implication:** for signup, upgrade, checkout, purchase, and lead-capture modals, first try to keep the decision context and primary CTA accessible without internal scrolling. If the content genuinely cannot fit, use progressive disclosure, a persistent action area, or a dedicated multi-step/page flow.

This is a **heuristic**, not a claim of a fixed conversion uplift.

**Sources:** Nielsen Norman Group — "Scrolling and Scrollbars"; "Mobile Web 2009 = Desktop Web 1998".

### 3. Modal dialogs have an interaction-cost tax

NN/G describes modal dialogs as interruptions that require immediate attention, interrupt workflow, can cause context loss, and add an extra goal: dismissing or completing the dialog. NN/G specifically recommends avoiding unnecessary modals in high-stakes processes such as checkout.

**Design implication:** a conversion modal must justify its interruption. If the user needs complex research or information outside the modal to make the decision, prefer a page or nonmodal flow.

**Source:** Nielsen Norman Group — "Modal & Nonmodal Dialogs: When (& When Not) to Use Them".

### 4. Simplify forms, but do not worship a field-count rule

NN/G cites a CHI study in which forms following basic usability guidelines produced 78% first-try submissions versus 42% for forms violating those guidelines. NN/G also emphasizes that removing a field can improve completion, but the business value of the information collected must be considered.

Baymard similarly finds that form-field count has a larger impact on checkout usability than the number of checkout steps.

**Design implication:** eliminate fields that do not support the immediate user or business goal; automate information where possible; defer optional data collection until after the primary conversion.

**Sources:** Nielsen Norman Group — "Website Forms Usability"; Baymard Institute — "Checkout Optimization: Minimize Form Fields".

### 5. Make labels and error recovery persistent

NN/G's form research finds that placeholder-only labels make it harder to remember what belongs in a field, review entered information, and recover from errors. Baymard's checkout testing likewise links unclear required/optional field treatment to validation errors, confusion, slower checkout, and abandonment.

**Design implication:** use persistent labels, explicit required/optional states where appropriate, inline/local error messages, and recovery paths that preserve entered data.

**Sources:** Nielsen Norman Group — "Placeholders in Form Fields Are Harmful"; Baymard Institute — "Required and Optional Form Fields".

### 6. Optimize perceived effort, not arbitrary step count

Baymard explicitly warns that the number of checkout steps is a poor optimization target by itself. A longer flow can be usable when each step is focused; a short flow can still be difficult when each screen contains too many fields or decisions.

**Design implication:** evaluate fields, choices, typing, scrolling, context switches, error recovery, uncertainty, and repeated information.

Do not apply "one page is always better" or "fewer steps is always better" as blanket rules.

**Source:** Baymard Institute — "Checkout Optimization: Minimize Form Fields".

### 7. Speed is part of conversion design

Google/SOASTA's 2017 mobile research found that as page load time increased from 1 second to 3 seconds, the probability of bounce increased 32%; from 1 to 5 seconds it increased 90%. These are historical aggregate mobile findings, not a universal conversion curve.

**Design implication:** treat loading performance as part of the conversion experience. Measure real-user performance and prioritize delays that occur immediately before or during a conversion action.

**Source:** Google/SOASTA mobile page-speed research, 2017.

### 8. A/B tests can overturn UX "best practices"

HubSpot documented an experiment where a two-column lead form converted 22% better than its one-column variant at a 99% confidence level. HubSpot explicitly notes that the result was specific to its long 13-field form and should not be generalized into "two columns are better."

VWO publishes case studies where redesigns produced measurable changes, including ForestView's reported 20.45% mobile form-conversion increase after reducing up/down scrolling and changing product navigation.

**Design implication:** use research to generate hypotheses, not to skip experimentation. A convention that is usually helpful can lose when the task, content density, audience, or business objective changes.

**Sources:** HubSpot — "Disproving Best Practices: The One- vs. Two-Column Form Test"; VWO — "ForestView improved form conversion by 20.45%".

### 9. Use business-specific evidence before declaring a conversion win

A reported uplift from a vendor case study is evidence about that experiment, not a transferable percentage.

When validating a change, prefer:
1. controlled A/B test with a defined primary metric
2. segmented results by device and traffic intent
3. funnel-level metrics rather than only clicks
4. statistical uncertainty/confidence reported by the experiment platform
5. downstream business outcomes, not just micro-conversions

Useful metrics:
- exposure → CTA click
- CTA click → completion
- form start → completion
- step-to-step drop-off
- mobile vs desktop completion
- error rate
- time to completion
- revenue per visitor / qualified lead rate when relevant

## Evidence hierarchy

When making a conversion recommendation, weigh evidence in this order:

1. **Product experiment or behavioral data from the actual interface**
2. **Direct usability testing with the target audience**
3. **Large-scale independent UX research**
4. **Peer-reviewed academic research**
5. **Vendor case studies with disclosed methodology**
6. **Expert heuristics**
7. **Designer intuition**

Do not present levels 5–7 as if they were causal proof.

## What this evidence does NOT justify

Do not encode these as universal rules:

- "Every modal must never scroll."
- "Everything must be above the fold."
- "Fewer form fields always means more revenue."
- "One-column forms always convert better."
- "Fewer checkout steps always convert better."
- "A particular CTA color increases conversion."
- "A UX change will increase conversion by a specific percentage."

Instead, encode the underlying mechanism:

**Reduce unnecessary effort, preserve decision context, make the primary action easy to discover and execute, and validate consequential changes with real user data.**

## Output format

For a conversion-focused review, use:

### Conversion intent
What action should the user take?

### Friction found
What makes that action harder than necessary?

### Risk
Why could the friction interrupt the intended flow?

### Recommended change
What should change?

### Validation
What viewport, device, interaction, or metric should be checked?

Keep recommendations concrete and implementation-aware.

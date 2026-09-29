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

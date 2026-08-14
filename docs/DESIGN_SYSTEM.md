# Design System

## Status
`FOUNDATION — implementation begins in Phase 5B`

## Product personality
- Calm
- Optimistic
- Tactile
- Intelligent
- Trustworthy
- Slightly playful
- Premium
- Minimalist

## Avoid
- generic fintech dashboards
- spreadsheet aesthetics
- arbitrary gradients
- inconsistent icon families
- placeholder illustrations
- meaningless animation
- excessive visual noise
- childish gamification
- excessive cards
- neon colors
- excessive shadows
- visual clutter

## Visual Hierarchy
Emphasize:
1. calm
2. trust
3. progress
4. celebration

## Component rule
Before creating a component, search for an existing component with the same responsibility.

## Tokens
All dimensions are logical pixels/dp.
Do not invent additional token values. This document is the authoritative visual source of truth.

### Colors

**Light Mode:**
- primary: #166B5C
- primaryDark: #0F5146
- primaryContainer: #DCEFEA
- background: #F7F8F5
- surface: #FFFFFF
- surfaceElevated: #FCFCFA
- textPrimary: #17211E
- textSecondary: #5C6964
- textMuted: #87928E
- border: #DCE2DE
- divider: #E8ECE9
- success: #1F7A5A
- successContainer: #DDF2E8
- warning: #A86A00
- warningContainer: #FFF0D0
- error: #B54747
- errorContainer: #FBE4E4
- info: #3569A8
- infoContainer: #E5EEFA
- focus: #166B5C

**Dark Mode:**
- background: #101614
- surface: #17201D
- surfaceElevated: #1D2925
- textPrimary: #F2F5F3
- textSecondary: #B8C3BE
- textMuted: #8F9B96
- border: #2B3833
- divider: #25312D
- primary: #63B5A3
- primaryContainer: #183F36
- (Other semantic colors map gracefully to Dark mode equivalents or use Light mode variants appropriately inverted).

### Typography
Use a bundled cross-platform sans-serif font (when finalized). Do NOT introduce a font package or download arbitrary fonts during Phase 5B without reporting it first.
Use tabular numerals where the selected font supports them.

**Typography scale (size / height):**
- Display Large: 36sp / 42
- Display Medium: 30sp / 36
- Headline Large: 26sp / 32
- Headline Medium: 22sp / 28
- Title Large: 20sp / 26
- Title Medium: 17sp / 22
- Body Large: 16sp / 24
- Body Medium: 14sp / 20
- Body Small: 12sp / 18
- Label Large: 14sp / 20
- Label Medium: 12sp / 16
- Label Small: 11sp / 14

**Financial scale (size / height / weight):**
- Financial Large: 40sp / 44 / weight 700
- Financial Medium: 28sp / 34 / weight 700
- Financial Small: 20sp / 26 / weight 600

### Spacing
- xs: 4
- sm: 8
- md: 12
- lg: 16
- xl: 24
- xxl: 32
- xxxl: 40

### Radii
- small: 8
- medium: 12
- large: 16
- xl: 24
- pill: 999

### Elevation
Keep shadows visually restrained.
- none: 0
- subtle: 1
- card: 2
- raised: 4
- modal: 8

### Interaction
- Minimum touch target: 48x48
- Primary button height: 48
- Primary button radius: 12
- Input radius: 12
- Card radius: 16

### Animation
Use native Flutter animation primitives (No flutter_animate, Rive, Lottie).
- fast: 120ms
- standard: 200ms
- emphasis: 300ms

### Overfunded Visualization
For progress values above 100%:
- retain the real percentage from Domain.
- clamp only the visual geometry to 100%.
- show the actual percentage in text/semantics.
- communicate OVERFUNDED through text/iconography, never color alone.
Example: 125% actual → 100% visual fill → "125% complete · Overfunded"

## Accessibility
Design must support:
- VoiceOver / TalkBack
- Dynamic Type / font scaling without clipping.
- Minimum touch target: 48x48.
- The color system must be used so status is never communicated by color alone.
- Use meaningful Semantics descriptions for buttons, amount displays, progress, and status.
- reduced motion (system settings).

---
name: Pencil & Paper
colors:
  surface: '#fcf9f3'
  surface-dim: '#dcdad4'
  surface-bright: '#fcf9f3'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f6f3ed'
  surface-container: '#f0eee8'
  surface-container-high: '#ebe8e2'
  surface-container-highest: '#e5e2dc'
  on-surface: '#1c1c18'
  on-surface-variant: '#404946'
  inverse-surface: '#31312d'
  inverse-on-surface: '#f3f0ea'
  outline: '#707975'
  outline-variant: '#c0c8c4'
  surface-tint: '#35675b'
  primary: '#35675b'
  on-primary: '#ffffff'
  primary-container: '#6b9e90'
  on-primary-container: '#00342a'
  inverse-primary: '#9dd1c2'
  secondary: '#735b26'
  on-secondary: '#ffffff'
  secondary-container: '#fddc9a'
  on-secondary-container: '#775f2a'
  tertiary: '#8b4c50'
  on-tertiary: '#ffffff'
  tertiary-container: '#c98083'
  on-tertiary-container: '#4f1c20'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#b8eede'
  primary-fixed-dim: '#9dd1c2'
  on-primary-fixed: '#00201a'
  on-primary-fixed-variant: '#1a4f44'
  secondary-fixed: '#ffdf9f'
  secondary-fixed-dim: '#e2c383'
  on-secondary-fixed: '#261a00'
  on-secondary-fixed-variant: '#594410'
  tertiary-fixed: '#ffdada'
  tertiary-fixed-dim: '#ffb3b5'
  on-tertiary-fixed: '#380b10'
  on-tertiary-fixed-variant: '#6f3539'
  background: '#fcf9f3'
  on-background: '#1c1c18'
  surface-variant: '#e5e2dc'
typography:
  headline-lg:
    fontFamily: Be Vietnam Pro
    fontSize: 30px
    fontWeight: '700'
    lineHeight: 38px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Be Vietnam Pro
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  body-lg:
    fontFamily: Be Vietnam Pro
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Be Vietnam Pro
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-lg:
    fontFamily: Be Vietnam Pro
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
  headline-lg-mobile:
    fontFamily: Be Vietnam Pro
    fontSize: 26px
    fontWeight: '700'
    lineHeight: 32px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  margin-mobile: 20px
  gutter: 16px
  stack-sm: 4px
  stack-md: 12px
  stack-lg: 24px
---

## Brand & Style

The design system is centered on the concept of the "Digital Sketchbook." It aims to evoke a sense of warmth, nostalgia, and personal touch, moving away from the cold precision of traditional mobile interfaces. The target audience values artisanal quality and seeks a digital experience that feels as tactile as a physical journal.

The visual language follows a **Tactile / Skeuomorphic** approach, but interpreted through a lo-fi, hand-drawn lens. Every element should look as though it was rendered by a human hand using colored pencils on high-quality, textured grain paper. The brand personality is whimsical yet organized, balancing the chaos of organic lines with the clarity of professional typography. The emotional goal is to make the user feel creative and at ease, as if they are interacting with a friendly, personal note.

## Colors

The palette is derived from the natural pigment of colored pencils and the warm undertones of uncoated paper. 

- **Primary (Soft Teal/Green):** Used for main actions, active states, and primary borders. It mimics a soft lead pencil stroke.
- **Secondary (Muted Yellow):** Used for highlights, stars, and "joy" elements.
- **Tertiary (Soft Red):** Reserved for alerts, deletions, or heart icons, maintained in a muted, rosy tone to avoid harshness.
- **Neutral (Warm Paper):** This is the canvas of this design system. It is a warm, off-white (#F9F6F0) that should be paired with a subtle full-screen grain texture to simulate paper tooth.
- **Ink (Dark Grey):** Instead of pure black, use a soft charcoal grey (#4A4A4A) for text and fine-line details to maintain the "graphite" feel.

## Typography

This design system utilizes **Be Vietnam Pro** for all roles. While the UI elements are "hand-drawn," the typography remains clean and highly legible to ensure the app is functional and accessible. 

The contrast between the "unrefined" organic borders and the "refined" sans-serif type creates a contemporary editorial look. Headlines should use heavier weights and tighter letter spacing to feel like bold titles in a journal. Body text requires generous line height to maintain a breezy, uncrowded feel on the textured background.

## Layout & Spacing

The layout follows an **informal fluid grid**. While the underlying structure is based on an 8px rhythm, elements should not feel perfectly snapped to a grid. 

- **Margins:** Use wide 20px lateral margins to give the "paper" room to breathe.
- **Organic Offset:** To enhance the hand-drawn feel, allow for slight intentional "misalignments" (e.g., a card might be rotated by 0.5 degrees, or a button might sit 2px higher than its neighbor).
- **Density:** Spacing should be airy. Avoid cramming information; treat the screen like a physical page where negative space is as important as the content.

## Elevation & Depth

In this design system, depth is communicated through **Tonal Layering** and **Pencil Hatching** rather than traditional drop shadows.

- **The Stack:** The base layer is the textured paper. Secondary layers (cards, menus) are slightly lighter or different colored "paper scraps" placed on top.
- **Shadows:** Shadows are represented by a subtle "hatching" effect—fine, diagonal lines drawn in a soft grey or the primary teal color. This creates the illusion of a shadow without using a digital blur.
- **Overlap:** Elements should slightly overlap one another (e.g., an icon breaking the border of a card) to emphasize the artisanal, hand-placed nature of the UI.

## Shapes

The shape language is **Rounded** but purposefully irregular. 

- **Borders:** Every border must have a "jitter" or "wobble." Instead of a single CSS `border: 1px solid`, use SVG filters or multiple overlaid paths to simulate the look of a pencil being pulled across paper.
- **Corners:** Use a base 0.5rem (8px) radius, but the actual path of the corner should not be a perfect arc. It should look like a hand-sketched curve that doesn't quite close perfectly.
- **Fills:** Use "scribble fills" for larger areas. Instead of a solid flat color, use a texture that looks like someone shaded the area with a colored pencil.

## Components

- **Buttons:** Styled as hand-drawn rectangles with a thick, double-stroked primary color border. The fill should be a light wash of the primary color, appearing as if colored in with a light touch.
- **Cards:** These should look like individual scraps of paper. The borders are irregular, and the background is slightly lighter than the main app background. Use subtle hatching on the bottom-right edge for a 3D effect.
- **Icons:** Must be custom line-art. No standard material or phosphor icons. They should look like 24x24 sketches with varying line weights.
- **Input Fields:** A single horizontal line (as if on lined paper) or a shaky rectangular box. The cursor should mimic a pencil tip or a simple vertical stroke.
- **Chips/Tags:** Rounded "bubbles" shaded with the secondary yellow or tertiary red colors, using a denser hatching pattern for the background.
- **Lists:** Separated by "pencil-thin" horizontal lines that don't quite touch the edges of the screen, mimicking the look of a hand-ruled notebook.
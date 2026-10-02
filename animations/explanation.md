# animations.qml: How and Why Each Animation Works

This document walks through every card in `animations.qml`. For each one you get what it does, how the code works line by line, and **why** it's written that way.

---

## 0. Shared Foundations

Before the cards, three ideas show up everywhere.

### 0.1 Coordinates are relative to the parent

Every QML item has `x` and `y`, and they are measured **from the top-left corner of its parent**, not from the screen or the window.

In this file every demo lives inside a `Card`'s `stage` item. The `Card` component uses:

```qml
default property alias content: stage.data
```

That line means anything you write between `Card { ... }` is placed inside `stage`. So the box, the `MouseArea`, and everything else in a card share one coordinate system: the stage's top-left corner is `(0, 0)`.

### 0.2 Binding vs assignment

QML has two ways to give a property a value.

```qml
x: ma.mouseX - 18      // BINDING: re-evaluates automatically when ma.mouseX changes
b1.x = mouse.x - 20    // ASSIGNMENT: sets it once, right now (imperative)
```

A binding says "this is always equal to that expression". An assignment says "make it this value now". Both are used below, and **Behavior works with either**.

### 0.3 What a `Behavior` really does

```qml
Behavior on x { NumberAnimation { duration: 450 } }
```

A `Behavior` sits on a property and intercepts **every change** to it. Instead of the value jumping, the animation runs from the old value to the new one. You don't call it, start it, or stop it. You just change the property normally.

This is why Behavior is the best tool for shell UI: your logic stays simple (`panel.x = 0`) and the animation is attached once.

---

## Card 1: Behavior (click to move)

```qml
Rectangle {
    id: b1
    width: 40; height: 40; radius: 6
    color: "#f78166"
    x: 20; y: 20
    Behavior on x { NumberAnimation { duration: 450; easing.type: Easing.OutCubic } }
    Behavior on y { NumberAnimation { duration: 450; easing.type: Easing.OutCubic } }
}
MouseArea {
    anchors.fill: parent
    onClicked: mouse => {
        b1.x = mouse.x - b1.width / 2
        b1.y = mouse.y - b1.height / 2
    }
}
```

### Where do the x and y values come from?

When you click, `MouseArea` hands the handler a `mouse` object containing `mouse.x` and `mouse.y`. These are the click position **relative to the MouseArea's own top-left corner**.

The `MouseArea` has `anchors.fill: parent`, so it covers exactly the same area as the stage. The box `b1` is also a child of the stage. Because they share the same parent, they share the same coordinate system:

```
stage (0,0) ────────────────────────►  x
   │
   │         click happens here
   │              ● (mouse.x, mouse.y)
   │
   ▼ y
```

So `mouse.x` and `mouse.y` can be used directly as `b1`'s coordinates with no conversion. If the `MouseArea` were nested inside a differently positioned item, you'd need `mapToItem()` to convert between coordinate systems.

### Why `- b1.width / 2` and `- b1.height / 2`?

An item's `x` and `y` describe its **top-left corner**, not its center.

If you wrote `b1.x = mouse.x`, the box's top-left corner would land under your cursor and the box would hang off to the bottom-right:

```
 WITHOUT the offset              WITH the offset
                                 
  ●───────┐                         ┌───────┐
  │       │   cursor at corner      │   ●   │   cursor at center
  │  box  │                         │  box  │
  └───────┘                         └───────┘
```

To put the **center** of the box under the cursor, move the top-left corner back by half the box's size:

```
b1.x = mouse.x - (b1.width / 2)    // shift left by half the width
b1.y = mouse.y - (b1.height / 2)   // shift up by half the height
```

Using `b1.width / 2` rather than a hardcoded `20` means the code stays correct if you later change the box size.

### Why `mouse => { ... }`?

This is an arrow function that names the injected parameter. Older QML let you use `mouse` implicitly inside the handler, but Qt 6 deprecates that and warns. Naming it explicitly is the modern, future-proof form.

### Why the animation looks smooth if you click quickly

If you click again mid-animation, the Behavior **retargets**: it starts a new animation from the box's *current* position to the new target. No jump, no queue. That's the main advantage over manually starting animations.

### Why `OutCubic`?

`Out` easings start fast and decelerate. For UI that responds to user input, this feels snappy because the box reacts instantly and then settles gently. `In` easings (slow start) feel sluggish for click responses.

---

## Card 2: Hover (scale + color + radius)

```qml
Rectangle {
    anchors.centerIn: parent
    width: 90; height: 90
    radius: hov.containsMouse ? 45 : 10
    color:  hov.containsMouse ? "#3fb950" : "#30363d"
    scale:  hov.containsMouse ? 1.25 : 1.0

    Behavior on scale  { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }
    Behavior on radius { NumberAnimation { duration: 250 } }
    Behavior on color  { ColorAnimation  { duration: 250 } }

    MouseArea { id: hov; anchors.fill: parent; hoverEnabled: true }
}
```

### How it works

`hov.containsMouse` is a boolean that flips between `true` and `false` as the cursor enters and leaves. Three properties are **bindings** to that boolean using the ternary operator (`condition ? ifTrue : ifFalse`).

When the boolean flips, all three bindings produce new values, and each `Behavior` animates its own property. You never write "on hover enter, do X". You describe **what the state looks like**, and the Behaviors handle the transition.

### Why `hoverEnabled: true`?

By default, a `MouseArea` only reports the mouse while a button is pressed. `hoverEnabled: true` makes it track the cursor even with no buttons down. Without it, `containsMouse` never becomes true and nothing happens.

### Why `radius: 45`?

`radius` rounds the corners. Setting it to **half the side length** (90 / 2 = 45) turns a square into a perfect circle. So hovering morphs square, to circle, to square.

### Why `scale` and not `width`/`height`?

`scale` is a visual transform. It doesn't change the item's layout size, so nothing around it gets pushed or re-laid-out, and it's cheap for the renderer. Animating `width` or `height` triggers layout recalculation. For hover pop effects, prefer `scale`.

### Why `ColorAnimation` for color?

`NumberAnimation` can only interpolate numbers. Colors need `ColorAnimation`, which blends the red, green, blue and alpha channels.

### Why `OutBack` on the scale?

`OutBack` overshoots the target slightly and then settles back (here, to roughly 1.3 and then 1.25). It gives a springy, playful feel that suits hover feedback.

### Gotcha

The `MouseArea` is a child of the scaled rectangle, so the hit area grows with it. If your cursor sits exactly on the edge, scaling can push the edge away, flip `containsMouse` to false, shrink the box, flip it back, and flicker. In real UI, put the `MouseArea` on an unscaled parent item.

---

## Card 3: Easing Race

```qml
Card {
    id: c3
    property bool go: false

    Column {
        anchors.fill: parent
        spacing: 10
        Repeater {
            model: [
                { n: "Linear",     t: Easing.Linear },
                { n: "InOutQuad",  t: Easing.InOutQuad },
                { n: "OutBounce",  t: Easing.OutBounce },
                { n: "OutElastic", t: Easing.OutElastic },
                { n: "OutBack",    t: Easing.OutBack }
            ]
            Item {
                width: parent.width
                height: 22
                Text { text: modelData.n; ... }
                Rectangle {
                    width: 18; height: 18; radius: 9
                    x: c3.go ? parent.width - width : 0
                    Behavior on x {
                        NumberAnimation { duration: 1000; easing.type: modelData.t }
                    }
                }
            }
        }
    }
    MouseArea { anchors.fill: parent; onClicked: c3.go = !c3.go }
}
```

### The point of this card

All five dots use the **same duration (1000 ms) and the same distance**. The only difference is the easing curve. This isolates what easing does: it changes *how progress is distributed over time*.

### How the code works

- **`property bool go`** is a custom property on the card. Clicking flips it. Every dot's `x` is bound to it.
- **`Repeater`** stamps out one copy of its delegate (`Item { ... }`) per entry in `model`. Inside the delegate, `modelData` is the current entry.
- **The model is an array of objects** (`{ n: name, t: easingType }`). `Easing.Linear` and friends evaluate to numbers (enum values), so they can be stored in a plain object and handed to `easing.type: modelData.t`. This is how you let one delegate use a different easing per row.
- **`parent.width`** in the delegate's `Item` refers to the `Column`, so each track spans the card's width.
- **`x: c3.go ? parent.width - width : 0`**: the dot's destination is the track's right edge. You subtract the dot's own `width` so its **right edge** (not its left edge) touches the end. Same top-left-corner logic as card 1.

### What each curve feels like

| Easing | Behavior | Good for |
|---|---|---|
| `Linear` | constant speed, mechanical | progress bars, spinners |
| `InOutQuad` | slow, fast, slow | moving things between two resting places |
| `OutBounce` | hits the end and bounces | playful notifications |
| `OutElastic` | overshoots and wobbles like a rubber band | attention-grabbing, use sparingly |
| `OutBack` | overshoots once then settles | buttons, popups appearing |

**Naming rule:** `In` = effect at the start, `Out` = effect at the end, `InOut` = both. Most good UI motion uses `Out*` variants, because things respond immediately and then settle.

---

## Card 4: Sequential + Parallel

```qml
Rectangle {
    id: b4
    anchors.centerIn: parent
    width: 70; height: 70; radius: 35
    color: "#58a6ff"

    SequentialAnimation {
        running: true
        loops: Animation.Infinite
        ParallelAnimation {
            NumberAnimation { target: b4; property: "scale";   to: 1.5; duration: 600; easing.type: Easing.InOutSine }
            NumberAnimation { target: b4; property: "opacity"; to: 0.3; duration: 600 }
        }
        ParallelAnimation {
            NumberAnimation { target: b4; property: "scale";   to: 1.0; duration: 600; easing.type: Easing.InOutSine }
            NumberAnimation { target: b4; property: "opacity"; to: 1.0; duration: 600 }
        }
        PauseAnimation { duration: 300 }
    }
}
```

### The two grouping types

- **`SequentialAnimation`**: children run **one after another**. Total time is the sum.
- **`ParallelAnimation`**: children run **at the same time**. Total time is the longest child.

Here the sequence is: *(grow + fade together)*, then *(shrink + unfade together)*, then *pause 300 ms*, then repeat forever. The grouping is what makes scale and opacity move in lockstep while the phases happen in order.

### Why `target:` and `property:` are written out

In cards 1 and 2 the animation lived *inside* a `Behavior`, which already knows which property it is attached to. Here the animations are free-floating children of a `SequentialAnimation`, so each `NumberAnimation` has to be told what to animate. `target: b4` is why the rectangle has an `id`.

### Why no `from:`?

When `from` is omitted, the animation starts from the property's **current value**. That's what you want in a loop. The shrink phase starts wherever the grow phase ended.

### Why `running: true` and `loops: Animation.Infinite`?

Free-floating animations don't start themselves. `running: true` starts it when the component loads, and `Animation.Infinite` repeats it forever.

### Why `InOutSine` and a pause?

`InOutSine` is a very gentle easing. It's good for breathing or pulsing effects because there are no sharp edges at either end. The `PauseAnimation` is a built-in "do nothing for N ms" step. It gives the pulse a resting beat so it feels like breathing rather than frantic throbbing.

---

## Card 5: States + Transitions

```qml
Rectangle {
    id: b5
    x: 0; y: 10
    width: 60; height: 60; radius: 8
    color: "#d29922"

    states: State {
        name: "big"
        PropertyChanges { target: b5; width: 220; height: 130; color: "#f85149" }
    }
    transitions: Transition {
        NumberAnimation { properties: "width,height"; duration: 400; easing.type: Easing.OutBack }
        ColorAnimation { duration: 400 }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: b5.state = (b5.state === "big") ? "" : "big"
    }
}
```

### The mental model

Cards 1 to 4 animate *properties*. This card animates *between named configurations*. You describe two or more complete "looks" and let QML work out the changes.

- **The base state** is the empty string `""`. It's whatever the item looks like when you declare it (60x60, orange).
- **`State { name: "big" }`** says "when in the big state, apply these `PropertyChanges`": 220x130, red.
- **Switching** is just assigning `b5.state = "big"` or `""`. QML applies and un-applies the changes automatically. You never write code to restore the old size.

### What the Transition does

A `Transition` says **how** to animate whenever the state changes. It's separate from the state definition on purpose, so you can restyle the motion without touching the states.

- By default a `Transition` matches every state change (`from: "*"`, `to: "*"`), in both directions, so one transition covers grow and shrink.
- `properties: "width,height"` limits that `NumberAnimation` to those two properties.
- `ColorAnimation` handles the color change, because `NumberAnimation` can't blend colors.
- The two animations inside a Transition run **in parallel** by default.

### Why use States instead of a Behavior here?

For one or two properties, a Behavior is simpler. States win when **many properties change together as one logical mode**: a panel being "open" vs "closed", a button being "pressed" vs "idle", a sidebar being "expanded" vs "collapsed". You switch one string instead of juggling a dozen bindings, and you can add per-state transitions.

### Why `OutBack` on width and height?

It makes the box briefly overshoot 220 wide before settling. The stage has `clip: true`, so overshoot past the card edge would get cut off. That's a good reason to keep some margin when using overshoot easings.

---

## Card 6: SpringAnimation

```qml
Rectangle {
    id: b6
    width: 36; height: 36; radius: 18
    x: ma6.mouseX - width / 2
    y: ma6.mouseY - height / 2
    Behavior on x { SpringAnimation { spring: 3; damping: 0.15 } }
    Behavior on y { SpringAnimation { spring: 3; damping: 0.15 } }
}
MouseArea { id: ma6; anchors.fill: parent; hoverEnabled: true }
```

### How the position is calculated

This uses a **binding** instead of an assignment. `ma6.mouseX` and `ma6.mouseY` always hold the live cursor position (relative to the MouseArea, which again matches the stage). The `- width / 2` offset centers the circle on the cursor, the same reason as card 1.

Because it's a binding, `x` is recalculated on every mouse movement. That's dozens of times per second.

### Why a Behavior on a binding works

A Behavior doesn't care whether a change came from an assignment or a binding. It sees "x wants a new value" and animates there. So the circle never snaps to the cursor. It is **pulled** toward it, and each new mouse position retargets the spring.

### Why SpringAnimation instead of a normal NumberAnimation?

A `NumberAnimation` needs a fixed `duration`, and when the target keeps changing (every mouse move), restarting 60 timed animations per second looks stiff. `SpringAnimation` has **no duration**. It simulates physics: the value is pulled toward the target and carries momentum. That's naturally smooth when the target moves constantly, and it overshoots and wobbles like a real object.

### The parameters

| Parameter | Meaning | Effect |
|---|---|---|
| `spring` | stiffness of the pull | higher = snappier, reaches target faster |
| `damping` | friction (0 to 1) | low = bouncy, long wobble; high = no overshoot |
| `mass` | weight (default 1.0) | higher = sluggish, more momentum |

Try `damping: 0.6` for a smooth glide with no bounce and `damping: 0.02` for a jelly-like wobble.

### Why is the circle at the top-left at the start?

Until the mouse enters, `mouseX` and `mouseY` are `0`, so the circle rests at `(0 - 18, 0 - 18)`, slightly cut off by the stage clip. In a real project you'd initialize it to the stage's center.

---

## Card 7: Animator + the `on` Syntax

```qml
Rectangle {
    anchors.centerIn: parent
    width: 80; height: 80; radius: 14
    color: "#bc8cff"

    Rectangle { /* white dot so you can see the rotation */ }

    RotationAnimator on rotation {
        from: 0; to: 360
        duration: 1800
        loops: Animation.Infinite
    }
    SequentialAnimation on color {
        loops: Animation.Infinite
        ColorAnimation { to: "#58a6ff"; duration: 1500 }
        ColorAnimation { to: "#bc8cff"; duration: 1500 }
    }
}
```

### Two new ideas

**1. The `on` syntax.** `SomeAnimation on propertyName { ... }` is shorthand that:

- sets the `target` and `property` for you automatically (no `id` needed),
- starts running as soon as the item loads (no `running: true` needed).

It's perfect for "this thing just does this forever" effects like spinners and ambient color shifts.

**2. Animators vs Animations.** `RotationAnimator` is an **Animator**. The others (`NumberAnimation` and so on) are regular **Animations**. The difference is *where they run*:

| | Animation | Animator |
|---|---|---|
| Runs on | main (UI) thread | render (scene graph) thread |
| Can animate | any property | only `x`, `y`, `scale`, `rotation`, `opacity` |
| Under load | can stutter if the UI thread is busy | stays smooth |
| Property value during run | updates every frame | updated only when it finishes |

For a never-ending spinner, an Animator is ideal. Even if your shell is busy doing work, the spin stays fluid. The trade-off is that you can't read `rotation` mid-animation or bind other things to it.

### Why the white dot?

Rotating a plain square by 360 degrees looks like nothing happened. The dot gives your eye a reference point. Rotation happens around the item's center by default (`transformOrigin: Item.Center`).

### Why does the color loop work without `from`?

The first `ColorAnimation` goes from the current color to blue. The second goes from blue back to purple. Each starts from wherever the previous one ended, so omitting `from` creates a seamless loop. Notice the second one ends at the original purple, which is what makes the loop continuous.

---

## Card 8: Staggered Wave

```qml
Row {
    anchors.centerIn: parent
    spacing: 8
    Repeater {
        model: 8
        Item {
            width: 14; height: 110
            Rectangle {
                id: bar
                width: 14; height: 20; radius: 3
                anchors.bottom: parent.bottom
            }
            SequentialAnimation {
                running: true
                PauseAnimation { duration: index * 100 }
                SequentialAnimation {
                    loops: Animation.Infinite
                    NumberAnimation { target: bar; property: "height"; to: 100; duration: 450; easing.type: Easing.InOutSine }
                    NumberAnimation { target: bar; property: "height"; to: 20;  duration: 450; easing.type: Easing.InOutSine }
                }
            }
        }
    }
}
```

### How a wave appears from identical bars

All 8 bars run the *same* animation. The only difference is a **start delay** that grows with the bar's position:

```
bar 0: starts at   0 ms
bar 1: starts at 100 ms
bar 2: starts at 200 ms
...
```

`index` is automatically provided by `Repeater` inside its delegate: 0, 1, 2 and so on. `index * 100` turns position into delay. Because each bar is shifted in time by a fixed amount, the eye sees a wave traveling across them. This is called **staggering**, and it's the standard trick for list reveals, loaders, and equalizer effects.

### Why the nested SequentialAnimation?

A tempting but **wrong** version:

```qml
SequentialAnimation {
    loops: Animation.Infinite
    PauseAnimation { duration: index * 100 }   // <- repeats every loop!
    NumberAnimation { ... to: 100 }
    NumberAnimation { ... to: 20 }
}
```

Here the pause would be inside the loop, so it repeats every cycle. Bar 0's cycle would be 900 ms and bar 7's would be 1600 ms. The bars would drift apart and the wave would fall apart after a few seconds.

The correct structure puts the pause **outside** the loop:

```
outer Sequential (runs once):
    1. Pause (index * 100)         <- happens ONCE
    2. inner Sequential (infinite) <- all bars now loop at the same 900 ms period
```

Every bar has the same loop period, so the fixed offset between them is preserved forever.

### Why `target: bar`?

The animation is a child of the wrapper `Item`, not of the `Rectangle`, so it has to be told what to animate. The `Rectangle` has `id: bar` so it can be referenced. Each delegate instance has its own scope, so `bar` always refers to that instance's rectangle.

### Why `anchors.bottom: parent.bottom`?

Anchoring to the bottom means that when `height` grows, the bar expands **upward** from a fixed baseline, like an equalizer. Without the anchor, the bar would grow downward from its top edge.

### Why a wrapper `Item` with `height: 110`?

`Row` positions children side by side using their sizes. Giving each slot a fixed height (110) reserves the space the tallest bar needs, so the `Row` doesn't jump around as bars grow. The `Item` is invisible and acts purely as a fixed-size slot.

---

## Cheat Sheet: Which Tool When?

| You want... | Use |
|---|---|
| A property to glide whenever it changes | `Behavior on prop` |
| Hover or press feedback | bindings from `containsMouse` / `pressed` plus `Behavior`s |
| Several properties to change together as a "mode" | `states` + `transitions` |
| Things to happen in order | `SequentialAnimation` |
| Things to happen at once | `ParallelAnimation` |
| An ambient or looping effect | `Animation on prop` (the `on` syntax) |
| Something that follows a moving target | `SpringAnimation` |
| A smooth spinner or fade under heavy load | Animators (`RotationAnimator`, `OpacityAnimator`, ...) |
| A list to cascade in | stagger with `index * delay` |

## Duration Rules of Thumb

- **100 to 200 ms**: hover feedback, small toggles
- **200 to 350 ms**: panels sliding, windows opening, workspace switches
- **400 to 600 ms**: large layout changes, attention effects
- **Above 600 ms** starts to feel slow unless it's intentionally ambient

Anything the user triggers should react immediately and settle quickly. Use `Out*` easings for that. Slow animations on frequent actions get annoying fast.
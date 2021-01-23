# ASCII canvas

Your task is to build a client-server system to represent an ASCII art drawing canvas. The exercise involves two pieces:

- A server that will implement the drawing endpoints into a canvas.
- (Optional) A _read-only_ client that will show the canvas stored by the server with the drawings.

## What we are looking for is…

- correctly functioning solution that comes with running instructions and examples.
- readable, clear code of the kind you would yourself like your team-mates to write and maintain with you.
- appropriately automatically tested, including failure scenarios.
- appropriate data structures and algorithms being applied as part of your solution.
- a version history being included with your solution.

### The server should be…

- implementing the canvas behaviours described below into a web service API as you see fit.
- written in Elixir or Go
- automatically tested appropriately.
- runnable with clear running instructions.

### Canvas should be…

- identifiable with a globally unique identifier.
- persisted across application launches.
- **_not_** authenticating users: authenticating or authorizing requests is out of scope.

### Drawing operations

- A rectangle parameterised with…
  - Coordinates for the **upper-left corner**.
  - **width** and **height**.
  - an optional **fill** character.
  - an optional **outline** character.
  - One of either **fill** or **outline** should always be present.
- A flood fill operation, parameterised with…
  - the **start coordinates** from where to begin the flood fill.
  - a **fill** character.

A flood fill operation draws the fill character to the start coordinate, and continues to attempt drawing the character around (up, down, left, right) in each direction from the position it was drawn at, as long as a different character, or a border of the canvas, is not reached.

- Drawing operations are applied to the canvas in the same order that they are passed in to the server.

A character can be assumed to be an ASCII encoded byte.

The canvas can be assumed to be a fixed size.

### If you decide to implement the read-only client (the bonus task), the client should be...

- Able to observe server side canvas changes without page refreshes.
- … non-interactive: you do **_not_** need to implement any client-side interactions. Read-only.
- simple: you can implement the drawing operations with constant-width characters.
- runnable with clear running instructions.

### Test fixture 1

- Rectangle at [3,2] with width: 5, height: 3, outline character: `@`, fill character: `X`
- Rectangle at [10, 3] with width: 14, height: 6, outline character: `X`, fill character: `O`

```


   @@@@@
   @XXX@  XXXXXXXXXXXXXX
   @@@@@  XOOOOOOOOOOOOX
          XOOOOOOOOOOOOX
          XOOOOOOOOOOOOX
          XOOOOOOOOOOOOX
          XXXXXXXXXXXXXX
```

### Test fixture 2

- Rectangle at `[14, 0]` with width `7`, height `6`, outline character: none, fill: `.`
- Rectangle at `[0, 3]` with width `8`, height `4`, outline character: `O`, fill: `none`
- Rectangle at `[5, 5]` with width `5`, height `3`, outline character: `X`, fill: `X`

```
              .......
              .......
              .......
OOOOOOOO      .......
O      O      .......
O    XXXXX    .......
OOOOOXXXXX
     XXXXX
```

### Test fixture 3

- Rectangle at `[14, 0]` with width `7`, height `6`, outline character: none, fill: `.`
- Rectangle at `[0, 3]` with width `8`, height `4`, outline character: `O`, fill: `none`
- Rectangle at `[5, 5]` with width `5`, height `3`, outline character: `X`, fill: `X`
- Flood fill at `[0, 0]` with fill character `-` (canvas presented in 32x12 size)

```
--------------.......
--------------.......
--------------.......
OOOOOOOO------.......
O      O------.......
O    XXXXX----.......
OOOOOXXXXX-----------
     XXXXX-----------
```

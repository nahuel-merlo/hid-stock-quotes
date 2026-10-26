A command-line tool that processes historical stock quotes from a CSV file and generates statistics, an SVG candlestick chart and an HTML report.

This is my implementation of the **stockquotes** project from the book [*Haskell in Depth*](https://www.manning.com/books/haskell-in-depth) by Vitaly Bragilevsky. I built it as a learning exercise: the goal wasn't the tool itself, but getting hands-on with a real Haskell project. That meant setting up a Cabal package, picking libraries from Hackage, parsing command-line arguments, and using the language extensions and abstractions that show up in everyday Haskell code.

This README focuses on how the application is structured and what I learned while building it.

---

## What it does

Given a CSV like this:

```csv
day,close,volume,open,high,low
2019-05-01,210.520004,64827300,209.880005,215.309998,209.229996
2019-05-02,209.149994,31996300,209.839996,212.649994,208.130005
```

it can:

- Print a **statistics table** to the terminal (mean, min, max, and days between min and max, for every quote field).
- Render an **SVG chart** with candlesticks, the closing price line and a volume bar chart.
- Generate an **HTML report** with the chart, the statistics and the full data table.

<p align="center">
  <img width="497" height="481" alt="image" src="https://github.com/user-attachments/assets/7e8ea8bf-a6da-4148-bd11-7402a8e6abdb" />
  <br><em>Data flow of the application. Figure from <a href="https://www.manning.com/books/haskell-in-depth">Haskell in Depth</a>.</em>
</p>

```
$ cabal run stockquotes -- stockquotes/data/quotes.csv --name ACME --chart --html report.html

+-------------+-------------+-------------+-------------+----------------------+
| Quote Field |        Mean |         Min |         Max | Days between Min/Max |
+-------------+-------------+-------------+-------------+----------------------+
| Open        |      ...    |      ...    |      ...    |                  ... |
| ...         |             |             |             |                      |
```

### Options

```
Usage: stockquotes FILE [-n|--name ARG] [-c|--chart] [--html FILE] [-s|--silent]

Available options:
  FILE                     CSV file name
  -n,--name ARG            company name
  -c,--chart               generate chart
  --html FILE              generate HTML report
  -s,--silent              don't print statistics
  -h,--help                Show this help text
```

---

## What I learned

The book's focus for this project is building a complete application, not just isolated functions. These are the two things that stuck the most.

### 1. Splitting the program into modules

Each module has one responsibility, and `Main` only wires them together:

| Module        | Responsibility                                                  |
|---------------|-----------------------------------------------------------------|
| `QuoteData`   | The domain type and how to parse it from CSV.                   |
| `Param`       | Command-line arguments.                                         |
| `StatReport`  | Computing statistics and rendering them as a text table.        |
| `Charts`      | Building the SVG chart.                                         |
| `HtmlReport`  | Building the HTML report.                                       |
| `Main`        | Reading the file, handling errors and calling the rest.         |

`QuoteData` sits at the bottom of the dependency graph: every other module depends on the domain type, but it depends on none of them.

<p align="center">
  <img width="578" height="401" alt="image" src="https://github.com/user-attachments/assets/850eecfd-2f3d-4e75-8b98-55a70326b242" />
  <br><em>Module dependencies. Figure from <a href="https://www.manning.com/books/haskell-in-depth">Haskell in Depth</a>.</em>
</p>

The most important split, though, isn't between modules but between **I/O and pure code**. `main` and `work` only handle effects: reading arguments, reading the file, printing and writing outputs. All the actual logic (parsing, statistics, formatting the text and HTML reports, describing the chart) lives in pure functions. That made each piece easy to try out in `cabal repl` and easy to reason about.

<p align="center">
  <img width="578" height="401" alt="image" src="https://github.com/user-attachments/assets/3bede6f3-fdfa-404f-bbfc-0a8ceffa1e5d" />
  <br><em>How the work is split between I/O and pure code. Figure from <a href="https://www.manning.com/books/haskell-in-depth">Haskell in Depth</a>.</em>
</p>

### 2. Libraries from the ecosystem

| Library                                   | What I used it for                                                     |
|-------------------------------------------|------------------------------------------------------------------------|
| **cassava**                               | Decoding the CSV into a typed `QuoteData` with `decodeByName`.        |
| **time**                                  | The `Day` type, date parsing and `diffDays`.                          |
| **optparse-applicative**                  | Declarative command-line parsing with auto-generated `--help`.        |
| **fmt**                                   | String formatting and interpolation (`fixedF`, `+\|`, `\|+`).          |
| **colonnade**                             | Describing table columns once, rendering them as ASCII or HTML.       |
| **blaze-html** / **blaze-colonnade**      | Generating HTML with a Haskell DSL.                                    |
| **Chart** / **Chart-diagrams**            | Candlestick, line and bar charts rendered to SVG.                     |
| **text** / **bytestring**                 | Efficient text and binary data instead of `String`.                   |

---

## Running it

Requirements: [GHC](https://www.haskell.org/ghcup/) and Cabal.

```bash
git clone https://github.com/nahuel-merlo/hid-stock-quotes
cd hid-stock-quotes
cabal build

# Print statistics
cabal run stockquotes -- stockquotes/data/quotes.csv

# Statistics + chart + HTML report
cabal run stockquotes -- stockquotes/data/quotes.csv -n ACME -c --html report.html
```

To explore the modules interactively:

```bash
cabal repl
```

---

## Credits

Project and diagrams from *Haskell in Depth* by Vitaly Bragilevsky (Manning).

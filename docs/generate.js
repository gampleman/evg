#!/usr/bin/env node

/**
 * Generates SVG documentation images from Elm source files.
 *
 * Each file in docs/src/ that exports `svgs` (a list of { name, svg } records)
 * will produce SVG files in docs/images/.
 *
 * Usage: node docs/generate.js
 */

const { execSync } = require("child_process");
const fs = require("fs");
const path = require("path");

const DOCS_DIR = __dirname;
const SRC_DIR = path.join(DOCS_DIR, "src");
const IMAGES_DIR = path.join(DOCS_DIR, "images");
const BUILD_DIR = path.join(DOCS_DIR, ".build");

// Find all Elm files in docs/src/ that export `svgs` (excluding generated DocMain)
const elmFiles = fs
  .readdirSync(SRC_DIR)
  .filter((f) => f.endsWith(".elm") && f !== "DocMain.elm")
  .map((f) => path.join(SRC_DIR, f))
  .filter((f) => fs.readFileSync(f, "utf8").includes("svgs :"));

if (elmFiles.length === 0) {
  console.log("No Elm files found in docs/src/");
  process.exit(0);
}

// Ensure build and output directories exist
fs.mkdirSync(BUILD_DIR, { recursive: true });
fs.mkdirSync(IMAGES_DIR, { recursive: true });

// Extract module names from file paths
const modules = elmFiles.map((f) => {
  const content = fs.readFileSync(f, "utf8");
  const match = content.match(/^module\s+([\w.]+)/m);
  if (!match) {
    console.error(`Could not find module name in ${f}`);
    process.exit(1);
  }
  return match[1];
});

// Generate a Main.elm that imports all doc modules and runs them
const mainContent = `port module DocMain exposing (main)

import Json.Encode as Encode
import Platform

${modules.map((m) => `import ${m}`).join("\n")}


port output : Encode.Value -> Cmd msg


type alias Flags =
    ()


main : Program Flags () ()
main =
    Platform.worker
        { init =
            \\_ ->
                ( ()
                , output
                    (Encode.list
                        (\\{ name, body } -> Encode.object [ ( "name", Encode.string name ), ( "body", Encode.string body ) ])
                        (List.concat
                            [ ${modules.map((m) => `${m}.svgs`).join("\n                            , ")}
                            ]
                        )
                    )
                )
        , update = \\_ model -> ( model, Cmd.none )
        , subscriptions = \\_ -> Sub.none
        }
`;

fs.writeFileSync(path.join(SRC_DIR, "DocMain.elm"), mainContent);

// Compile
console.log("Compiling documentation SVGs...");
try {
  execSync(
    `npx elm make src/DocMain.elm --optimize --output=${BUILD_DIR}/doc.js`,
    {
      cwd: DOCS_DIR,
      stdio: "pipe",
    }
  );
} catch (e) {
  console.error("Elm compilation failed:");
  console.error(e.stderr?.toString() || e.message);
  process.exit(1);
}

// Run the compiled Elm program and capture the port output
const runnerPath = path.join(BUILD_DIR, "runner.js");
fs.writeFileSync(
  runnerPath,
  `
const { Elm } = require('./doc.js');

const app = Elm.DocMain.init();
app.ports.output.subscribe(function(svgs) {
  process.stdout.write(JSON.stringify(svgs));
  process.exit(0);
});

setTimeout(function() {
  console.error('Timeout waiting for Elm port output');
  process.exit(1);
}, 5000);
`
);

let result;
try {
  result = execSync(`node runner.js`, {
    cwd: BUILD_DIR,
    encoding: "utf8",
    stdio: ["pipe", "pipe", "pipe"],
  });
} catch (e) {
  console.error("Failed to run Elm program:");
  console.error(e.stderr?.toString() || e.message);
  process.exit(1);
}

// Parse output and write SVG files
const svgs = JSON.parse(result);
let count = 0;
for (const { name, body } of svgs) {
  const outPath = path.join(IMAGES_DIR, name);
  fs.writeFileSync(outPath, body);
  console.log(`  Generated: docs/images/${name}`);
  count++;
}

console.log(`Done! Generated ${count} image(s).`);

// Clean up generated DocMain
fs.unlinkSync(path.join(SRC_DIR, "DocMain.elm"));

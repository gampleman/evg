#!/usr/bin/env node

/**
 * Builds and serves the examples page.
 * Reads source files and passes them as flags to the Elm app.
 *
 * Usage: node examples/serve.js
 * Then open http://localhost:8000
 */

const { execSync } = require("child_process");
const http = require("http");
const fs = require("fs");
const path = require("path");

const EXAMPLES_DIR = __dirname;
const BUILD_DIR = path.join(EXAMPLES_DIR, ".build");
const SRC_DIR = path.join(EXAMPLES_DIR, "src");

fs.mkdirSync(BUILD_DIR, { recursive: true });

function collectSources() {
  const files = fs.readdirSync(SRC_DIR).filter(f => f.endsWith(".elm") && f !== "Main.elm");
  const sources = {};
  for (const file of files) {
    const name = file.replace(".elm", "");
    sources[name] = fs.readFileSync(path.join(SRC_DIR, file), "utf-8");
  }
  return sources;
}

console.log("Compiling examples...");
try {
  execSync(`npx elm make src/Main.elm --output=${BUILD_DIR}/examples.js`, {
    cwd: EXAMPLES_DIR,
    stdio: "pipe",
  });
} catch (e) {
  console.error("Compilation failed:");
  console.error(e.stderr?.toString() || e.message);
  process.exit(1);
}

const sources = collectSources();

const html = `<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Evg Examples</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Racing+Sans+One&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/github.min.css">
  <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/highlight.min.js"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/languages/elm.min.js"></script>
  <style>
    pre code.hljs { padding: 16px; border-radius: 6px; font-size: 13px; line-height: 1.4; }
  </style>
</head>
<body>
  <div id="app"></div>
  <script src="examples.js"></script>
  <script>
    var app = Elm.Main.init({
      node: document.getElementById("app"),
      flags: ${JSON.stringify(sources)}
    });

    // Highlight code blocks after Elm renders
    function highlightAll() {
      document.querySelectorAll('pre code.language-elm:not(.hljs)').forEach(function(el) {
        hljs.highlightElement(el);
      });
    }

    // Run on initial render and whenever DOM changes (e.g. opening details)
    requestAnimationFrame(highlightAll);
    var observer = new MutationObserver(function() {
      requestAnimationFrame(highlightAll);
    });
    observer.observe(document.body, { childList: true, subtree: true });
  </script>
</body>
</html>`;

fs.writeFileSync(path.join(BUILD_DIR, "index.html"), html);

if (process.argv.includes("--build")) {
  console.log("Build complete: " + BUILD_DIR);
  process.exit(0);
}

const PORT = 8000;
const server = http.createServer((req, res) => {
  let filePath;
  if (req.url === "/" || req.url === "/index.html") {
    filePath = path.join(BUILD_DIR, "index.html");
  } else {
    filePath = path.join(BUILD_DIR, req.url);
  }

  if (!fs.existsSync(filePath)) {
    res.writeHead(404);
    res.end("Not found");
    return;
  }

  const ext = path.extname(filePath);
  const contentType =
    ext === ".html"
      ? "text/html"
      : ext === ".js"
      ? "application/javascript"
      : "text/plain";

  res.writeHead(200, { "Content-Type": contentType });
  res.end(fs.readFileSync(filePath));
});

server.listen(PORT, () => {
  console.log(`\nExamples server running at http://localhost:${PORT}`);
  console.log("Press Ctrl+C to stop.\n");
});

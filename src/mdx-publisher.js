import fs from "node:fs";
import path from "node:path";
import React from "react";
import { renderToStaticMarkup } from "react-dom/server";
import { compile } from "@mdx-js/mdx";
import * as jsxRuntime from "react/jsx-runtime";

function slugify(input) {
  return String(input)
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "") || "page";
}

function walk(dir, out = []) {
  if (!fs.existsSync(dir)) return out;
  for (const ent of fs.readdirSync(dir, { withFileTypes: true })) {
    const p = path.join(dir, ent.name);
    if (ent.isDirectory()) walk(p, out);
    else if (ent.isFile() && p.endsWith(".mdx")) out.push(p);
  }
  return out;
}

async function loadReusableComponents(componentsDir) {
  const components = {};
  if (!fs.existsSync(componentsDir)) return components;
  globalThis.React = React;
  for (const ent of fs.readdirSync(componentsDir, { withFileTypes: true })) {
    if (!ent.isFile()) continue;
    if (!ent.name.endsWith(".js") && !ent.name.endsWith(".mjs")) continue;
    const modPath = path.join(componentsDir, ent.name);
    const mod = await import(`file://${modPath}`);
    for (const [key, val] of Object.entries(mod)) {
      if (typeof val === "function") components[key] = val;
    }
  }
  return components;
}

function htmlDocument(title, body) {
  return `<!doctype html>
<html>
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>${title}</title>
  <style>
    body{font-family:Inter,system-ui,-apple-system,Segoe UI,Roboto,sans-serif;max-width:980px;margin:2rem auto;padding:0 1rem;line-height:1.5}
    a{color:#0f62fe}
    .card{border:1px solid #ddd;border-radius:12px;padding:1rem;margin:.75rem 0}
    .muted{color:#666}
  </style>
</head>
<body>${body}</body>
</html>`;
}

export async function buildVisuals({ srcDir, outDir, publicBasePath = "/stories" }) {
  fs.mkdirSync(srcDir, { recursive: true });
  fs.mkdirSync(outDir, { recursive: true });

  const componentMap = await loadReusableComponents(path.join(srcDir, "_components"));
  const files = walk(srcDir).filter((p) => !p.includes(`${path.sep}_components${path.sep}`));

  const pages = [];
  for (const filePath of files) {
    const source = fs.readFileSync(filePath, "utf8");
    const compiled = await compile(source, { outputFormat: "function-body", development: false });
    const fn = new Function(String(compiled));
    const mod = fn({ Fragment: jsxRuntime.Fragment, jsx: jsxRuntime.jsx, jsxs: jsxRuntime.jsxs });
    const MDXContent = mod.default;
    const body = renderToStaticMarkup(React.createElement(MDXContent, { components: componentMap }));

    const relative = path.relative(srcDir, filePath).replace(/\\/g, "/");
    const stem = relative.replace(/\.mdx$/, "");
    const outFile = path.join(outDir, `${stem}.html`);
    fs.mkdirSync(path.dirname(outFile), { recursive: true });
    fs.writeFileSync(outFile, htmlDocument(stem, body), "utf8");

    pages.push({
      source: filePath,
      output: outFile,
      urlPath: `${publicBasePath.replace(/\/$/, "")}/${stem}.html`,
    });
  }

  const indexBody = [`<h1>Interactive Pages</h1>`, `<p class="muted">Generated from MDX files in ${srcDir}</p>`]
    .concat(pages.map((p) => `<div class="card"><a href="${p.urlPath}">${p.urlPath}</a><div class="muted">${p.source}</div></div>`))
    .join("\n");
  fs.writeFileSync(path.join(outDir, "index.html"), htmlDocument("Interactive Pages", indexBody), "utf8");

  return { built: pages.length, pages };
}

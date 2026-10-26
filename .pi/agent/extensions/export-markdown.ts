import { mkdir, writeFile } from "node:fs/promises";
import { dirname, isAbsolute, relative, resolve, sep } from "node:path";
import type { ExtensionAPI, ExtensionCommandContext } from "@earendil-works/pi-coding-agent";

function textParts(content: unknown): string {
  if (typeof content === "string") return content;
  if (!Array.isArray(content)) return "";

  return content
    .map((part) => {
      if (!part || typeof part !== "object") return "";
      const value = part as { type?: string; text?: string; mimeType?: string };
      if (value.type === "text") return value.text ?? "";
      if (value.type === "image") return `[Image: ${value.mimeType ?? "unknown type"}]`;
      return "";
    })
    .filter(Boolean)
    .join("\n");
}

function assistantText(message: unknown): string {
  if (!message || typeof message !== "object") return "";
  return textParts((message as { content?: unknown }).content).trim();
}

function generatedName(prefix: string): string {
  const stamp = new Date().toISOString().replace(/[:.]/g, "-").replace("T", "-").replace("Z", "");
  return `${prefix}-${stamp}.md`;
}

function outputPath(cwd: string, requestedName: string, prefix: string): string {
  let name = requestedName.trim() || generatedName(prefix);
  if (!name.toLowerCase().endsWith(".md")) name += ".md";
  if (isAbsolute(name)) throw new Error("Export paths must be relative to the current directory.");

  const target = resolve(cwd, name);
  const pathFromCwd = relative(cwd, target);
  if (pathFromCwd === ".." || pathFromCwd.startsWith(`..${sep}`) || isAbsolute(pathFromCwd)) {
    throw new Error("Export paths must stay inside the current directory.");
  }
  return target;
}

async function saveMarkdown(
  ctx: ExtensionCommandContext,
  requestedName: string,
  prefix: string,
  markdown: string,
): Promise<void> {
  const target = outputPath(ctx.cwd, requestedName, prefix);
  await mkdir(dirname(target), { recursive: true });
  await writeFile(target, markdown.trimEnd() + "\n", "utf8");
  ctx.ui.notify(`Markdown exported to ${target}`, "info");
}

function sessionMarkdown(ctx: ExtensionCommandContext): string {
  const header = ctx.sessionManager.getHeader();
  const sections = [
    "# Pi session",
    "",
    `- Exported: ${new Date().toISOString()}`,
    `- Working directory: \`${ctx.cwd}\``,
    header ? `- Session ID: \`${header.id}\`` : "",
  ];

  for (const entry of ctx.sessionManager.getBranch()) {
    if (entry.type !== "message") continue;
    const message = entry.message;

    if (message.role === "user") {
      sections.push("", "## User", "", textParts(message.content));
    } else if (message.role === "assistant") {
      const text = assistantText(message);
      if (text) sections.push("", "## Assistant", "", text);

      for (const part of message.content) {
        if (part.type === "toolCall") {
          sections.push("", `### Tool call: \`${part.name}\``, "", "```json", JSON.stringify(part.arguments, null, 2), "```");
        }
      }
    } else if (message.role === "toolResult") {
      const text = textParts(message.content);
      if (text) sections.push("", `### Tool result: \`${message.toolName}\``, "", text);
    }
  }

  return sections.join("\n");
}

export default function (pi: ExtensionAPI): void {
  pi.registerCommand("export-markdown", {
    description: "Export the current session branch to Markdown: /export-markdown [file]",
    handler: async (args, ctx) => {
      await saveMarkdown(ctx, args, "pi-session", sessionMarkdown(ctx));
    },
  });
}

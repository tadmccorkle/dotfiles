import { mkdir, writeFile } from "node:fs/promises";
import { dirname, isAbsolute, relative, resolve, sep } from "node:path";
import type { ExtensionAPI, ExtensionCommandContext } from "@earendil-works/pi-coding-agent";
import { DynamicBorder } from "@earendil-works/pi-coding-agent";
import { Container, Key, matchesKey, type SelectItem, SelectList, Text } from "@earendil-works/pi-tui";

type AssistantResponse = {
  id: string;
  timestamp: string;
  prompt: string;
  text: string;
};

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

function responses(ctx: ExtensionCommandContext): AssistantResponse[] {
  let latestPrompt = "(No preceding user message)";
  const result: AssistantResponse[] = [];

  for (const entry of ctx.sessionManager.getBranch()) {
    if (entry.type !== "message") continue;
    if (entry.message.role === "user") {
      const text = textParts(entry.message.content).trim();
      if (text) latestPrompt = text;
      continue;
    }
    if (entry.message.role !== "assistant") continue;

    const text = assistantText(entry.message);
    if (text) result.push({ id: entry.id, timestamp: entry.timestamp, prompt: latestPrompt, text });
  }

  return result;
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

function responseMarkdown(response: AssistantResponse): string {
  return `# Pi response\n\n_Exported ${new Date().toISOString()}_\n\n${response.text}`;
}

async function selectResponse(ctx: ExtensionCommandContext, available: AssistantResponse[]): Promise<AssistantResponse | undefined> {
  let showResponse = false;
  let selectedId = available.at(-1)?.id;

  const result = await ctx.ui.custom<string | undefined>((tui, theme, _keybindings, done) => {
    const container = new Container();
    let selectList: SelectList;

    const build = () => {
      const items: SelectItem[] = available.map((response, index) => ({
        value: response.id,
        label: `${index + 1}. ${response.timestamp}`,
        description: (showResponse ? response.text : response.prompt).replace(/\s+/g, " ").slice(0, 100),
      }));
      selectList = new SelectList(items, Math.min(items.length, 10), {
        selectedPrefix: (text) => theme.fg("accent", text),
        selectedText: (text) => theme.fg("accent", text),
        description: (text) => theme.fg("muted", text),
        scrollInfo: (text) => theme.fg("dim", text),
        noMatch: (text) => theme.fg("warning", text),
      });
      selectList.setSelectedIndex(Math.max(0, items.findIndex((item) => item.value === selectedId)));
      selectList.onSelect = (item) => done(item.value);
      selectList.onCancel = () => done(undefined);

      container.clear();
      container.addChild(new DynamicBorder((text) => theme.fg("accent", text)));
      container.addChild(new Text(theme.fg("accent", theme.bold(`Save assistant response — showing ${showResponse ? "responses" : "prompts"}`))));
      container.addChild(selectList);
      container.addChild(new Text(theme.fg("dim", "Tab to toggle prompt/response • Enter to select • Esc to cancel")));
      container.addChild(new DynamicBorder((text) => theme.fg("accent", text)));
    };

    build();
    return {
      render: (width) => container.render(width),
      invalidate: () => container.invalidate(),
      handleInput: (data) => {
        if (matchesKey(data, Key.tab)) {
          selectedId = selectList.getSelectedItem()?.value ?? selectedId;
          showResponse = !showResponse;
          build();
        } else {
          selectList.handleInput(data);
          selectedId = selectList.getSelectedItem()?.value ?? selectedId;
        }
        tui.requestRender();
      },
    };
  });

  return available.find((response) => response.id === result);
}

export default function (pi: ExtensionAPI): void {
  pi.registerCommand("save-markdown", {
    description: "Select an assistant response and save it as Markdown: /save-markdown [file]",
    handler: async (args, ctx) => {
      if (ctx.mode !== "tui") {
        ctx.ui.notify("Selecting a response requires Pi's interactive terminal UI.", "warning");
        return;
      }

      const available = responses(ctx);
      if (available.length === 0) {
        ctx.ui.notify("No assistant responses are available to save.", "warning");
        return;
      }

      const response = await selectResponse(ctx, available);
      if (!response) return;

      const requestedName = args.trim() || (await ctx.ui.input("Markdown filename", "Leave blank for a generated filename")) || "";
      await saveMarkdown(ctx, requestedName, "pi-response", responseMarkdown(response));
    },
  });
}

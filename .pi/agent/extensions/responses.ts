import type { ExtensionAPI, ExtensionCommandContext } from "@earendil-works/pi-coding-agent";
import { copyToClipboard, DynamicBorder } from "@earendil-works/pi-coding-agent";
import { Container, Key, matchesKey, type SelectItem, SelectList, Text } from "@earendil-works/pi-tui";

type Response = {
  id: string;
  timestamp: string;
  prompt: string;
  text: string;
};

function textParts(content: unknown): string {
  if (typeof content === "string") return content;
  if (!Array.isArray(content)) return "";

  return content
    .flatMap((part) => {
      if (!part || typeof part !== "object") return [];
      const value = part as { type?: string; text?: string };
      return value.type === "text" && value.text ? [value.text] : [];
    })
    .join("\n")
    .trim();
}

function responses(ctx: ExtensionCommandContext): Response[] {
  let latestPrompt = "(No preceding user message)";
  const result: Response[] = [];

  for (const entry of ctx.sessionManager.getBranch()) {
    if (entry.type !== "message") continue;
    if (entry.message.role === "user") {
      const text = textParts(entry.message.content);
      if (text) latestPrompt = text;
      continue;
    }
    if (entry.message.role !== "assistant") continue;

    const text = textParts(entry.message.content);
    if (text) result.push({ id: entry.id, timestamp: entry.timestamp, prompt: latestPrompt, text });
  }

  return result;
}

async function selectResponse(ctx: ExtensionCommandContext, responses: Response[]): Promise<Response | undefined> {
  let showResponse = false;
  let selectedId = responses.at(-1)?.id;

  const result = await ctx.ui.custom<string | undefined>((tui, theme, _keybindings, done) => {
    const container = new Container();
    let selectList: SelectList;

    const build = () => {
      const items: SelectItem[] = responses.map((response, index) => ({
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
      container.addChild(new Text(theme.fg("accent", theme.bold(`Copy a response — showing ${showResponse ? "responses" : "prompts"}`))));
      container.addChild(selectList);
      container.addChild(new Text(theme.fg("dim", "Tab to toggle prompt/response • Enter to copy • Esc to cancel")));
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

  return responses.find((response) => response.id === result);
}

export default function (pi: ExtensionAPI): void {
  pi.registerCommand("responses", {
    description: "Select a response and copy it to the clipboard; Tab toggles prompt/response previews",
    handler: async (_args, ctx) => {
      if (ctx.mode !== "tui") {
        ctx.ui.notify("Selecting a response requires Pi's interactive terminal UI.", "warning");
        return;
      }

      const available = responses(ctx);
      if (available.length === 0) {
        ctx.ui.notify("No text responses are available to copy.", "warning");
        return;
      }

      const response = await selectResponse(ctx, available);
      if (!response) return;

      try {
        await copyToClipboard(response.text);
        ctx.ui.notify(`Copied response ${available.indexOf(response) + 1} to the clipboard.`, "info");
      } catch (error) {
        ctx.ui.notify(error instanceof Error ? error.message : String(error), "error");
      }
    },
  });
}
